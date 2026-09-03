<#
.SYNOPSIS
    UltraGoal Vision Capture Engine v2.1 (Multi-Sector & Burst Inspection)
.DESCRIPTION
    Motor de captura e inspección visual de alta fidelidad para agentes Gemini en Antigravity.
    Incluye:
    - Captura GDI nativa ultra-resiliente (pantalla completa o ventana por proceso).
    - Modo GridOverlay: Inscribe cuadrícula de coordenadas [A1]..[C3] para ubicar sectores exactos.
    - Modo MultiSector: Extrae recortes 1:1 sin reescalado (Ground/Baseline, Viewport Center, HUD/Inventory)
      para que la IA detecte bloques invisibles, costuras y detalles minúsculos.
    - Modo Burst: Ráfaga secuencial de N fotogramas para auditar animaciones, seguimiento de cursor
      e interacción en tiempo real (drag-and-drop).
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
    [ValidateSet("Full", "GridOverlay", "MultiSector", "Burst")]
    [string]$Mode = "Full",

    [Parameter(Mandatory = $false)]
    [switch]$GenerateSectors,

    [Parameter(Mandatory = $false)]
    [int]$BurstCount = 3,

    [Parameter(Mandatory = $false)]
    [int]$BurstIntervalMs = 300
)

$ErrorActionPreference = "Stop"

try {
    Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class UltraVisionCaptureV2 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetDesktopWindow();
    [DllImport("user32.dll")]
    public static extern IntPtr GetWindowDC(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern IntPtr ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int nIndex);

    [DllImport("gdi32.dll")]
    public static extern bool BitBlt(IntPtr hObject, int nXDest, int nYDest, int nWidth, int nHeight, IntPtr hObjectSource, int nXSrc, int nYSrc, int dwRop);
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateCompatibleBitmap(IntPtr hDC, int nWidth, int nHeight);
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateCompatibleDC(IntPtr hDC);
    [DllImport("gdi32.dll")]
    public static extern bool DeleteDC(IntPtr hDC);
    [DllImport("gdi32.dll")]
    public static extern bool DeleteObject(IntPtr hObject);
    [DllImport("gdi32.dll")]
    public static extern IntPtr SelectObject(IntPtr hDC, IntPtr hObject);

    public const int SRCCOPY = 0x00CC0020;
    public const int SM_CXSCREEN = 0;
    public const int SM_CYSCREEN = 1;

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    public static Bitmap CaptureDesktop() {
        int width = GetSystemMetrics(SM_CXSCREEN);
        int height = GetSystemMetrics(SM_CYSCREEN);
        if (width <= 0) width = 1920;
        if (height <= 0) height = 1080;

        IntPtr hDesk = GetDesktopWindow();
        IntPtr hDC = GetWindowDC(hDesk);
        IntPtr hMemDC = CreateCompatibleDC(hDC);
        IntPtr hBitmap = CreateCompatibleBitmap(hDC, width, height);
        IntPtr hOld = SelectObject(hMemDC, hBitmap);

        BitBlt(hMemDC, 0, 0, width, height, hDC, 0, 0, SRCCOPY);

        SelectObject(hMemDC, hOld);
        DeleteDC(hMemDC);
        ReleaseDC(hDesk, hDC);

        Bitmap bmp = Image.FromHbitmap(hBitmap);
        DeleteObject(hBitmap);
        return bmp;
    }

    public static Bitmap CaptureWindow(IntPtr hWnd) {
        RECT rect;
        GetWindowRect(hWnd, out rect);
        int width = rect.Right - rect.Left;
        int height = rect.Bottom - rect.Top;
        if (width <= 0) width = 800;
        if (height <= 0) height = 600;

        IntPtr hDC = GetWindowDC(hWnd);
        IntPtr hMemDC = CreateCompatibleDC(hDC);
        IntPtr hBitmap = CreateCompatibleBitmap(hDC, width, height);
        IntPtr hOld = SelectObject(hMemDC, hBitmap);

        bool pwSuccess = PrintWindow(hWnd, hMemDC, 2);
        if (!pwSuccess) {
            BitBlt(hMemDC, 0, 0, width, height, hDC, 0, 0, SRCCOPY);
        }

        SelectObject(hMemDC, hOld);
        DeleteDC(hMemDC);
        ReleaseDC(hWnd, hDC);

        Bitmap bmp = Image.FromHbitmap(hBitmap);
        DeleteObject(hBitmap);
        return bmp;
    }

    public static Bitmap ApplyInspectionGrid(Bitmap source) {
        Bitmap output = new Bitmap(source);
        using (Graphics g = Graphics.FromImage(output)) {
            int w = output.Width;
            int h = output.Height;
            int colW = w / 3;
            int rowH = h / 3;

            using (Pen pen = new Pen(Color.FromArgb(140, 0, 240, 255), 2))
            using (Font font = new Font("Arial", Math.Max(12, h / 45), FontStyle.Bold))
            using (Brush textBrush = new SolidBrush(Color.FromArgb(255, 255, 230, 0)))
            using (Brush bgBrush = new SolidBrush(Color.FromArgb(150, 0, 0, 0))) {
                // Vertical lines
                g.DrawLine(pen, colW, 0, colW, h);
                g.DrawLine(pen, colW * 2, 0, colW * 2, h);

                // Horizontal lines
                g.DrawLine(pen, 0, rowH, w, rowH);
                g.DrawLine(pen, 0, rowH * 2, w, rowH * 2);

                string[] labels = new string[] {
                    "[A1: Top-Left]",   "[A2: Top-Center / Sky]",      "[A3: Top-Right]",
                    "[B1: Mid-Left]",   "[B2: Viewport / Raycast Focus]", "[B3: Mid-Right]",
                    "[C1: Bottom-Left]","[C2: Ground / Baseline Voxels]","[C3: Bottom-Right / HUD]"
                };

                for (int r = 0; r < 3; r++) {
                    for (int c = 0; c < 3; c++) {
                        string lbl = labels[r * 3 + c];
                        int x = c * colW + 12;
                        int y = r * rowH + 12;
                        SizeF size = g.MeasureString(lbl, font);
                        g.FillRectangle(bgBrush, x - 2, y - 2, size.Width + 4, size.Height + 4);
                        g.DrawString(lbl, font, textBrush, x, y);
                    }
                }
            }
        }
        return output;
    }

    public static Bitmap CropRegion(Bitmap source, Rectangle rect) {
        int x = Math.Max(0, rect.X);
        int y = Math.Max(0, rect.Y);
        int w = Math.Min(rect.Width, source.Width - x);
        int h = Math.Min(rect.Height, source.Height - y);

        Bitmap crop = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(crop)) {
            g.DrawImage(source, new Rectangle(0, 0, w, h), new Rectangle(x, y, w, h), GraphicsUnit.Pixel);
        }
        return crop;
    }
}
"@ -ReferencedAssemblies System.Drawing -ErrorAction SilentlyContinue

    if ($DelaySeconds -gt 0) {
        Start-Sleep -Seconds $DelaySeconds
    }

    # Directorio base de salida
    $baseDir = ""
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $baseDir = Split-Path $OutputPath -Parent
        if ([string]::IsNullOrWhiteSpace($baseDir)) { $baseDir = "." }
    } elseif (-not [string]::IsNullOrWhiteSpace($ConversationId)) {
        $baseDir = "C:\Users\Administrator\.gemini\antigravity\brain\$ConversationId\scratch"
    } else {
        $baseDir = $env:TEMP
    }

    if (-not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $OutputPath = Join-Path $baseDir "vision_capture_$timestamp.png"
    }

    # Funcion interna para capturar un frame
    function Get-RawFrame {
        $targetProc = $null
        if (-not [string]::IsNullOrWhiteSpace($ProcessName)) {
            $targetProc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        }

        if ($targetProc) {
            [UltraVisionCaptureV2]::SetForegroundWindow($targetProc.MainWindowHandle) | Out-Null
            Start-Sleep -Milliseconds 200
            return [UltraVisionCaptureV2]::CaptureWindow($targetProc.MainWindowHandle)
        } else {
            return [UltraVisionCaptureV2]::CaptureDesktop()
        }
    }

    # MODO BURST: Ráfaga de N frames para auditar dinamismo e interacción
    if ($Mode -eq "Burst") {
        $burstFrames = @()
        for ($i = 1; $i -le $BurstCount; $i++) {
            $bmp = Get-RawFrame
            $framePath = Join-Path $baseDir "burst_frame_${i}_$timestamp.png"
            $bmp.Save($framePath, [System.Drawing.Imaging.ImageFormat]::Png)
            $burstFrames += [PSCustomObject]@{
                index      = $i
                path       = $framePath
                timestamp  = (Get-Date -Format "o")
                size_bytes = (Get-Item $framePath).Length
            }
            $bmp.Dispose()
            if ($i -lt $BurstCount) {
                Start-Sleep -Milliseconds $BurstIntervalMs
            }
        }

        $result = [PSCustomObject]@{
            status       = "ok"
            mode         = "Burst"
            frame_count  = $BurstCount
            interval_ms  = $BurstIntervalMs
            frames       = $burstFrames
            summary      = "Ráfaga de $BurstCount fotogramas capturada para auditoría dinámica y seguimiento de cursor/movimiento."
        }
        Write-Output ($result | ConvertTo-Json -Depth 5)
        exit 0
    }

    # CAPTURA PRINCIPAL
    $rawBmp = Get-RawFrame

    # Si se pide GridOverlay o MultiSector, aplicar la cuadrícula sobre la imagen base
    $mainSaveBmp = $rawBmp
    if ($Mode -eq "GridOverlay" -or $Mode -eq "MultiSector") {
        $mainSaveBmp = [UltraVisionCaptureV2]::ApplyInspectionGrid($rawBmp)
    }

    $mainSaveBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # GENERAR RECORTES DE SECTOR EN ALTA RESOLUCIÓN (1:1 Native Crops)
    $sectorFiles = [ordered]@{}
    if ($Mode -eq "MultiSector" -or $GenerateSectors) {
        $w = $rawBmp.Width
        $h = $rawBmp.Height

        # 1. Sector Central (Viewport & Crosshair Focus) - 40% central
        $rectCenter = New-Object System.Drawing.Rectangle([int]($w * 0.3), [int]($h * 0.25), [int]($w * 0.4), [int]($h * 0.4))
        $bmpCenter = [UltraVisionCaptureV2]::CropRegion($rawBmp, $rectCenter)
        $pathCenter = Join-Path $baseDir "sector_center_$timestamp.png"
        $bmpCenter.Save($pathCenter, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmpCenter.Dispose()
        $sectorFiles["center_focus"] = $pathCenter

        # 2. Sector Suelo/Ground Baseline (Donde descansan bloques, entidades y colisiones) - 40% inferior central
        $rectGround = New-Object System.Drawing.Rectangle([int]($w * 0.2), [int]($h * 0.55), [int]($w * 0.6), [int]($h * 0.35))
        $bmpGround = [UltraVisionCaptureV2]::CropRegion($rawBmp, $rectGround)
        $pathGround = Join-Path $baseDir "sector_ground_$timestamp.png"
        $bmpGround.Save($pathGround, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmpGround.Dispose()
        $sectorFiles["ground_baseline"] = $pathGround

        # 3. Sector HUD / Inventario / Barra de Acciones (Bottom 20%)
        $rectHUD = New-Object System.Drawing.Rectangle([int]($w * 0.15), [int]($h * 0.78), [int]($w * 0.7), [int]($h * 0.22))
        $bmpHUD = [UltraVisionCaptureV2]::CropRegion($rawBmp, $rectHUD)
        $pathHUD = Join-Path $baseDir "sector_hud_$timestamp.png"
        $bmpHUD.Save($pathHUD, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmpHUD.Dispose()
        $sectorFiles["hud_inventory"] = $pathHUD
    }

    $wFinal = $rawBmp.Width
    $hFinal = $rawBmp.Height

    if ($mainSaveBmp -ne $rawBmp) { $mainSaveBmp.Dispose() }
    $rawBmp.Dispose()

    $fileSize = (Get-Item $OutputPath).Length

    $result = [PSCustomObject]@{
        status        = "ok"
        mode          = $Mode
        path          = $OutputPath
        width         = $wFinal
        height        = $hFinal
        size_bytes    = $fileSize
        captured_at   = (Get-Date -Format "o")
        sector_crops  = $sectorFiles
        instructions  = "Inspecciona 'sector_ground' para verificar que las superficies toquen el suelo; 'sector_center' para raycast/mallas; y 'sector_hud' para inventario e iconos."
    }

    Write-Output ($result | ConvertTo-Json -Depth 5)
} catch {
    $errObj = [PSCustomObject]@{
        status  = "error"
        message = $_.Exception.Message
    }
    Write-Output ($errObj | ConvertTo-Json -Compress)
    exit 1
}