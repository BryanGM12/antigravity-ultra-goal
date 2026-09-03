<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v3.0 (Deep Architecture Edition)
.DESCRIPTION
    Ejecuta una batería completa de 15 pruebas automatizadas sobre todos los componentes
    de UltraGoal Engine (Deep Planner, Anti-Toy Rubric Gate, State Machine, MultiSector Vision, Visual Differencing).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS INTEGRATION TEST SUITE v3.0 " -ForegroundColor Cyan
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

# --- TEST 1: Deep Planner & Canonical Pillars ---
Write-Host "`n[Test 1] Evaluando Deep Domain Planner & Anti-Toy Pre-Mortem..." -ForegroundColor Yellow
$specFile = Join-Path $tempDir "spec_test.json"

& "$scriptsDir\deep_planner.ps1" -GoalObjective "has un clon de minecraft tal cual" -OutputPath $specFile | Out-Null
Assert-Test -TestName "Deep Planner Generates Spec File" -Condition (Test-Path $specFile)

$specObj = Get-Content $specFile | ConvertFrom-Json
Assert-Test -TestName "Deep Planner Detects Game Domain" -Condition ($specObj.category -eq "Interactive_Game")
Assert-Test -TestName "Deep Planner Decomposes 6 Pillars" -Condition ($specObj.canonical_pillars_count -eq 6)
Assert-Test -TestName "Deep Planner Formulates Anti-Toy Defenses" -Condition ($specObj.anti_toy_pre_mortem.Count -gt 0)

# --- TEST 2: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 2] Evaluando Milestone Tracker State Machine..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"

& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Minecraft Voxel Clone" -Milestones $specObj.recommended_milestones | Out-Null
Assert-Test -TestName "Tracker Init with Deep Milestones" -Condition (Test-Path $stateFile)

$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Has 7 Deep Milestones" -Condition ($state.total_milestones -ge 7)

# --- TEST 3: Rubric Anti-Toy Quality & Performance Gate ---
Write-Host "`n[Test 3] Evaluando Rubric Anti-Toy & Performance Gate..." -ForegroundColor Yellow
$codeDir = Join-Path $tempDir "sample_code"
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null

# Codigo tipo maqueta de juguete (sin menus, sin mobs, sin F5)
$toyCode = @"
import * as THREE from 'three';
const scene = new THREE.Scene();
document.addEventListener('click', () => { console.log('click to start'); });
"@
Set-Content (Join-Path $codeDir "toy_game.js") -Value $toyCode
Set-Content (Join-Path $codeDir "toy.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$rubricOutputToy = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir -Category "Interactive_Game" | ConvertFrom-Json
Assert-Test -TestName "Rubric Rejects Shallow Toy Demo" -Condition ($rubricOutputToy.verdict -eq "REJECTED" -and $rubricOutputToy.score -lt 95)

# Codigo con arquitectura profunda
Remove-Item (Join-Path $codeDir "toy_game.js") -Force
$proCode = @"
import * as THREE from 'three';
export class StartMenu { constructor() { this.options = 'optionsMenu'; this.pause = 'pauseMenu'; } }
export class CameraSystem { toggleCamera() { this.thirdPerson = !this.thirdPerson; } }
export class MobSystem { spawnMob(type) { return { type, stateMachine: 'wander' }; } }
export class CraftingMatrix { craftRecipe(grid) { return 'craftingTable'; } }
const sharedVec = new THREE.Vector3();
export function animate(dt) { sharedVec.set(0, 1, 0); }
"@
Set-Content (Join-Path $codeDir "pro_game.js") -Value $proCode

$rubricOutputPro = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir -Category "Interactive_Game" | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Deep Architecture Code" -Condition ($rubricOutputPro.verdict -eq "APPROVED" -and $rubricOutputPro.score -ge 95)

# --- TEST 4: MultiSector Vision Engine ---
Write-Host "`n[Test 4] Evaluando MultiSector Vision Engine..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "full_capture.png"
$multiOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath -Mode "MultiSector" | ConvertFrom-Json
Assert-Test -TestName "MultiSector Full Image Generated" -Condition (Test-Path $capPath)
Assert-Test -TestName "Ground Sector 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.ground_baseline)
Assert-Test -TestName "Center Focus 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.center_focus)
Assert-Test -TestName "HUD Inventory 1:1 Crop Generated" -Condition (Test-Path $multiOutput.sector_crops.hud_inventory)

# --- TEST 5: Visual Differencing & State Tracking ---
Write-Host "`n[Test 5] Evaluando Visual Differencing Engine (compare_visuals)..." -ForegroundColor Yellow
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