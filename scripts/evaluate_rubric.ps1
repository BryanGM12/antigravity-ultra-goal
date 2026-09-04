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
    "Domain_Depth_Extensibility"  = 20
    "Presentation_Shell_UX"       = 15
    "Performance_Resource_Hygiene"= 15
    "Robustness_Error_Handling"   = 15
    "Interaction_State_Sync"      = 10
    "Functional_Completeness"     = 10
    "Automated_Testing"           = 15
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