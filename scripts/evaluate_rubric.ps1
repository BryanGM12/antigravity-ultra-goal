<#
.SYNOPSIS
    UltraGoal Universal Quality & Anti-Toy Rubric Evaluator v3.1
.DESCRIPTION
    Motor de auditoría rigurosa y evaluación de calidad universal para proyectos en Antigravity.
    Agnóstico de tecnología: evalúa proyectos en JavaScript, TypeScript, Python, C#, Rust, Go,
    PowerShell, Java, C++, HTML/CSS, etc.
    Audita:
    - Profundidad de dominio (penaliza maquetas de juguete con datos planos hardcodeados).
    - Shell de usuario y navegación (evita interfaces de 1 sola pantalla sin ajustes ni salida).
    - Higiene de recursos y rendimiento (fugas de memoria, asignaciones en bucles intensivos).
    - Reactividad y sincronización de estado (interacciones que no actualizan el modelo).
    - Robustez y blindaje de errores (cero silenciamiento de excepciones o catch vacíos).
    - Batería de pruebas automatizadas con aserciones verificadas.
    Umbral inquebrantable de aprobación: 95/100 ("No se conforma con cualquier resultado").
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [Parameter(Mandatory = $false)]
    [string]$TestCommand = "",

    [Parameter(Mandatory = $false)]
    [string]$Category = "Auto",

    [Parameter(Mandatory = $false)]
    [switch]$LiveBootCheck,

    [Parameter(Mandatory = $false)]
    [string[]]$ExcludeDirs = @("node_modules", ".git", "bin", "obj", "venv", ".venv", "dist", "build", ".system_generated", "coverage")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetPath)) {
    Write-Error "Target path '$TargetPath' does not exist."
    exit 1
}

$validExtensions = @(".py", ".ts", ".js", ".cs", ".go", ".rs", ".ps1", ".java", ".cpp", ".c", ".h", ".html", ".css", ".jsx", ".tsx")

$targetItem = Get-Item $TargetPath
$files = @()

if ($targetItem.PSIsContainer) {
    $allFiles = Get-ChildItem -Path $TargetPath -Recurse -File
    foreach ($f in $allFiles) {
        $skip = $false
        foreach ($ex in $ExcludeDirs) {
            if ($f.FullName -like "*\$ex\*" -or $f.FullName -like "*/$ex/*") {
                $skip = $true
                break
            }
        }
        if (-not $skip -and ($validExtensions -contains $f.Extension.ToLower())) {
            $files += $f
        }
    }
} else {
    $files += $targetItem
}

$scores = [ordered]@{
    "Domain_Depth_Extensibility"   = 15
    "Presentation_Shell_UX"        = 15
    "Kinetic_Asset_Integrity"      = 15
    "Performance_Resource_Hygiene" = 15
    "Robustness_Error_Handling"    = 15
    "Functional_Completeness"      = 10
    "Automated_Testing"            = 15
}

$violations = [System.Collections.Generic.List[PSCustomObject]]::new()
$testFilesFound = 0
$assertionCount = 0
$totalCodeLines = 0
$allCodeTextBuilder = [System.Text.StringBuilder]::new()

# Expresiones regulares universales de detección
$todoRegex = [regex]'(?i)\b(TODO|FIXME|HACK|XXX|TBD|PLACEHOLDER)\b'
$stubRegex = [regex]'(?i)(NotImplementedError|NotImplementedException|throw new Error\("Not implemented"\)|pass\s*$|\bSTUB\b)'
$emptyCatchRegex = [regex]'(?i)(catch\s*\([^)]*\)\s*\{\s*\}|except:\s*pass|except\s+Exception:\s*pass)'
$debugDebrisRegex = [regex]'(?i)(console\.log\("debug|print\("test|System\.out\.println\("here|Debugger\.Break)'
$secretRegex = [regex]'(?i)(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|BEGIN PRIVATE KEY|api_key\s*=\s*["''][a-zA-Z0-9_-]{16,}["''])'

# Rendimiento universal: bucles intensivos (animación, rendering, tick, polling)
$allocInHotLoopRegex = [regex]'(?i)(function\s+(animate|render|update|tick|loop|draw|onAnimationFrame)\b|requestAnimationFrame)'

# Interacción y estado: eventos desconectados
$orphanActionRegex = [regex]'(?i)(draggedItem|selectedItem|activeElement|activeTab)\s*=[^;]+;(?!.*(clientX|clientY|position|target|id|emit|dispatch))'

foreach ($file in $files) {
    $lines = @(Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue)
    if ($null -eq $lines -or $lines.Count -eq 0) { continue }
    $totalCodeLines += $lines.Count
    $fullContent = $lines -join "`n"
    [void]$allCodeTextBuilder.AppendLine($fullContent)

    if ($file.Name -match '(?i)(test|spec|_test|\.test\.|\.spec\.)') {
        $testFilesFound++
    }

    $inHotFunc = $false
    $hotBraceCount = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNum = $i + 1
        $line = $lines[$i]

        # Rastrear funciones de alta frecuencia (animación, renderizado, polling)
        if ($line -match $allocInHotLoopRegex) {
            $inHotFunc = $true
            $hotBraceCount = 0
        }
        if ($inHotFunc) {
            if ($line -match '\{') { $hotBraceCount++ }
            if ($line -match '\}') {
                $hotBraceCount--
                if ($hotBraceCount -le 0) { $inHotFunc = $false }
            }

            # Asignaciones continuas de objetos/arrays/vectores en bucle caliente (causa GC spikes)
            if ($line -match 'new\s+(Object|Array|THREE\.|Vector|Matrix|[A-Z][a-zA-Z0-9]+)\b' -and -not ($line -match 'new\s+Promise')) {
                $violations.Add([PSCustomObject]@{
                    Category    = "Performance_Resource_Hygiene"
                    Penalty     = 6
                    File        = $file.FullName
                    Line        = $lineNum
                    Snippet     = $line.Trim()
                    Issue       = "Asignación de memoria dentro de bucle de alta frecuencia (Causa pausas de recolección de basura y degradación de rendimiento)."
                })
            }
        }

        # TODOs
        if ($line -match $todoRegex) {
            $violations.Add([PSCustomObject]@{
                Category    = "Functional_Completeness"
                Penalty     = 5
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Marcador de trabajo pendiente o incompleto (TODO/FIXME)"
            })
        }
        # Stubs
        if ($line -match $stubRegex) {
            $violations.Add([PSCustomObject]@{
                Category    = "Functional_Completeness"
                Penalty     = 6
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Stub o código sin implementar (NotImplemented / pass)"
            })
        }
        # Catch vacíos
        if ($line -match $emptyCatchRegex) {
            $violations.Add([PSCustomObject]@{
                Category    = "Robustness_Error_Handling"
                Penalty     = 6
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Bloque de excepción vacío o silenciamiento de errores"
            })
        }
        # Debug Debris
        if ($line -match $debugDebrisRegex) {
            $violations.Add([PSCustomObject]@{
                Category    = "Robustness_Error_Handling"
                Penalty     = 2
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Residuo de depuración temporal en código de producción"
            })
        }
        # Secretos
        if ($line -match $secretRegex) {
            $violations.Add([PSCustomObject]@{
                Category    = "Robustness_Error_Handling"
                Penalty     = 5
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = "******** (Secret Redacted)"
                Issue       = "Posible clave de API o secreto en texto plano"
            })
        }

        # Aserciones en tests
        $assertionMatches = [regex]::Matches($line, '(?i)(assert|expect\(|should|Assert\.|AssertTrue|AssertEqual)')
        $assertionCount += $assertionMatches.Count
    }
}

# --- EVALUACIÓN UNIVERSAL DE PROFUNDIDAD Y SHELL DE USUARIO ---
$totalCodeString = $allCodeTextBuilder.ToString()

# 1. Comprobación de Shell de Usuario / Punto de Entrada (Presentation & Shell)
$isUIOrWebOrGame = ($totalCodeString -match '(?i)(document\.|window\.|html|<div|<app|THREE\.|canvas|screen|view|render|component)')
if ($isUIOrWebOrGame) {
    $hasShellOrMenu = ($totalCodeString -match '(?i)(menu|start|title|header|navbar|nav|settings|options|pause|modal|viewRouter|router|route)')
    if (-not $hasShellOrMenu) {
        $violations.Add([PSCustomObject]@{
            Category    = "Presentation_Shell_UX"
            Penalty     = 8
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin estructura de navegación ni shell de usuario"
            Issue       = "Trampa de Demo de Juguete: No se encontró barra de navegación, menú de inicio ni vistas de configuración/opciones. La interfaz es un contenedor plano sin opciones reales."
        })
    }

    # Comprobación de Reporte de Inspección Visual por la IA (Hiper-Estrictez V-HEX7)
    $visualReportFile = Join-Path $TargetPath "VISUAL_INSPECTION_REPORT.md"
    $hasVisualReport = (Test-Path $visualReportFile)
    $repText = ""
    if ($hasVisualReport) {
        $repText = Get-Content -LiteralPath $visualReportFile -Raw -ErrorAction SilentlyContinue
    } elseif ($targetItem.PSIsContainer) {
        $walkthrough = Join-Path $TargetPath "walkthrough.md"
        if (Test-Path $walkthrough) {
            $wtContent = Get-Content -LiteralPath $walkthrough -Raw -ErrorAction SilentlyContinue
            if ($wtContent -match '(?i)(inspecci[oó]n visual|an[aá]lisis visual|V-HEX7)') {
                $hasVisualReport = $true
                $repText = $wtContent
            }
        }
    }

    if (-not $hasVisualReport) {
        $violations.Add([PSCustomObject]@{
            Category    = "Presentation_Shell_UX"
            Penalty     = 12
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin análisis visual multimodal"
            Issue       = "Fallo Fatal de Auditoría Visual: La IA no analizó visualmente el proyecto. Debe llamar a view_file sobre las capturas generadas y registrar su análisis visual en VISUAL_INSPECTION_REPORT.md bajo el protocolo V-HEX7."
        })
    } else {
        # Validar rigor del reporte existente
        $vCount = 0
        if ($repText -match '(?i)(geometr[ií]a|malla|mesh|primitiv|tobera|pieza|v[oó]xel)') { $vCount++ }
        if ($repText -match '(?i)(material|pbr|ilumina|luz|luces|sombra|shading|specular)') { $vCount++ }
        if ($repText -match '(?i)(textur|filtr|nearest|albedo|pixel)') { $vCount++ }
        if ($repText -match '(?i)(suelo|ground|y\s*=\s*0|contacto|apoyo|colisi[oó]n)') { $vCount++ }
        if ($repText -match '(?i)(fondo|skybox|cielo|estrell|atm[oó]sfer|espacio)') { $vCount++ }
        if ($repText -match '(?i)(hud|ui|interfaz|legibil|tipograf|fuente|contraste)') { $vCount++ }
        if ($repText -match '(?i)(part[ií]cul|vfx|humo|fuego|chispa|polvo|din[aá]mic)') { $vCount++ }

        $hasQuad = ($repText -match '(?i)(\[[A-C][1-3]\]|cuadrante|sector_center|sector_ground)')
        if ($vCount -lt 4 -or -not $hasQuad) {
            $violations.Add([PSCustomObject]@{
                Category    = "Presentation_Shell_UX"
                Penalty     = 8
                File        = $visualReportFile
                Line        = 0
                Snippet     = "Reporte visual superficial (V-HEX7 insuficiente)"
                Issue       = "Auditoría Visual Débil: El reporte no cumple el protocolo V-HEX7. Cubrió solo $vCount vectores o carece de referencias a cuadrantes taxonómicos ([A1]..[C3])."
            })
        }
    }
}

# 2. Comprobación de Profundidad de Dominio y Modelado (Domain Depth)
# Si el proyecto simula una aplicación compleja (tienda, juego, dashboard, gestor), debe poseer estructuras de datos o colecciones tipadas
$hasExtensibleModel = ($totalCodeString -match '(?i)(class\s+[A-Z]|interface\s+[A-Z]|type\s+[A-Z]|struct\s+[A-Z]|def\s+[a-z_]+|Map<|Dictionary<|new\s+Map|items\s*:\s*\[|recipes|models|entities|collection)')
if (-not $hasExtensibleModel -and $files.Count -gt 0) {
    $violations.Add([PSCustomObject]@{
        Category    = "Domain_Depth_Extensibility"
        Penalty     = 8
        File        = $TargetPath
        Line        = 0
        Snippet     = "Sin modelos de dominio estructurados"
        Issue       = "Trampa de Demo de Juguete: Código plano sin modelos de datos, entidades ni estructuras extensibles."
    })
}

# 3. Comprobación Estática de Errores Fatales en HTML (Imports fuera de módulo, scripts faltantes)
$htmlFiles = $files | Where-Object { $_.Extension.ToLower() -eq ".html" }
foreach ($h in $htmlFiles) {
    $hContent = Get-Content -LiteralPath $h.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -ne $hContent) {
        if ($hContent -match '<script\b(?![^>]*\btype\s*=\s*["'']module["''])[^>]*>[^<]*\bimport\s+[\s\S]*?from\b') {
            $violations.Add([PSCustomObject]@{
                Category    = "Robustness_Error_Handling"
                Penalty     = 10
                File        = $h.FullName
                Line        = 1
                Snippet     = "import ... inside traditional script"
                Issue       = "ERROR FATAL DE SINTAXIS: Declaración 'import' dentro de <script> tradicional sin type='module'. La app no arranca en navegadores (SyntaxError: Cannot use import statement outside a module)."
            })
        }
        $scriptSrcMatches = [regex]::Matches($hContent, '(?i)<script[^>]+src=["'']([^"'']+)["'']')
        foreach ($sm in $scriptSrcMatches) {
            $srcVal = $sm.Groups[1].Value
            if (-not ($srcVal -like "http*" -or $srcVal -like "//*" -or $srcVal -like "data:*")) {
                $resolvedLocal = Join-Path $h.DirectoryName $srcVal.Replace('/', '\')
                if (-not (Test-Path $resolvedLocal)) {
                    $violations.Add([PSCustomObject]@{
                        Category    = "Functional_Completeness"
                        Penalty     = 10
                        File        = $h.FullName
                        Line        = 1
                        Snippet     = "src='$srcVal'"
                        Issue       = "ARCHIVO LOCAL FALTANTE: El script local '$srcVal' referenciado en el HTML no existe en el disco."
                    })
                }
            }
        }
    }
}

# 4. Comprobación de Arranque en Vivo y Detección de Pantalla Negra (Live Boot Gate)
if ($LiveBootCheck -and ($targetItem.PSIsContainer)) {
    $indexHtmlPath = Join-Path $TargetPath "index.html"
    if (Test-Path $indexHtmlPath) {
        $bootScript = Join-Path $PSScriptRoot "verify_runtime_boot.ps1"
        if (Test-Path $bootScript) {
            try {
                $bootJson = & $bootScript -TargetDirectory $TargetPath 2>&1
                $bootObj = $bootJson | ConvertFrom-Json
                if ($bootObj.verdict -ne "BOOT_SUCCESS") {
                    foreach ($diag in $bootObj.diagnostics) {
                        $violations.Add([PSCustomObject]@{
                            Category    = "Functional_Completeness"
                            Penalty     = 15
                            File        = $indexHtmlPath
                            Line        = 0
                            Snippet     = "Live Boot Failure"
                            Issue       = "FALLO CRÍTICO DE ARRANQUE EN VIVO: $diag"
                        })
                    }
                }
            } catch {}
        }
    }
}

# 5. Comprobación de Cinética, Cámara y Texturas (Kinetic & Asset Integrity Gate)
$is3DOrGameOrCanvas = ($totalCodeString -match '(?i)(THREE\.|PointerLock|camera\.|controls\.|voxel|canvas|keydown|keyup)')

if ($is3DOrGameOrCanvas) {
    # A. Comprobación de Bloqueo de Cabeceo de Cámara en controles de primera persona / ratón
    $isFirstPersonOrMouseLook = ($totalCodeString -match '(?i)(PointerLock|mousemove|controls\.isLocked|onMouseMove|mouseLook)')
    if ($isFirstPersonOrMouseLook) {
        $hasPitchClamp = ($totalCodeString -match '(?i)(Math\.(max|min)\s*\([^)]*(-1\.5|-Math\.PI|clamp|maxPolarAngle|minPolarAngle)|\.clamp|\bpolarAngle\b)')
        if (-not $hasPitchClamp) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Sin limitación de cabeceo de cámara"
                Issue       = "Fallo Crítico de Cámara: Falta limitación de ángulo vertical (Pitch Clamping). La cámara gira sin límite y se invierte de cabeza (flip upside down), arruinando la vista."
            })
        }

        # B. Comprobación de Movimiento Direccional sin Hundimiento (dir.y = 0)
        $hasYFlattening = ($totalCodeString -match '(?i)(direction\.y\s*=\s*0|dir\.y\s*=\s*0|moveForward|moveRight|\.setFromAxisAngle)')
        if (-not $hasYFlattening) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Movimiento sin neutralización del eje Y"
                Issue       = "Fallo Crítico de Movimiento: La dirección de avance no neutraliza el eje Y (dir.y = 0 o moveForward). El personaje vuela hacia arriba al mirar al cielo o se hunde al mirar al suelo."
            })
        }
    }

    # C. Comprobación de Física con DeltaTime (Evita velocidades erráticas por tasa de refresco)
    $hasDeltaTime = ($totalCodeString -match '(?i)(getDelta\(\)|delta\s*\*|dt\s*\*|\*\s*delta|\*\s*dt|deltaTime)')
    if (-not $hasDeltaTime) {
        $violations.Add([PSCustomObject]@{
            Category    = "Kinetic_Asset_Integrity"
            Penalty     = 5
            File        = $TargetPath
            Line        = 0
            Snippet     = "Física sin DeltaTime"
            Issue       = "Fallo Crítico de Movimiento: El desplazamiento no multiplica por DeltaTime (dt/delta). La velocidad varía de forma descontrolada según los Hz del monitor."
        })
    }

    # D. Comprobación de Filtro de Texturas Nítidas (NearestFilter)
    $isVoxelOrPixel = ($totalCodeString -match '(?i)(voxel|block|minecraft|pixel|tile|textureLoader|createTexture|canvasTexture)')
    if ($isVoxelOrPixel) {
        $hasNearestFilter = ($totalCodeString -match '(?i)(NearestFilter|image-rendering\s*:\s*pixelated|magFilter\s*=\s*THREE\.NearestFilter)')
        if (-not $hasNearestFilter) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Texturas sin NearestFilter"
                Issue       = "Fallo Crítico de Texturas: Texturas borrosas o sin nitidez de vóxel. Falta configurar magFilter = THREE.NearestFilter y minFilter = THREE.NearestFilter."
            })
        }
    }

    # E. Comprobación de Síntesis de Audio / Paisaje Sonoro Obligatorio en Simulaciones/Vuelo
    $isSimOrFlightOrSpace = ($totalCodeString -match '(?i)(rocket|cohete|space\b|luna\b|moon\b|flight\b|launch\b|alunizaje)')
    if ($isSimOrFlightOrSpace) {
        $hasAudio = ($totalCodeString -match '(?i)(AudioContext|webkitAudioContext|createOscillator|createBufferSource|new\s+Audio\b|sound|audioEngine|playAudio|playCountdown|startRocketRoar|SpaceAudioEngine|ProceduralAudioEngine)')
        if (-not $hasAudio) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Simulación o animación muda"
                Issue       = "Fallo Sensorial Crítico: Simulación/animación espacial o de vuelo sin diseño de sonido. Se exige síntesis de audio procedural con Web Audio API (AudioContext) para rugido de motor, cuenta atrás y efectos de propulsión."
            })
        }

        # F. Comprobación de Modelos 3D Compuestos PBR (Anti-Toy Cylinder Trap)
        $hasCompositeModel = ($totalCodeString -match '(?i)(new\s+THREE\.Group|createHighFidelity|GLTFLoader|\.add\(|MeshStandardMaterial|MeshPhysicalMaterial|emissive)')
        if (-not $hasCompositeModel) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Modelos 3D primitivos o sin materiales PBR"
                Issue       = "Fallo de Fidelidad de Mallas 3D: Trampa del Cilindro de Juguete. El vehículo o nave fue modelado como una figura primitiva simple sin jerarquía compuesta (etapas desacoplables, toberas F-1/Raptor, aletas, cápsula) ni materiales PBR realistas."
            })
        }

        # G. Comprobación de Transiciones Suaves de Cámara (Cinematic Director)
        $hasSmoothCamera = ($totalCodeString -match '(?i)(\.lerp\(|\.slerp\(|TWEEN|damping|smoothstep|CinematicFlightDirector|interpolate)')
        if (-not $hasSmoothCamera) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 5
                File        = $TargetPath
                Line        = 0
                Snippet     = "Cámara con saltos bruscos entre fases"
                Issue       = "Fallo de Cámara/Movimiento: Falta interpolación suave en la cámara o director cinematográfico. El cambio entre fases de vuelo salta bruscamente sin lerp/slerp, provocando bugs y desorientación visual."
            })
        }
    }

    # H. Comprobación de Texturizado Universal y Materiales PBR en Juegos y Escenarios 3D
    $is3DProject = ($totalCodeString -match '(?i)(Camera3D|Raylib\.DrawCube|BoxGeometry|THREE\.PerspectiveCamera|BeginMode3D|glDrawArrays)')
    $hasTextureOrPBR = ($totalCodeString -match '(?i)(Texture2D|LoadTexture|SetTexture|Rlgl\.SetTexture|TextureLoader|map\s*:|albedoMap|materials|shader|PBR|MeshStandardMaterial|MeshPhysicalMaterial|metalness|roughness|TextureManager|ProceduralTexture|GenImage|GenTexture)')
    if ($is3DProject -and -not $hasTextureOrPBR) {
        $violations.Add([PSCustomObject]@{
            Category    = "Kinetic_Asset_Integrity"
            Penalty     = 10
            File        = $TargetPath
            Line        = 0
            Snippet     = "Geometría 3D sin texturas ni PBR"
            Issue       = "Fallo Gráfico Fatal (Anti-Flat-Box 3D): El proyecto 3D dibuja geometría sin cargar texturas, mapear UVs ni generar texturas procedurales en VRAM. Prohibido renderizar cajas monocolor planas en juegos y simulaciones 3D. Se exige TextureManager o materiales PBR."
        })
    }

    # I. Comprobación de Viewmodel y Game Feel en Shooters / FPS
    $isFPSOrShooter = ($totalCodeString -match '(?i)\b(FPS|Counter|Strike|Viewmodel|Gun|Weapon|Pistol|Rifle)\b')
    if ($isFPSOrShooter -and $is3DProject) {
        if ($totalCodeString -match 'Raylib\.DrawCylinder\s*\(' -and -not ($totalCodeString -match 'Raylib\.DrawCylinderEx\s*\(')) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 8
                File        = $TargetPath
                Line        = 0
                Snippet     = "Raylib.DrawCylinder en viewmodel"
                Issue       = "Bug de Orientación de Cañón: Raylib.DrawCylinder orienta el cilindro verticalmente en Y. Se exige DrawCylinderEx para alinear a lo largo del vector frontal de la cámara."
            })
        }
        $hasDecalsOrParticles = ($totalCodeString -match '(?i)(Decal|BulletHole|MuzzleFlash|Particle|Impact)')
        if (-not $hasDecalsOrParticles) {
            $violations.Add([PSCustomObject]@{
                Category    = "Kinetic_Asset_Integrity"
                Penalty     = 6
                File        = $TargetPath
                Line        = 0
                Snippet     = "Sin calcomanías de impacto ni destellos"
                Issue       = "Fallo de Game Feel: Falta sistema de calcomanías de impacto (decals) en superficies o destellos de fogonazo (muzzle flash) en armas."
            })
        }
    }
}

# Aplicar deducciones
foreach ($v in $violations) {
    $cat = $v.Category
    if ($scores.Contains($cat)) {
        $scores[$cat] = [Math]::Max(0, $scores[$cat] - $v.Penalty)
    }
}

# Evaluación de tests
if ($testFilesFound -eq 0) {
    $scores["Automated_Testing"] = 0
    $violations.Add([PSCustomObject]@{
        Category = "Automated_Testing"
        Penalty  = 15
        File     = $TargetPath
        Line     = 0
        Snippet  = "Sin suites de tests"
        Issue    = "No se encontraron archivos de test (*test*, *spec*)"
    })
} elseif ($assertionCount -lt 3) {
    $scores["Automated_Testing"] = [Math]::Min(5, $scores["Automated_Testing"])
    $violations.Add([PSCustomObject]@{
        Category = "Automated_Testing"
        Penalty  = 10
        File     = $TargetPath
        Line     = 0
        Snippet  = "Solo $assertionCount aserciones encontradas"
        Issue    = "La suite de pruebas contiene muy pocas aserciones para verificar el contrato"
    })
}

# Ejecución de Tests en Runtime
$testExecutionStatus = "Not_Executed"
if (-not [string]::IsNullOrWhiteSpace($TestCommand)) {
    try {
        $testOutput = Invoke-Expression $TestCommand 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            $testExecutionStatus = "PASSED"
        } else {
            $testExecutionStatus = "FAILED"
            $scores["Automated_Testing"] = 0
            $violations.Add([PSCustomObject]@{
                Category = "Automated_Testing"
                Penalty  = 15
                File     = "TestRunner"
                Line     = 0
                Snippet  = "Exit Code: $exitCode"
                Issue    = "El comando de pruebas falló durante la ejecución: $TestCommand"
            })
        }
    } catch {
        $testExecutionStatus = "ERROR"
        $scores["Automated_Testing"] = 0
        $violations.Add([PSCustomObject]@{
            Category = "Automated_Testing"
            Penalty  = 15
            File     = "TestRunner"
            Line     = 0
            Snippet  = $_.Exception.Message
            Issue    = "Excepción al ejecutar suite de pruebas: $TestCommand"
        })
    }
}

$totalScore = 0
foreach ($val in $scores.Values) {
    $totalScore += $val
}

$status = if ($totalScore -ge 95) { "APPROVED" } else { "REJECTED" }
$verdictMessage = if ($status -eq "APPROVED") {
    "CALIDAD DE EXCELENCIA: Proyecto validado y aprobado para entrega (Score $totalScore/100)."
} else {
    "RECHAZADO: Calidad insuficiente ($totalScore/100). El estándar exige mínimo 95/100 sin excepciones."
}

$report = [PSCustomObject]@{
    verdict              = $status
    score                = $totalScore
    threshold            = 95
    summary              = $verdictMessage
    total_files_scanned  = $files.Count
    total_lines_scanned  = $totalCodeLines
    test_files_count     = $testFilesFound
    assertions_count     = $assertionCount
    test_execution       = $testExecutionStatus
    breakdown            = $scores
    violations_count     = $violations.Count
    violations           = $violations
    timestamp            = (Get-Date -Format "o")
}

Write-Output ($report | ConvertTo-Json -Depth 5)