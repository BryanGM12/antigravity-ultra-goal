<#
.SYNOPSIS
    UltraGoal Vision Capture Engine (GDI Ultra-Resilient)
.DESCRIPTION
    Motor de captura de pantalla e inspección visual de alta fidelidad para agentes Gemini en Antigravity.
    Utiliza Win32 GDI nativo (BitBlt + PrintWindow) para evitar excepciones de 'CopyFromScreen' en
    sesiones desacopladas o de fondo.
.PARAMETER OutputPath
    Ruta donde guardar la captura en formato PNG.
.PARAMETER ConversationId
    ID de la conversación de Antigravity. Si se especifica, ubica la imagen en el directorio brain/scratch.
.PARAMETER ProcessName
    Nombre del proceso de la ventana específica a capturar (ej. "chrome", "Code", "msedge").
.PARAMETER DelaySeconds
    Segundos de espera antes de la captura.
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
    [int]$DelaySeconds = 0
)

$ErrorActionPreference = "Stop"

try {
    Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

public class UltraVisionCapture {
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

        bool pwSuccess = PrintWindow(hWnd, hMemDC, 2); // PW_RENDERFULLCONTENT
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
}
"@ -ReferencedAssemblies System.Drawing -ErrorAction SilentlyContinue

    if ($DelaySeconds -gt 0) {
        Start-Sleep -Seconds $DelaySeconds
    }

    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        if (-not [string]::IsNullOrWhiteSpace($ConversationId)) {
            $brainDir = "C:\Users\Administrator\.gemini\antigravity\brain\$ConversationId\scratch"
            if (-not (Test-Path $brainDir)) {
                New-Item -ItemType Directory -Path $brainDir -Force | Out-Null
            }
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $OutputPath = Join-Path $brainDir "vision_capture_$timestamp.png"
        } else {
            $OutputPath = Join-Path $env:TEMP "ag_vision_latest.png"
        }
    } else {
        $parent = Split-Path $OutputPath -Parent
        if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    $targetName = "Desktop"
    $bmp = $null

    if (-not [string]::IsNullOrWhiteSpace($ProcessName)) {
        $proc = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        if ($proc) {
            [UltraVisionCapture]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
            Start-Sleep -Milliseconds 300
            $bmp = [UltraVisionCapture]::CaptureWindow($proc.MainWindowHandle)
            $targetName = "Process:$ProcessName"
        }
    }

    if ($null -eq $bmp) {
        $bmp = [UltraVisionCapture]::CaptureDesktop()
        $targetName = "Primary_Screen"
    }

    $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $w = $bmp.Width
    $h = $bmp.Height
    $bmp.Dispose()

    $fileSize = (Get-Item $OutputPath).Length

    $outputObj = [PSCustomObject]@{
        status      = "ok"
        path        = $OutputPath
        width       = $w
        height      = $h
        size_bytes  = $fileSize
        target      = $targetName
        captured_at = (Get-Date -Format "o")
    }

    $json = $outputObj | ConvertTo-Json -Compress
    Write-Output $json
} catch {
    $errObj = [PSCustomObject]@{
        status  = "error"
        message = $_.Exception.Message
    }
    Write-Output ($errObj | ConvertTo-Json -Compress)
    exit 1
}