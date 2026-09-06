<#
.SYNOPSIS
    UltraGoal Exhaustive System-Wide Verification Suite v5.4.0
.DESCRIPTION
    Batería de pruebas automatizadas hiper-rigurosa que audita el 100% de los componentes
    de UltraGoal Engine:
    1. OmniThink System 2 Hyper-Cognition (5 Perspectivas, Red Team, Mandatos Sensoriales)
    2. Universal Deep Domain Planner (Detección de Dominio, Defensas Anti-Toy)
    3. Milestone Tracker Full Lifecycle (init -> status -> submit -> reject -> approve -> complete -> reset)
    4. Live Runtime Boot Verifier (Chrome Headless, Detección de Sintaxis y Lienzo Muerto)
    5. Rigorous 5-Phase Test Harness Core (Defectos Fatales, Reporte V-HEX7, Umbral >= 90)
    6. Escrutinio Empírico de Imágenes Sintéticas (Pantallazo Negro, Monocromo Plano, Unlit, Texturizado)
    7. Visual Capture Engine Multi-Mode (Full, GridOverlay, MultiSector, Burst, MultiStateAudit con InputImage)
    8. Differential Visual Analysis & Detección de Congelamiento (STATE_CHANGED vs FROZEN_OR_NO_CHANGE)
    9. Asset, Shaders & Sensory Resource Orchestrator (Catálogos, Mallas Compuestas, Audio Web, Director de Cámara)
    10. Space Flight Simulation Sensory & Composite Mesh Gates (Rechazo de Simulaciones Mudas / Cilindros Planos)
    11. Universal Quality & Anti-Toy Rubric Gatekeeper (Evaluación de 100 Puntos, Deducciones Estrictas)
    12. Procedural Web Audio Engine File Integrity (Web Audio API nativo, Cero Enlaces Rotos)
    13. Architectural Templates & Formal Contracts Integrity (5 Plantillas Estructurales)
    14. Universal Tech Stack Selector & Anti-HTML Monoculture (Juegos, CLI, API, Desktop)
    15. Multi-Runtime Boot Verifier (Python, .NET, Rust, Web Cross-Runtime)
    16. Advanced Computer Vision Metrics & DWM Native Engine (Laplaciano, Shannon, HUD WCAG)
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$templatesDir = Join-Path $baseDir "templates"
$resourcesDir = Join-Path $baseDir "resources"
$tempDir = Join-Path $env:TEMP "ultragoal_exhaustive_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL EXHAUSTIVE SYSTEM-WIDE VERIFICATION SUITE v5.4.0   " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Assert-Test {
    param([string]$TestName, [bool]$Condition, [string]$Detail = "")
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $global:passed++
    } else {
        Write-Host "  [FAIL] $TestName - $Detail" -ForegroundColor Red
        $global:failed++
    }
}

# --- TEST 1: OmniThink System 2 Hyper-Cognition ---
Write-Host "`n[Test 1] Evaluando OmniThink Hyper-Cognition (5 Perspectivas)..." -ForegroundColor Yellow
$specOmni = Join-Path $tempDir "omni_spec.json"
& "$scriptsDir\omnithink_analyzer.ps1" -GoalObjective "animacion de un lanzamiento de cohete a la luna" -OutputPath $specOmni | Out-Null
$omniObj = Get-Content $specOmni | ConvertFrom-Json
$propsCount = @($omniObj.perspectives.PSObject.Properties).Count
Assert-Test -TestName "OmniThink Analyzes 5 Perspectives" -Condition ([bool]($propsCount -ge 5))
Assert-Test -TestName "OmniThink Red Team Identifies Critical Failure Vectors" -Condition ($omniObj.perspectives.'2_RedTeam_Adversary'.critical_failure_vectors.Count -ge 5)
Assert-Test -TestName "OmniThink Visual/Kinetic Mandates Exist" -Condition ($omniObj.perspectives.'3_Visual_Kinetic'.sensory_requirements.Count -ge 5)
Assert-Test -TestName "OmniThink Sensory & Asset Orchestrator Rules Exist" -Condition ($omniObj.perspectives.'5_Sensory_Assets'.mandatory_asset_rules.Count -ge 4)

# --- TEST 2: Universal Deep Domain Planner ---
Write-Host "`n[Test 2] Evaluando Universal Deep Domain Planner..." -ForegroundColor Yellow
$specFileGame = Join-Path $tempDir "spec_game.json"
& "$scriptsDir\deep_planner.ps1" -GoalObjective "Haz un clon de voxel/minecraft 3D" -OutputPath $specFileGame | Out-Null
$specGame = Get-Content $specFileGame | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies Game Domain" -Condition ($specGame.detected_category -eq "Interactive_Simulation_or_Game")
Assert-Test -TestName "Planner Enforces Kinetic & NearestFilter Defenses" -Condition ($specGame.anti_toy_defenses.Count -ge 8)
Assert-Test -TestName "Planner Supplies Recommended Deep Milestones" -Condition ($specGame.recommended_milestones.Split(';').Count -ge 4)

# --- TEST 3: Milestone Tracker Full State Lifecycle ---
Write-Host "`n[Test 3] Evaluando Milestone Tracker Ciclo de Vida Completo..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state_lifecycle.json"
& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Full Lifecycle Test" -Milestones "M1;M2;M3" | Out-Null
Assert-Test -TestName "Tracker Init with 3 Milestones" -Condition (Test-Path $stateFile)

$stObj = & "$scriptsDir\milestone_tracker.ps1" -Action status -StateFilePath $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Status Returns Active State" -Condition ($stObj.status -eq "ACTIVE" -and $stObj.current_index -eq 1)

# Enviar hito 1 a auditoría
& "$scriptsDir\milestone_tracker.ps1" -Action submit -StateFilePath $stateFile -MilestoneIndex 1 -Notes "Builder draft ready" | Out-Null

# Rechazar hito 1 con score 80 (< 95)
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 1 -Score 80 -Verdict "REJECTED" -Notes "Faltan pruebas rigurosas" | Out-Null
$stRejected = & "$scriptsDir\milestone_tracker.ps1" -Action status -StateFilePath $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Rejects Milestone Below 95 Score" -Condition ($stRejected.milestones[0].status -eq "REJECTED")

# Intentar completar con hitos no aprobados (debe fallar)
$completeFailed = $false
try {
    & "$scriptsDir\milestone_tracker.ps1" -Action complete -StateFilePath $stateFile 2>&1 | Out-Null
} catch {
    $completeFailed = $true
}
if ($LASTEXITCODE -ne 0) { $completeFailed = $true }
Assert-Test -TestName "Tracker Blocks Complete When Milestones Not Approved" -Condition ($completeFailed)

# Aprobar hito 1 con score 98 (>= 95)
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 1 -Score 98 -Verdict "APPROVED" -Notes "Superó compuertas" | Out-Null
$stApp1 = & "$scriptsDir\milestone_tracker.ps1" -Action status -StateFilePath $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Approves Milestone 1 and Advances Index" -Condition ($stApp1.milestones[0].status -eq "APPROVED" -and $stApp1.current_index -eq 2)

# Aprobar hitos 2 y 3
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 2 -Score 97 -Verdict "APPROVED" -Notes "M2 Clean" | Out-Null
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 3 -Score 99 -Verdict "APPROVED" -Notes "M3 Clean" | Out-Null

# Completar meta exitosamente
& "$scriptsDir\milestone_tracker.ps1" -Action complete -StateFilePath $stateFile | Out-Null
$stCompleted = & "$scriptsDir\milestone_tracker.ps1" -Action status -StateFilePath $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Successfully Completes Goal" -Condition ($stCompleted.status -eq "COMPLETED" -and -not [string]::IsNullOrWhiteSpace($stCompleted.completed_at))

# Reiniciar (reset) estado
& "$scriptsDir\milestone_tracker.ps1" -Action reset -StateFilePath $stateFile | Out-Null
Assert-Test -TestName "Tracker Resets and Removes State File" -Condition (-not (Test-Path $stateFile))

# --- TEST 4: Live Runtime Boot Verifier & Dead Screen Gate ---
Write-Host "`n[Test 4] Evaluando Live Runtime Boot Verifier..." -ForegroundColor Yellow
$bootTestDir = Join-Path $tempDir "boot_test_case"
New-Item -ItemType Directory -Path $bootTestDir -Force | Out-Null

$brokenGameHtml = "<html><body style='margin:0;background:black;'><script>import * as THREE from 'three';</script></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $brokenGameHtml
$bootResBroken = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Catches Broken Syntax & Black Screen" -Condition ($bootResBroken.verdict -eq "BOOT_FAILED")

$workingGameHtml = "<html><body style='margin:0;background:#5c94fc;'><h1>Minecraft Live Engine</h1><div style='height:200px;background:#557a2b;'></div></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $workingGameHtml
$bootResWorking = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Approves Running Game" -Condition ($bootResWorking.verdict -eq "BOOT_SUCCESS")

# --- TEST 5: Rigorous 5-Phase Test Harness Core Verification ---
Write-Host "`n[Test 5] Evaluando Rigorous 5-Phase Test Harness Core..." -ForegroundColor Yellow
$harnessBrokenDir = Join-Path $tempDir "harness_broken"
New-Item -ItemType Directory -Path $harnessBrokenDir -Force | Out-Null
Set-Content (Join-Path $harnessBrokenDir "index.html") -Value $brokenGameHtml
Set-Content (Join-Path $harnessBrokenDir "game.js") -Value "// TODO: arreglar esto`nconst camera = new THREE.PerspectiveCamera();"

$harnessResBroken = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessBrokenDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Broken Code (Defects >= 5)" -Condition ($harnessResBroken.verdict -eq "RIGOROUS_TEST_FAILED" -and $harnessResBroken.fatal_defects_count -ge 5)

$harnessCleanDir = Join-Path $tempDir "harness_clean"
New-Item -ItemType Directory -Path $harnessCleanDir -Force | Out-Null
Set-Content (Join-Path $harnessCleanDir "index.html") -Value $workingGameHtml
$cleanCode = @"
import * as THREE from 'three';
export class PlayerController {
    constructor(cam) {
        this.camera = cam;
        this.pitch = 0;
        this.clock = new THREE.Clock();
    }
    onMouseMove(e) {
        this.pitch = Math.max(-1.5, Math.min(1.5, this.pitch - e.movementY * 0.002));
        this.camera.rotation.x = this.pitch;
    }
    update() {
        const dt = this.clock.getDelta();
        const dir = new THREE.Vector3();
        this.camera.getWorldDirection(dir);
        dir.y = 0;
        dir.normalize();
        this.camera.position.addScaledVector(dir, 5 * dt);
    }
    createTexture() {
        const tex = new THREE.Texture();
        tex.magFilter = THREE.NearestFilter;
        tex.minFilter = THREE.NearestFilter;
        return tex;
    }
}
export class ShellMenu { constructor() { this.routes = new Map(); } }
"@
Set-Content (Join-Path $harnessCleanDir "game.js") -Value $cleanCode
Set-Content (Join-Path $harnessCleanDir "game.test.js") -Value "test('engine', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

# Probar que el arnés rechaza si falta VISUAL_INSPECTION_REPORT.md
$harnessNoVision = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Visual Project Lacking VISUAL_INSPECTION_REPORT.md" -Condition ($harnessNoVision.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessNoVision.fatal_defects | Where-Object { $_ -match "Auditoría Visual Incompleta" }).Count -gt 0))

# Probar que el arnés rechaza reporte superficial sin cuadrantes ni vectores V-HEX7
Set-Content (Join-Path $harnessCleanDir "VISUAL_INSPECTION_REPORT.md") -Value @"
# Visual Report
- Todo se ve bien y no hay errores graficos.
- Funciona correctamente en pantalla.
"@
$harnessSuperficial = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Superficial Visual Report Lacking V-HEX7 Vectors & Quadrants" -Condition ($harnessSuperficial.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessSuperficial.fatal_defects | Where-Object { $_ -match "V-HEX7" }).Count -gt 0))

# Probar que el arnés rechaza reporte con puntuación insuficiente (< 90/100)
Set-Content (Join-Path $harnessCleanDir "VISUAL_INSPECTION_REPORT.md") -Value @"
# Reporte V-HEX7 con Calificacion Baja por Defectos Visuales
En el cuadrante [B2] se observa la geometria voxel con algunos bloques que presentan aristas irregulares y caras mal orientadas.
En el sector [B1] la iluminacion direccional genera sombras difusas que no alcanzan el contraste deseado para una experiencia inmersiva.
En el sector [B2] las texturas emplean nearest filter pero se detectan desalineaciones menores en los bordes de los bloques.
En el sector [C2] el contacto en el suelo Y=0 y las colisiones presentan ligeras discrepancias de altura.
En el sector [A1] el fondo skybox con horizonte carece de gradiente atmosferico detallado.
En el sector [C3] el hud de la interfaz y la tipografia muestran bajo contraste con el fondo.
Puntuacion de Fidelidad Visual: 75/100
"@
$harnessLowScore = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Visual Report with Score Below 90" -Condition ($harnessLowScore.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessLowScore.fatal_defects | Where-Object { $_ -match "insuficiente" }).Count -gt 0))

# Ahora agregar el reporte de inspección visual exhaustivo V-HEX7
Set-Content (Join-Path $harnessCleanDir "VISUAL_INSPECTION_REPORT.md") -Value @"
# Reporte de Inspeccion Visual Hiper-Estricto V-HEX7

## 1. Capturas Inspeccionadas con view_file
- Vista general con cuadricula taxonomica [A1]..[C3]
- Recortes 1:1 de sector_center y sector_ground

## 2. Auditoria Detallada por Vectores V-HEX7
- [GEOMETRIA Y MALLA]: En el cuadrante [B2] se observa la estructura de bloques voxel perfectamente alineada, sin colisiones deformadas ni primitivas rotas.
- [MATERIALES E ILUMINACION PBR]: En los sectores [B1] y [B2] la luz direccional proyecta sombras claras sobre el terreno, generando un gradiente especular nitido con rango dinamico de contraste superior.
- [NITIDEZ DE TEXTURAS]: En el sector [B2] las texturas presentan magFilter y minFilter configurados con THREE.NearestFilter, eliminando por completo el difuminado bilineal y garantizando nitidez pixelada.
- [CONTACTO CON SUELO Y COLISIONES]: En el sector [C2] los bloques y entidades hacen contacto exacto sobre el plano base en el eje Y=0, sin clipeo con el suelo ni flotacion anomala.
- [FONDO Y SKYBOX]: En el sector [A1] y [A3] el horizonte muestra un gradiente atmosferico limpio con cielo celeste azul continuo.
- [HUD Y LEGIBILIDAD]: En el cuadrante [C3] la barra de interfaz y el menu de inicio exhiben tipografia limpia con alto contraste sobre el fondo.
- [PARTICULAS Y DINAMISMO]: En el sector [C2] se aprecian efectos visuales reactivos sin pausas de renderizado.

## 3. Veredicto Final
- Vectores evaluados: 7 de 7 cumplidos con rigor.
- Puntuacion de Fidelidad Visual: 98/100
- Dictamen: APROBADO_ESTRICTO
"@

$harnessResClean = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Approves Clean Code with Visual Report (0 Defects)" -Condition ($harnessResClean.verdict -eq "RIGOROUS_TEST_PASSED" -and $harnessResClean.fatal_defects_count -eq 0)

# --- TEST 6: Escrutinio Empírico de Imágenes Sintéticas en el Arnés ---
Write-Host "`n[Test 6] Evaluando Escrutinio Empírico de Imágenes Sintéticas en el Arnés..." -ForegroundColor Yellow
Add-Type -AssemblyName System.Drawing
$synthImgDir = Join-Path $tempDir "synthetic_images"
New-Item -ItemType Directory -Path $synthImgDir -Force | Out-Null

# 1. Imagen Sintética: Pantalla Negra 100%
$bmpBlack = New-Object System.Drawing.Bitmap 400, 300
$gBlack = [System.Drawing.Graphics]::FromImage($bmpBlack)
$gBlack.Clear([System.Drawing.Color]::Black)
$pathBlack = Join-Path $synthImgDir "black_screen.png"
$bmpBlack.Save($pathBlack, [System.Drawing.Imaging.ImageFormat]::Png)
$gBlack.Dispose(); $bmpBlack.Dispose()

# Probar que el arnés detecta y rechaza la pantalla negra
$harnessBlack = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir -ScreenshotPath $pathBlack | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Synthetic Black Screen via Phase 3 Scrutiny" -Condition ($harnessBlack.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessBlack.fatal_defects | Where-Object { $_ -match "Pantallazo Negro" }).Count -gt 0))

# 2. Imagen Sintética: Monocromo Plano 100% (Azul sólido sin sombras ni texturas)
$bmpFlat = New-Object System.Drawing.Bitmap 400, 300
$gFlat = [System.Drawing.Graphics]::FromImage($bmpFlat)
$gFlat.Clear([System.Drawing.Color]::FromArgb(30, 80, 220))
$pathFlat = Join-Path $synthImgDir "flat_monochrome.png"
$bmpFlat.Save($pathFlat, [System.Drawing.Imaging.ImageFormat]::Png)
$gFlat.Dispose(); $bmpFlat.Dispose()

# Probar que el arnés detecta y rechaza el monocromo plano
$harnessFlat = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir -ScreenshotPath $pathFlat | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Synthetic Flat Monochrome via Phase 3 Scrutiny" -Condition ($harnessFlat.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessFlat.fatal_defects | Where-Object { $_ -match "Monocromatica Plana" }).Count -gt 0))

# 3. Imagen Sintética: Escena Unlit (Rango dinámico de luminancia < 12, con 4 cuadrantes para StdDev >= 3.0)
$bmpUnlit = New-Object System.Drawing.Bitmap 400, 300
$gUnlit = [System.Drawing.Graphics]::FromImage($bmpUnlit)
$gUnlit.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(80, 80, 80))), 0, 0, 200, 150)
$gUnlit.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(82, 82, 82))), 200, 0, 200, 150)
$gUnlit.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(88, 88, 88))), 0, 150, 200, 150)
$gUnlit.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 90, 90))), 200, 150, 200, 150)
$pathUnlit = Join-Path $synthImgDir "unlit_scene.png"
$bmpUnlit.Save($pathUnlit, [System.Drawing.Imaging.ImageFormat]::Png)
$gUnlit.Dispose(); $bmpUnlit.Dispose()

# Probar que el arnés detecta y rechaza la escena unlit
$harnessUnlit = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir -ScreenshotPath $pathUnlit | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Synthetic Unlit Scene via Phase 3 Scrutiny" -Condition ($harnessUnlit.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessUnlit.fatal_defects | Where-Object { $_ -match "Sin Iluminacion" }).Count -gt 0))

# 4. Imagen Sintética: Escena Rica y Texturizada con Gradientes y Bordes
$bmpRich = New-Object System.Drawing.Bitmap 400, 300
$gRich = [System.Drawing.Graphics]::FromImage($bmpRich)
$gRich.Clear([System.Drawing.Color]::DeepSkyBlue)
$gRich.FillRectangle([System.Drawing.Brushes]::ForestGreen, 0, 150, 400, 150)
$gRich.FillEllipse([System.Drawing.Brushes]::Gold, 20, 20, 60, 60)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)
for ($i = 0; $i -lt 400; $i += 40) {
    $gRich.DrawLine($pen, $i, 150, $i, 300)
}
$pen.Dispose()
$penCobble = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 90, 40), 1)
for ($cy = 160; $cy -lt 300; $cy += 15) {
    $gRich.DrawLine($penCobble, 0, $cy, 400, $cy)
}
$penCobble.Dispose()
$penCenter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 240, 240), 2)
$gRich.DrawArc($penCenter, 160, 90, 80, 40, 0, 180)
$gRich.DrawArc($penCenter, 180, 110, 60, 30, 0, 180)
$penCenter.Dispose()
$pathRich = Join-Path $synthImgDir "rich_scene.png"
$bmpRich.Save($pathRich, [System.Drawing.Imaging.ImageFormat]::Png)
$gRich.Dispose(); $bmpRich.Dispose()

# Probar que el arnés aprueba la imagen rica sin defectos visuales
$harnessRich = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir -ScreenshotPath $pathRich | ConvertFrom-Json
Assert-Test -TestName "Harness Approves Synthetic Rich Textured Scene (0 Defects)" -Condition ($harnessRich.verdict -eq "RIGOROUS_TEST_PASSED" -and $harnessRich.phases.Phase_3_Visual_Textures.status -eq "PASSED")

# --- TEST 7: Visual Capture Engine Multi-Mode & Quantitative Metrics ---
Write-Host "`n[Test 7] Evaluando Visual Capture Engine Multi-Mode (Full, GridOverlay, MultiSector, Burst, MultiStateAudit)..." -ForegroundColor Yellow
$visionTestDir = Join-Path $tempDir "vision_tests"
New-Item -ItemType Directory -Path $visionTestDir -Force | Out-Null

# A. Modo Full con InputImage
$capFull = Join-Path $visionTestDir "cap_full.png"
$outFull = & "$scriptsDir\capture_vision.ps1" -Mode "Full" -InputImage $pathRich -OutputPath $capFull | ConvertFrom-Json
Assert-Test -TestName "Capture Engine Full Mode Generates Screenshot" -Condition (Test-Path $capFull)
Assert-Test -TestName "Capture Engine Full Mode Detects Non-Dead Screen" -Condition ($outFull.dead_screen_detected -eq $false)

# B. Modo GridOverlay con InputImage
$capGrid = Join-Path $visionTestDir "cap_grid.png"
$outGrid = & "$scriptsDir\capture_vision.ps1" -Mode "GridOverlay" -InputImage $pathRich -OutputPath $capGrid | ConvertFrom-Json
Assert-Test -TestName "Capture Engine GridOverlay Inscribes Taxonomic Grid" -Condition ((Test-Path $capGrid) -and ($outGrid.grid_sectors.Count -eq 9))

# C. Modo MultiSector con InputImage
$outSectors = & "$scriptsDir\capture_vision.ps1" -Mode "MultiSector" -InputImage $pathRich | ConvertFrom-Json
Assert-Test -TestName "Capture Engine MultiSector Extracts 1:1 Center Sector" -Condition (Test-Path $outSectors.sectors.sector_center.path)
Assert-Test -TestName "Capture Engine MultiSector Extracts 1:1 Ground Sector" -Condition (Test-Path $outSectors.sectors.sector_ground.path)
Assert-Test -TestName "Capture Engine MultiSector Extracts 1:1 HUD Sector" -Condition (Test-Path $outSectors.sectors.sector_hud.path)

# D. Modo Burst
$outBurst = & "$scriptsDir\capture_vision.ps1" -Mode "Burst" -BurstCount 3 -BurstIntervalMs 50 | ConvertFrom-Json
Assert-Test -TestName "Capture Engine Burst Mode Captures 3 Sequential Frames" -Condition ($outBurst.frame_count -eq 3 -and $outBurst.frames.Count -eq 3)

# E. Modo MultiStateAudit con InputImage (Galería completa + métricas cuantitativas estrictas)
$capAudit = Join-Path $visionTestDir "cap_audit.png"
$outAudit = & "$scriptsDir\capture_vision.ps1" -Mode "MultiStateAudit" -InputImage $pathRich -OutputPath $capAudit | ConvertFrom-Json
Assert-Test -TestName "Capture Engine MultiStateAudit Produces Complete Gallery" -Condition ([bool](@($outAudit.photo_gallery.PSObject.Properties).Count -ge 4))
Assert-Test -TestName "Capture Engine MultiStateAudit Passes Strict Quantitative Metrics" -Condition ($outAudit.strict_vision_metrics.verdict -eq "STRICT_METRICS_PASSED")

# --- TEST 8: Differential Visual Analysis & Freezing Detection ---
Write-Host "`n[Test 8] Evaluando Differential Visual Analysis & Detección de Congelamiento..." -ForegroundColor Yellow
$diffDir = Join-Path $tempDir "diff_tests"
New-Item -ItemType Directory -Path $diffDir -Force | Out-Null

$imgA = Join-Path $diffDir "state_a.png"
$imgB = Join-Path $diffDir "state_b.png"
$diffOut = Join-Path $diffDir "diff_output.png"

$bA = New-Object System.Drawing.Bitmap 400, 300
$gA = [System.Drawing.Graphics]::FromImage($bA)
$gA.Clear([System.Drawing.Color]::Black)
$gA.FillRectangle([System.Drawing.Brushes]::Red, 30, 30, 60, 60)
$bA.Save($imgA, [System.Drawing.Imaging.ImageFormat]::Png)

$bB = New-Object System.Drawing.Bitmap 400, 300
$gB = [System.Drawing.Graphics]::FromImage($bB)
$gB.Clear([System.Drawing.Color]::Black)
$gB.FillRectangle([System.Drawing.Brushes]::Red, 180, 120, 60, 60)
$bB.Save($imgB, [System.Drawing.Imaging.ImageFormat]::Png)
$gA.Dispose(); $bA.Dispose(); $gB.Dispose(); $bB.Dispose()

# A. Cambio Dinámico Claro
$diffChange = & "$scriptsDir\compare_visuals.ps1" -ImageA $imgA -ImageB $imgB -OutputPath $diffOut | ConvertFrom-Json
Assert-Test -TestName "Visual Diff Detects Active State Change" -Condition ($diffChange.verdict -eq "STATE_CHANGED" -and $diffChange.delta_percent -gt 0.5)

# B. Detección de Pantalla Congelada (Imágenes Idénticas)
$diffFrozen = & "$scriptsDir\compare_visuals.ps1" -ImageA $imgA -ImageB $imgA | ConvertFrom-Json
Assert-Test -TestName "Visual Diff Detects Frozen Screen on Identical Frames" -Condition ($diffFrozen.verdict -eq "FROZEN_OR_NO_CHANGE" -and $diffFrozen.diff_pixels -eq 0)

# C. Detección de Micro-Cambio bajo Umbral
$diffSubThreshold = & "$scriptsDir\compare_visuals.ps1" -ImageA $imgA -ImageB $imgB -MinExpectedDelta 90.0 | ConvertFrom-Json
Assert-Test -TestName "Visual Diff Declares Frozen When Delta Below MinExpectedDelta" -Condition ($diffSubThreshold.verdict -eq "FROZEN_OR_NO_CHANGE")

# --- TEST 9: Asset, Shaders & Sensory Resource Orchestrator ---
Write-Host "`n[Test 9] Evaluando Asset & Sensory Resource Orchestrator..." -ForegroundColor Yellow
$orchestratorOut = & "$scriptsDir\asset_orchestrator.ps1" -Domain "Space_Rocket" | ConvertFrom-Json
Assert-Test -TestName "Orchestrator Supplies Space Texture Catalog" -Condition ($orchestratorOut.catalog.Space_Solar_System.Earth_Day_Texture -match 'http')
Assert-Test -TestName "Orchestrator Exports Composite Rocket Mesh Code" -Condition ($orchestratorOut.procedural_mesh_js -match 'createHighFidelityMultiStageRocket')
Assert-Test -TestName "Orchestrator Exports Procedural Web Audio Engine" -Condition ($orchestratorOut.audio_synth_js -match 'SpaceAudioEngine')
Assert-Test -TestName "Orchestrator Exports Cinematic Flight Director" -Condition ($orchestratorOut.camera_director_js -match 'CinematicFlightDirector')

# Verificación de nuevo dominio Tactical_FPS (Counter-Strike / Shooters)
$orchestratorFps = & "$scriptsDir\asset_orchestrator.ps1" -Domain "Tactical_FPS" | ConvertFrom-Json
Assert-Test -TestName "Orchestrator Supplies Tactical PBR Texture Catalog" -Condition ($orchestratorFps.catalog.Tactical_PBR_Textures.Sandstone_Wall -match 'http')
Assert-Test -TestName "Orchestrator Exports Tactical Viewmodel & VRAM Texture Pipeline" -Condition ($orchestratorFps.procedural_mesh_js -match 'TextureManager' -and $orchestratorFps.procedural_mesh_js -match 'DrawCylinderEx')
Assert-Test -TestName "Orchestrator Exports Tactical Combat Audio Engine" -Condition ($orchestratorFps.audio_synth_js -match 'TacticalAudioEngine')

# --- TEST 10: Space Flight Simulation Sensory & Composite Mesh Gates ---
Write-Host "`n[Test 10] Evaluando Space Flight Sensory & Composite Mesh Gates en el Arnés..." -ForegroundColor Yellow
$rocketBrokenDir = Join-Path $tempDir "rocket_broken"
New-Item -ItemType Directory -Path $rocketBrokenDir -Force | Out-Null
$brokenRocketCode = @"
import * as THREE from 'three';
// Trampa: simulacion muda y cilindro plano solitario sin audio ni director de camaras
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera();
const rocket = new THREE.Mesh(new THREE.CylinderGeometry(1, 1, 10), new THREE.MeshBasicMaterial());
scene.add(rocket);
function animate() {
    requestAnimationFrame(animate);
    rocket.position.y += 1;
}
"@
Set-Content (Join-Path $rocketBrokenDir "main.js") -Value $brokenRocketCode
Set-Content (Join-Path $rocketBrokenDir "index.html") -Value "<html><body><canvas></canvas></body></html>"
Set-Content (Join-Path $rocketBrokenDir "rocket.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$harnessRocketBroken = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $rocketBrokenDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Silent & Flat-Cylinder Rocket Simulation" -Condition ($harnessRocketBroken.verdict -eq "RIGOROUS_TEST_FAILED" -and $harnessRocketBroken.fatal_defects_count -ge 1)

$rocketCleanDir = Join-Path $tempDir "rocket_clean"
New-Item -ItemType Directory -Path $rocketCleanDir -Force | Out-Null
$cleanRocketCode = @"
import * as THREE from 'three';
export class SpaceMission {
    constructor() {
        this.clock = new THREE.Clock();
        this.audio = new AudioContext();
        this.camera = new THREE.PerspectiveCamera();
        this.rocket = new THREE.Group();
        this.rocket.name = 'Saturn_V';
        const stage1 = new THREE.Mesh(new THREE.CylinderGeometry(2, 2, 10), new THREE.MeshStandardMaterial({ roughness: 0.3, metalness: 0.8 }));
        this.rocket.add(stage1);
        this.director = {
            update: (dt) => {
                this.camera.position.lerp(new THREE.Vector3(0, 10, 30), 0.05);
            }
        };
    }
    update() {
        const dt = this.clock.getDelta();
        this.director.update(dt);
    }
}
export class ShellMenu { constructor() { this.routes = new Map(); } }
"@
Set-Content (Join-Path $rocketCleanDir "main.js") -Value $cleanRocketCode
Set-Content (Join-Path $rocketCleanDir "index.html") -Value "<html><body style='margin:0;background:#050510;'><h1 style='color:white;'>Apollo Mission Simulation</h1><div style='height:300px;background:linear-gradient(to top, #ff6600, #000);'></div></body></html>"
Set-Content (Join-Path $rocketCleanDir "rocket.test.js") -Value "test('mission', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"
Set-Content (Join-Path $rocketCleanDir "VISUAL_INSPECTION_REPORT.md") -Value @"
# Reporte de Inspeccion Visual Hiper-Estricto V-HEX7 (Mision Lunar)

## 1. Capturas Inspeccionadas con view_file
- Vista general con cuadricula taxonomica [A1]..[C3]
- Recortes 1:1 de sector_center (cohete) y sector_ground (plataforma)

## 2. Auditoria Detallada por Vectores V-HEX7
- [GEOMETRIA Y JERARQUIA DE MALLA]: En el cuadrante [B2] se observa el cohete Saturn V modelado como una jerarquia compuesta con primera etapa cilíndrica de fuselaje, anillo interetapas y toberas detalladas.
- [MATERIALES, SHADERS E ILUMINACION PBR]: En los sectores [B1] y [B2] los materiales PBR reflejan la iluminacion direccional solar con roughness calibrado y fulgor emissive en los motores.
- [NITIDEZ DE TEXTURAS Y SHADERS]: En el sector [B2] las lineas y marcas de fuselaje presentan nitidez sin distorsion de texturas.
- [INTEGRACION Y APOYO]: En el sector [C2] la tobera de escape reposa con precision sobre la base de lanzamiento en Y=0 con sombra arrojada visible.
- [COMPOSICION DE FONDO Y SKYBOX]: En [A1] y [A3] el fondo espacial negro integra gradientes cosmicos y campo estelar.
- [HUD Y TELEMETRIA]: En el cuadrante [C3] los indicadores de estado y velocidad son legibles con buen contraste.
- [PARTICULAS Y DINAMISMO VFX]: En el sector [C2] se proyecta fulgor continuo de empuje con dinamismo.

## 3. Veredicto Final
- Puntuacion de Fidelidad Visual: 96/100
- Dictamen: APROBADO_ESTRICTO
"@

$harnessRocketClean = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $rocketCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Approves High-Fidelity Rocket with Web Audio & Smooth Camera" -Condition ($harnessRocketClean.verdict -eq "RIGOROUS_TEST_PASSED" -and $harnessRocketClean.fatal_defects_count -eq 0)

# --- TEST 10B: Anti-Flat-Box 3D Geometry & Raylib DrawCylinder Trap Gates ---
Write-Host "`n[Test 10B] Evaluando Compuertas Anti-Cajas 3D Planas y Bug de Raylib DrawCylinder..." -ForegroundColor Yellow
$flat3DDir = Join-Path $tempDir "flat_3d_project"
New-Item -ItemType Directory -Path $flat3DDir -Force | Out-Null
Set-Content (Join-Path $flat3DDir "Program.cs") -Value @"
using Raylib_cs;
public class Program {
    public static void Main() {
        Raylib.InitWindow(800, 600, "Flat Game");
        Camera3D camera = new Camera3D();
        while (!Raylib.WindowShouldClose()) {
            Raylib.BeginDrawing();
            Raylib.BeginMode3D(camera);
            Raylib.DrawCube(new System.Numerics.Vector3(0, 0, 0), 2, 2, 2, Color.Beige);
            Raylib.EndMode3D();
            Raylib.EndDrawing();
        }
    }
}
"@
Set-Content (Join-Path $flat3DDir "Game.csproj") -Value "<Project Sdk='Microsoft.NET.Sdk'></Project>"
Set-Content (Join-Path $flat3DDir "GameTest.cs") -Value "public class Test { public void Run() { System.Diagnostics.Debug.Assert(true); System.Diagnostics.Debug.Assert(true); System.Diagnostics.Debug.Assert(true); } }"

$harnessFlat3D = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $flat3DDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Untextured 3D Game via Phase 1 PreFlight" -Condition ($harnessFlat3D.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessFlat3D.fatal_defects | Where-Object { $_ -match "Anti-Flat-Box 3D" }).Count -gt 0))

$raylibCylDir = Join-Path $tempDir "raylib_cyl_project"
New-Item -ItemType Directory -Path $raylibCylDir -Force | Out-Null
Set-Content (Join-Path $raylibCylDir "Viewmodel.cs") -Value @"
using Raylib_cs;
public class ViewmodelWeapon {
    public Texture2D gunTexture;
    public void Draw() {
        Raylib.DrawCylinder(new System.Numerics.Vector3(0, 0, 0), 0.1f, 0.1f, 1.0f, 16, Color.Black);
    }
}
"@
Set-Content (Join-Path $raylibCylDir "WeaponTest.cs") -Value "public class Test { public void Run() { System.Diagnostics.Debug.Assert(true); System.Diagnostics.Debug.Assert(true); System.Diagnostics.Debug.Assert(true); } }"

$harnessRaylibCyl = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $raylibCylDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Raylib Vertical DrawCylinder on Weapon Viewmodel" -Condition ($harnessRaylibCyl.verdict -eq "RIGOROUS_TEST_FAILED" -and (@($harnessRaylibCyl.fatal_defects | Where-Object { $_ -match "Raylib Cylinder Trap" }).Count -gt 0))

# --- TEST 11: Universal Quality & Anti-Toy Rubric Gatekeeper ---
Write-Host "`n[Test 11] Evaluando Universal Quality & Anti-Toy Rubric Gatekeeper..." -ForegroundColor Yellow
$rubricClean = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Clean Code (Score >= 95)" -Condition ($rubricClean.verdict -eq "APPROVED" -and $rubricClean.score -ge 95)

# Probar deducción por falta de reporte visual en rúbrica
$rubricNoVisionDir = Join-Path $tempDir "rubric_no_vision"
New-Item -ItemType Directory -Path $rubricNoVisionDir -Force | Out-Null
Copy-Item (Join-Path $harnessCleanDir "*") -Destination $rubricNoVisionDir -Recurse
Remove-Item (Join-Path $rubricNoVisionDir "VISUAL_INSPECTION_REPORT.md") -Force
$rubricNoVision = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $rubricNoVisionDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Deducts Points for Missing Visual Report (-12 Pts)" -Condition ($rubricNoVision.score -lt 95 -and (@($rubricNoVision.violations | Where-Object { $_.Issue -match "Auditoría Visual" }).Count -gt 0))

# --- TEST 12: Procedural Web Audio Engine File Integrity ---
Write-Host "`n[Test 12] Evaluando Procedural Web Audio Engine File Integrity..." -ForegroundColor Yellow
$audioEnginePath = Join-Path $resourcesDir "procedural_audio_engine.js"
Assert-Test -TestName "Procedural Audio Engine Resource Exists" -Condition (Test-Path $audioEnginePath)

$audioJs = Get-Content -LiteralPath $audioEnginePath -Raw -ErrorAction SilentlyContinue
Assert-Test -TestName "Audio Engine Defines ProceduralAudioEngine Class" -Condition ($audioJs -match 'class ProceduralAudioEngine')
Assert-Test -TestName "Audio Engine Implements Unlock for Autoplay Policy" -Condition ($audioJs -match 'unlock\(\)' -and $audioJs -match 'AudioContext')
Assert-Test -TestName "Audio Engine Implements Pink Noise Rocket Roar" -Condition ($audioJs -match 'startRocketRoar' -and $audioJs -match 'createBuffer')
Assert-Test -TestName "Audio Engine Has Zero External File Dependencies" -Condition (-not ($audioJs -match '["''`][^"''`]+\.(mp3|wav|ogg|flac)["''`]'))

# --- TEST 13: Architectural Templates & Formal Contracts Integrity ---
Write-Host "`n[Test 13] Evaluando Architectural Templates & Formal Contracts Integrity..." -ForegroundColor Yellow
$templateList = @(
    "SPECIFICATION_TEMPLATE.md",
    "CONTRACT_TEMPLATE.md",
    "AUDIT_REPORT_TEMPLATE.md",
    "VISION_AUDIT_TEMPLATE.md",
    "STRICT_VISUAL_INSPECTION_TEMPLATE.md"
)

foreach ($tpl in $templateList) {
    $tPath = Join-Path $templatesDir $tpl
    $exists = Test-Path $tPath
    Assert-Test -TestName "Template Exists: $tpl" -Condition ($exists)
    if ($exists) {
        $content = Get-Content -LiteralPath $tPath -Raw
        Assert-Test -TestName "Template Non-Empty & Has Structure: $tpl" -Condition ($content.Length -gt 200)
    }
}

$strictTpl = Get-Content (Join-Path $templatesDir "STRICT_VISUAL_INSPECTION_TEMPLATE.md") -Raw
Assert-Test -TestName "Strict Visual Template Enforces V-HEX7 & Taxonomic Grid" -Condition ($strictTpl -match 'V-HEX7' -and $strictTpl -match '\[B2\]')

# --- TEST 14: Universal Tech Stack Selector & Anti-HTML Monoculture ---
Write-Host "`n[Test 14] Evaluando Universal Tech Stack Selector & Anti-HTML Monoculture..." -ForegroundColor Yellow
$gameStackJson = & "$scriptsDir\tech_stack_selector.ps1" -GoalObjective "Haz un clon de voxel/minecraft 3D nativo"
$gameStack = $gameStackJson | ConvertFrom-Json
Assert-Test -TestName "Stack Selector Categorizes Game Domain" -Condition ($gameStack.detected_category -eq "Interactive_Simulation_or_Game")
Assert-Test -TestName "Stack Selector Recommends Native GPU Runtime for 3D Game" -Condition ($gameStack.selected_stack.native_gpu_access -eq $true)
Assert-Test -TestName "Stack Selector Forbids HTML Monoculture" -Condition (@($gameStack.prohibited_anti_patterns | Where-Object { $_ -match "monocultivo de HTML/Canvas" }).Count -gt 0)

$cliStackJson = & "$scriptsDir\tech_stack_selector.ps1" -GoalObjective "crear una herramienta cli para optimizar imagenes"
$cliStack = $cliStackJson | ConvertFrom-Json
Assert-Test -TestName "Stack Selector Categorizes CLI Systems Tool" -Condition ($cliStack.detected_category -eq "CLI_or_Systems_Tool")
Assert-Test -TestName "Stack Selector Recommends Compiled CLI (Rust/Go/PowerShell)" -Condition ($cliStack.selected_stack.language -match '(?i)(Rust|Go|PowerShell)')

$apiStackJson = & "$scriptsDir\tech_stack_selector.ps1" -GoalObjective "crear un microservicio rest con base de datos postgres"
$apiStack = $apiStackJson | ConvertFrom-Json
Assert-Test -TestName "Stack Selector Categorizes Backend API" -Condition ($apiStack.detected_category -eq "Backend_Service_or_API")
Assert-Test -TestName "Stack Selector Recommends FastAPI or .NET 9 for API" -Condition ($apiStack.selected_stack.framework -match '(?i)(FastAPI|Minimal APIs)')

# --- TEST 15: Multi-Runtime Boot Verifier (Python & Cross-Language) ---
Write-Host "`n[Test 15] Evaluando Multi-Runtime Boot Verifier..." -ForegroundColor Yellow
$pyTestDir = Join-Path $tempDir "python_test_runtime"
New-Item -ItemType Directory -Path $pyTestDir -Force | Out-Null

# A. Python con sintaxis correcta
Set-Content (Join-Path $pyTestDir "main.py") -Value "import sys`ndef run(): print('engine online')`nif __name__ == '__main__': run()"
$pyResClean = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $pyTestDir | ConvertFrom-Json
Assert-Test -TestName "Multi-Runtime Boot Detects & Approves Clean Python Project" -Condition ($pyResClean.verdict -eq "BOOT_SUCCESS" -and $pyResClean.runtime_type -eq "Python")

# B. Python con error fatal de sintaxis
Set-Content (Join-Path $pyTestDir "main.py") -Value "def broken_syntax(: print('error')"
$pyResBroken = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $pyTestDir | ConvertFrom-Json
Assert-Test -TestName "Multi-Runtime Boot Catches Python Syntax Error" -Condition ($pyResBroken.verdict -eq "BOOT_FAILED" -and (@($pyResBroken.diagnostics | Where-Object { $_ -match "SINTAXIS" }).Count -gt 0))

# --- TEST 16: Advanced Computer Vision Metrics (Laplacian, Shannon & HUD) ---
Write-Host "`n[Test 16] Evaluando Advanced Computer Vision Metrics & DWM Engine..." -ForegroundColor Yellow
$cvTestDir = Join-Path $tempDir "cv_metrics_tests"
New-Item -ItemType Directory -Path $cvTestDir -Force | Out-Null

# 1. Imagen con alta nitidez (bordes fuertes de alto contraste)
$bmpSharp = New-Object System.Drawing.Bitmap 400, 300
$gSharp = [System.Drawing.Graphics]::FromImage($bmpSharp)
$gSharp.Clear([System.Drawing.Color]::White)
$penB = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 3)
for ($x = 0; $x -lt 400; $x += 20) { $gSharp.DrawLine($penB, $x, 0, $x, 300) }
$penB.Dispose()
$pathSharp = Join-Path $cvTestDir "sharp_image.png"
$bmpSharp.Save($pathSharp, [System.Drawing.Imaging.ImageFormat]::Png)
$gSharp.Dispose(); $bmpSharp.Dispose()

$outSharp = & "$scriptsDir\capture_vision.ps1" -Mode "Full" -InputImage $pathSharp | ConvertFrom-Json
Assert-Test -TestName "Laplacian Variance Computes High Sharpness Score (> 100)" -Condition ($outSharp.luminance_stat.sharpness_score -gt 100.0)
Assert-Test -TestName "Laplacian Variance Declares Non-Blurred Image" -Condition ($outSharp.luminance_stat.is_excessively_blurred -eq $false)

# 2. Imagen con interfaz HUD de alto contraste WCAG (Texto negro sobre fondo blanco en sector HUD)
$bmpHudHigh = New-Object System.Drawing.Bitmap 400, 300
$gHud = [System.Drawing.Graphics]::FromImage($bmpHudHigh)
$gHud.Clear([System.Drawing.Color]::SteelBlue)
$gHud.FillRectangle([System.Drawing.Brushes]::White, 0, 220, 400, 80)
$fontH = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$gHud.DrawString("HEALTH: 100% | AMMO: 50", $fontH, [System.Drawing.Brushes]::Black, 20, 240)
$fontH.Dispose()
$pathHudHigh = Join-Path $cvTestDir "hud_high_contrast.png"
$bmpHudHigh.Save($pathHudHigh, [System.Drawing.Imaging.ImageFormat]::Png)
$gHud.Dispose(); $bmpHudHigh.Dispose()

$outHudHigh = & "$scriptsDir\capture_vision.ps1" -Mode "Full" -InputImage $pathHudHigh | ConvertFrom-Json
Assert-Test -TestName "HUD Contrast Metric Complies with WCAG AA (Ratio >= 3.0:1)" -Condition ($outHudHigh.luminance_stat.hud_contrast_ratio -ge 3.0 -and $outHudHigh.luminance_stat.is_hud_illegible -eq $false)

# 3. Imagen con HUD ilegible (Gris oscuro sobre gris oscuro)
$bmpHudLow = New-Object System.Drawing.Bitmap 400, 300
$gHudLow = [System.Drawing.Graphics]::FromImage($bmpHudLow)
$gHudLow.Clear([System.Drawing.Color]::SteelBlue)
$brushDarkGray = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 40, 40))
$gHudLow.FillRectangle($brushDarkGray, 0, 220, 400, 80)
$brushLowText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, 45, 45))
$fontLow = New-Object System.Drawing.Font("Arial", 14)
$gHudLow.DrawString("ILLEGIBLE HUD TEXT", $fontLow, $brushLowText, 20, 240)
$fontLow.Dispose(); $brushLowText.Dispose(); $brushDarkGray.Dispose()
$pathHudLow = Join-Path $cvTestDir "hud_low_contrast.png"
$bmpHudLow.Save($pathHudLow, [System.Drawing.Imaging.ImageFormat]::Png)
$gHudLow.Dispose(); $bmpHudLow.Dispose()

$outHudLow = & "$scriptsDir\capture_vision.ps1" -Mode "Full" -InputImage $pathHudLow | ConvertFrom-Json
Assert-Test -TestName "HUD Contrast Metric Detects Illegible UI (Ratio < 3.0:1)" -Condition ($outHudLow.luminance_stat.is_hud_illegible -eq $true)

# 4. Verificación de Métodos Win32 DWM en UltraVisionCaptureV4
$typeLoaded = ([System.Management.Automation.PSTypeName]'UltraVisionCaptureV4').Type
Assert-Test -TestName "UltraVisionCaptureV4 Type Successfully Exported with DWM P/Invoke" -Condition ($null -ne $typeLoaded)
$findMethod = $typeLoaded.GetMethod("FindWindowByTitle")
Assert-Test -TestName "FindWindowByTitle Static Method Exists" -Condition ($null -ne $findMethod)
$dwmMethod = $typeLoaded.GetMethod("GetAccurateWindowBounds")
Assert-Test -TestName "GetAccurateWindowBounds Static Method Exists" -Condition ($null -ne $dwmMethod)

# Limpieza segura
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "   RESULTADOS DE VERIFICACIÓN TOTAL: $passed PASADAS, $failed FALLIDAS" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }
