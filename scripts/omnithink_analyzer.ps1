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

# Invocación del Selector de Stack Tecnológico Óptimo
$scriptsDir = $PSScriptRoot
if (-not $scriptsDir) { $scriptsDir = "." }
$stackSelectorPath = Join-Path $scriptsDir "tech_stack_selector.ps1"
$techStackResult = $null
if (Test-Path $stackSelectorPath) {
    try {
        $stackRaw = & $stackSelectorPath -GoalObjective $GoalObjective -Category $Category
        $techStackResult = $stackRaw | ConvertFrom-Json
    } catch {}
}

$selectedStackName = if ($techStackResult) { $techStackResult.selected_stack.name } else { "Stack Específico de Alto Rendimiento" }

# 1. Perspectiva 1: Arquitectura de Sistemas & Flujo de Datos
$archAnalysis = [ordered]@{
    perspective = "System_Architect"
    core_responsibilities = @(
        "Desacoplamiento estricto: la vista no debe contener lógica de negocio ni estado de simulación directo",
        "Selección de stack óptimo ($selectedStackName): erradicar el monocultivo de maquetas HTML y aprovechar el hardware nativo",
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
        "Degradación por monocultivo HTML: forzar una simulación física, juego 3D o herramienta en una maqueta web rudimentaria con caídas de FPS",
        "Trampa de las Cajas Planas (Flat-Box 3D Horror): renderizar figuras o cubos 3D sin textura ni mapeo UV (DrawCube, MeshBasicMaterial), produciendo un prototipo horrendo y amateur",
        "Trampa del Vacío Infinito: dejar el fondo de simulaciones o juegos 3D como un color plano sólido sin cielo, domo atmosférico ni horizonte",
        "Bug del Cilindro Vertical de Raylib: usar DrawCylinder en lugar de DrawCylinderEx en armas en primera persona, haciendo que el cañón apunte verticalmente hacia el cielo",
        "Trampa del Muro a Bocajarro: spawnear al jugador mirando a una pared plana a 1 metro de distancia, llenando el 50% de la pantalla con un polígono plano sin perspectiva",
        "Juego Muerto Sin Feedback: disparos sin calcomanías 3D de agujero de bala, armas sin retroceso visible ni destello, y simulación muda sin efectos sonoros",
        "Fallo de arranque inicial: scripts con imports sin type='module', rutas relativas 404, o llamadas a DOM antes de DOMContentLoaded",
        "Pantallazo Negro (BSOD): canvas 3D sin iluminación, cámara apuntando al vacío infinito o bucle de render no iniciado",
        "Degradación de memoria: event listeners acumulados en cada reinicio o arrays/objetos instanciados en requestAnimationFrame",
        "Casos borde de interacción: doble clic rápido, presionar ESC repetidamente, cambiar de pestaña (window blur) con teclas presionadas",
        "Corrupción de persistencia: datos de guardado malformados en LocalStorage o desincronización de esquemas"
    )
    mandatory_defenses = @(
        "Generador de texturas procedurales en GPU VRAM obligatorio para erradicar cualquier polígono plano sin textura",
        "Sombreado direccional por cara o iluminación PBR obligatoria para dotar de profundidad tridimensional a cada objeto",
        "Skybox atmosférico con gradiente cenit-horizonte y cúpula solar radiante para dar escala y horizonte",
        "Viewmodel táctico con miras de tritio 3-dot, alineación frontal exacta (DrawCylinderEx) y guantes texturizados",
        "Sistema de calcomanías 3D dinámicas de impacto (decals) y destellos de fogonazo en armas",
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
        "Texturizado 3D Universal: Toda superficie visible (arenisca, adoquines, cajas de madera con remaches, contenedores con franjas de peligro) debe poseer textura UV y sombreado direccional",
        "Encuadre de Spawn con Profundidad: Punto de aparición orientado hacia una línea de visión despejada de 8 a 15 metros con perspectiva, nunca encarando un muro a menos de 3m",
        "Viewmodel Táctico Articulado: En shooters/FPS, armas modeladas con miras nocturnas de tritio 3-dot luminiscentes, corredera, cañón orientado y guantes Weaver",
        "Micro-interacciones: Crosshair central con dispersión dinámica al disparar/moverse, iluminación con contraste (sol + luz ambiental) y menú de pausa funcional"
    )
}

# 4. Perspectiva 4: Perfilador de Rendimiento & Presupuesto de Hardware
$perfAnalysis = [ordered]@{
    perspective = "Performance_Engineer"
    hardware_budgets = @(
        "Tasa de cuadros: 60-120 FPS estables sin micro-stuttering ni pausas de recolección de basura (GC pauses)",
        "Presupuesto de asignación en bucles: CERO 'new THREE.Vector3()', matrices o arrays dentro de animate() / loop()",
        "Optimización de dibujo: Geometrías combinadas (Chunk Merging o InstancedMesh) para terrenos vóxel en lugar de miles de mallas individuales",
        "Pooling de calcomanías y partículas: Reutilización de quads de impacto de bala para evitar fugas de memoria en sesiones largas",
        "Tiempos de respuesta en UI/APIs: < 100ms para cualquier interacción de usuario o mutación de estado"
    )
}

# 5. Perspectiva 5: Arquitecto Sensorial, Audio & Orquestación de Assets (The Anti-Toy Multi-Media Invariant)
$sensoryAssetAnalysis = [ordered]@{
    perspective = "Sensory_Asset_Orchestrator"
    mandatory_asset_rules = @(
        "Prohibido usar primitivas geométricas desnudas (cilindros o conos planos solitarios). Vehículos, naves o maquinaria deben construirse con mallas compuestas detalladas (etapas desacoplables, toberas F-1/Raptor, aletas, cápsula, anillo interetapas) con materiales PBR (metalness >= 0.7, roughness <= 0.4)",
        "Prohibidas las cajas 3D planas sin textura: Todo escenario 3D debe integrar un generador procedural de texturas en VRAM (arenisca, enlucido, adoquines, madera, contenedores, metal) o cargar mapas UV de alta resolución",
        "Calcomanías 3D de impacto y partículas: Proyectiles o balas deben estampar agujeros de bala 3D (decals) en muros y cajas con desprendimiento de virutas/polvo y destellos de fogonazo",
        "Diseño sonoro obligatorio (Web Audio API / Native Audio): Ninguna animación o juego puede ser mudo. Integrar síntesis de audio procedural (disparo con transitorio de percusión + cola de ruido, recarga, pasos, rugido de cohete pink noise, cuenta atrás y ráfagas RCS)",
        "Director cinematográfico con interpolación suave: Prohibidos los saltos bruscos entre fases de vuelo o cámaras. La transición de vista (pad tracking, booster cam, chase cam, cockpit) debe usar lerp/slerp continuo con amortiguación (damping)",
        "Efectos visuales volumétricos & Post-Processing: Integrar partículas con gradiente térmico de escape (ignición a humo blanco) y fulgor emissive o UnrealBloomPass para motores al 100% de empuje",
        "Orquestación y búsqueda de recursos: Emplear 'asset_orchestrator.ps1' o búsqueda web (search_web) para enlazar texturas 4K de la NASA (Tierra, Luna, Vía Láctea) o modelos GLTF oficiales"
    )
}

# Consolidación del Hyper-Cognition Spec
$hyperSpec = [ordered]@{
    goal_objective          = $GoalObjective
    detected_category       = $Category
    analysis_framework      = "UltraGoal OmniThink System 2 Hyper-Cognition v5.0"
    created_at              = (Get-Date -Format "o")
    perspectives            = [ordered]@{
        "1_Architecture"      = $archAnalysis
        "2_RedTeam_Adversary" = $redTeamAnalysis
        "3_Visual_Kinetic"    = $uxKineticAnalysis
        "4_Performance"       = $perfAnalysis
        "5_Sensory_Assets"    = $sensoryAssetAnalysis
    }
    tech_stack              = if ($techStackResult) { $techStackResult.selected_stack } else { $null }
    omnithink_mandate       = "Queda terminantemente prohibido escribir una sola línea de código sin haber diseñado previamente las defensas para cada uno de los vectores de fallo identificados por el Red Team, el Especialista Cinético y el Arquitecto Sensorial de Assets."
}

$json = $hyperSpec | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
Write-Output $json