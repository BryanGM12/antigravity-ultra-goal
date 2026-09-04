<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v3.3 (Kinetic & Texture Integrity Edition)
.DESCRIPTION
    Ejecuta una batería completa de 16 pruebas automatizadas sobre todos los componentes
    de UltraGoal Engine (Kinetic Clamping, NearestFilter Textures, Live Boot, Multi-Photo Vision, Rubric Gate).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL HARNESS TEST SUITE v3.3 (KINETICS)  " -ForegroundColor Cyan
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
$specFileGame = Join-Path $tempDir "spec_game.json"
& "$scriptsDir\deep_planner.ps1" -GoalObjective "Haz un clon de voxel/minecraft 3D" -OutputPath $specFileGame | Out-Null
$specGame = Get-Content $specFileGame | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies Game Domain" -Condition ($specGame.detected_category -eq "Interactive_Simulation_or_Game")
Assert-Test -TestName "Planner Enforces Kinetic & NearestFilter Defenses" -Condition ($specGame.anti_toy_defenses.Count -ge 8)

# --- TEST 2: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 2] Evaluando Milestone Tracker..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"
& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Kinetic Voxel Game" -Milestones $specGame.recommended_milestones | Out-Null
Assert-Test -TestName "Tracker Init with Deep Milestones" -Condition (Test-Path $stateFile)

# --- TEST 3: Live Runtime Boot Verifier & Dead Screen Gate ---
Write-Host "`n[Test 3] Evaluando Live Runtime Boot Verifier..." -ForegroundColor Yellow
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

# --- TEST 4: Kinetic, Camera & Texture Integrity Gate in Rubric ---
Write-Host "`n[Test 4] Evaluando Kinetic, Camera & Texture Integrity Gate..." -ForegroundColor Yellow
$kineticDir = Join-Path $tempDir "kinetic_code"
New-Item -ItemType Directory -Path $kineticDir -Force | Out-Null

# Codigo con camara invertida, sin delta time, sin dir.y neutralizado y sin NearestFilter
$badVoxelCode = @"
import * as THREE from 'three';
const camera = new THREE.PerspectiveCamera();
document.addEventListener('mousemove', (e) => { camera.rotation.x -= e.movementY * 0.002; });
function update() {
    const dir = new THREE.Vector3();
    camera.getWorldDirection(dir);
    camera.position.addScaledVector(dir, 5);
}
"@
Set-Content (Join-Path $kineticDir "game.js") -Value $badVoxelCode
Set-Content (Join-Path $kineticDir "game.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$rubricBad = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $kineticDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Rejects Broken Camera & Blurry Textures" -Condition ($rubricBad.verdict -eq "REJECTED")

$kineticViolations = @($rubricBad.violations | Where-Object { $_.Category -eq "Kinetic_Asset_Integrity" })
Assert-Test -TestName "Rubric Catches Camera Pitch Flip Bug" -Condition (@($kineticViolations | Where-Object { $_.Issue -match "Cabeceo|Pitch" }).Count -gt 0)
Assert-Test -TestName "Rubric Catches Flying Movement Bug" -Condition (@($kineticViolations | Where-Object { $_.Issue -match "neutraliza el eje Y" }).Count -gt 0)
Assert-Test -TestName "Rubric Catches Missing DeltaTime Bug" -Condition (@($kineticViolations | Where-Object { $_.Issue -match "DeltaTime" }).Count -gt 0)

# Codigo limpio con cinematica perfecta y NearestFilter
Remove-Item (Join-Path $kineticDir "game.js") -Force
$goodVoxelCode = @"
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
Set-Content (Join-Path $kineticDir "game.js") -Value $goodVoxelCode
$rubricGood = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $kineticDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Clean Kinetic & NearestFilter Code" -Condition ($rubricGood.verdict -eq "APPROVED" -and $rubricGood.score -ge 95)

# --- TEST 5: Multi-State Audit Vision Engine (Galería de 4 Fotos) ---
Write-Host "`n[Test 5] Evaluando MultiStateAudit Vision Engine..." -ForegroundColor Yellow
$capPath = Join-Path $tempDir "overview_grid.png"
$auditOutput = & "$scriptsDir\capture_vision.ps1" -OutputPath $capPath -Mode "MultiStateAudit" | ConvertFrom-Json
Assert-Test -TestName "Overview Grid Generated" -Condition (Test-Path $capPath)
Assert-Test -TestName "Ground Sector 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."3_sector_ground".path)
Assert-Test -TestName "Center Focus 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."2_sector_center".path)
Assert-Test -TestName "HUD Inventory 1:1 Generated" -Condition (Test-Path $auditOutput.photo_gallery."4_sector_hud".path)

# --- TEST 6: Visual Differencing & State Tracking ---
Write-Host "`n[Test 6] Evaluando Visual Differencing Engine..." -ForegroundColor Yellow
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