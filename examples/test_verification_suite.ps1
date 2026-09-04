<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v3.2 (Live Boot & Multi-Photo Edition)
.DESCRIPTION
    Ejecuta una batería completa de 16 pruebas automatizadas sobre todos los componentes
    de UltraGoal Engine (Universal Planner, Live Boot Verifier, Multi-Photo Vision, Rubric Gate, Visual Diff).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS TEST SUITE v3.2 (LIVE BOOT) " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Assert-Test {
    param([string]$TestName, [bool]$Condition, [string]$Detail = "")
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $global:passed++
    } else {
        Write-Host "  [FAIL] $TestName - $Detail" -ForegroundColor Red
        $global:failed++
    }
}

# --- TEST 1: Universal Deep Domain Planner ---
Write-Host "`n[Test 1] Evaluando Universal Deep Domain Planner..." -ForegroundColor Yellow
$specFileWeb = Join-Path $tempDir "spec_web.json"
& "$scriptsDir\deep_planner.ps1" -GoalObjective "Crea un dashboard SaaS de facturacion con autenticacion y graficas" -OutputPath $specFileWeb | Out-Null
$specWeb = Get-Content $specFileWeb | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies Web/FullStack SaaS Domain" -Condition ($specWeb.detected_category -eq "Web_or_FullStack_Application")
Assert-Test -TestName "Planner Decomposes 7 Universal Tiers" -Condition ($specWeb.total_tiers -eq 7)

# --- TEST 2: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 2] Evaluando Milestone Tracker..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"
& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Universal SaaS Engine" -Milestones $specWeb.recommended_milestones | Out-Null
Assert-Test -TestName "Tracker Init with Universal Milestones" -Condition (Test-Path $stateFile)

# --- TEST 3: Live Runtime Boot Verifier & Dead Screen Gate ---
Write-Host "`n[Test 3] Evaluando Live Runtime Boot Verifier (Detección de Juego que no arranca)..." -ForegroundColor Yellow
$bootTestDir = Join-Path $tempDir "boot_test_case"
New-Item -ItemType Directory -Path $bootTestDir -Force | Out-Null

# Caso A: Código que no arranca (import fuera de módulo y pantalla negra)
$brokenGameHtml = "<html><body style='margin:0;background:black;'><script>import * as THREE from 'three';</script></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $brokenGameHtml
$bootResBroken = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Catches Broken Game Syntax" -Condition ($bootResBroken.verdict -eq "BOOT_FAILED" -and $bootResBroken.diagnostics.Count -gt 0)

# Caso B: Código que arranca y renderiza interfaz viva
$workingGameHtml = "<html><body style='margin:0;background:#5c94fc;'><h1>Minecraft Live Engine</h1><div style='height:200px;background:#557a2b;'></div></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $workingGameHtml
$bootResWorking = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Approves Running Game" -Condition ($bootResWorking.verdict -eq "BOOT_SUCCESS" -and -not $bootResWorking.luminance_stats.is_dead_or_blank)

# --- TEST 4: Rubric Universal Gate con LiveBootCheck ---
Write-Host "`n[Test 4] Evaluando Rubric Gate con LiveBootCheck..." -ForegroundColor Yellow
$codeDir = Join-Path $tempDir "sample_code"
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null

Set-Content (Join-Path $codeDir "index.html") -Value $brokenGameHtml
Set-Content (Join-Path $codeDir "game.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$rubricOutputBroken = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir -LiveBootCheck | ConvertFrom-Json
Assert-Test -TestName "Rubric Rejects App that Fails Live Boot" -Condition ($rubricOutputBroken.verdict -eq "REJECTED" -and $rubricOutputBroken.score -lt 95)

# --- TEST 5: Multi-State Audit Vision Engine (Galería de 4 Fotos) ---
Write-Host "`n[Test 5] Evaluando MultiStateAudit Vision Engine (Galería de Fotos)..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "overview_grid.png"
$auditOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath -Mode "MultiStateAudit" | ConvertFrom-Json
Assert-Test -TestName "MultiState Overview Grid Generated" -Condition (Test-Path $capPath)
Assert-Test -TestName "Ground Sector 1:1 Crop Generated" -Condition (Test-Path $auditOutput.photo_gallery."3_sector_ground".path)
Assert-Test -TestName "HUD Inventory 1:1 Crop Generated" -Condition (Test-Path $auditOutput.photo_gallery."4_sector_hud".path)
Assert-Test -TestName "Center Focus 1:1 Crop Generated" -Condition (Test-Path $auditOutput.photo_gallery."2_sector_center".path)
Assert-Test -TestName "Luminance Metric Computed on Photos" -Condition ($null -ne $auditOutput.photo_gallery."1_overview_grid".luminance_stat.std_deviation)

# --- TEST 6: Visual Differencing & State Tracking ---
Write-Host "`n[Test 6] Evaluando Visual Differencing Engine (compare_visuals)..." -ForegroundColor Yellow
$img1 = Join-Path $tempDir "state1.png"
$img2 = Join-Path $tempDir "state2.png"
$diffOut = Join-Path $tempDir "diff_out.png"

Add-Type -AssemblyName System.Drawing
$b1 = New-Object System.Drawing.Bitmap 400, 300
$g1 = [System.Drawing.Graphics]::FromImage($b1)
$g1.Clear([System.Drawing.Color]::Black)
$g1.FillRectangle([System.Drawing.Brushes]::Blue, 20, 20, 50, 50)
$b1.Save($img1)

$b2 = New-Object System.Drawing.Bitmap 400, 300
$g2 = [System.Drawing.Graphics]::FromImage($b2)
$g2.Clear([System.Drawing.Color]::Black)
$g2.FillRectangle([System.Drawing.Brushes]::Blue, 200, 150, 50, 50)
$b2.Save($img2)

$g1.Dispose(); $b1.Dispose(); $g2.Dispose(); $b2.Dispose()

$diffOutput = & "$scriptsDir\compare_visuals.ps1" -ImageA $img1 -ImageB $img2 -OutputPath $diffOut | ConvertFrom-Json
Assert-Test -TestName "Visual Diff State Change Detected" -Condition ($diffOutput.verdict -eq "STATE_CHANGED" -and $diffOutput.delta_percent -gt 0)
Assert-Test -TestName "Visual Diff Heatmap Image Created" -Condition (Test-Path $diffOut)

# Limpieza
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   RESULTADOS: $passed PASADAS, $failed FALLIDAS" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }