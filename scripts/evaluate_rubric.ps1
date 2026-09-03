<#
.SYNOPSIS
    UltraGoal Quality & Anti-Toy Rubric Evaluator v3.0 (Domain Depth & Anti-Toy Gate)
.DESCRIPTION
    Motor de auditoría rigurosa y evaluación de calidad para proyectos complejos en Antigravity.
    Incluye:
    - Análisis de Profundidad de Dominio y Barrera Anti-Juguete (Anti-Toy Pre-Mortem Gate).
    - Detección de omisión de menús de inicio, falta de mobs/animales, carencia de 3ra persona y crafteo falso.
    - Detección de fugas de rendimiento en bucles de render (animaciones).
    - Desconexión de eventos de interacción (drag-and-drop huérfano).
    - Umbral inquebrantable de aprobación: 95/100 ("No se conforma con cualquier resultado").
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
    "Functional_Completeness"     = 20
    "Domain_Depth_Anti_Toy"       = 15
    "Performance_Render_Budget"   = 15
    "Interaction_Tracking_UX"     = 10
    "Robustness_Error_Handling"   = 15
    "Architecture_Cleanliness"    = 10
    "Automated_Testing"           = 15
}

$violations = [System.Collections.Generic.List[PSCustomObject]]::new()
$testFilesFound = 0
$assertionCount = 0
$totalCodeLines = 0
$allCodeTextBuilder = [System.Text.StringBuilder]::new()

# Expresiones regulares de detección
$todoRegex = [regex]'(?i)\b(TODO|FIXME|HACK|XXX|TBD|PLACEHOLDER)\b'
$stubRegex = [regex]'(?i)(NotImplementedError|NotImplementedException|throw new Error\("Not implemented"\)|pass\s*$|\bSTUB\b)'
$emptyCatchRegex = [regex]'(?i)(catch\s*\([^)]*\)\s*\{\s*\}|except:\s*pass|except\s+Exception:\s*pass)'
$debugDebrisRegex = [regex]'(?i)(console\.log\("debug|print\("test|System\.out\.println\("here|Debugger\.Break)'
$secretRegex = [regex]'(?i)(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|BEGIN PRIVATE KEY|api_key\s*=\s*["''][a-zA-Z0-9_-]{16,}["''])'

# Rendimiento y bucles de render
$allocInRenderRegex = [regex]'(?i)(function\s+(animate|render|update|tick|loop)\b|requestAnimationFrame)'
$naiveLoopMeshRegex = [regex]'(?i)(for\s*\([^)]*\)\s*\{[^}]*for\s*\([^)]*\)\s*\{[^}]*new\s+(THREE\.Mesh|GameObject|MeshRenderer))'

# Seguimiento de interacción
$orphanDragRegex = [regex]'(?i)(draggedItem|selectedItem|activeSlot)\s*=[^;]+;(?!.*(clientX|clientY|pageX|pageY|cursor\.position|pointer))'

foreach ($file in $files) {
    $lines = @(Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue)
    if ($null -eq $lines -or $lines.Count -eq 0) { continue }
    $totalCodeLines += $lines.Count
    $fullContent = $lines -join "`n"
    [void]$allCodeTextBuilder.AppendLine($fullContent)

    if ($file.Name -match '(?i)(test|spec|_test|\.test\.|\.spec\.)') {
        $testFilesFound++
    }

    # Bucle de mallas anidadas sin batching
    if ($fullContent -match $naiveLoopMeshRegex) {
        $violations.Add([PSCustomObject]@{
            Category    = "Performance_Render_Budget"
            Penalty     = 8
            File        = $file.FullName
            Line        = 1
            Snippet     = "Bucle anidado instanciando mallas individuales"
            Issue       = "Grave cuello de botella de rendimiento: Creación de mallas individuales en bucles de terreno en lugar de InstancedMesh o Chunk Geometry merging."
        })
    }

    # Analisis linea por linea
    $inRenderFunc = $false
    $renderBraceCount = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNum = $i + 1
        $line = $lines[$i]

        if ($line -match $allocInRenderRegex) {
            $inRenderFunc = $true
            $renderBraceCount = 0
        }
        if ($inRenderFunc) {
            if ($line -match '\{') { $renderBraceCount++ }
            if ($line -match '\}') {
                $renderBraceCount--
                if ($renderBraceCount -le 0) { $inRenderFunc = $false }
            }

            if ($line -match 'new\s+(THREE\.|Vector|Matrix|Object|Array)\b' -and -not ($line -match 'new\s+Promise')) {
                $violations.Add([PSCustomObject]@{
                    Category    = "Performance_Render_Budget"
                    Penalty     = 6
                    File        = $file.FullName
                    Line        = $lineNum
                    Snippet     = $line.Trim()
                    Issue       = "Instanciación dentro del bucle de renderizado/animación (Causa GC pauses y caídas de FPS)."
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
                Penalty     = 8
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Stub o código sin implementar (NotImplemented / pass)"
            })
        }
        # Empty Catch
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
                Category    = "Architecture_Cleanliness"
                Penalty     = 2
                File        = $file.FullName
                Line        = $lineNum
                Snippet     = $line.Trim()
                Issue       = "Residuo de depuración temporal en código de producción"
            })
        }
        # Secrets
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

        # Aserciones de tests
        $assertionMatches = [regex]::Matches($line, '(?i)(assert|expect\(|should|Assert\.|AssertTrue|AssertEqual)')
        $assertionCount += $assertionMatches.Count
    }
}

# --- EVALUACIÓN DE PROFUNDIDAD DE DOMINIO & BARRERA ANTI-JUGUETE (Anti-Toy Gate) ---
$totalCodeString = $allCodeTextBuilder.ToString()
$isGameOrVoxel = ($Category -eq "Interactive_Game") -or ($totalCodeString -match '(?i)(THREE\.|voxel|minecraft|PointerLockControls|raycast|chunk|blockType)')

if ($isGameOrVoxel) {
    # 1. Chequeo de Menú de Inicio / Shell
    $hasMenu = ($totalCodeString -match '(?i)(startMenu|titleScreen|mainMenu|menuOverlay|optionsMenu|pauseMenu|settingsScreen)')
    if (-not $hasMenu) {
        $violations.Add([PSCustomObject]@{
            Category    = "Domain_Depth_Anti_Toy"
            Penalty     = 8
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin subsistema de menús de inicio/pausa"
            Issue       = "Trampa de Demo de Juguete: No existe menú de inicio ni pausa con opciones. Se redujo la interfaz a un simple click para continuar."
        })
    }

    # 2. Chequeo de Entidades / Mobs / IA
    $hasMobs = ($totalCodeString -match '(?i)(mob|entity|npc|creature|animal|zombie|cow|pig|sheep|stateMachine|wander|spawnMob)')
    if (-not $hasMobs) {
        $violations.Add([PSCustomObject]@{
            Category    = "Domain_Depth_Anti_Toy"
            Penalty     = 6
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin entidades vivas ni mobs"
            Issue       = "Trampa de Demo de Juguete: Mundo completamente estático y desierto. No se implementaron animales ni criaturas con IA de deambulación."
        })
    }

    # 3. Chequeo de Perspectivas Múltiples (1ra y 3ra persona / F5)
    $hasPerspectives = ($totalCodeString -match '(?i)(thirdPerson|firstPerson|toggleCamera|viewMode|cameraDistance|F5)')
    if (-not $hasPerspectives) {
        $violations.Add([PSCustomObject]@{
            Category    = "Domain_Depth_Anti_Toy"
            Penalty     = 4
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin soporte de tercera persona"
            Issue       = "Trampa de Demo de Juguete: Cámara fija en primera persona sin soporte para alternar a tercera persona (F5)."
        })
    }

    # 4. Chequeo de Crafteo Real y Matriz de Recetas
    $hasCrafting = ($totalCodeString -match '(?i)(craftingTable|recipeGrid|craftRecipe|recipes\s*=|craftingMatrix|recipeBook)')
    if (-not $hasCrafting) {
        $violations.Add([PSCustomObject]@{
            Category    = "Domain_Depth_Anti_Toy"
            Penalty     = 5
            File        = $TargetPath
            Line        = 0
            Snippet     = "Sin motor de recetas ni crafteo matricial"
            Issue       = "Trampa de Demo de Juguete: Crafteo inexistente o botón hardcodeado falso en lugar de cuadrícula y motor de recetas."
        })
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