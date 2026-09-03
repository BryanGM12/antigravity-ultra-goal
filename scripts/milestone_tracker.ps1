<#
.SYNOPSIS
    UltraGoal Milestone & Multi-Agent State Machine
.DESCRIPTION
    Gestiona el estado auditable y la trazabilidad entre el Agente Orquestador,
    el Agente Constructor (Worker) y el Agente Auditor (Critic) para el comando /goal.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("init", "status", "submit", "audit", "complete", "reset")]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [string]$StateFilePath = "goal_state.json",

    [Parameter(Mandatory = $false)]
    [string]$GoalTitle = "",

    [Parameter(Mandatory = $false)]
    [string]$Milestones = "",

    [Parameter(Mandatory = $false)]
    [int]$MilestoneIndex = 1,

    [Parameter(Mandatory = $false)]
    [string]$Notes = "",

    [Parameter(Mandatory = $false)]
    [int]$Score = 0,

    [Parameter(Mandatory = $false)]
    [string]$Verdict = "APPROVED"
)

$ErrorActionPreference = "Stop"

function Load-State {
    param([string]$Path)
    if (Test-Path $Path) {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    }
    return $null
}

function Save-State {
    param([object]$State, [string]$Path)
    $parent = Split-Path $Path -Parent
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $json = $State | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($Path, $json, [System.Text.Encoding]::UTF8)
}

switch ($Action) {
    "init" {
        if ([string]::IsNullOrWhiteSpace($GoalTitle)) {
            $GoalTitle = "Autonomous Goal Task"
        }

        $milestoneList = @()
        if (-not [string]::IsNullOrWhiteSpace($Milestones)) {
            $milestoneList = $Milestones.Split(';') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
        if ($milestoneList.Count -eq 0) {
            $milestoneList = @("Arquitectura y Especificación", "Implementación Central", "Verificación y Pruebas Rigurosas", "Auditoría Final y Entrega")
        }

        $items = @()
        $idx = 1
        foreach ($m in $milestoneList) {
            $items += [PSCustomObject]@{
                index        = $idx
                name         = $m
                status       = if ($idx -eq 1) { "IN_PROGRESS" } else { "PENDING" }
                score        = 0
                builder_note = ""
                auditor_note = ""
                updated_at   = (Get-Date -Format "o")
            }
            $idx++
        }

        $stateObj = [PSCustomObject]@{
            goal_title       = $GoalTitle
            created_at       = (Get-Date -Format "o")
            completed_at     = ""
            status           = "ACTIVE"
            current_index    = 1
            total_milestones = $items.Count
            milestones       = $items
            history          = @(
                [PSCustomObject]@{
                    timestamp = (Get-Date -Format "o")
                    role      = "Orchestrator"
                    message   = "Meta inicializada con $($items.Count) hitos."
                }
            )
        }

        Save-State -State $stateObj -Path $StateFilePath
        Write-Host "UltraGoal State initialized at $StateFilePath"
        Write-Output ($stateObj | ConvertTo-Json -Depth 5)
    }

    "status" {
        $state = Load-State -Path $StateFilePath
        if (-not $state) {
            Write-Error "No active state file found at $StateFilePath"
            exit 1
        }
        Write-Output ($state | ConvertTo-Json -Depth 5)
    }

    "submit" {
        $state = Load-State -Path $StateFilePath
        if (-not $state) {
            Write-Error "No active state file found at $StateFilePath"
            exit 1
        }
        $target = $state.milestones | Where-Object { $_.index -eq $MilestoneIndex }
        if (-not $target) {
            Write-Error "Milestone index $MilestoneIndex not found."
            exit 1
        }
        $target.status = "SUBMITTED_FOR_AUDIT"
        $target.builder_note = $Notes
        $target.updated_at = (Get-Date -Format "o")

        $historyEntry = [PSCustomObject]@{
            timestamp = (Get-Date -Format "o")
            role      = "Builder"
            message   = "Hito $MilestoneIndex enviado para auditoría: $Notes"
        }
        $state.history = @($state.history) + $historyEntry
        Save-State -State $state -Path $StateFilePath
        Write-Host "Hito $MilestoneIndex enviado para auditoría."
    }

    "audit" {
        $state = Load-State -Path $StateFilePath
        if (-not $state) {
            Write-Error "No active state file found at $StateFilePath"
            exit 1
        }
        $target = $state.milestones | Where-Object { $_.index -eq $MilestoneIndex }
        if (-not $target) {
            Write-Error "Milestone index $MilestoneIndex not found."
            exit 1
        }

        $target.score = $Score
        $target.auditor_note = $Notes
        $target.updated_at = (Get-Date -Format "o")

        if ($Verdict -eq "APPROVED" -and $Score -ge 95) {
            $target.status = "APPROVED"
            if ($MilestoneIndex -lt $state.total_milestones) {
                $next = $state.milestones | Where-Object { $_.index -eq ($MilestoneIndex + 1) }
                if ($next) { $next.status = "IN_PROGRESS" }
                $state.current_index = $MilestoneIndex + 1
            }
            $historyEntry = [PSCustomObject]@{
                timestamp = (Get-Date -Format "o")
                role      = "Auditor"
                message   = "Hito $MilestoneIndex APROBADO (Score $Score/100): $Notes"
            }
            Write-Host "Hito $MilestoneIndex APROBADO con score $Score/100."
        } else {
            $target.status = "REJECTED"
            $historyEntry = [PSCustomObject]@{
                timestamp = (Get-Date -Format "o")
                role      = "Auditor"
                message   = "Hito $MilestoneIndex RECHAZADO (Score $Score/100, Mínimo 95): $Notes"
            }
            Write-Host "Hito $MilestoneIndex RECHAZADO con score $Score/100. Retornado a Builder."
        }

        $state.history = @($state.history) + $historyEntry
        Save-State -State $state -Path $StateFilePath
    }

    "complete" {
        $state = Load-State -Path $StateFilePath
        if (-not $state) {
            Write-Error "No active state file found at $StateFilePath"
            exit 1
        }

        $unapproved = $state.milestones | Where-Object { $_.status -ne "APPROVED" }
        if ($unapproved.Count -gt 0) {
            Write-Error "No se puede completar el Goal. Hay $($unapproved.Count) hito(s) no aprobados."
            exit 1
        }

        $state.status = "COMPLETED"
        if ($null -ne $state.PSObject.Properties['completed_at']) {
            $state.completed_at = (Get-Date -Format "o")
        } else {
            $state | Add-Member -NotePropertyName "completed_at" -NotePropertyValue (Get-Date -Format "o") -Force
        }

        $historyEntry = [PSCustomObject]@{
            timestamp = (Get-Date -Format "o")
            role      = "Orchestrator"
            message   = "Todos los hitos aprobados con excelencia (Score >= 95). Meta concluida con éxito."
        }
        $state.history = @($state.history) + $historyEntry
        Save-State -State $state -Path $StateFilePath
        Write-Host "VERIFICACIÓN TOTAL EXITOSA: Meta completamente completada."
    }
}