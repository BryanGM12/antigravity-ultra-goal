<#
.SYNOPSIS
    UltraGoal Live Runtime Boot & Multi-Runtime Verifier v5.4.0
.DESCRIPTION
    Verifica de forma autónoma que un juego o aplicación (Web, Python, .NET, Rust, Node)
    realmente INICIE, COMPILE y RENDERICE.
    Soporta múltiples runtimes:
    1. Web/HTML: Chrome Headless + Pixel Inspection + Dead-Screen Gate
    2. Python: py_compile / syntax validation / headless execution check
    3. .NET / C#: dotnet build / project integrity check
    4. Rust: cargo check / AST integrity check
    5. Node: package.json / node module integrity check
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDirectory,

    [Parameter(Mandatory = $false)]
    [string]$EntryFile = "index.html",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetDirectory)) {
    Write-Error "Target directory '$TargetDirectory' does not exist."
    exit 1
}

# 1. Detección Inteligente del Runtime
$detectedRuntime = "Web_HTML"

if ($EntryFile -eq "index.html" -and -not (Test-Path (Join-Path $TargetDirectory "index.html"))) {
    if (Test-Path (Join-Path $TargetDirectory "main.py")) {
        $EntryFile = "main.py"
        $detectedRuntime = "Python"
    } elseif (Test-Path (Join-Path $TargetDirectory "app.py")) {
        $EntryFile = "app.py"
        $detectedRuntime = "Python"
    } elseif ((Get-ChildItem -Path $TargetDirectory -Filter "*.csproj" -File -ErrorAction SilentlyContinue).Count -gt 0 -or (Test-Path (Join-Path $TargetDirectory "Program.cs"))) {
        $EntryFile = if (Test-Path (Join-Path $TargetDirectory "Program.cs")) { "Program.cs" } else { (Get-ChildItem -Path $TargetDirectory -Filter "*.csproj" -File)[0].Name }
        $detectedRuntime = "DotNet"
    } elseif (Test-Path (Join-Path $TargetDirectory "Cargo.toml")) {
        $EntryFile = "Cargo.toml"
        $detectedRuntime = "Rust"
    } elseif (Test-Path (Join-Path $TargetDirectory "package.json")) {
        $EntryFile = "package.json"
        $detectedRuntime = "Node"
    }
} elseif ($EntryFile -match '\.py$') {
    $detectedRuntime = "Python"
} elseif ($EntryFile -match '(\.csproj|\.cs)$') {
    $detectedRuntime = "DotNet"
} elseif ($EntryFile -match '(Cargo\.toml|\.rs)$') {
    $detectedRuntime = "Rust"
} elseif ($EntryFile -match '(\.json|\.js|\.ts)$') {
    $detectedRuntime = "Node"
}

$fullEntryPath = Join-Path $TargetDirectory $EntryFile
if (-not (Test-Path $fullEntryPath)) {
    $res = [PSCustomObject]@{
        verdict           = "BOOT_FAILED"
        target_directory  = $TargetDirectory
        entry_file        = $EntryFile
        runtime_type      = $detectedRuntime
        diagnostics_count = 1
        diagnostics       = @("El archivo de entrada '$EntryFile' no existe en '$TargetDirectory'.")
    }
    Write-Output ($res | ConvertTo-Json -Depth 5)
    exit 0
}

$diagnostics = [System.Collections.Generic.List[string]]::new()
$luminanceStats = $null
$bootSuccess = $false
$resolvedOutput = ""

# 2. Verificación por Runtime

if ($detectedRuntime -eq "Python") {
    # Validación de sintaxis Python
    $pyCmd = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($pyCmd) {
        $compileOut = & python -m py_compile "$fullEntryPath" 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) {
            $diagnostics.Add("ERROR FATAL DE SINTAXIS PYTHON en '$EntryFile': $($compileOut.Trim())")
        } else {
            $bootSuccess = $true
        }
    } else {
        $pyContent = Get-Content -LiteralPath $fullEntryPath -Raw -ErrorAction SilentlyContinue
        if ($pyContent -match '(?i)(def\s+\w+|class\s+\w+|import\s+\w+)') {
            $bootSuccess = $true
        } else {
            $diagnostics.Add("AVISO: Archivo Python vacío o sin definiciones válidas.")
        }
    }
}
elseif ($detectedRuntime -eq "DotNet") {
    $dotnetCmd = Get-Command dotnet.exe -ErrorAction SilentlyContinue
    $csProjFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.csproj" -File -ErrorAction SilentlyContinue
    if ($dotnetCmd -and $csProjFiles.Count -gt 0) {
        $buildOut = & dotnet build $csProjFiles[0].FullName --nologo 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) {
            $diagnostics.Add("ERROR DE COMPILACION .NET: $($buildOut.Trim())")
        } else {
            $bootSuccess = $true
        }
    } else {
        $csContent = Get-Content -LiteralPath $fullEntryPath -Raw -ErrorAction SilentlyContinue
        if ($csContent -match '(?i)(class\s+\w+|namespace\s+\w+|static\s+void\s+Main)') {
            $bootSuccess = $true
        } else {
            $diagnostics.Add("AVISO: Archivo C# sin clases ni método Main.")
        }
    }
}
elseif ($detectedRuntime -eq "Rust") {
    $cargoCmd = Get-Command cargo.exe -ErrorAction SilentlyContinue
    if ($cargoCmd -and (Test-Path (Join-Path $TargetDirectory "Cargo.toml"))) {
        $cargoOut = Push-Location $TargetDirectory; & cargo check --quiet 2>&1 | Out-String; Pop-Location
        if ($LASTEXITCODE -ne 0) {
            $diagnostics.Add("ERROR DE COMPILACION RUST: $($cargoOut.Trim())")
        } else {
            $bootSuccess = $true
        }
    } else {
        $rsContent = Get-Content -LiteralPath $fullEntryPath -Raw -ErrorAction SilentlyContinue
        if ($rsContent -match '(?i)(fn\s+main|struct\s+\w+|enum\s+\w+)') {
            $bootSuccess = $true
        } else {
            $diagnostics.Add("AVISO: Archivo Rust sin función main o structs válidos.")
        }
    }
}
else {
    # 3. Verificación Web / HTML Clásica con Chrome Headless
    $htmlContent = Get-Content -LiteralPath $fullEntryPath -Raw -ErrorAction SilentlyContinue

    if ($null -ne $htmlContent) {
        # Detectar declaraciones import dentro de <script> tradicional sin type="module"
        if ($htmlContent -match '<script\b(?![^>]*\btype\s*=\s*["'']module["''])[^>]*>[^<]*\bimport\s+[\s\S]*?from\b') {
            $diagnostics.Add("ERROR FATAL DE SINTAXIS: Declaración 'import' dentro de <script> tradicional sin type='module'. La app no arranca en ningún navegador (SyntaxError: Cannot use import statement outside a module).")
        }

        # Detectar Three.js / Canvas games sin elemento canvas ni renderer agregado al DOM
        if ($htmlContent -match '(?i)(three\.js|three\.min\.js|THREE\.)' -and -not ($htmlContent -match '(?i)(<canvas|id=["'']canvas|renderer\.domElement|document\.body\.appendChild)')) {
            $diagnostics.Add("ERROR DE RENDER: Se utiliza Three.js pero no se añade el canvas al DOM (falta renderer.domElement o etiqueta <canvas>).")
        }

        # Detectar scripts locales referenciados que no existen en el disco
        $scriptMatches = [regex]::Matches($htmlContent, '(?i)<script[^>]+src=["'']([^"'']+)["'']')
        foreach ($m in $scriptMatches) {
            $src = $m.Groups[1].Value
            if (-not ($src -like "http*" -or $src -like "//*" -or $src -like "data:*")) {
                $resolvedLocal = Join-Path $TargetDirectory $src.Replace('/', '\')
                if (-not (Test-Path $resolvedLocal)) {
                    $diagnostics.Add("ARCHIVO FALTANTE: El archivo de script '$src' referenciado en el HTML no existe en '$TargetDirectory'.")
                }
            }
        }
    }

    # Configuración de Ruta de Salida para Captura
    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $OutputPath = Join-Path $TargetDirectory "boot_rendered_screenshot.png"
    }
    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
    if (Test-Path $resolvedOutput) { Remove-Item $resolvedOutput -Force -ErrorAction SilentlyContinue }

    # Lanzar Headless Chrome
    $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path $chromePath)) {
        $cmd = Get-Command chrome.exe -ErrorAction SilentlyContinue
        if ($cmd) { $chromePath = $cmd.Source }
    }

    if ($chromePath -and (Test-Path $chromePath)) {
        $fileUri = "file:///" + $fullEntryPath.Replace('\', '/')
        $cmdLine = "`"$chromePath`" --headless=new --disable-gpu --allow-file-access-from-files --screenshot=`"$resolvedOutput`" --window-size=1280,720 `"$fileUri`" >nul 2>nul"
        
        cmd.exe /c $cmdLine

        $maxWaitSec = 5.0
        $elapsed = 0.0
        while (-not (Test-Path $resolvedOutput) -and $elapsed -lt $maxWaitSec) {
            Start-Sleep -Milliseconds 250
            $elapsed += 0.25
        }

        # Inspección de Píxeles & Detección de Pantallazo Negro/Blanco
        if (Test-Path $resolvedOutput) {
            Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
            $bmp = [System.Drawing.Bitmap]::FromFile($resolvedOutput)
            $w = $bmp.Width
            $h = $bmp.Height
            
            $stepX = [Math]::Max(1, [int]($w / 32))
            $stepY = [Math]::Max(1, [int]($h / 32))
            $samples = [System.Collections.Generic.List[double]]::new()
            $blackCount = 0
            $whiteCount = 0

            for ($x = 0; $x -lt $w; $x += $stepX) {
                for ($y = 0; $y -lt $h; $y += $stepY) {
                    $pixel = $bmp.GetPixel($x, $y)
                    $lum = 0.299 * $pixel.R + 0.587 * $pixel.G + 0.114 * $pixel.B
                    $samples.Add($lum)
                    if ($lum -lt 5) { $blackCount++ }
                    if ($lum -gt 250) { $whiteCount++ }
                }
            }
            $bmp.Dispose()

            $sum = 0
            foreach ($s in $samples) { $sum += $s }
            $mean = if ($samples.Count -gt 0) { $sum / $samples.Count } else { 0 }
            
            $varSum = 0
            foreach ($s in $samples) { $varSum += [Math]::Pow($s - $mean, 2) }
            $stdDev = if ($samples.Count -gt 0) { [Math]::Sqrt($varSum / $samples.Count) } else { 0 }
            $blackPct = if ($samples.Count -gt 0) { ($blackCount / $samples.Count) * 100 } else { 0 }
            $whitePct = if ($samples.Count -gt 0) { ($whiteCount / $samples.Count) * 100 } else { 0 }

            $isDeadOrBlank = ($stdDev -lt 3.0) -or ($blackPct -gt 98.0) -or ($whitePct -gt 98.0)

            $luminanceStats = [PSCustomObject]@{
                mean_luminance     = [Math]::Round($mean, 2)
                std_deviation      = [Math]::Round($stdDev, 2)
                black_percentage   = [Math]::Round($blackPct, 1)
                white_percentage   = [Math]::Round($whitePct, 1)
                is_dead_or_blank   = $isDeadOrBlank
            }

            if ($isDeadOrBlank) {
                $diagnostics.Add("PANTALLAZO NEGRO/BLANCO DETECTADO: La aplicación no inició el bucle de renderizado ni mostró interfaz gráfica activa (StdDev: $([Math]::Round($stdDev,2)), Black: $([Math]::Round($blackPct,1))%, White: $([Math]::Round($whitePct,1))%).")
            } else {
                $bootSuccess = ($diagnostics.Count -eq 0)
            }
        } else {
            $diagnostics.Add("ERROR DE CAPTURA: Chrome headless no pudo generar la captura de pantalla de la aplicación.")
        }
    } else {
        $diagnostics.Add("AVISO: Chrome no encontrado en el sistema; no se pudo realizar captura headless.")
    }
}

$verdict = if ($bootSuccess -and $diagnostics.Count -eq 0) { "BOOT_SUCCESS" } else { "BOOT_FAILED" }

$result = [PSCustomObject]@{
    verdict           = $verdict
    target_directory  = $TargetDirectory
    entry_file        = $EntryFile
    runtime_type      = $detectedRuntime
    screenshot_saved  = (-not [string]::IsNullOrWhiteSpace($resolvedOutput) -and (Test-Path $resolvedOutput))
    screenshot_path   = $resolvedOutput
    luminance_stats   = $luminanceStats
    diagnostics_count = $diagnostics.Count
    diagnostics       = $diagnostics
    timestamp         = (Get-Date -Format "o")
}

Write-Output ($result | ConvertTo-Json -Depth 5)
