<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v4.0 (OmniThink & Rigorous Harness Edition)
.DESCRIPTION
    Ejecuta una batería completa de 18 pruebas automatizadas sobre todos los componentes
    de UltraGoal Engine (OmniThink Hyper-Cognition, Rigorous 5-Phase Test Harness, Kinetic Clamping, NearestFilter, Live Boot).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS TEST SUITE v4.0 (OMNITHINK) " -ForegroundColor Cyan
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

# --- TEST 1: OmniThink System 2 Hyper-Cognition ---
Write-Host "`n[Test 1] Evaluando OmniThink Hyper-Cognition (4 Perspectivas)..." -ForegroundColor Yellow
$specOmni = Join-Path $tempDir "omni_spec.json"
& "$scriptsDir\omnithink_analyzer.ps1" -GoalObjective "clon de minecraft con bloques y animales" -OutputPath $specOmni | Out-Null
$omniObj = Get-Content $specOmni | ConvertFrom-Json
$propsCount = @($omniObj.perspectives.PSObject.Properties).Count
Assert-Test -TestName "OmniThink Analyzes 4 Perspectives" -Condition ([bool]($propsCount -ge 4))
Assert-Test -TestName "OmniThink Red Team Identifies Critical Vectors" -Condition ($omniObj.perspectives.'2_RedTeam_Adversary'.critical_failure_vectors.Count -ge 5)
Assert-Test -TestName "OmniThink Visual/Kinetic Mandates Exist" -Condition ($omniObj.perspectives.'3_Visual_Kinetic'.sensory_requirements.Count -ge 5)

# --- TEST 2: Universal Deep Domain Planner ---
Write-Host "`n[Test 2] Evaluando Universal Deep Domain Planner..." -ForegroundColor Yellow
$specFileGame = Join-Path $tempDir "spec_game.json"
& "$scriptsDir\deep_planner.ps1" -GoalObjective "Haz un clon de voxel/minecraft 3D" -OutputPath $specFileGame | Out-Null
$specGame = Get-Content $specFileGame | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies Game Domain" -Condition ($specGame.detected_category -eq "Interactive_Simulation_or_Game")
Assert-Test -TestName "Planner Enforces Kinetic & NearestFilter Defenses" -Condition ($specGame.anti_toy_defenses.Count -ge 8)

# --- TEST 3: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 3] Evaluando Milestone Tracker..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"
& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Kinetic Voxel Game" -Milestones $specGame.recommended_milestones | Out-Null
Assert-Test -TestName "Tracker Init with Deep Milestones" -Condition (Test-Path $stateFile)

# --- TEST 4: Live Runtime Boot Verifier & Dead Screen Gate ---
Write-Host "`n[Test 4] Evaluando Live Runtime Boot Verifier..." -ForegroundColor Yellow
$bootTestDir = Join-Path $tempDir "boot_test_case"
New-Item -ItemType Directory -Path $bootTestDir -Force | Out-Null

$brokenGameHtml = "<html><body style='margin:0;background:black;'><script>import * as THREE from 'three';</script></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $brokenGameHtml
$bootResBroken = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Catches Broken Syntax & Black Screen" -Condition ($bootResBroken.verdict -eq "BOOT_FAILED")

$workingGameHtml = "<html><body style='margin:0;background:#5c94fc;'><h1>Minecraft Live Engine</h1><div style='height:200px;background:#557a2b;'></div></body></html>"
Set-Content (Join-Path $bootTestDir "index.html") -Value $workingGameHtml
$bootResWorking = & "$scriptsDir\verify_runtime_boot.ps1" -TargetDirectory $bootTestDir | ConvertFrom-Json
Assert-Test -TestName "Live Boot Approves Running Game" -Condition ($bootResWorking.verdict -eq "BOOT_SUCCESS")

# --- TEST 5: Rigorous 5-Phase Test Harness (rigorous_test_harness) ---
Write-Host "`n[Test 5] Evaluando Rigorous 5-Phase Test Harness..." -ForegroundColor Yellow
$harnessBrokenDir = Join-Path $tempDir "harness_broken"
New-Item -ItemType Directory -Path $harnessBrokenDir -Force | Out-Null
Set-Content (Join-Path $harnessBrokenDir "index.html") -Value $brokenGameHtml
Set-Content (Join-Path $harnessBrokenDir "game.js") -Value "// TODO: arreglar esto`nconst camera = new THREE.PerspectiveCamera();"

$harnessResBroken = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessBrokenDir | ConvertFrom-Json
Assert-Test -TestName "Harness Rejects Broken Code (Defects >= 5)" -Condition ($harnessResBroken.verdict -eq "RIGOROUS_TEST_FAILED" -and $harnessResBroken.fatal_defects_count -ge 5)

$harnessCleanDir = Join-Path $tempDir "harness_clean"
New-Item -ItemType Directory -Path $harnessCleanDir -Force | Out-Null
Set-Content (Join-Path $harnessCleanDir "index.html") -Value $workingGameHtml
$cleanCode = @"
import * as THREE from 'three';
export class PlayerController {
    constructor(cam) {
        this.camera = cam;
        this.pitch = 0;
        this.clock = new THREE.Clock();
    }
    onMouseMove(e) {
        this.pitch = Math.max(-1.5, Math.min(1.5, this.pitch - e.movementY * 0.002));
        this.camera.rotation.x = this.pitch;
    }
    update() {
        const dt = this.clock.getDelta();
        const dir = new THREE.Vector3();
        this.camera.getWorldDirection(dir);
        dir.y = 0;
        dir.normalize();
        this.camera.position.addScaledVector(dir, 5 * dt);
    }
    createTexture() {
        const tex = new THREE.Texture();
        tex.magFilter = THREE.NearestFilter;
        tex.minFilter = THREE.NearestFilter;
        return tex;
    }
}
export class ShellMenu { constructor() { this.routes = new Map(); } }
"@
Set-Content (Join-Path $harnessCleanDir "game.js") -Value $cleanCode
Set-Content (Join-Path $harnessCleanDir "game.test.js") -Value "test('engine', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$harnessResClean = & "$scriptsDir\rigorous_test_harness.ps1" -TargetDirectory $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Harness Approves Clean Code (0 Defects)" -Condition ($harnessResClean.verdict -eq "RIGOROUS_TEST_PASSED" -and $harnessResClean.fatal_defects_count -eq 0)

# --- TEST 6: Kinetic, Camera & Texture Integrity Gate in Rubric ---
Write-Host "`n[Test 6] Evaluando Kinetic, Camera & Texture Integrity Gate en Rubrica..." -ForegroundColor Yellow
$rubricClean = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $harnessCleanDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Clean Kinetic & NearestFilter Code" -Condition ($rubricClean.verdict -eq "APPROVED" -and $rubricClean.score -ge 95)

# --- TEST 7: Multi-State Audit Vision Engine (Galería de 4 Fotos) ---
Write-Host "`n[Test 7] Evaluando MultiStateAudit Vision Engine..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "overview_grid.png"
$auditOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath -Mode "MultiStateAudit" | ConvertFrom-Json
Assert-Test -TestName "Overview Grid Generated" -Condition (Test-Path $capPath)
Assert-Test -TestName "Ground Sector 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."3_sector_ground".path)
Assert-Test -TestName "Center Focus 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."2_sector_center".path)
Assert-Test -TestName "HUD Inventory 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."4_sector_hud".path)

# --- TEST 8: Visual Differencing & State Tracking ---
Write-Host "`n[Test 8] Evaluando Visual Differencing Engine..." -ForegroundColor Yellow
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

# Limpieza
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   RESULTADOS: $passed PASADAS, $failed FALLIDAS" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }