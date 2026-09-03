<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite
.DESCRIPTION
    Ejecuta una batería completa de pruebas unitarias y de integración sobre los componentes
    de UltraGoal (Vision Capture, Rubric Evaluator, Milestone State Machine).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS INTEGRATION TEST SUITE       " -ForegroundColor Cyan
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

# --- TEST 2: Rubric Quality Gate ---
Write-Host "`n[Test 2] Evaluando Rubric Quality Gate..." -ForegroundColor Yellow
$codeDir = Join-Path $tempDir "sample_code"
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null

# Codigo deficiente
$badCode = @"
def dirty_func():
    # TODO: arreglar esto
    try:
        x = 1
    except:
        pass
"@
Set-Content (Join-Path $codeDir "bad.py") -Value $badCode

$rubricOutputBad = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Rejects Sloth Code" -Condition ($rubricOutputBad.verdict -eq "REJECTED" -and $rubricOutputBad.score -lt 95) -Detail "Score: $($rubricOutputBad.score)"

# Limpieza y codigo excelente
Remove-Item (Join-Path $codeDir "bad.py") -Force
$cleanCode = @"
def calculate_area(w: float, h: float) -> float:
    if w <= 0 or h <= 0:
        raise ValueError("Dimensions must be positive")
    return w * h
"@
$cleanTest = @"
from clean import calculate_area
import pytest

def test_area():
    assert calculate_area(5.0, 10.0) == 50.0
    assert calculate_area(1.0, 1.0) == 1.0
    assert calculate_area(2.5, 4.0) == 10.0
"@
Set-Content (Join-Path $codeDir "clean.py") -Value $cleanCode
Set-Content (Join-Path $codeDir "test_clean.py") -Value $cleanTest

$rubricOutputGood = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Clean Code" -Condition ($rubricOutputGood.verdict -eq "APPROVED" -and $rubricOutputGood.score -ge 95) -Detail "Score: $($rubricOutputGood.score)"

# --- TEST 3: GDI Vision Capture ---
Write-Host "`n[Test 3] Evaluando GDI Vision Capture Engine..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "test_cap.png"
$capOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath | ConvertFrom-Json
Assert-Test -TestName "Vision Capture File Created" -Condition (Test-Path $capPath)
Assert-Test -TestName "Vision Capture JSON Output" -Condition ($capOutput.status -eq "ok" -and $capOutput.size_bytes -gt 0)

# Limpieza
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   RESULTADOS: $passed PASADAS, $failed FALLIDAS" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }