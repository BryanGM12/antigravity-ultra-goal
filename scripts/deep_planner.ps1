<#
.SYNOPSIS
    UltraGoal Deep Domain Planner & Anti-Toy Pre-Mortem Engine v3.0
.DESCRIPTION
    Motor de investigación profunda y descomposición de alcance para proyectos ambiciosos en Antigravity.
    Previene el síndrome de la "Demo de Juguete" (toy demo) donde la IA implementa versiones
    superficiales e incompletas de software complejo (ej. clon de Minecraft sin menú de inicio,
    sin animales, sin tercera persona, con crafteo roto o solo 3 bloques).
    Descompone cualquier objetivo en los 6 Pilares Canónicos de Ingeniería y genera
    un contrato de especificación exhaustivo con cláusulas anti-juguete.
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

# Deteccion automatica de categoria si es Auto
if ($Category -eq "Auto") {
    if ($GoalObjective -match '(?i)(juego|game|minecraft|clon|voxel|3d|arcade|rpg|simula)') {
        $Category = "Interactive_Game"
    } elseif ($GoalObjective -match '(?i)(web|dashboard|frontend|react|vue|landing|portal|ecommerce|tienda)') {
        $Category = "Web_Application"
    } elseif ($GoalObjective -match '(?i)(api|microservicio|backend|rest|graphql|database|servicio)') {
        $Category = "Backend_Service"
    } else {
        $Category = "General_Software"
    }
}

# 1. Definición de los 6 Pilares Canónicos según Categoría
$pillars = [ordered]@{}
$antiToyRisks = @()

switch ($Category) {
    "Interactive_Game" {
        $pillars = [ordered]@{
            "1_Presentation_Shell" = [PSCustomObject]@{
                Name = "Menú de Inicio, Pantallas & Audio (Tier-1 Shell)"
                Mandatory_Requirements = @(
                    "Menú de título real con fondo panorámico/animado, botón 'Jugar', botón 'Opciones' y botón 'Créditos' (PROHIBIDO mero overlay 'click para continuar')",
                    "Menú de Pausa (tecla ESC) con opciones de reanudar, ajustes y volver al menú principal",
                    "Sistema de Ajustes funcionales: control de volumen de sonido, campo de visión (FOV) y distancia de renderizado",
                    "Efectos de audio / SFX (pasos, colocación/ruptura de bloques, clics de interfaz)"
                )
            }
            "2_Perspective_Controls" = [PSCustomObject]@{
                Name = "Cámara Multiperspectiva & Controles Fluidos"
                Mandatory_Requirements = @(
                    "Soporte para Primera Persona Y Tercera Persona (conmutador con tecla F5 o botón)",
                    "Mira central (Crosshair) con resaltado de caja wireframe en el bloque apuntado",
                    "Movimiento físico completo: caminar, correr (doble W o Shift), saltar con gravedad y colisión AABB sólida"
                )
            }
            "3_Entities_AI" = [PSCustomObject]@{
                Name = "Entidades Vivas & Sistema de IA (Mobs)"
                Mandatory_Requirements = @(
                    "Al menos 2 tipos de animales pasivos (ej. vaca, cerdo, oveja o pollo) con modelo 3D y texturas",
                    "Al menos 1 criatura hostil o NPC con máquina de estados (Wander, Idle, Chase, Attack)",
                    "Colisiones físicas independientes para entidades y detección de daño/impacto"
                )
            }
            "4_Materials_Content" = [PSCustomObject]@{
                Name = "Riqueza de Materiales (Zero-Paucity Invariant)"
                Mandatory_Requirements = @(
                    "Mínimo 8 a 12 tipos distintos de bloques con texturas diferenciadas (Pasto con cara superior/lateral, Tierra, Piedra, Madera, Hojas, Arena, Agua, Carbón, Cristal)",
                    "Propiedades físicas por bloque (dureza de picado, transparencia, resistencia)",
                    "Generación procedural de terreno con capas geológicas (césped arriba, tierra al medio, piedra profunda)"
                )
            }
            "5_Crafting_Mechanics" = [PSCustomObject]@{
                Name = "Mecánicas Profundas & Matriz de Crafteo Real"
                Mandatory_Requirements = @(
                    "Cuadrícula de Crafteo real (2x2 en inventario del jugador Y 3x3 en Mesa de Trabajo / Crafting Table)",
                    "Motor de recetas extensible basado en diccionario/matriz (madera -> tablones -> palos -> pico/espada/mesa)",
                    "Inventario con arrastre de objetos donde el sprite sigue al cursor (Drag-and-Drop verificado)",
                    "Apilamiento de ítems con números de cantidad visibles (x64, x16) y barra de acceso rápido (Hotbar de 9 slots con rueda del ratón)"
                )
            }
            "6_Persistence_Environment" = [PSCustomObject]@{
                Name = "Ciclo Ambiental & Persistencia de Estado"
                Mandatory_Requirements = @(
                    "Ciclo de día y noche con rotación de sol/luna y variación de luz ambiental",
                    "Sistema de guardado y carga del mundo e inventario (LocalStorage o archivo JSON)",
                    "Partículas al romper bloques"
                )
            }
        }

        $antiToyRisks = @(
            "Riesgo de Demo: Reducir el inicio a un texto blanco 'Click para empezar' -> DEFENSA: Exigir menú estilo Minecraft completo.",
            "Riesgo de Demo: Mundo vacío sin vida -> DEFENSA: Implementar mobs con máquina de estados de deambulación.",
            "Riesgo de Demo: Solo 2 tipos de bloques -> DEFENSA: Exigir catálogo mínimo de 10 bloques con caras independientes.",
            "Riesgo de Demo: Crafteo de 1 solo botón falso -> DEFENSA: Exigir cuadrícula 2x2 y 3x3 con motor de recetas.",
            "Riesgo de Demo: Cámara fija sin tercera persona -> DEFENSA: Exigir conmutación F5 (1ra/3ra persona)."
        )
    }

    "Web_Application" {
        $pillars = [ordered]@{
            "1_Presentation_Shell" = [PSCustomObject]@{
                Name = "Diseño UI/UX Profesional & Navegación"
                Mandatory_Requirements = @(
                    "Barra de navegación responsive con logo, menú colapsable (hamburguesa) y tema claro/oscuro",
                    "Estados de carga (Skeletons/Spinners) y páginas de error 404/500 pulidas",
                    "Tipografía legible y paleta de colores con tokens accesibles (WCAG AA)"
                )
            }
            "2_Forms_Validation" = [PSCustomObject]@{
                Name = "Formularios Robustos & Validación en Tiempo Real"
                Mandatory_Requirements = @(
                    "Validación client-side y feedback visual instantáneo (errores en rojo, éxito en verde)",
                    "Manejo de entradas maliciosas (XSS sanitization)",
                    "Máscaras y formateo para campos numéricos/teléfono/fechas"
                )
            }
            "3_Interactive_State" = [PSCustomObject]@{
                Name = "Gestión de Estado & Feedback Dinámico"
                Mandatory_Requirements = @(
                    "Transiciones suaves sin parpadeo de pantalla (micro-animaciones)",
                    "Modales accesibles con foco atrapado y cierre con ESC o clic fuera",
                    "Notificaciones Toast no bloqueantes para acciones exitosas o fallidas"
                )
            }
            "4_Data_Table_Grid" = [PSCustomObject]@{
                Name = "Filtrado, Paginación & Búsqueda"
                Mandatory_Requirements = @(
                    "Búsqueda instantánea con debouncing",
                    "Ordenamiento por columnas y filtros combinados",
                    "Paginación o scroll infinito fluido sin degradación de memoria"
                )
            }
            "5_Persistence_Auth" = [PSCustomObject]@{
                Name = "Autenticación, Sesión & Persistencia"
                Mandatory_Requirements = @(
                    "Protección de rutas privadas y persistencia de sesión",
                    "Almacenamiento seguro en LocalStorage/IndexedDB con serialización tipada"
                )
            }
            "6_Responsive_Accessibility" = [PSCustomObject]@{
                Name = "Adaptabilidad Móvil & Accesibilidad"
                Mandatory_Requirements = @(
                    "Diseño mobile-first 100% utilizable en 320px, 768px y 1080p+",
                    "Navegabilidad completa por teclado (Tab, Enter, Espacio)"
                )
            }
        }
        $antiToyRisks = @(
            "Riesgo de Demo: Una sola tabla fea sin estilos -> DEFENSA: Exigir diseño profesional con tokens UI.",
            "Riesgo de Demo: Formularios que no validan nada -> DEFENSA: Validación estricta con feedback visual.",
            "Riesgo de Demo: Sin estados de carga ni manejo de error -> DEFENSA: Skeletons y modales de error."
        )
    }

    Default {
        $pillars = [ordered]@{
            "1_Architecture_Core" = [PSCustomObject]@{
                Name = "Núcleo Arquitectónico & Modularidad"
                Mandatory_Requirements = @(
                    "Separación estricta de responsabilidades (Clean Architecture / Hexagonal)",
                    "Tipado estricto y modelos de dominio inmutables"
                )
            }
            "2_Robustness_Resilience" = [PSCustomObject]@{
                Name = "Manejo Exhaustivo de Excepciones"
                Mandatory_Requirements = @(
                    "Cero errores silenciosos o bloques catch vacíos",
                    "Reintentos con backoff exponencial para I/O y red"
                )
            }
            "3_Telemetry_Logging" = [PSCustomObject]@{
                Name = "Observabilidad & Logging Estructurado"
                Mandatory_Requirements = @(
                    "Logs estructurados JSON con niveles (DEBUG, INFO, WARN, ERROR)",
                    "Métricas de salud y rendimiento"
                )
            }
            "4_Testing_Rigor" = [PSCustomObject]@{
                Name = "Batería de Pruebas Automatizadas"
                Mandatory_Requirements = @(
                    "Pruebas unitarias de todas las ramas lógicas",
                    "Pruebas de integración de contratos de datos"
                )
            }
            "5_Configuration_Security" = [PSCustomObject]@{
                Name = "Configuración Segura & Sin Secretos"
                Mandatory_Requirements = @(
                    "Configuración desacoplada en variables de entorno",
                    "Cero credenciales en código fuente"
                )
            }
            "6_Documentation_CLI" = [PSCustomObject]@{
                Name = "Documentación & Experiencia de Uso"
                Mandatory_Requirements = @(
                    "README con instrucciones de instalación y ejemplos de uso",
                    "CLI o interfaz intuitiva con mensajes claros"
                )
            }
        }
        $antiToyRisks = @(
            "Riesgo de Demo: Script de 1 solo archivo sin pruebas -> DEFENSA: Exigir modularidad y tests unitarios.",
            "Riesgo de Demo: Sin manejo de fallos -> DEFENSA: Exigir resiliencia y logging estructurado."
        )
    }
}

# 2. Generar Plan de Hitos Exhaustivos (5 a 7 hitos profundos, nunca 3 superficiales)
$suggestedMilestones = @()
$idx = 1
foreach ($k in $pillars.Keys) {
    $p = $pillars[$k]
    $suggestedMilestones += "$idx. $($p.Name)"
    $idx++
}
$suggestedMilestones += "$idx. Verificación Adversarial Integral, Visión 1:1 & Entrega"

$specData = [PSCustomObject]@{
    goal_objective          = $GoalObjective
    category                = $Category
    created_at              = (Get-Date -Format "o")
    canonical_pillars_count = $pillars.Count
    canonical_pillars       = $pillars
    anti_toy_pre_mortem     = $antiToyRisks
    recommended_milestones  = ($suggestedMilestones -join "; ")
    execution_mandate       = "Queda terminantemente prohibido omitir cualquiera de los 6 pilares canónicos. Toda entrega parcial que carezca de menús reales, entidades autónomas o mecánicas completas será vetada por el Auditor."
}

$json = $specData | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
Write-Output $json