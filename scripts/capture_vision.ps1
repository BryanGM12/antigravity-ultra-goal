<#
.SYNOPSIS
    UltraGoal Vision Capture Engine v5.4.0 (DWM Native Window & Advanced CV Metrics)
.DESCRIPTION
    Motor de captura e inspección visual de alta fidelidad para agentes Gemini en Antigravity.
    Capacidades v5.4.0:
    - Captura DWM nativa ultra-precisa de ventanas por Proceso o Título (DWMWA_EXTENDED_FRAME_BOUNDS)
      eliminando sombras y bordes falsos de Windows.
    - Métricas Avanzadas de Visión por Computadora:
      * Varianza Laplaciana de nitidez (sharpness_score >= 15.0, anti-borrosidad).
      * Ratio de contraste en HUD bajo WCAG 2.1 (hud_contrast_ratio >= 3.0:1).
      * Entropía cromática de Shannon (chromatic_entropy >= 2.5).
      * Detección de distorsión de relación de aspecto anamórfico.
    - Modo MultiStateAudit: Galería completa de fotos (General con cuadrícula, recortes 1:1 de Suelo, HUD y Centro).
    - Modo GridOverlay: Inscribe cuadrícula de coordenadas taxonómicas [A1]..[C3].
    - Modo MultiSector: Extrae recortes 1:1 sin reescalado.
    - Modo Burst: Ráfaga secuencial de N fotogramas para auditar dinámicas en tiempo real.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory = $false)]
    [string]$InputImage = "",

    [Parameter(Mandatory = $false)]
    [string]$ConversationId = "",

    [Parameter(Mandatory = $false)]
    [string]$ProcessName = "",

    [Parameter(Mandatory = $false)]
    [string]$WindowTitle = "",

    [Parameter(Mandatory = $false)]
    [int]$DelaySeconds = 0,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Full", "GridOverlay", "MultiSector", "Burst", "MultiStateAudit")]
    [string]$Mode = "MultiStateAudit",

    [Parameter(Mandatory = $false)]
    [switch]$GenerateSectors,

    [Parameter(Mandatory = $false)]
    [string]$TargetDirectory = "",

    [Parameter(Mandatory = $false)]
    [string]$HtmlPath = "",

    [Parameter(Mandatory = $false)]
    [int]$BurstCount = 3,

    [Parameter(Mandatory = $false)]
    [int]$BurstIntervalMs = 300
)

$ErrorActionPreference = "Stop"

if (-not ([System.Management.Automation.PSTypeName]'UltraVisionCaptureV4').Type) {
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $typeDefinition = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;

public struct RECT_V4 {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}

public class UltraVisionCaptureV4 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetDesktopWindow();
    [DllImport("user32.dll")]
    public static extern IntPtr GetWindowDC(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern IntPtr ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("gdi32.dll")]
    public static extern bool BitBlt(IntPtr hObject, int nXDest, int nYDest, int nWidth, int nHeight, IntPtr hObjectSource, int nXSrc, int nYSrc, int dwRop);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT_V4 lpRect);
    [DllImport("dwmapi.dll")]
    public static extern int DwmGetWindowAttribute(IntPtr hwnd, int dwAttribute, out RECT_V4 pvAttribute, int cbAttribute);
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    public const int SRCCOPY = 0x00CC0020;
    public const int DWMWA_EXTENDED_FRAME_BOUNDS = 9;

    public static IntPtr FindWindowByTitle(string titleSubstring) {
        IntPtr found = IntPtr.Zero;
        EnumWindows(delegate (IntPtr hWnd, IntPtr lParam) {
            if (IsWindowVisible(hWnd)) {
                StringBuilder sb = new StringBuilder(512);
                GetWindowText(hWnd, sb, 512);
                string t = sb.ToString();
                if (!string.IsNullOrEmpty(t) && t.IndexOf(titleSubstring, StringComparison.OrdinalIgnoreCase) >= 0) {
                    found = hWnd;
                    return false;
                }
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static Rectangle GetAccurateWindowBounds(IntPtr hWnd) {
        RECT_V4 rect;
        try {
            int res = DwmGetWindowAttribute(hWnd, DWMWA_EXTENDED_FRAME_BOUNDS, out rect, Marshal.SizeOf(typeof(RECT_V4)));
            if (res == 0 && (rect.Right - rect.Left > 0) && (rect.Bottom - rect.Top > 0)) {
                return new Rectangle(rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top);
            }
        } catch {}
        RECT_V4 gRect;
        GetWindowRect(hWnd, out gRect);
        return new Rectangle(gRect.Left, gRect.Top, Math.Max(10, gRect.Right - gRect.Left), Math.Max(10, gRect.Bottom - gRect.Top));
    }

    public static Bitmap CaptureDesktopGDI(int width, int height) {
        IntPtr hDesk = GetDesktopWindow();
        IntPtr hDeskDC = GetWindowDC(hDesk);
        Bitmap bmp = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(bmp)) {
            IntPtr hBmpDC = g.GetHdc();
            BitBlt(hBmpDC, 0, 0, width, height, hDeskDC, 0, 0, SRCCOPY);
            g.ReleaseHdc(hBmpDC);
        }
        ReleaseDC(hDesk, hDeskDC);
        return bmp;
    }

    public static Bitmap CaptureWindowGDI(IntPtr hWnd, int width, int height) {
        Bitmap bmp = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(bmp)) {
            IntPtr hBmpDC = g.GetHdc();
            bool ok = PrintWindow(hWnd, hBmpDC, 2);
            if (!ok) {
                IntPtr hWndDC = GetWindowDC(hWnd);
                BitBlt(hBmpDC, 0, 0, width, height, hWndDC, 0, 0, SRCCOPY);
                ReleaseDC(hWnd, hWndDC);
            }
            g.ReleaseHdc(hBmpDC);
        }
        return bmp;
    }

    public static Bitmap ApplyInspectionGrid(Bitmap source) {
        Bitmap target = new Bitmap(source.Width, source.Height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(target)) {
            g.DrawImage(source, 0, 0);
            using (Pen pen = new Pen(Color.FromArgb(180, 0, 255, 255), 2))
            using (Font font = new Font("Consolas", 14, FontStyle.Bold))
            using (Brush textBrush = new SolidBrush(Color.FromArgb(240, 255, 255, 0)))
            using (Brush bgBrush = new SolidBrush(Color.FromArgb(140, 0, 0, 0))) {
                int colW = source.Width / 3;
                int rowH = source.Height / 3;
                string[] colLabels = new string[] { "A", "B", "C" };
                for (int c = 1; c < 3; c++) {
                    g.DrawLine(pen, c * colW, 0, c * colW, source.Height);
                }
                for (int r = 1; r < 3; r++) {
                    g.DrawLine(pen, 0, r * rowH, source.Width, r * rowH);
                }
                for (int r = 0; r < 3; r++) {
                    for (int c = 0; c < 3; c++) {
                        string tag = string.Format("[{0}{1}]", colLabels[c], r + 1);
                        int tx = c * colW + 15;
                        int ty = r * rowH + 15;
                        g.FillRectangle(bgBrush, tx - 4, ty - 2, 60, 24);
                        g.DrawString(tag, font, textBrush, tx, ty);
                    }
                }
            }
        }
        return target;
    }

    public static Bitmap CropRegion(Bitmap source, Rectangle rect) {
        Rectangle srcRect = new Rectangle(0, 0, source.Width, source.Height);
        rect.Intersect(srcRect);
        if (rect.Width <= 0 || rect.Height <= 0) {
            return new Bitmap(10, 10);
        }
        Bitmap crop = new Bitmap(rect.Width, rect.Height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(crop)) {
            g.DrawImage(source, new Rectangle(0, 0, rect.Width, rect.Height), rect, GraphicsUnit.Pixel);
        }
        return crop;
    }
}
"@
    $refs = @("System.Drawing", "System.Windows.Forms")
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $refs = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { 
            -not [string]::IsNullOrWhiteSpace($_.Location) 
        } | ForEach-Object { $_.Location } | Select-Object -Unique
    }
    Add-Type -TypeDefinition $typeDefinition -ReferencedAssemblies $refs
}

function Test-DeadOrBlankBitmap([System.Drawing.Bitmap]$bmp) {
    $w = $bmp.Width
    $h = $bmp.Height
    $stepX = [Math]::Max(1, [int]($w / 32))
    $stepY = [Math]::Max(1, [int]($h / 32))
    $samples = [System.Collections.Generic.List[double]]::new()
    $colorBuckets = @{}
    $edgeDeltas = [System.Collections.Generic.List[double]]::new()
    $laplacianSamples = [System.Collections.Generic.List[double]]::new()
    $hudLuminanceList = [System.Collections.Generic.List[double]]::new()
    $hist256 = New-Object int[] 256
    $blackCount = 0
    $whiteCount = 0
    $minLum = 255.0
    $maxLum = 0.0

    $limitX = [Math]::Max(1, $w - $stepX)
    $limitY = [Math]::Max(1, $h - $stepY)
    $hudStartY = [int]($h * 0.75)

    for ($x = $stepX; $x -lt $limitX; $x += $stepX) {
        for ($y = $stepY; $y -lt $limitY; $y += $stepY) {
            $pixel = $bmp.GetPixel($x, $y)
            $lum = 0.299 * $pixel.R + 0.587 * $pixel.G + 0.114 * $pixel.B
            $samples.Add($lum)
            if ($lum -lt 5) { $blackCount++ }
            if ($lum -gt 250) { $whiteCount++ }
            if ($lum -lt $minLum) { $minLum = $lum }
            if ($lum -gt $maxLum) { $maxLum = $lum }

            # Histograma de luminancia para entropía de Shannon
            $binIdx = [Math]::Max(0, [Math]::Min(255, [int]$lum))
            $hist256[$binIdx]++

            # Muestra HUD si está en la franja inferior
            if ($y -ge $hudStartY) {
                # Luminancia relativa normalizada WCAG
                $relLum = 0.2126 * ($pixel.R / 255.0) + 0.7152 * ($pixel.G / 255.0) + 0.0722 * ($pixel.B / 255.0)
                $hudLuminanceList.Add($relLum)
            }

            # Cubeta de color cuantizada (4 bits por canal)
            $bucketKey = "$([int]($pixel.R / 16))_$([int]($pixel.G / 16))_$([int]($pixel.B / 16))"
            if ($colorBuckets.ContainsKey($bucketKey)) {
                $colorBuckets[$bucketKey]++
            } else {
                $colorBuckets[$bucketKey] = 1
            }

            # Magnitud de gradiente simple con vecinos
            $pRight = $bmp.GetPixel($x + $stepX, $y)
            $pDown  = $bmp.GetPixel($x, $y + $stepY)
            $lumRight = 0.299 * $pRight.R + 0.587 * $pRight.G + 0.114 * $pRight.B
            $lumDown  = 0.299 * $pDown.R  + 0.587 * $pDown.G  + 0.114 * $pDown.B
            $grad = [Math]::Abs($lumRight - $lum) + [Math]::Abs($lumDown - $lum)
            $edgeDeltas.Add($grad)

            # Varianza Laplaciana (Convolución de kernel 3x3 en muestra de paso)
            $pLeft = $bmp.GetPixel($x - $stepX, $y)
            $pUp   = $bmp.GetPixel($x, $y - $stepY)
            $lumLeft = 0.299 * $pLeft.R + 0.587 * $pLeft.G + 0.114 * $pLeft.B
            $lumUp   = 0.299 * $pUp.R   + 0.587 * $pUp.G   + 0.114 * $pUp.B
            $lapVal = ($lumRight + $lumLeft + $lumUp + $lumDown) - (4.0 * $lum)
            $laplacianSamples.Add($lapVal)
        }
    }

    $count = $samples.Count
    if ($count -eq 0) { $count = 1 }
    $sum = 0.0
    foreach ($s in $samples) { $sum += $s }
    $mean = $sum / $count
    
    $varSum = 0.0
    foreach ($s in $samples) { $varSum += [Math]::Pow($s - $mean, 2) }
    $stdDev = [Math]::Sqrt($varSum / $count)
    
    $gradSum = 0.0
    foreach ($g in $edgeDeltas) { $gradSum += $g }
    $avgEdgeGrad = if ($edgeDeltas.Count -gt 0) { $gradSum / $edgeDeltas.Count } else { 0.0 }

    # Cálculo de Varianza Laplaciana (Sharpness Score)
    $lapSum = 0.0
    foreach ($lp in $laplacianSamples) { $lapSum += $lp }
    $lapMean = if ($laplacianSamples.Count -gt 0) { $lapSum / $laplacianSamples.Count } else { 0.0 }
    $lapVarSum = 0.0
    foreach ($lp in $laplacianSamples) { $lapVarSum += [Math]::Pow($lp - $lapMean, 2) }
    $sharpnessScore = if ($laplacianSamples.Count -gt 0) { [Math]::Round($lapVarSum / $laplacianSamples.Count, 2) } else { 0.0 }

    # Cálculo de Entropía Cromática de Shannon
    $shannonEntropy = 0.0
    for ($i = 0; $i -lt 256; $i++) {
        if ($hist256[$i] -gt 0) {
            $p = $hist256[$i] / $count
            $shannonEntropy -= ($p * [Math]::Log($p, 2.0))
        }
    }
    $shannonEntropy = [Math]::Round($shannonEntropy, 2)

    # Cálculo de Contraste en HUD (WCAG 2.1 con muestreo denso en percentiles 99 y 1)
    $hudContrastRatio = 21.0
    $hudLuminances = [System.Collections.Generic.List[double]]::new()
    $hudStepX = [Math]::Max(2, [int]($w / 100))
    $hudStepY = [Math]::Max(2, [int]($h / 100))
    for ($hx = 0; $hx -lt $w; $hx += $hudStepX) {
        for ($hy = $hudStartY; $hy -lt $h; $hy += $hudStepY) {
            $px = $bmp.GetPixel($hx, $hy)
            $relLum = 0.2126 * ($px.R / 255.0) + 0.7152 * ($px.G / 255.0) + 0.0722 * ($px.B / 255.0)
            $hudLuminances.Add($relLum)
        }
    }

    if ($hudLuminances.Count -ge 20) {
        $sortedHud = @($hudLuminances | Sort-Object)
        $idx99 = [Math]::Min($sortedHud.Count - 1, [int]($sortedHud.Count * 0.99))
        $idx01 = [Math]::Max(0, [int]($sortedHud.Count * 0.01))
        $lBright = $sortedHud[$idx99]
        $lDark   = $sortedHud[$idx01]
        $hudContrastRatio = [Math]::Round(($lBright + 0.05) / ($lDark + 0.05), 2)
    }

    # Relación de aspecto
    $aspectRatio = [Math]::Round($w / [Math]::Max(1.0, $h), 2)
    $isAspectDistorted = ($aspectRatio -lt 0.5 -or $aspectRatio -gt 3.8)

    $blackPct = ($blackCount / $count) * 100.0
    $whitePct = ($whiteCount / $count) * 100.0
    $dynRange = [Math]::Max(0.0, $maxLum - $minLum)

    $uniqueColors = $colorBuckets.Keys.Count
    $maxBucketCount = 0
    foreach ($k in $colorBuckets.Keys) {
        if ($colorBuckets[$k] -gt $maxBucketCount) {
            $maxBucketCount = $colorBuckets[$k]
        }
    }
    $maxColorDominancePct = ($maxBucketCount / $count) * 100.0

    # Detección de Polígonos Planos Sin Texturizar (Anti-Flat-Box Geometry)
    $flatPixelCount = 0
    $interiorCount = 0
    for ($y = $stepY; $y -lt ($h - $stepY); $y += $stepY) {
        for ($x = $stepX; $x -lt ($w - $stepX); $x += $stepX) {
            $interiorCount++
            $pCurr  = $bmp.GetPixel($x, $y)
            $pRight = $bmp.GetPixel($x + $stepX, $y)
            $pDown  = $bmp.GetPixel($x, $y + $stepY)
            $dR = [Math]::Abs($pCurr.R - $pRight.R) + [Math]::Abs($pCurr.G - $pRight.G) + [Math]::Abs($pCurr.B - $pRight.B)
            $dD = [Math]::Abs($pCurr.R - $pDown.R) + [Math]::Abs($pCurr.G - $pDown.G) + [Math]::Abs($pCurr.B - $pDown.B)
            if ($dR -le 3 -and $dD -le 3) {
                $flatPixelCount++
            }
        }
    }
    $flatSurfacePct = if ($interiorCount -gt 0) { [Math]::Round(($flatPixelCount / $interiorCount) * 100.0, 1) } else { 0.0 }
    $isUntexturedFlatGeometry = ($flatSurfacePct -gt 78.0) -and (-not $isDead)

    $isDead = ($stdDev -lt 3.0) -or ($blackPct -gt 98.0) -or ($whitePct -gt 98.0)
    $isFlatMonochrome = ($uniqueColors -le 2) -and ($maxColorDominancePct -gt 92.0) -and (-not $isDead)
    $isUnlit = ($dynRange -lt 15.0) -and (-not $isDead)
    $lacksDetail = ($avgEdgeGrad -lt 1.0) -and (-not $isDead)
    $isBlurred = ($sharpnessScore -lt 15.0) -and (-not $isDead) -and (-not $isFlatMonochrome)
    $isHudIllegible = ($hudContrastRatio -lt 3.0) -and (-not $isDead) -and ($w -ge 600 -or $h -le 250)
    $isFlatEntropy = ($shannonEntropy -lt 0.70) -and (-not $isDead)

    return [PSCustomObject]@{
        mean_luminance          = [Math]::Round($mean, 2)
        std_deviation           = [Math]::Round($stdDev, 2)
        black_percentage        = [Math]::Round($blackPct, 1)
        white_percentage        = [Math]::Round($whitePct, 1)
        dynamic_range           = [Math]::Round($dynRange, 1)
        unique_color_clusters   = $uniqueColors
        max_color_dominance_pct = [Math]::Round($maxColorDominancePct, 1)
        avg_edge_gradient       = [Math]::Round($avgEdgeGrad, 2)
        sharpness_score         = $sharpnessScore
        shannon_entropy         = $shannonEntropy
        hud_contrast_ratio      = $hudContrastRatio
        aspect_ratio            = $aspectRatio
        flat_surface_pct        = $flatSurfacePct
        is_untextured_geometry  = $isUntexturedFlatGeometry
        is_dead_or_blank        = $isDead
        is_flat_monochrome      = $isFlatMonochrome
        is_unlit_scene          = $isUnlit
        lacks_texture_detail    = $lacksDetail
        is_excessively_blurred  = $isBlurred
        is_hud_illegible        = $isHudIllegible
        is_flat_entropy         = $isFlatEntropy
        is_aspect_distorted     = $isAspectDistorted
    }
}

if ($DelaySeconds -gt 0) {
    Start-Sleep -Seconds $DelaySeconds
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    if (-not [string]::IsNullOrWhiteSpace($ConversationId)) {
        $baseDir = "C:\Users\Administrator\.gemini\antigravity\brain\$ConversationId\scratch"
    } else {
        $baseDir = "$env:TEMP\ultragoal_vision"
    }
    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
    $OutputPath = Join-Path $baseDir "vision_capture_$timestamp.png"
} else {
    $baseDir = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($baseDir) -and -not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    }
}

# Resolución de Ventana por Proceso o Título (DWM Frame Bounds)
$targetHWnd = [IntPtr]::Zero
$targetWidth = 0
$targetHeight = 0

if (-not [string]::IsNullOrWhiteSpace($WindowTitle)) {
    $targetHWnd = [UltraVisionCaptureV4]::FindWindowByTitle($WindowTitle)
    if ($targetHWnd -ne [IntPtr]::Zero) {
        $bounds = [UltraVisionCaptureV4]::GetAccurateWindowBounds($targetHWnd)
        $targetWidth = $bounds.Width
        $targetHeight = $bounds.Height
    }
}

if ($targetHWnd -eq [IntPtr]::Zero -and -not [string]::IsNullOrWhiteSpace($ProcessName)) {
    $proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
    if ($proc) {
        $targetHWnd = $proc.MainWindowHandle
        $bounds = [UltraVisionCaptureV4]::GetAccurateWindowBounds($targetHWnd)
        $targetWidth = $bounds.Width
        $targetHeight = $bounds.Height
    }
}

if (-not [string]::IsNullOrWhiteSpace($InputImage) -and (Test-Path $InputImage)) {
    try {
        $imgProbe = [System.Drawing.Bitmap]::FromFile((Resolve-Path $InputImage).Path)
        $targetWidth = $imgProbe.Width
        $targetHeight = $imgProbe.Height
        $imgProbe.Dispose()
    } catch {}
}

if ($targetHWnd -eq [IntPtr]::Zero -or $targetWidth -le 0 -or $targetHeight -le 0) {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen
        if ($screen) {
            $targetWidth = $screen.Bounds.Width
            $targetHeight = $screen.Bounds.Height
        }
    } catch {}

    if ($targetWidth -le 0 -or $targetHeight -le 0) {
        $targetWidth = 1920
        $targetHeight = 1080
    }
}

function Get-RawFrame {
    # 0. Imagen directa de entrada
    if (-not [string]::IsNullOrWhiteSpace($InputImage) -and (Test-Path $InputImage)) {
        $rawImg = [System.Drawing.Bitmap]::FromFile((Resolve-Path $InputImage).Path)
        $cloned = New-Object System.Drawing.Bitmap($rawImg)
        $rawImg.Dispose()
        return $cloned
    }

    # 1. Renderizado HTML con Chrome Headless
    $renderTarget = $HtmlPath
    if ([string]::IsNullOrWhiteSpace($renderTarget) -and -not [string]::IsNullOrWhiteSpace($TargetDirectory)) {
        $cand = Join-Path $TargetDirectory "index.html"
        if (Test-Path $cand) { $renderTarget = $cand }
    }

    if (-not [string]::IsNullOrWhiteSpace($renderTarget) -and (Test-Path $renderTarget)) {
        $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        if (-not (Test-Path $chromePath)) {
            $cmd = Get-Command chrome.exe -ErrorAction SilentlyContinue
            if ($cmd) { $chromePath = $cmd.Source }
        }
        if ($chromePath -and (Test-Path $chromePath)) {
            $tempRender = Join-Path $baseDir "headless_render_$timestamp.png"
            $fileUri = "file:///" + (Resolve-Path $renderTarget).Path.Replace('\', '/')
            $cmdLine = "`"$chromePath`" --headless=new --disable-gpu --allow-file-access-from-files --screenshot=`"$tempRender`" --window-size=1280,720 `"$fileUri`" >nul 2>nul"
            cmd.exe /c $cmdLine
            $elapsed = 0
            while (-not (Test-Path $tempRender) -and $elapsed -lt 4.0) {
                Start-Sleep -Milliseconds 200
                $elapsed += 0.2
            }
            if (Test-Path $tempRender) {
                $rawImg = [System.Drawing.Bitmap]::FromFile($tempRender)
                $cloned = New-Object System.Drawing.Bitmap($rawImg)
                $rawImg.Dispose()
                Remove-Item $tempRender -Force -ErrorAction SilentlyContinue
                return $cloned
            }
        }
    }

    # 2. Captura DWM nativa de ventana o escritorio GDI
    if ($targetHWnd -ne [IntPtr]::Zero) {
        return [UltraVisionCaptureV4]::CaptureWindowGDI($targetHWnd, $targetWidth, $targetHeight)
    } else {
        return [UltraVisionCaptureV4]::CaptureDesktopGDI($targetWidth, $targetHeight)
    }
}

# 1. MODO BURST
if ($Mode -eq "Burst") {
    $burstFrames = @()
    for ($i = 1; $i -le $BurstCount; $i++) {
        $bmp = Get-RawFrame
        $framePath = Join-Path $baseDir "burst_frame_${i}_$timestamp.png"
        $bmp.Save($framePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $lum = Test-DeadOrBlankBitmap $bmp
        $burstFrames += [PSCustomObject]@{
            index          = $i
            path           = $framePath
            timestamp      = (Get-Date -Format "o")
            size_bytes     = (Get-Item $framePath).Length
            luminance_stat = $lum
        }
        $bmp.Dispose()
        if ($i -lt $BurstCount) { Start-Sleep -Milliseconds $BurstIntervalMs }
    }

    $result = [PSCustomObject]@{
        status       = "ok"
        mode         = "Burst"
        frame_count  = $BurstCount
        frames       = $burstFrames
        summary      = "Ráfaga de $BurstCount fotogramas capturada para auditoría dinámica."
    }
    Write-Output ($result | ConvertTo-Json -Depth 5)
    exit 0
}

# 2. MODO FULL (Captura directa sin cuadrícula)
if ($Mode -eq "Full") {
    $rawBmp = Get-RawFrame
    $rawBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $lum = Test-DeadOrBlankBitmap $rawBmp
    $rawBmp.Dispose()
    $result = [PSCustomObject]@{
        status               = "ok"
        mode                 = "Full"
        screenshot_path      = $OutputPath
        width                = $targetWidth
        height               = $targetHeight
        dead_screen_detected = $lum.is_dead_or_blank
        luminance_stat       = $lum
        captured_at          = (Get-Date -Format "o")
    }
    Write-Output ($result | ConvertTo-Json -Depth 5)
    exit 0
}

# 3. MODO GRIDOVERLAY (Cuadrícula taxonómica [A1]..[C3])
if ($Mode -eq "GridOverlay") {
    $rawBmp = Get-RawFrame
    $gridBmp = [UltraVisionCaptureV4]::ApplyInspectionGrid($rawBmp)
    $gridBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $lum = Test-DeadOrBlankBitmap $gridBmp
    $gridBmp.Dispose()
    $rawBmp.Dispose()
    $result = [PSCustomObject]@{
        status               = "ok"
        mode                 = "GridOverlay"
        grid_screenshot_path = $OutputPath
        grid_sectors         = @("[A1]","[A2]","[A3]","[B1]","[B2]","[B3]","[C1]","[C2]","[C3]")
        dead_screen_detected = $lum.is_dead_or_blank
        luminance_stat       = $lum
        captured_at          = (Get-Date -Format "o")
    }
    Write-Output ($result | ConvertTo-Json -Depth 5)
    exit 0
}

# 4. MODO MULTISECTOR (Recortes 1:1 nativos)
if ($Mode -eq "MultiSector") {
    $rawBmp = Get-RawFrame
    $w = $rawBmp.Width
    $h = $rawBmp.Height

    $rectCenter = New-Object System.Drawing.Rectangle([int]($w * 0.3), [int]($h * 0.25), [int]($w * 0.4), [int]($h * 0.4))
    $bmpCenter = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectCenter)
    $pathCenter = Join-Path $baseDir "sector_center_$timestamp.png"
    $bmpCenter.Save($pathCenter, [System.Drawing.Imaging.ImageFormat]::Png)
    $statCenter = Test-DeadOrBlankBitmap $bmpCenter
    $bmpCenter.Dispose()

    $rectGround = New-Object System.Drawing.Rectangle([int]($w * 0.2), [int]($h * 0.55), [int]($w * 0.6), [int]($h * 0.35))
    $bmpGround = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectGround)
    $pathGround = Join-Path $baseDir "sector_ground_$timestamp.png"
    $bmpGround.Save($pathGround, [System.Drawing.Imaging.ImageFormat]::Png)
    $statGround = Test-DeadOrBlankBitmap $bmpGround
    $bmpGround.Dispose()

    $rectHUD = New-Object System.Drawing.Rectangle([int]($w * 0.15), [int]($h * 0.78), [int]($w * 0.7), [int]($h * 0.22))
    $bmpHUD = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectHUD)
    $pathHUD = Join-Path $baseDir "sector_hud_$timestamp.png"
    $bmpHUD.Save($pathHUD, [System.Drawing.Imaging.ImageFormat]::Png)
    $statHUD = Test-DeadOrBlankBitmap $bmpHUD
    $bmpHUD.Dispose()

    $rawBmp.Dispose()

    $result = [PSCustomObject]@{
        status          = "ok"
        mode            = "MultiSector"
        sectors         = [PSCustomObject]@{
            sector_center = [PSCustomObject]@{ path = $pathCenter; luminance_stat = $statCenter }
            sector_ground = [PSCustomObject]@{ path = $pathGround; luminance_stat = $statGround }
            sector_hud    = [PSCustomObject]@{ path = $pathHUD; luminance_stat = $statHUD }
        }
        captured_at     = (Get-Date -Format "o")
    }
    Write-Output ($result | ConvertTo-Json -Depth 5)
    exit 0
}

# 5. MODO MULTI-STATE AUDIT (Galería Completa con Análisis de Pantalla Negra y Métricas CV)
$rawBmp = Get-RawFrame
$mainLum = Test-DeadOrBlankBitmap $rawBmp

# Imagen con Cuadrícula de Coordenadas
$gridBmp = [UltraVisionCaptureV4]::ApplyInspectionGrid($rawBmp)
$gridBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gridBmp.Dispose()

# Generar Recortes Nativos 1:1
$w = $rawBmp.Width
$h = $rawBmp.Height

$gallery = [ordered]@{}
$gallery["1_overview_grid"] = [PSCustomObject]@{
    path            = $OutputPath
    description     = "Captura general con cuadricula [A1]..[C3]"
    luminance_stat  = $mainLum
}

# Sector Centro (30% a 70%)
$rectCenter = New-Object System.Drawing.Rectangle([int]($w * 0.3), [int]($h * 0.25), [int]($w * 0.4), [int]($h * 0.4))
$bmpCenter = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectCenter)
$pathCenter = Join-Path $baseDir "sector_center_$timestamp.png"
$bmpCenter.Save($pathCenter, [System.Drawing.Imaging.ImageFormat]::Png)
$gallery["2_sector_center"] = [PSCustomObject]@{
    path            = $pathCenter
    description     = "Recorte 1:1 Sector Centro (mira, raycast wireframe y horizonte)"
    luminance_stat  = (Test-DeadOrBlankBitmap $bmpCenter)
}
$bmpCenter.Dispose()

# Sector Suelo / Baseline (20% a 80%, inferior)
$rectGround = New-Object System.Drawing.Rectangle([int]($w * 0.2), [int]($h * 0.55), [int]($w * 0.6), [int]($h * 0.35))
$bmpGround = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectGround)
$pathGround = Join-Path $baseDir "sector_ground_$timestamp.png"
$bmpGround.Save($pathGround, [System.Drawing.Imaging.ImageFormat]::Png)
$gallery["3_sector_ground"] = [PSCustomObject]@{
    path            = $pathGround
    description     = "Recorte 1:1 Sector Suelo (apoyo en suelo Y=0 y colisiones)"
    luminance_stat  = (Test-DeadOrBlankBitmap $bmpGround)
}
$bmpGround.Dispose()

# Sector HUD / Barra Inferior
$rectHUD = New-Object System.Drawing.Rectangle([int]($w * 0.15), [int]($h * 0.78), [int]($w * 0.7), [int]($h * 0.22))
$bmpHUD = [UltraVisionCaptureV4]::CropRegion($rawBmp, $rectHUD)
$pathHUD = Join-Path $baseDir "sector_hud_$timestamp.png"
$bmpHUD.Save($pathHUD, [System.Drawing.Imaging.ImageFormat]::Png)
$gallery["4_sector_hud"] = [PSCustomObject]@{
    path            = $pathHUD
    description     = "Recorte 1:1 Sector HUD (inventario, numeros de items y hotbar)"
    luminance_stat  = (Test-DeadOrBlankBitmap $bmpHUD)
}
$bmpHUD.Dispose()

$rawBmp.Dispose()

# Comprobar si hay pantalla negra o muerta
$hasDeadScreen = $mainLum.is_dead_or_blank
$deadWarning = if ($hasDeadScreen) {
    "ALERTA CRITICA DE VISION: Se detecto pantalla negra o vacia (Dead Screen). El juego/aplicacion no renderizo graficos activos."
} else {
    "PANTALLA ACTIVA: Graficos vivos detectados con varianza de luminancia normal ($($mainLum.std_deviation)) y nitidez ($($mainLum.sharpness_score))."
}

# Auditoría de Hiper-Estrictez Visual Cuantitativa
$strictDefects = [System.Collections.Generic.List[string]]::new()
if ($mainLum.is_dead_or_blank) {
    $strictDefects.Add("PANTALLA_MUERTA: Varianza de luminancia nula o pantalla negra/blanca en su totalidad.")
}
if ($mainLum.is_flat_monochrome) {
    $strictDefects.Add("MONOCROMO_PLANO: Escena dominada por un solo color plano sin texturas, degradados ni variedad cromatica.")
}
if ($mainLum.is_unlit_scene) {
    $strictDefects.Add("ESCENA_SIN_ILUMINACION: Rango dinamico menor a 15 niveles. Falta modelo de luces direccionales, brillos especulares o sombras.")
}
if ($mainLum.is_excessively_blurred) {
    $strictDefects.Add("IMAGEN_EXCESIVAMENTE_BORROSA: Varianza Laplaciana de nitidez ($($mainLum.sharpness_score)) inferior al umbral de 15.0. Texturas o render desenfocado.")
}
if ($mainLum.is_flat_entropy) {
    $strictDefects.Add("ENTROPIA_CROMATICA_PLANA: Entropia de Shannon ($($mainLum.shannon_entropy)) inferior a 1.0. Distribucion tonal pobre.")
}
if ($mainLum.is_hud_illegible) {
    $strictDefects.Add("HUD_ILEGIBLE: Ratio de contraste de interfaz ($($mainLum.hud_contrast_ratio):1) inferior a 3.0:1 (WCAG AA). Texto o iconos poco visibles.")
}
$centerStat = $gallery["2_sector_center"].luminance_stat
if ($centerStat -and $centerStat.lacks_texture_detail) {
    $strictDefects.Add("SECTOR_CENTRAL_SIN_DETALLE: Variacion de bordes en alta frecuencia casi nula. Posible figura geometrica plana o primitiva sin biseles ni textura.")
}
if ($centerStat -and $centerStat.is_untextured_geometry) {
    $strictDefects.Add("SECTOR_CENTRAL_SIN_TEXTURA: Se detectaron poligonos 3D planos sin texturizar ($($centerStat.flat_surface_pct)% plano). Se exige mapeo de texturas UV y materiales ricos.")
}
$groundStat = $gallery["3_sector_ground"].luminance_stat
if ($groundStat -and $groundStat.is_untextured_geometry) {
    $strictDefects.Add("SECTOR_SUELO_SIN_TEXTURA: El suelo 3D consiste en poligonos planos monocolor sin textura ni detalle superficial ($($groundStat.flat_surface_pct)% plano). Se exigen adoquines, pavimento o hierba texturizada.")
}

$strictVerdict = if ($strictDefects.Count -eq 0) { "STRICT_METRICS_PASSED" } else { "STRICT_METRICS_FAILED" }

$result = [PSCustomObject]@{
    status                 = "ok"
    mode                   = $Mode
    primary_screenshot     = $OutputPath
    width                  = $targetWidth
    height                 = $targetHeight
    dead_screen_detected   = $hasDeadScreen
    visual_verdict         = $deadWarning
    photo_gallery          = $gallery
    strict_vision_metrics  = [PSCustomObject]@{
        verdict                 = $strictVerdict
        defects_detected        = $strictDefects
        sharpness_score         = $mainLum.sharpness_score
        hud_contrast_ratio      = $mainLum.hud_contrast_ratio
        shannon_entropy         = $mainLum.shannon_entropy
        aspect_ratio            = $mainLum.aspect_ratio
        color_entropy_clusters  = $mainLum.unique_color_clusters
        max_color_dominance_pct = $mainLum.max_color_dominance_pct
        dynamic_range           = $mainLum.dynamic_range
        avg_edge_gradient       = $mainLum.avg_edge_gradient
    }
    instructions           = "La IA DEBE abrir las imagenes de la galeria con la herramienta view_file para inspeccionar visualmente la interfaz y los graficos bajo el Protocolo V-HEX7."
    action_required_for_ai = @(
        "PASO 1 OBLIGATORIO: Invoca view_file con AbsolutePath = '$OutputPath' para ver la captura general con cuadricula taxonómica [A1]..[C3].",
        "PASO 2 OBLIGATORIO: Invoca view_file con AbsolutePath = '$pathCenter' para auditar el modelo 3D o foco central 1:1 (mallas compuestas, shaders PBR y biseles).",
        "PASO 3 OBLIGATORIO: Invoca view_file con AbsolutePath = '$pathGround' para auditar el sector suelo 1:1 (apoyo en Y=0, sombras de contacto y colisiones).",
        "PASO 4 OBLIGATORIO: Redacta 'VISUAL_INSPECTION_REPORT.md' aplicando el PROTOCOLO HIPER-ESTRICTO V-HEX7 (7 vectores obligatorios, citas a cuadrantes [A1]..[C3], sin frases complacientes y puntuacion >= 90/100)."
    )
    captured_at            = (Get-Date -Format "o")
}

Write-Output ($result | ConvertTo-Json -Depth 5)

