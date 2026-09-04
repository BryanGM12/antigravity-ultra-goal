<#
.SYNOPSIS
    UltraGoal OmniThink Hyper-Cognition & Multi-Perspective Reasoner v4.0
.DESCRIPTION
    Motor de razonamiento profundo por primeros principios (System 2 Thinking).
    Obliga a la IA a "pensar en todo pero absolutamente todo" antes de escribir código.
    Analiza la meta desde 4 perspectivas críticas obligatorias:
    1. Arquitecto de Sistemas (Modelos, Estados, Flujo de Datos)
    2. Red Team Adversarial (Casos límite, entradas maliciosas, caídas, desincronizaciones)
    3. Ergonomía Visual & Cinética (Controles, cámaras, texturas, feedback UX)
    4. Perfilador de Rendimiento (Presupuesto de FPS, GC, fugas de memoria, batching)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GoalObjective,

    [Parameter(Mandatory = $false)]
    [string]$Category = "Auto",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "HYPER_COGNITION_SPEC.json"
)

$ErrorActionPreference = "Stop"

if ($Category -eq "Auto") {
    if ($GoalObjective -match '(?i)(juego|game|3d|voxel|arcade|minecraft|simula)') {
        $Category = "Interactive_Simulation_or_Game"
    } elseif ($GoalObjective -match '(?i)(web|dashboard|react|vue|saas|frontend)') {
        $Category = "Web_or_FullStack_Application"
    } elseif ($GoalObjective -match '(?i)(api|backend|microservicio|rest|server)') {
        $Category = "Backend_Service_or_API"
    } elseif ($GoalObjective -match '(?i)(cli|terminal|consola|script|daemon)') {
        $Category = "CLI_or_Systems_Tool"
    } else {
        $Category = "General_Software_System"
    }
}

# 1. Perspectiva 1: Arquitectura de Sistemas & Flujo de Datos
$archAnalysis = [ordered]@{
    perspective = "System_Architect"
    core_responsibilities = @(
        "Desacoplamiento estricto: la vista no debe contener lógica de negocio ni estado de simulación directo",
        "Máquina de estados finitos (FSM) exhaustiva: definir explícitamente estados (Init, Loading, Ready, Active, Paused, Error, Destroyed)",
        "Contrato de tipos inmutable y esquemas de datos validados antes de cualquier procesamiento"
    )
    data_flow_guards = @(
        "Direccionalidad de datos unidireccional (Action -> State Mutation -> Render)",
        "Eliminación de dependencias circulares y referencias cruzadas en memoria"
    )
}

# 2. Perspectiva 2: Red Team Adversarial (¿Dónde y cómo fallará si no nos anticipamos?)
$redTeamAnalysis = [ordered]@{
    perspective = "Adversarial_Red_Team"
    critical_failure_vectors = @(
        "Fallo de arranque inicial: scripts con imports sin type='module', rutas relativas 404, o llamadas a DOM antes de DOMContentLoaded",
        "Pantallazo Negro (BSOD): canvas 3D sin iluminación, cámara apuntando al vacío infinito o bucle de render no iniciado",
        "Degradación de memoria: event listeners acumulados en cada reinicio o arrays/objetos instanciados en requestAnimationFrame",
        "Casos borde de interacción: doble clic rápido, presionar ESC repetidamente, cambiar de pestaña (window blur) con teclas presionadas",
        "Corrupción de persistencia: datos de guardado malformados en LocalStorage o desincronización de esquemas"
    )
    mandatory_defenses = @(
        "Error Boundary global con mensaje legible en pantalla (cero pantallas en blanco silenciosas)",
        "Limpieza obligatoria de teclas en window.onblur para evitar personajes corriendo solos",
        "Fallback visual y assets por defecto embebidos para evitar bloqueos por 404"
    )
}

# 3. Perspectiva 3: Ergonomía Visual, Cinética & Sensación de Uso (Feel & Look)
$uxKineticAnalysis = [ordered]@{
    perspective = "Visual_Kinetic_Specialist"
    sensory_requirements = @(
        "Cámara cinematográfica estable: Clamping de ángulo vertical obligatorio (-1.5 a 1.5 rad) para erradicar volteos de cabeza",
        "Movimiento físico coherente: Vector de avance neutralizado en el plano horizontal (dir.y = 0) para no volar ni hundirse al mirar arriba/abajo",
        "Física proporcional: Toda traslación, aceleración y salto debe multiplicar por DeltaTime (clock.getDelta()) para ser independiente de los Hz",
        "Nitidez de texturas vóxel: magFilter y minFilter configurados en NearestFilter con mapeo diferenciado por caras (Top/Sides/Bottom)",
        "Micro-interacciones: Crosshair central con wireframe de bloque apuntado, iluminación con contraste (sol + luz ambiental) y menú de pausa funcional"
    )
}

# 4. Perspectiva 4: Perfilador de Rendimiento & Presupuesto de Hardware
$perfAnalysis = [ordered]@{
    perspective = "Performance_Engineer"
    hardware_budgets = @(
        "Tasa de cuadros: 60 FPS estables sin micro-stuttering ni pausas de recolección de basura (GC pauses)",
        "Presupuesto de asignación en bucles: CERO 'new THREE.Vector3()', matrices o arrays dentro de animate() / loop()",
        "Optimización de dibujo: Geometrías combinadas (Chunk Merging o InstancedMesh) para terrenos vóxel en lugar de miles de mallas individuales",
        "Tiempos de respuesta en UI/APIs: < 100ms para cualquier interacción de usuario o mutación de estado"
    )
}

# Consolidación del Hyper-Cognition Spec
$hyperSpec = [ordered]@{
    goal_objective          = $GoalObjective
    detected_category       = $Category
    analysis_framework      = "UltraGoal OmniThink System 2 Hyper-Cognition v4.0"
    created_at              = (Get-Date -Format "o")
    perspectives            = [ordered]@{
        "1_Architecture"      = $archAnalysis
        "2_RedTeam_Adversary" = $redTeamAnalysis
        "3_Visual_Kinetic"    = $uxKineticAnalysis
        "4_Performance"       = $perfAnalysis
    }
    omnithink_mandate       = "Queda terminantemente prohibido escribir una sola línea de código sin haber diseñado previamente las defensas para cada uno de los vectores de fallo identificados por el Red Team y el Especialista Cinético."
}

$json = $hyperSpec | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
Write-Output $json