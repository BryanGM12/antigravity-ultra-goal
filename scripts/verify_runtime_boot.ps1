<#
.SYNOPSIS
    UltraGoal Live Runtime Boot & Dead-Screen Verifier v3.2
.DESCRIPTION
    Verifica de forma autónoma que un juego o aplicación web realmente INICIE y RENDERICE.
    Previene el fallo crítico de entregar código que no arranca o que genera
    una pantalla completamente negra/blanca (Black Screen of Death / Broken Canvas).
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

$fullEntryPath = Join-Path $TargetDirectory $EntryFile
if (-not (Test-Path $fullEntryPath)) {
    $res = [PSCustomObject]@{
        verdict           = "BOOT_FAILED"
        target_directory  = $TargetDirectory
        entry_file        = $EntryFile
        diagnostics_count = 1
        diagnostics       = @("El archivo de entrada '$EntryFile' no existe en '$TargetDirectory'.")
    }
    Write-Output ($res | ConvertTo-Json -Depth 5)
    exit 0
}

$diagnostics = [System.Collections.Generic.List[string]]::new()

# 1. Inspección Estática Pre-Vuelo en HTML/JS
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

# 2. Configuración de Ruta de Salida para Captura
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $TargetDirectory "boot_rendered_screenshot.png"
}
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path $resolvedOutput) { Remove-Item $resolvedOutput -Force -ErrorAction SilentlyContinue }

# 3. Lanzar Headless Chrome de Forma Limpia
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $cmd = Get-Command chrome.exe -ErrorAction SilentlyContinue
    if ($cmd) { $chromePath = $cmd.Source }
}

$luminanceStats = $null
$bootSuccess = $false

if ($chromePath -and (Test-Path $chromePath)) {
    $fileUri = "file:///" + $fullEntryPath.Replace('\', '/')
    $cmdLine = "`"$chromePath`" --headless=new --disable-gpu --allow-file-access-from-files --screenshot=`"$resolvedOutput`" --window-size=1280,720 `"$fileUri`" >nul 2>nul"
    
    cmd.exe /c $cmdLine

    # Esperar hasta 5 segundos a que el archivo se termine de escribir
    $maxWaitSec = 5.0
    $elapsed = 0.0
    while (-not (Test-Path $resolvedOutput) -and $elapsed -lt $maxWaitSec) {
        Start-Sleep -Milliseconds 250
        $elapsed += 0.25
    }

    # 4. Inspección de Píxeles & Detección de Pantallazo Negro/Blanco
    if (Test-Path $resolvedOutput) {
        Add-Type -AssemblyName System.Drawing
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

$verdict = if ($bootSuccess -and $diagnostics.Count -eq 0) { "BOOT_SUCCESS" } else { "BOOT_FAILED" }

$result = [PSCustomObject]@{
    verdict           = $verdict
    target_directory  = $TargetDirectory
    entry_file        = $EntryFile
    screenshot_saved  = (Test-Path $resolvedOutput)
    screenshot_path   = $resolvedOutput
    luminance_stats   = $luminanceStats
    diagnostics_count = $diagnostics.Count
    diagnostics       = $diagnostics
    timestamp         = (Get-Date -Format "o")
}

Write-Output ($result | ConvertTo-Json -Depth 5)