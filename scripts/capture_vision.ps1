<#
.SYNOPSIS
    UltraGoal Vision Capture Engine v3.2 (Multi-State Audit & Dead-Screen Gate)
.DESCRIPTION
    Motor de captura e inspección visual de alta fidelidad para agentes Gemini en Antigravity.
    Incluye:
    - Captura GDI nativa ultra-resiliente (pantalla completa o ventana por proceso).
    - Modo MultiStateAudit: Genera una galería completa de fotos (General con cuadrícula, recortes 1:1 de Suelo, HUD y Centro)
      con análisis de varianza de luminancia para detectar de inmediato pantallas negras o vacías.
    - Modo GridOverlay: Inscribe cuadrícula de coordenadas [A1]..[C3] para ubicar sectores exactos.
    - Modo MultiSector: Extrae recortes 1:1 sin reescalado (Ground/Baseline, Viewport Center, HUD/Inventory).
    - Modo Burst: Ráfaga secuencial de N fotogramas para auditar animaciones en tiempo real.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory = $false)]
    [string]$ConversationId = "",

    [Parameter(Mandatory = $false)]
    [string]$ProcessName = "",

    [Parameter(Mandatory = $false)]
    [int]$DelaySeconds = 0,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Full", "GridOverlay", "MultiSector", "Burst", "MultiStateAudit")]
    [string]$Mode = "MultiStateAudit",

    [Parameter(Mandatory = $false)]
    [switch]$GenerateSectors,

    [Parameter(Mandatory = $false)]
    [int]$BurstCount = 3,

    [Parameter(Mandatory = $false)]
    [int]$BurstIntervalMs = 300
)

$ErrorActionPreference = "Stop"

try {
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing.Common -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing.Primitives -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $refAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.Location } | Select-Object -ExpandProperty Location)
    Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class UltraVisionCaptureV3 {
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

    public const int SRCCOPY = 0x00CC0020;

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
"@ -ReferencedAssemblies $refAssemblies
} catch {
    # El tipo ya puede estar cargado en la sesión
}

function Test-DeadOrBlankBitmap([System.Drawing.Bitmap]$bmp) {
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

    $sum = 0
    foreach ($s in $samples) { $sum += $s }
    $mean = if ($samples.Count -gt 0) { $sum / $samples.Count } else { 0 }
    
    $varSum = 0
    foreach ($s in $samples) { $varSum += [Math]::Pow($s - $mean, 2) }
    $stdDev = if ($samples.Count -gt 0) { [Math]::Sqrt($varSum / $samples.Count) } else { 0 }
    $blackPct = if ($samples.Count -gt 0) { ($blackCount / $samples.Count) * 100 } else { 0 }
    $whitePct = if ($samples.Count -gt 0) { ($whiteCount / $samples.Count) * 100 } else { 0 }

    $isDead = ($stdDev -lt 3.0) -or ($blackPct -gt 98.0) -or ($whitePct -gt 98.0)

    return [PSCustomObject]@{
        mean_luminance   = [Math]::Round($mean, 2)
        std_deviation    = [Math]::Round($stdDev, 2)
        black_percentage = [Math]::Round($blackPct, 1)
        white_percentage = [Math]::Round($whitePct, 1)
        is_dead_or_blank = $isDead
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

$targetHWnd = [IntPtr]::Zero
$targetWidth = 0
$targetHeight = 0

if (-not [string]::IsNullOrWhiteSpace($ProcessName)) {
    $proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } | Select-Object -First 1
    if ($proc) {
        $targetHWnd = $proc.MainWindowHandle
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
        public class WinPos {
            [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
        }
"@ -ErrorAction SilentlyContinue
        $rc = New-Object RECT
        [WinPos]::GetWindowRect($targetHWnd, [ref]$rc) | Out-Null
        $targetWidth = $rc.Right - $rc.Left
        $targetHeight = $rc.Bottom - $rc.Top
    }
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
        try {
            Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);' -Name "User32Metrics" -Namespace "Win32" -ErrorAction SilentlyContinue
            $targetWidth = [Win32.User32Metrics]::GetSystemMetrics(0)
            $targetHeight = [Win32.User32Metrics]::GetSystemMetrics(1)
        } catch {}
    }

    if ($targetWidth -le 0) { $targetWidth = 1920 }
    if ($targetHeight -le 0) { $targetHeight = 1080 }
}

function Get-RawFrame {
    if ($targetHWnd -ne [IntPtr]::Zero) {
        return [UltraVisionCaptureV3]::CaptureWindowGDI($targetHWnd, $targetWidth, $targetHeight)
    } else {
        return [UltraVisionCaptureV3]::CaptureDesktopGDI($targetWidth, $targetHeight)
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

# 2. MODO MULTI-STATE AUDIT (Galería Completa con Análisis de Pantalla Negra)
$rawBmp = Get-RawFrame
$mainLum = Test-DeadOrBlankBitmap $rawBmp

# Imagen con Cuadrícula de Coordenadas
$gridBmp = [UltraVisionCaptureV3]::ApplyInspectionGrid($rawBmp)
$gridBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$gridBmp.Dispose()

# Generar Recortes Nativos 1:1
$w = $rawBmp.Width
$h = $rawBmp.Height

$gallery = [ordered]@{}
$gallery["1_overview_grid"] = [PSCustomObject]@{
    path            = $OutputPath
    description     = "Captura general con cuadrícula [A1]..[C3]"
    luminance_stat  = $mainLum
}

# Sector Centro (30% a 70%)
$rectCenter = New-Object System.Drawing.Rectangle([int]($w * 0.3), [int]($h * 0.25), [int]($w * 0.4), [int]($h * 0.4))
$bmpCenter = [UltraVisionCaptureV3]::CropRegion($rawBmp, $rectCenter)
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
$bmpGround = [UltraVisionCaptureV3]::CropRegion($rawBmp, $rectGround)
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
$bmpHUD = [UltraVisionCaptureV3]::CropRegion($rawBmp, $rectHUD)
$pathHUD = Join-Path $baseDir "sector_hud_$timestamp.png"
$bmpHUD.Save($pathHUD, [System.Drawing.Imaging.ImageFormat]::Png)
$gallery["4_sector_hud"] = [PSCustomObject]@{
    path            = $pathHUD
    description     = "Recorte 1:1 Sector HUD (inventario, números de ítems y hotbar)"
    luminance_stat  = (Test-DeadOrBlankBitmap $bmpHUD)
}
$bmpHUD.Dispose()

$rawBmp.Dispose()

# Comprobar si hay pantalla negra o muerta
$hasDeadScreen = $mainLum.is_dead_or_blank
$deadWarning = if ($hasDeadScreen) {
    "ALERTA CRÍTICA DE VISIÓN: Se detectó pantalla negra o vacía (Dead Screen). El juego/aplicación no renderizó gráficos activos."
} else {
    "PANTALLA ACTIVA: Gráficos vivos detectados con varianza de luminancia normal ($($mainLum.std_deviation))."
}

$result = [PSCustomObject]@{
    status              = "ok"
    mode                = $Mode
    primary_screenshot  = $OutputPath
    width               = $targetWidth
    height              = $targetHeight
    dead_screen_detected= $hasDeadScreen
    visual_verdict      = $deadWarning
    photo_gallery       = $gallery
    instructions        = "El Auditor DEBE abrir cada imagen de la galería con view_file. Si dead_screen_detected es TRUE, la entrega debe ser vetada de inmediato."
    captured_at         = (Get-Date -Format "o")
}

Write-Output ($result | ConvertTo-Json -Depth 5)