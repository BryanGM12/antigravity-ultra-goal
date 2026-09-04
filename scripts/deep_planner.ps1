<#
.SYNOPSIS
    UltraGoal Universal Deep Domain Planner v3.1 (First-Principles Software Architecture)
.DESCRIPTION
    Motor de planificación profunda universal y erradicación del "Síndrome de la Demo de Juguete".
    Totalmente agnóstico de dominio: aplicable a aplicaciones web, full-stack, servicios backend,
    herramientas CLI, apps móviles, dashboards, sistemas de escritorio, motores y videojuegos.
    Descompone cualquier objetivo en los 7 Niveles Universales de Ingeniería de Software y
    establece un contrato de completitud técnica sin necesidad de supervisión constante del usuario.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GoalObjective,

    [Parameter(Mandatory = $false)]
    [string]$Category = "Auto",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "SPECIFICATION.json"
)

$ErrorActionPreference = "Stop"

# Clasificación inteligente del dominio de software
if ($Category -eq "Auto") {
    if ($GoalObjective -match '(?i)(juego|game|3d|arcade|voxel|simula|unity|canvas|phaser)') {
        $Category = "Interactive_Simulation_or_Game"
    } elseif ($GoalObjective -match '(?i)(web|dashboard|react|vue|angular|frontend|saas|portal|landing|ecommerce|ui\b)') {
        $Category = "Web_or_FullStack_Application"
    } elseif ($GoalObjective -match '(?i)(api|microservicio|rest|graphql|backend|server|endpoint|database|grpc)') {
        $Category = "Backend_Service_or_API"
    } elseif ($GoalObjective -match '(?i)(cli|terminal|herramienta|script|tui|daemon|automatiza|consola|powershell)') {
        $Category = "CLI_or_Systems_Tool"
    } elseif ($GoalObjective -match '(?i)(desktop|escritorio|electron|tauri|winforms|wpf|gui\b)') {
        $Category = "Desktop_Application"
    } else {
        $Category = "General_Software_System"
    }
}

# Definición de los 7 Niveles Universales de Ingeniería de Software
$universalTiers = [ordered]@{
    "Tier_1_Entry_And_Presentation_Shell" = [PSCustomObject]@{
        Name = "Capa 1: Interfaz de Entrada, Navegación & Shell de Usuario"
        Mandatory_Requirements = @(
            "Punto de entrada profesional y estructurado (Menú de inicio/Landing/Dashboard/CLI Help completa; PROHIBIDO iniciar en un vacío o cartel plano sin opciones)",
            "Configuración y Preferencias accesibles (Ajustes de tema, volumen, parámetros de ejecución o credenciales)",
            "Retroalimentación visual/auditiva clara ante estados de carga, transiciones y pantallas de error/pausa"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Diseñar una pantalla de inicio y navegación completa con rutas o menús reales, en lugar de un único contenedor sin salida."
        )
    }

    "Tier_2_Core_Domain_Model_And_Rules" = [PSCustomObject]@{
        Name = "Capa 2: Motor de Dominio Central & Lógica de Negocio"
        Mandatory_Requirements = @(
            "Modelo de datos exhaustivo con entidades tipadas, validación de esquemas y reglas de negocio formales",
            "Manejo de relaciones y casos de borde de la lógica principal (no conformarse con 1 solo caso hardcodeado)",
            "Separación estricta entre la lógica de procesamiento y la capa de presentación (Clean Architecture)"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Prohibido usar un 'if (item == x)' estático. La lógica debe operar sobre diccionarios, colecciones o registros extensibles."
        )
    }

    "Tier_3_Interactivity_And_Dynamic_State" = [PSCustomObject]@{
        Name = "Capa 3: Interacción Fluida, Eventos & Transiciones de Estado"
        Mandatory_Requirements = @(
            "Gestión reactiva de eventos (arrastrar y soltar / drag-and-drop, selección interactiva, filtrado en tiempo real, atajos de teclado)",
            "Sincronización bidireccional perfecta: cuando un elemento se mueve o edita, todos los observadores y componentes visuales reflejan el cambio instantáneamente",
            "Micro-interacciones pulidas: hover states, animaciones de transición suaves y prevención de desalineaciones"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Cada acción de usuario (clic, arrastre, tecla) debe disparar una mutación visible verificable mediante diffs."
        )
    }

    "Tier_4_Content_Depth_And_Variety" = [PSCustomObject]@{
        Name = "Capa 4: Amplitud de Contenido & Catálogo (Zero-Paucity Invariant)"
        Mandatory_Requirements = @(
            "Diversidad sustancial de datos, materiales o componentes: mínimo 8 a 15 variantes reales con propiedades diferenciadas",
            "Generación o carga de datos sintéticos realistas para verificar escalabilidad",
            "Sistemas auxiliares activos (ej. agentes de fondo, mobs con IA, tablas paginadas, procesamiento en lotes)"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Queda prohibido entregar proyectos con solo 2 o 3 ítems de ejemplo. Debe incluirse un catálogo rico y representativo."
        )
    }

    "Tier_5_Resilience_And_Error_Boundaries" = [PSCustomObject]@{
        Name = "Capa 5: Resiliencia, Blindaje de Excepciones & Auto-Recuperación"
        Mandatory_Requirements = @(
            "Límites de error (Error Boundaries) que prevengan que un fallo en un componente tumbe toda la aplicación",
            "Validación exhaustiva de entradas de usuario, tipos incompatibles, valores nulos y casos límite",
            "Reintentos inteligentes con backoff exponencial para operaciones de E/S o red, y mensajes de error humanos y descriptivos"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Cero bloques catch vacíos o silenciamiento de errores. Cada excepción debe ser manejada y comunicada."
        )
    }

    "Tier_6_Performance_And_Resource_Hygiene" = [PSCustomObject]@{
        Name = "Capa 6: Optimización de Rendimiento & Cero Fugas de Memoria"
        Mandatory_Requirements = @(
            "Eliminación radical de asignaciones continuas de memoria en bucles de alta frecuencia (animación, tick, rendering o polling)",
            "Manejo eficiente de recursos: cancelación de suscripciones/listeners al destruir componentes, batching de operaciones y debouncing de inputs",
            "Fluidez garantizada: tiempos de respuesta < 100ms en UIs/APIs y 60 FPS estables sin pausas de Garbage Collector en aplicaciones gráficas"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: Reutilización obligatoria de estructuras en memoria y perfilado de recursos antes de la entrega."
        )
    }

    "Tier_7_Persistence_And_Lifecycle" = [PSCustomObject]@{
        Name = "Capa 7: Persistencia de Estado, Configuración & Cierre Limpio"
        Mandatory_Requirements = @(
            "Persistencia confiable del estado de la aplicación (LocalStorage, IndexedDB, SQLite, JSON en disco o base de datos)",
            "Capacidad de exportar/importar datos o restaurar la sesión exactamente en el punto donde se dejó",
            "Manejo limpio del ciclo de vida (inicialización ordenada, migración de esquemas y cierre de conexiones/streams)"
        )
        Anti_Toy_Defenses = @(
            "Defensa contra la trampa de la maqueta: La aplicación debe recordar datos entre reinicios sin perder información."
        )
    }
}

# Generar Hitos de Ingeniería de Alta Fidelidad
$milestonesList = @()
$idx = 1
foreach ($k in $universalTiers.Keys) {
    $tier = $universalTiers[$k]
    $milestonesList += "$idx. $($tier.Name)"
    $idx++
}
$milestonesList += "$idx. Batería de Pruebas de Calidad, Auditoría Adversarial & Certificación Final"

# Extraer defensas anti-juguete
$defenses = @()
foreach ($tier in $universalTiers.Values) {
    $defenses += $tier.Anti_Toy_Defenses
}

$specObj = [PSCustomObject]@{
    goal_objective          = $GoalObjective
    detected_category       = $Category
    architecture_framework  = "UltraGoal 7-Tier Universal Engineering Framework"
    created_at              = (Get-Date -Format "o")
    total_tiers             = $universalTiers.Count
    tiers                   = $universalTiers
    anti_toy_defenses       = $defenses
    recommended_milestones  = ($milestonesList -join "; ")
    autonomous_rule         = "AUTODETERMINACIÓN TOTAL: El agente NO debe pedir feedback al usuario para corregir defectos. Debe ejecutar el bucle Constructor-Auditor internamente hasta superar el umbral de 95/100 en todas las dimensiones."
}

$json = $specObj | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
Write-Output $json