<#
.SYNOPSIS
    UltraGoal Autonomous Verification Suite v3.1 (Universal Software Engineering Edition)
.DESCRIPTION
    Ejecuta una batería completa de 15 pruebas automatizadas sobre todos los componentes
    de UltraGoal Universal Engine (Universal Planner, 7-Tier Framework, Rubric Quality Gate, MultiSector Vision, Visual Differencing).
#>

$baseDir = Split-Path -Parent $PSScriptRoot
if (-not $baseDir) { $baseDir = $PSScriptRoot }

$scriptsDir = Join-Path $baseDir "scripts"
$tempDir = Join-Path $env:TEMP "ultragoal_suite_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   ULTRAGOAL UNIVERSAL HARNESS TEST SUITE v3.1   " -ForegroundColor Cyan
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

# --- TEST 1: Universal Deep Planner across Diverse Domains ---
Write-Host "`n[Test 1] Evaluando Universal Deep Domain Planner (Web SaaS & CLI Tool)..." -ForegroundColor Yellow
$specFileWeb = Join-Path $tempDir "spec_web.json"
$specFileCLI = Join-Path $tempDir "spec_cli.json"

& "$scriptsDir\deep_planner.ps1" -GoalObjective "Crea un dashboard SaaS de facturacion con autenticacion y graficas" -OutputPath $specFileWeb | Out-Null
$specWeb = Get-Content $specFileWeb | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies Web/FullStack SaaS Domain" -Condition ($specWeb.detected_category -eq "Web_or_FullStack_Application")
Assert-Test -TestName "Planner Decomposes 7 Universal Tiers for Web" -Condition ($specWeb.total_tiers -eq 7)

& "$scriptsDir\deep_planner.ps1" -GoalObjective "Desarrolla una herramienta CLI de sincronizacion de archivos encriptados" -OutputPath $specFileCLI | Out-Null
$specCLI = Get-Content $specFileCLI | ConvertFrom-Json
Assert-Test -TestName "Planner Identifies CLI/Systems Domain" -Condition ($specCLI.detected_category -eq "CLI_or_Systems_Tool")
Assert-Test -TestName "Planner Formulates Universal Anti-Toy Defenses" -Condition ($specCLI.anti_toy_defenses.Count -gt 0)

# --- TEST 2: Milestone Tracker Lifecycle ---
Write-Host "`n[Test 2] Evaluando Milestone Tracker con los 7 Niveles..." -ForegroundColor Yellow
$stateFile = Join-Path $tempDir "goal_state.json"

& "$scriptsDir\milestone_tracker.ps1" -Action init -StateFilePath $stateFile -GoalTitle "Universal SaaS Engine" -Milestones $specWeb.recommended_milestones | Out-Null
Assert-Test -TestName "Tracker Init with Universal Milestones" -Condition (Test-Path $stateFile)

$state = Get-Content $stateFile | ConvertFrom-Json
Assert-Test -TestName "Tracker Has >= 7 Universal Milestones" -Condition ($state.total_milestones -ge 7)

# --- TEST 3: Rubric Universal Quality & Anti-Toy Gate ---
Write-Host "`n[Test 3] Evaluando Rubric Universal Gate (Agnóstico de Tecnología)..." -ForegroundColor Yellow
$codeDir = Join-Path $tempDir "sample_code"
New-Item -ItemType Directory -Path $codeDir -Force | Out-Null

# Codigo tipo maqueta de juguete (plano, sin navegacion, sin modelos estructurados)
$toyCode = @"
const app = document.getElementById('root');
app.innerHTML = '<h1>Hola Mundo</h1>';
"@
Set-Content (Join-Path $codeDir "toy_app.js") -Value $toyCode
Set-Content (Join-Path $codeDir "toy.test.js") -Value "test('dummy', () => { expect(1).toBe(1); expect(2).toBe(2); expect(3).toBe(3); });"

$rubricOutputToy = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Rejects Shallow Toy Mockup" -Condition ($rubricOutputToy.verdict -eq "REJECTED" -and $rubricOutputToy.score -lt 95)

# Codigo profesional con arquitectura universal limpia (Shell, Modelos, Tests)
Remove-Item (Join-Path $codeDir "toy_app.js") -Force
$proCode = @"
// Universal Modular SaaS Component
export class NavigationShell {
    constructor() {
        this.currentRoute = '/dashboard';
        this.routes = new Map([
            ['/dashboard', 'DashboardView'],
            ['/settings', 'SettingsView'],
            ['/invoices', 'InvoicesView']
        ]);
    }
    navigate(route) {
        if (this.routes.has(route)) { this.currentRoute = route; }
    }
}

export class InvoiceModel {
    constructor(id, customer, amount) {
        this.id = id;
        this.customer = customer;
        this.amount = amount;
        this.status = 'PENDING';
    }
    markPaid() { this.status = 'PAID'; }
}

export class DataStore {
    constructor() {
        this.invoices = new Map();
    }
    add(inv) { this.invoices.set(inv.id, inv); }
}
"@
Set-Content (Join-Path $codeDir "pro_saas.js") -Value $proCode

$rubricOutputPro = & "$scriptsDir\evaluate_rubric.ps1" -TargetPath $codeDir | ConvertFrom-Json
Assert-Test -TestName "Rubric Approves Deep Universal Architecture" -Condition ($rubricOutputPro.verdict -eq "APPROVED" -and $rubricOutputPro.score -ge 95)

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