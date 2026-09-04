<#
.SYNOPSIS
    UltraGoal Rigorous Autonomous Test Harness v4.0 (The 5-Phase Deep Quality Engine)
.DESCRIPTION
    Batería de pruebas automatizadas sumamente rigurosa que audita cualquier proyecto
    a través de 5 fases críticas e inquebrantables antes de permitir su entrega:
    1. Fase 1: Análisis Estático Pre-Vuelo & AST (0 syntax errors, 0 TODOs, 0 stubs, type='module')
    2. Fase 2: Verificación de Arranque en Vivo (Chrome Headless, 0 errores de carga)
    3. Fase 3: Escrutinio Visual & Texturas (Anti-Pantallazo Negro, StdDev > 5.0, NearestFilter)
    4. Fase 4: Estabilidad Cinética & Cámara (Pitch Clamping, dir.y = 0, DeltaTime)
    5. Fase 5: Batería de Pruebas Unitarias / Integración (Aserciones reales, exit code 0)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDirectory,

    [Parameter(Mandatory = $false)]
    [string]$TestCommand = "",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "RIGOROUS_TEST_REPORT.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetDirectory)) {
    Write-Error "Target directory '$TargetDirectory' does not exist."
    exit 1
}

$phaseResults = [ordered]@{}
$fatalDefects = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

# =========================================================================
# FASE 1: Análisis Estático Pre-Vuelo & AST
# =========================================================================
Write-Host ">>> [Fase 1/5] Ejecutando Análisis Estático Pre-Vuelo & AST..." -ForegroundColor Cyan

$allFiles = Get-ChildItem -Path $TargetDirectory -Recurse -File | Where-Object {
    $_.FullName -notmatch '(?i)(\.git|node_modules|bin|obj|dist|build|\.system_generated)'
}

$codeFiles = $allFiles | Where-Object { $_.Extension -match '(?i)\.(js|ts|py|cs|html|css|ps1)$' }
$htmlFiles = $allFiles | Where-Object { $_.Extension -eq ".html" }

$syntaxErrorFound = $false
$todoCount = 0
$stubCount = 0

foreach ($f in $codeFiles) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    if ($content -match '(?i)\b(TODO|FIXME|HACK|XXX|TBD)\b') {
        $todoCount++
        $fatalDefects.Add("Fase 1: Se detectaron marcadores TODO/FIXME en '$($f.Name)'. Se exige código 100% implementado.")
    }
    if ($content -match '(?i)(NotImplementedError|NotImplementedException|throw new Error\("Not implemented"\)|\bSTUB\b)') {
        $stubCount++
        $fatalDefects.Add("Fase 1: Se detectaron stubs sin implementar en '$($f.Name)'.")
    }
    if ($content -match '(?i)(catch\s*\([^)]*\)\s*\{\s*\}|except:\s*pass)') {
        $fatalDefects.Add("Fase 1: Bloque de excepción vacío en '$($f.Name)'. Cero silenciamiento de errores.")
    }
}

# Verificación de imports sin type='module' en HTML
foreach ($h in $htmlFiles) {
    $hContent = Get-Content -LiteralPath $h.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -ne $hContent) {
        if ($hContent -match '<script\b(?![^>]*\btype\s*=\s*["'']module["''])[^>]*>[^<]*\bimport\s+[\s\S]*?from\b') {
            $fatalDefects.Add("Fase 1: Declaración 'import' dentro de <script> tradicional sin type='module' en '$($h.Name)'. Impide el arranque.")
            $syntaxErrorFound = $true
        }
    }
}

$phaseResults["Phase_1_Static_PreFlight"] = [PSCustomObject]@{
    status         = if ($fatalDefects.Count -eq 0) { "PASSED" } else { "FAILED" }
    files_analyzed = $codeFiles.Count
    todo_count     = $todoCount
    stub_count     = $stubCount
    syntax_error   = $syntaxErrorFound
}

# =========================================================================
# FASE 2: Verificación de Arranque en Vivo (Live Boot)
# =========================================================================
Write-Host ">>> [Fase 2/5] Ejecutando Verificación de Arranque en Vivo en Chrome Headless..." -ForegroundColor Cyan

$indexHtmlPath = Join-Path $TargetDirectory "index.html"
$liveBootPassed = $false
$liveBootDiagnostics = @()
$liveBootScreenshot = ""

if (Test-Path $indexHtmlPath) {
    $scriptsDir = $PSScriptRoot
    $bootScript = Join-Path $scriptsDir "verify_runtime_boot.ps1"
    if (Test-Path $bootScript) {
        $bootOutJson = & $bootScript -TargetDirectory $TargetDirectory 2>&1
        try {
            $bootObj = $bootOutJson | ConvertFrom-Json
            $liveBootPassed = ($bootObj.verdict -eq "BOOT_SUCCESS")
            $liveBootDiagnostics = $bootObj.diagnostics
            $liveBootScreenshot = $bootObj.screenshot_path
            if (-not $liveBootPassed) {
                foreach ($d in $bootObj.diagnostics) {
                    $fatalDefects.Add("Fase 2 (Arranque en Vivo): $d")
                }
            }
        } catch {
            $fatalDefects.Add("Fase 2: Excepción al ejecutar verify_runtime_boot.ps1: $_")
        }
    }
} else {
    $liveBootPassed = $true # No es app web con index.html
}

$phaseResults["Phase_2_Live_Boot"] = [PSCustomObject]@{
    status            = if ($liveBootPassed) { "PASSED" } else { "FAILED" }
    tested_entry      = if (Test-Path $indexHtmlPath) { "index.html" } else { "N/A" }
    screenshot_saved  = (-not [string]::IsNullOrWhiteSpace($liveBootScreenshot) -and (Test-Path $liveBootScreenshot))
    diagnostics       = $liveBootDiagnostics
}

# =========================================================================
# FASE 3: Escrutinio Visual & Texturas (Anti-Pantallazo Negro & NearestFilter)
# =========================================================================
Write-Host ">>> [Fase 3/5] Ejecutando Escrutinio Visual, Luminancia & Texturas..." -ForegroundColor Cyan

$visualPassed = $true
$allCodeText = ($codeFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue }) -join "`n"

# A. Análisis de luminancia si hay captura de pantalla
$isDeadScreen = $false
$luminanceStdDev = 0
if (-not [string]::IsNullOrWhiteSpace($liveBootScreenshot) -and (Test-Path $liveBootScreenshot)) {
    Add-Type -AssemblyName System.Drawing
    $bmp = [System.Drawing.Bitmap]::FromFile($liveBootScreenshot)
    $w = $bmp.Width
    $h = $bmp.Height
    $samples = [System.Collections.Generic.List[double]]::new()
    $blackCount = 0

    $stepX = [Math]::Max(1, [int]($w / 32))
    $stepY = [Math]::Max(1, [int]($h / 32))
    for ($x = 0; $x -lt $w; $x += $stepX) {
        for ($y = 0; $y -lt $h; $y += $stepY) {
            $p = $bmp.GetPixel($x, $y)
            $lum = 0.299 * $p.R + 0.587 * $p.G + 0.114 * $p.B
            $samples.Add($lum)
            if ($lum -lt 5) { $blackCount++ }
        }
    }
    $bmp.Dispose()

    $sum = 0
    foreach ($s in $samples) { $sum += $s }
    $mean = $sum / $samples.Count
    $varSum = 0
    foreach ($s in $samples) { $varSum += [Math]::Pow($s - $mean, 2) }
    $luminanceStdDev = [Math]::Round([Math]::Sqrt($varSum / $samples.Count), 2)
    $blackPct = [Math]::Round(($blackCount / $samples.Count) * 100, 1)

    if ($luminanceStdDev -lt 3.0 -or $blackPct -gt 98.0) {
        $isDeadScreen = $true
        $visualPassed = $false
        $fatalDefects.Add("Fase 3 (Visual): Pantallazo Negro o lienzo vacío detectado (StdDev: $luminanceStdDev, Black: $blackPct%).")
    }
}

# B. Verificación de NearestFilter en texturas vóxel
$isVoxelGame = ($allCodeText -match '(?i)(voxel|block|minecraft|canvasTexture|textureLoader)')
$hasNearestFilter = ($allCodeText -match '(?i)(NearestFilter|image-rendering\s*:\s*pixelated|magFilter\s*=\s*THREE\.NearestFilter)')

if ($isVoxelGame -and -not $hasNearestFilter) {
    $visualPassed = $false
    $fatalDefects.Add("Fase 3 (Texturas): Texturas borrosas o sin nitidez de vóxel. Falta configurar magFilter y minFilter = THREE.NearestFilter.")
}

# C. Verificación de Auditoría Visual Realizada por la IA (MANDATO ANTI-CIEGAS)
    $isVisualApp = (Test-Path $indexHtmlPath) -or ($allCodeText -match '(?i)(THREE\.|canvas|screen|<html|<body|render\(|draw\(|document\.createElement)')
    $visualReportPath = Join-Path $TargetDirectory "VISUAL_INSPECTION_REPORT.md"
    $hasVisualInspection = $false
    $reportObservationsCount = 0

    if (Test-Path $visualReportPath) {
        $repContent = Get-Content -LiteralPath $visualReportPath -Raw -ErrorAction SilentlyContinue
        if ($null -ne $repContent) {
            $bulletMatches = [regex]::Matches($repContent, '(?m)^\s*[-*•]\s+.+')
            $reportObservationsCount = $bulletMatches.Count
            if ($reportObservationsCount -ge 3 -or $repContent.Length -gt 150) {
                $hasVisualInspection = $true
            }
        }
    }

    if ($isVisualApp -and -not $hasVisualInspection) {
        $visualPassed = $false
        $targetImgToView = if (-not [string]::IsNullOrWhiteSpace($liveBootScreenshot) -and (Test-Path $liveBootScreenshot)) {
            $liveBootScreenshot
        } else {
            Join-Path $TargetDirectory "boot_rendered_screenshot.png"
        }
        $fatalDefects.Add("Fase 3 (Auditoría Visual Incompleta): La IA no ha realizado el análisis visual multimodal. DEBES invocar la herramienta view_file sobre '$targetImgToView' (o las fotos de capture_vision.ps1) para mirar el renderizado con tus propios ojos y crear '$visualReportPath' documentando al menos 3 observaciones críticas: 1) Geometría y modelos 3D, 2) Iluminación y materiales PBR, 3) Nitidez de texturas, 4) Interfaz/HUD, 5) Defectos visuales observados.")
    }

    $phaseResults["Phase_3_Visual_Textures"] = [PSCustomObject]@{
        status                 = if ($visualPassed) { "PASSED" } else { "FAILED" }
        luminance_std_dev      = $luminanceStdDev
        dead_screen_detected   = $isDeadScreen
        nearest_filter_ok      = if ($isVoxelGame) { $hasNearestFilter } else { "N/A" }
        visual_inspection_done = if ($isVisualApp) { $hasVisualInspection } else { "N/A" }
    }

# =========================================================================
# FASE 4: Estabilidad Cinética, Cámara & Movimiento
# =========================================================================
Write-Host ">>> [Fase 4/5] Evaluando Estabilidad Cinética, Cámara & Movimiento..." -ForegroundColor Cyan

$kineticPassed = $true
$isInteractive3D = ($allCodeText -match '(?i)(THREE\.|camera\.|controls\.|PointerLock|mousemove|keydown)')

if ($isInteractive3D) {
    # 1. Pitch clamp & dir.y=0 en controles de primera persona / ratón
    $isFirstPersonOrMouseLook = ($allCodeText -match '(?i)(PointerLock|mousemove|controls\.isLocked|onMouseMove|mouseLook)')
    if ($isFirstPersonOrMouseLook) {
        $hasPitchClamp = ($allCodeText -match '(?i)(Math\.(max|min)\s*\([^)]*(-1\.5|-Math\.PI|clamp|maxPolarAngle|minPolarAngle)|\.clamp|\bpolarAngle\b)')
        if (-not $hasPitchClamp) {
            $kineticPassed = $false
            $fatalDefects.Add("Fase 4 (Cámara): Falta Pitch Clamping (-1.5 a 1.5 rad). La cámara gira sin límite y se invierte boca abajo.")
        }

        $hasYFlattening = ($allCodeText -match '(?i)(direction\.y\s*=\s*0|dir\.y\s*=\s*0|moveForward|moveRight|\.setFromAxisAngle)')
        if (-not $hasYFlattening) {
            $kineticPassed = $false
            $fatalDefects.Add("Fase 4 (Movimiento): La dirección de avance no neutraliza el eje Y (dir.y = 0). El personaje vuela al mirar arriba o se hunde al mirar abajo.")
        }
    }

    # 3. DeltaTime
    $hasDeltaTime = ($allCodeText -match '(?i)(getDelta\(\)|delta\s*\*|dt\s*\*|\*\s*delta|\*\s*dt|deltaTime)')
    if (-not $hasDeltaTime) {
        $kineticPassed = $false
        $fatalDefects.Add("Fase 4 (Física): Desplazamiento sin DeltaTime. Velocidad errática dependiente de la tasa de refresco.")
    }

    # 4. Verificación de Audio, Mallas Compuestas & Transición Suave en Simulaciones Espaciales/Vuelo
    $isSimOrFlightOrSpace = ($allCodeText -match '(?i)(rocket|cohete|space\b|luna\b|moon\b|flight\b|launch\b|alunizaje)')
    if ($isSimOrFlightOrSpace) {
        $hasAudio = ($allCodeText -match '(?i)(AudioContext|webkitAudioContext|createOscillator|createBufferSource|new\s+Audio\b|sound|audioEngine|playAudio|playCountdown|startRocketRoar|SpaceAudioEngine|ProceduralAudioEngine)')
        if (-not $hasAudio) {
            $kineticPassed = $false
            $fatalDefects.Add("Fase 4 (Sensorial): Simulación o animación de vuelo muda. Se exige integrar síntesis de audio procedural Web Audio API (AudioContext) para rugido de motores, cuenta atrás y efectos de vuelo.")
        }
        $hasCompositeModel = ($allCodeText -match '(?i)(new\s+THREE\.Group|createHighFidelity|GLTFLoader|\.add\(|MeshStandardMaterial|MeshPhysicalMaterial|emissive)')
        if (-not $hasCompositeModel) {
            $kineticPassed = $false
            $fatalDefects.Add("Fase 4 (Mallas 3D): Modelo 3D primitivo (trampa del cilindro plano). Se exige ensamblaje jerárquico compuesto con toberas, etapas desacoplables y materiales PBR.")
        }
        $hasSmoothCam = ($allCodeText -match '(?i)(\.lerp\(|\.slerp\(|TWEEN|damping|smoothstep|CinematicFlightDirector|interpolate)')
        if (-not $hasSmoothCam) {
            $kineticPassed = $false
            $fatalDefects.Add("Fase 4 (Cámara): Falta interpolación suave (lerp/slerp) en transiciones de vuelo o cámara cinematográfica.")
        }
    }
}

$phaseResults["Phase_4_Kinetic_Stability"] = [PSCustomObject]@{
    status            = if ($kineticPassed) { "PASSED" } else { "FAILED" }
    pitch_clamp_ok    = if ($isInteractive3D) { $hasPitchClamp } else { "N/A" }
    dir_y_flatten_ok  = if ($isInteractive3D) { $hasYFlattening } else { "N/A" }
    delta_time_ok     = if ($isInteractive3D) { $hasDeltaTime } else { "N/A" }
    audio_sensory_ok  = if ($isSimOrFlightOrSpace) { $hasAudio } else { "N/A" }
    composite_mesh_ok = if ($isSimOrFlightOrSpace) { $hasCompositeModel } else { "N/A" }
}

# =========================================================================
# FASE 5: Batería de Pruebas Automatizadas (Unit / Integration)
# =========================================================================
Write-Host ">>> [Fase 5/5] Ejecutando Batería de Pruebas Automatizadas..." -ForegroundColor Cyan

$testFiles = $allFiles | Where-Object { $_.Name -match '(?i)(test|spec|_test|\.test\.|\.spec\.)' }
$testsPassed = $false
$testExecOutput = "N/A"

if ($testFiles.Count -gt 0) {
    if (-not [string]::IsNullOrWhiteSpace($TestCommand)) {
        try {
            $testExecOutput = Invoke-Expression $TestCommand 2>&1 | Out-String
            $testsPassed = ($LASTEXITCODE -eq 0)
            if (-not $testsPassed) {
                $fatalDefects.Add("Fase 5 (Tests): La suite de pruebas falló con exit code $LASTEXITCODE.")
            }
        } catch {
            $fatalDefects.Add("Fase 5 (Tests): Excepción al ejecutar comando de pruebas: $_")
        }
    } else {
        # Si no hay comando de test, verificar presencia de aserciones en archivos de test
        $assertionMatches = [regex]::Matches($allCodeText, '(?i)(assert|expect\(|should|Assert\.|AssertTrue)')
        if ($assertionMatches.Count -ge 3) {
            $testsPassed = $true
        } else {
            $fatalDefects.Add("Fase 5 (Tests): Se encontraron archivos de prueba pero contienen menos de 3 aserciones formales.")
        }
    }
} else {
    $fatalDefects.Add("Fase 5 (Tests): No se encontraron archivos de pruebas automatizadas (*test*, *spec*).")
}

$phaseResults["Phase_5_Automated_Tests"] = [PSCustomObject]@{
    status       = if ($testsPassed) { "PASSED" } else { "FAILED" }
    test_files   = $testFiles.Count
    command_run  = if (-not [string]::IsNullOrWhiteSpace($TestCommand)) { $TestCommand } else { "Static Assertion Scan" }
}

# Consolidación del Dictamen
$overallVerdict = if ($fatalDefects.Count -eq 0) { "RIGOROUS_TEST_PASSED" } else { "RIGOROUS_TEST_FAILED" }
$summaryMsg = if ($overallVerdict -eq "RIGOROUS_TEST_PASSED") {
    "CERTIFICACION DE EXCELENCIA: Todas las 5 fases de pruebas rigurosas fueron aprobadas al 100%."
} else {
    "VETO INAPELABLE: Se detectaron $($fatalDefects.Count) defectos críticos en el arnés. El proyecto NO puede ser entregado hasta que el Constructor los resuelva."
}

$report = [PSCustomObject]@{
    verdict              = $overallVerdict
    summary              = $summaryMsg
    target_directory     = $TargetDirectory
    fatal_defects_count  = $fatalDefects.Count
    fatal_defects        = $fatalDefects
    phases               = $phaseResults
    timestamp            = (Get-Date -Format "o")
}

$jsonReport = $report | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($OutputPath, $jsonReport, [System.Text.Encoding]::UTF8)

Write-Host "`n=================================================" -ForegroundColor $(if ($overallVerdict -eq "RIGOROUS_TEST_PASSED") { "Green" } else { "Red" })
Write-Host "   DICTAMEN FINAL: $overallVerdict" -ForegroundColor $(if ($overallVerdict -eq "RIGOROUS_TEST_PASSED") { "Green" } else { "Red" })
Write-Host "   Defectos Críticos: $($fatalDefects.Count)" -ForegroundColor $(if ($fatalDefects.Count -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================" -ForegroundColor $(if ($overallVerdict -eq "RIGOROUS_TEST_PASSED") { "Green" } else { "Red" })

Write-Output $jsonReport