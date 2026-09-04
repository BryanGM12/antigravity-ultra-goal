<#
.SYNOPSIS
    UltraGoal Multi-Frame Visual Differencing Engine (compare_visuals.ps1)
.DESCRIPTION
    Compara dos fotogramas secuenciales para auditar interacciones dinámicas en tiempo real:
    - Arrastre y seguimiento de objetos (drag-and-drop en inventarios, cursores).
    - Colocación y destrucción de bloques o entidades (verificación de delta visual en terreno).
    - Transición de estados de UI (apertura de modales, cambio de pestañas, hover).
    Genera un mapa de calor diferencial (diff heatmap) con resaltado magenta de alta visibilidad
    y calcula el porcentaje exacto de cambio de píxeles y el bounding box de la interacción.
.PARAMETER ImageA
    Ruta a la imagen inicial (antes de la interacción).
.PARAMETER ImageB
    Ruta a la imagen posterior (después de la interacción).
.PARAMETER OutputPath
    Ruta para guardar el mapa de calor diferencial.
.PARAMETER Tolerance
    Tolerancia RGB (0 a 255) para ignorar ruido de compresión (por defecto: 25).
.PARAMETER MinExpectedDelta
    Porcentaje mínimo esperado de cambio. Si el cambio es inferior, se declara congelamiento.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ImageA,

    [Parameter(Mandatory = $true)]
    [string]$ImageB,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory = $false)]
    [int]$Tolerance = 25,

    [Parameter(Mandatory = $false)]
    [double]$MinExpectedDelta = 0.05
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ImageA)) {
    Write-Error "ImageA path '$ImageA' does not exist."
    exit 1
}
if (-not (Test-Path $ImageB)) {
    Write-Error "ImageB path '$ImageB' does not exist."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path $ImageB -Parent
    if ([string]::IsNullOrWhiteSpace($parent)) { $parent = $env:TEMP }
    $OutputPath = Join-Path $parent "diff_heatmap_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
}

try {
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing.Common -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing.Primitives -ErrorAction SilentlyContinue
    $refAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.Location } | Select-Object -ExpandProperty Location)
    Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class UltraImageDiff {
    public static string AnalyzeDiff(string pathA, string pathB, string outDiffPath, int tolerance, double minDelta) {
        using (Bitmap bmpA = new Bitmap(pathA))
        using (Bitmap bmpB = new Bitmap(pathB)) {
            int w = Math.Min(bmpA.Width, bmpB.Width);
            int h = Math.Min(bmpA.Height, bmpB.Height);
            int diffPixels = 0;
            long totalPixels = (long)w * h;

            int minX = w, minY = h, maxX = 0, maxY = 0;

            Bitmap diffBmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);

            BitmapData dataA = bmpA.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData dataB = bmpB.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData dataDiff = diffBmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

            int byteCount = dataA.Stride * h;
            byte[] bytesA = new byte[byteCount];
            byte[] bytesB = new byte[byteCount];
            byte[] bytesDiff = new byte[byteCount];

            Marshal.Copy(dataA.Scan0, bytesA, 0, byteCount);
            Marshal.Copy(dataB.Scan0, bytesB, 0, byteCount);

            for (int y = 0; y < h; y++) {
                int rowOffset = y * dataA.Stride;
                for (int x = 0; x < w; x++) {
                    int i = rowOffset + (x * 4);

                    int bA = bytesA[i];
                    int gA = bytesA[i + 1];
                    int rA = bytesA[i + 2];

                    int bB = bytesB[i];
                    int gB = bytesB[i + 1];
                    int rB = bytesB[i + 2];

                    int delta = Math.Abs(rA - rB) + Math.Abs(gA - gB) + Math.Abs(bA - bB);

                    if (delta > tolerance) {
                        diffPixels++;
                        if (x < minX) minX = x;
                        if (x > maxX) maxX = x;
                        if (y < minY) minY = y;
                        if (y > maxY) maxY = y;

                        // Resaltado fucsia/magenta ultra-visible
                        bytesDiff[i] = 255;     // B
                        bytesDiff[i + 1] = 0;   // G
                        bytesDiff[i + 2] = 255; // R
                        bytesDiff[i + 3] = 255; // A
                    } else {
                        // Atenuado en escala de grises para dar contexto espacial
                        byte gray = (byte)((rA * 0.3 + gA * 0.59 + bA * 0.11) * 0.25);
                        bytesDiff[i] = gray;
                        bytesDiff[i + 1] = gray;
                        bytesDiff[i + 2] = gray;
                        bytesDiff[i + 3] = 255;
                    }
                }
            }

            Marshal.Copy(bytesDiff, 0, dataDiff.Scan0, byteCount);

            bmpA.UnlockBits(dataA);
            bmpB.UnlockBits(dataB);
            diffBmp.UnlockBits(dataDiff);

            // Si se detectaron cambios, dibujar caja delimitadora (Bounding Box) amarilla
            if (diffPixels > 0 && maxX >= minX && maxY >= minY) {
                using (Graphics g = Graphics.FromImage(diffBmp)) {
                    using (Pen boxPen = new Pen(Color.Yellow, 3))
                    using (Font f = new Font("Arial", 11, FontStyle.Bold))
                    using (Brush textBrush = new SolidBrush(Color.Black))
                    using (Brush bgBrush = new SolidBrush(Color.Yellow)) {
                        int boxW = Math.Max(20, maxX - minX);
                        int boxH = Math.Max(20, maxY - minY);
                        g.DrawRectangle(boxPen, minX, minY, boxW, boxH);

                        string tag = string.Format("[Delta Zone: {0}px]", diffPixels);
                        SizeF sz = g.MeasureString(tag, f);
                        g.FillRectangle(bgBrush, minX, Math.Max(0, minY - 20), sz.Width, sz.Height);
                        g.DrawString(tag, f, textBrush, minX, Math.Max(0, minY - 20));
                    }
                }
            }

            diffBmp.Save(outDiffPath, ImageFormat.Png);
            diffBmp.Dispose();

            double pct = (double)diffPixels / totalPixels * 100.0;
            string verdict = (pct >= minDelta) ? "STATE_CHANGED" : "FROZEN_OR_NO_CHANGE";

            int finalW = (diffPixels > 0) ? (maxX - minX) : 0;
            int finalH = (diffPixels > 0) ? (maxY - minY) : 0;
            int finalX = (diffPixels > 0) ? minX : 0;
            int finalY = (diffPixels > 0) ? minY : 0;

            return string.Format(
                "{{\"verdict\":\"{0}\",\"diff_pixels\":{1},\"total_pixels\":{2},\"delta_percent\":{3:F3},\"min_expected_delta\":{4:F3},\"bbox\":{{\"x\":{5},\"y\":{6},\"width\":{7},\"height\":{8}}},\"diff_image\":\"{9}\"}}",
                verdict, diffPixels, totalPixels, pct, minDelta, finalX, finalY, finalW, finalH, outDiffPath.Replace("\\", "\\\\")
            );
        }
    }
}
"@ -ReferencedAssemblies $refAssemblies -ErrorAction SilentlyContinue

    $rawJson = [UltraImageDiff]::AnalyzeDiff($ImageA, $ImageB, $OutputPath, $Tolerance, $MinExpectedDelta)
    $obj = $rawJson | ConvertFrom-Json

    $instructionNote = if ($obj.verdict -eq "STATE_CHANGED") {
        "Interacción detectada exitosamente. Inspecciona '$OutputPath' con view_file para confirmar que el objeto se movió a las coordenadas deseadas y no quedó huérfano."
    } else {
        "FALLO CRÍTICO: No se detectó cambio visual suficiente ($($obj.delta_percent)% < $($obj.min_expected_delta)%). La pantalla parece congelada o la acción no tuvo efecto en la interfaz."
    }

    $obj | Add-Member -NotePropertyName "guidance" -NotePropertyValue $instructionNote -Force
    Write-Output ($obj | ConvertTo-Json -Depth 5)
} catch {
    $errObj = [PSCustomObject]@{
        status  = "error"
        message = $_.Exception.Message
    }
    Write-Output ($errObj | ConvertTo-Json -Compress)
    exit 1
}