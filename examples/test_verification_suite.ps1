<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v2.1
.DESCRIPTION
    Ejecuta una batería completa de 12 pruebas automatizadas sobre todos los componentes
    de UltraGoal Engine (State Machine, Rubric Gate, Performance Scanner, MultiSector Vision, Visual Differencing).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS INTEGRATION TEST SUITE v2.1 " -ForegroundColor Cyan
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

# --- TEST 1: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 1] Evaluando Milestone Tracker State Machine..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"

& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Unit Test Goal" -Milestones "M1;M2" | Out-Null
Assert-Test -TestName "Tracker Init" -Condition (Test-Path $stateFile)

& "$scriptsDir\milestone_tracker.ps1" -Action submit -StateFilePath $stateFile -MilestoneIndex 1 -Notes "Trabajo listo" | Out-Null
$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Submit Status" -Condition ($state.milestones[0].status -eq "SUBMITTED_FOR_AUDIT")

# Rechazo deliberado
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 1 -Score 85 -Verdict "REJECTED" -Notes "Bajo puntaje" | Out-Null
$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Audit Rejection" -Condition ($state.milestones[0].status -eq "REJECTED")

# Aprobacion hito 1
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 1 -Score 98 -Verdict "APPROVED" -Notes "Excelente" | Out-Null
$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Audit Approval" -Condition ($state.milestones[0].status -eq "APPROVED")

# Aprobacion hito 2
& "$scriptsDir\milestone_tracker.ps1" -Action submit -StateFilePath $stateFile -MilestoneIndex 2 -Notes "Hito final" | Out-Null
& "$scriptsDir\milestone_tracker.ps1" -Action audit -StateFilePath $stateFile -MilestoneIndex 2 -Score 100 -Verdict "APPROVED" -Notes "Impecable" | Out-Null

# Completitud
& "$scriptsDir\milestone_tracker.ps1" -Action complete -StateFilePath $stateFile | Out-Null
$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Final Completion" -Condition ($state.status -eq "COMPLETED" -and -not [string]::IsNullOrWhiteSpace($state.completed_at))

# --- TEST 2: Rubric Quality & Performance Gate ---
Write-Host "`n[Test 2] Evaluando Rubric Quality & Performance Gate..." -ForegroundColor Yellow
$codeDir = Join-Path $tempDir "sample_code"
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null

# Codigo con fugas de rendimiento en render loop
$perfBadCode = @"
function animate() {
    requestAnimationFrame(animate);
    const tmpVec = new THREE.Vector3();
}
"@
Set-Content (Join-Path $codeDir "render_bad.js") -Value $perfBadCode
Set-Content (Join-Path $codeDir "render.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$rubricOutputPerf = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Detects Render Allocation Bottleneck" -Condition ($rubricOutputPerf.verdict -eq "REJECTED" -and $rubricOutputPerf.violations_count -gt 0)

# Codigo limpio
Remove-Item (Join-Path $codeDir "render_bad.js") -Force
$cleanCode = @"
const sharedVec = new THREE.Vector3();
function animate(dt) {
    requestAnimationFrame(animate);
    sharedVec.set(0, 1, 0);
}
"@
Set-Content (Join-Path $codeDir "render_clean.js") -Value $cleanCode

$rubricOutputGood = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Clean Modular Code" -Condition ($rubricOutputGood.verdict -eq "APPROVED" -and $rubricOutputGood.score -ge 95)

# --- TEST 3: MultiSector Vision Engine ---
Write-Host "`n[Test 3] Evaluando MultiSector Vision Engine..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "full_capture.png"
$multiOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath -Mode "MultiSector" | ConvertFrom-Json
Assert-Test -TestName "MultiSector Full Image Generated" -Condition (Test-Path $capPath)
Assert-Test -TestName "Ground Sector 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.ground_baseline)
Assert-Test -TestName "Center Focus 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.center_focus)
Assert-Test -TestName "HUD Inventory 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.hud_inventory)

# --- TEST 4: Visual Differencing & State Tracking ---
Write-Host "`n[Test 4] Evaluando Visual Differencing Engine (compare_visuals)..." -ForegroundColor Yellow
$img1 = Join-Path $tempDir "state1.png"
$img2 = Join-Path $tempDir "state2.png"
$diffOut = Join-Path $tempDir "diff_out.png"

Add-Type -AssemblyName System.Drawing
$b1 = New-Object System.Drawing.Bitmap 400, 300
$g1 = [System.Drawing.Graphics]::FromImage($b1)
$g1.Clear([System.Drawing.Color]::Black)
$g1.FillRectangle([System.Drawing.Brushes]::Red, 20, 20, 50, 50)
$b1.Save($img1)

$b2 = New-Object System.Drawing.Bitmap 400, 300
$g2 = [System.Drawing.Graphics]::FromImage($b2)
$g2.Clear([System.Drawing.Color]::Black)
# Rectangulo movido a otra posicion (simulando arrastre de item en inventario)
$g2.FillRectangle([System.Drawing.Brushes]::Red, 200, 150, 50, 50)
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