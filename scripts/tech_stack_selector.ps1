<#
.SYNOPSIS
    UltraGoal Universal Tech Stack Selector v5.4.0 (Anti-HTML Monoculture Engine)
.DESCRIPTION
    Motor de selección activa de la tecnología óptima para cualquier objetivo de software.
    Erradica de raíz el monocultivo de maquetas HTML/Canvas genéricas. Evalúa rigurosamente
    múltiples ecosistemas modernos (Python nativo, C# / .NET 9, Rust, Go, TypeScript/WebGPU)
    y selecciona el stack técnico con mayor fidelidad, rendimiento (FPS/latencia) y
    acceso a hardware/GPU adecuado para el dominio solicitado.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GoalObjective,

    [Parameter(Mandatory = $false)]
    [string]$Category = "Auto",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Auto", "Native", "Web", "CLI", "Desktop", "Backend")]
    [string]$PreferredEcosystem = "Auto",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

# 1. Clasificación Inteligente del Dominio
if ($Category -eq "Auto") {
    if ($GoalObjective -match '(?i)(juego|game|3d|arcade|voxel|minecraft|simula|cohete|rocket|espacio|space|fps\b|fisica|physics)') {
        $Category = "Interactive_Simulation_or_Game"
    } elseif ($GoalObjective -match '(?i)(desktop|escritorio|electron|tauri|winforms|wpf|avalonia|gui\b|ventana\b)') {
        $Category = "Desktop_Application"
    } elseif ($GoalObjective -match '(?i)(cli|terminal|herramienta|script|tui|daemon|automatiza|consola|powershell|rtk|prompt)') {
        $Category = "CLI_or_Systems_Tool"
    } elseif ($GoalObjective -match '(?i)(api|microservicio|rest|graphql|backend|server|endpoint|database|db|postgres|sql|fastapi)') {
        $Category = "Backend_Service_or_API"
    } elseif ($GoalObjective -match '(?i)(web|dashboard|react|vue|angular|frontend|saas|portal|landing|ecommerce|html\b)') {
        $Category = "Web_or_FullStack_Application"
    } else {
        $Category = "General_Software_System"
    }
}

# 2. Detección de Mandatos Explícitos en el Objetivo
$explicitWebMandate = ($GoalObjective -match '(?i)\b(en el navegador|browser|web\b|html5|pwa|sitio web|pagina web)\b')
$explicitNativeMandate = ($GoalObjective -match '(?i)\b(nativo|native|escritorio|desktop|ejecutable|exe|app nativa|sin navegador)\b')
$explicitPythonMandate = ($GoalObjective -match '(?i)\b(python|pygame|panda3d|moderngl|fastapi)\b')
$explicitRustMandate = ($GoalObjective -match '(?i)\b(rust|bevy|tauri|wgpu)\b')
$explicitDotNetMandate = ($GoalObjective -match '(?i)\b(c#|csharp|\.net|dotnet|raylib|godot|wpf|avalonia)\b')

# 3. Matriz de Candidatos por Categoría
$candidates = @()

switch ($Category) {
    "Interactive_Simulation_or_Game" {
        $candidates = @(
            [PSCustomObject]@{
                id                = "python_moderngl_pygame"
                name              = "Python 3 + ModernGL / Pygame-ce"
                language          = "Python"
                runtime           = "Python 3.10+"
                framework         = "ModernGL / Pygame-ce / Ursina"
                rendering_engine  = "Hardware Accelerated OpenGL 3.3+ / ModernGL Shaders"
                entry_file        = "main.py"
                test_runner       = "pytest"
                package_manager   = "pip / uv"
                target_fps        = 60
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 94
                performance_score = 90
                pros              = @("Acceso directo a OpenGL/Vulkan sin sandbox de navegador", "Matemáticas vectoriales NumPy ultra-rápidas", "Soporte nativo de audio y controladores USB")
                cons              = @("Requiere entorno Python instalado")
                anti_toy_defense  = "Evita la trampa de maquetas HTML en canvas 2D. Provee shaders GLSL reales y renderizado nativo 3D."
            },
            [PSCustomObject]@{
                id                = "csharp_raylib_godot"
                name              = "C# .NET 9 + Raylib-cs / Silk.NET"
                language          = "C#"
                runtime           = ".NET 9 Native AOT"
                framework         = "Raylib-cs / Silk.NET"
                rendering_engine  = "DirectX 11 / 12 / OpenGL / Vulkan"
                entry_file        = "Program.cs"
                test_runner       = "dotnet test"
                package_manager   = "NuGet"
                target_fps        = 120
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 96
                performance_score = 98
                pros              = @("Rendimiento nativo extremo AOT", "Gestión de memoria de alta eficiencia sin GC pauses en bucles", "Ecosistema tipado riguroso")
                cons              = @("Tiempo de compilación inicial de dotnet")
                anti_toy_defense  = "Arquitectura de juego profesional compilada a código nativo de máquina, sin degradaciones web."
            },
            [PSCustomObject]@{
                id                = "rust_bevy_wgpu"
                name              = "Rust + Bevy Engine / WGPU"
                language          = "Rust"
                runtime           = "Cargo Native Binary"
                framework         = "Bevy / WGPU"
                rendering_engine  = "Vulkan / DirectX 12 / Metal vía WGPU"
                entry_file        = "src/main.rs"
                test_runner       = "cargo test"
                package_manager   = "cargo"
                target_fps        = 144
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 98
                performance_score = 99
                pros              = @("Arquitectura ECS (Entity Component System) inigualable", "Cero costo de abstracción y memoria segura sin GC", "Gráficos Vulkan/DX12 de última generación")
                cons              = @("Curva de compilación más lenta")
                anti_toy_defense  = "Máxima robustez matemática y ausencia total de fallos de memoria o caídas de framerate."
            },
            [PSCustomObject]@{
                id                = "web_threejs_webgpu_vite"
                name              = "TypeScript + Three.js / WebGPU / Vite"
                language          = "TypeScript / JavaScript"
                runtime           = "Node.js / Modern Browser"
                framework         = "Vite + Three.js / Babylon.js"
                rendering_engine  = "WebGPU / WebGL 2.0 con Shaders PBR"
                entry_file        = "index.html"
                test_runner       = "vitest / npm test"
                package_manager   = "npm / pnpm"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $false
                fidelity_score    = 90
                performance_score = 82
                pros              = @("Ejecución directa en cualquier navegador sin compilación binaria", "Rica suite de shaders y loaders Three.js", "Web Audio API nativo")
                cons              = @("Sandbox de navegador con restricciones de hilos y memoria", "Rendimiento inferior a binarios C#/Rust/Python en cálculo de vóxeles masivos")
                anti_toy_defense  = "Si se implementa en Web, se PROHÍBE una maqueta HTML plana sin bundler. Se exige arquitectura modular con TypeScript y shaders PBR."
            }
        )
    }

    "Desktop_Application" {
        $candidates = @(
            [PSCustomObject]@{
                id                = "rust_tauri_v2"
                name              = "Rust + Tauri v2 (Frontend React/Svelte o Nativo)"
                language          = "Rust / TypeScript"
                runtime           = "Tauri Native Binary"
                framework         = "Tauri v2 + WebView2"
                rendering_engine  = "Windows WebView2 DirectComposition / OS Native Controls"
                entry_file        = "src-tauri/src/main.rs"
                test_runner       = "cargo test"
                package_manager   = "cargo + npm"
                target_fps        = 60
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 97
                performance_score = 98
                pros              = @("Consumo de RAM insignificante (<30MB) comparado con Electron (>200MB)", "Seguridad de memoria estricta en backend Rust", "Integración con bandeja del sistema y atajos globales")
                cons              = @("Requiere toolchains de Rust y Node")
                anti_toy_defense  = "Erradica las aplicaciones de juguete en Electron hinchadas y maquetas no ejecutables."
            },
            [PSCustomObject]@{
                id                = "csharp_avalonia_wpf"
                name              = "C# .NET 9 + Avalonia UI / Modern WPF"
                language          = "C#"
                runtime           = ".NET 9 Desktop"
                framework         = "Avalonia UI / WPF XAML"
                rendering_engine  = "SkiaSharp / Direct3D 11"
                entry_file        = "Program.cs"
                test_runner       = "dotnet test"
                package_manager   = "NuGet"
                target_fps        = 60
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 95
                performance_score = 95
                pros              = @("Arquitectura MVVM profesional de nivel empresarial", "Renderizado Skia acelerado por GPU", "Soporte multiplataforma completo en Avalonia")
                cons              = @("Estructura de proyecto más pesada")
                anti_toy_defense  = "Aplicación de escritorio 100% nativa con controles ricos, enlace de datos reactivo y menús del sistema."
            },
            [PSCustomObject]@{
                id                = "python_pyqt6_customtkinter"
                name              = "Python + PyQt6 / CustomTkinter"
                language          = "Python"
                runtime           = "Python 3.10+"
                framework         = "PyQt6 / CustomTkinter"
                rendering_engine  = "Qt6 Graphics View / Windows Native GDI/DirectX"
                entry_file        = "main.py"
                test_runner       = "pytest"
                package_manager   = "pip"
                target_fps        = 60
                native_gpu        = $true
                multithreading    = $true
                fidelity_score    = 92
                performance_score = 88
                pros              = @("Rápido desarrollo con widgets nativos pulidos", "Tema oscuro moderno e integración de gráficos Matplotlib/Seaborn")
                cons              = @("Distribución requiere PyInstaller o virtualenv")
                anti_toy_defense  = "Interfaz de escritorio real con eventos asíncronos y diálogos del sistema."
            }
        )
    }

    "CLI_or_Systems_Tool" {
        $candidates = @(
            [PSCustomObject]@{
                id                = "rust_clap_ratatui"
                name              = "Rust + Clap + Ratatui (TUI de Alto Rendimiento)"
                language          = "Rust"
                runtime           = "Cargo Native Binary"
                framework         = "clap + ratatui + crossterm"
                rendering_engine  = "Terminal ANSI / Virtual Terminal Processing"
                entry_file        = "src/main.rs"
                test_runner       = "cargo test"
                package_manager   = "cargo"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 99
                performance_score = 100
                pros              = @("Arranque en <5 milisegundos", "Cero dependencias externas en tiempo de ejecución", "Interfaces de terminal interactivas (TUI) hermosas y reactivas")
                cons              = @("Sintaxis rigurosa")
                anti_toy_defense  = "Herramienta CLI de nivel de producción con flags POSIX, subcomandos y manejo de señales."
            },
            [PSCustomObject]@{
                id                = "powershell_rtk_turbo"
                name              = "PowerShell 7 + RTK Turbo Automation"
                language          = "PowerShell 7"
                runtime           = "pwsh 7.4+"
                framework         = "PowerShell RTK CLI Proxy"
                rendering_engine  = "Windows Terminal / Host Console"
                entry_file        = "main.ps1"
                test_runner       = "Pester / Script Test Runner"
                package_manager   = "PSGallery / WinGet"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 94
                performance_score = 92
                pros              = @("Integración nativa con APIs de Windows y WMI/CIM", "Aceleración de tokens del 60-90% con proxy RTK", "Tuberías asíncronas y jobs nativos")
                cons              = @("Enfocado principalmente en entornos Windows")
                anti_toy_defense  = "Automatización de sistemas con hardening estricto, logging estructurado y validación de permisos."
            },
            [PSCustomObject]@{
                id                = "go_cobra_bubbletea"
                name              = "Go + Cobra + Bubbletea"
                language          = "Go"
                runtime           = "Go Native Executable"
                framework         = "cobra + bubbletea"
                rendering_engine  = "Terminal Console"
                entry_file        = "main.go"
                test_runner       = "go test ./..."
                package_manager   = "go modules"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 95
                performance_score = 96
                pros              = @("Compilación en un solo binario autónomo", "Concurrencia nativa con Goroutines", "TUI interactiva basada en The Elm Architecture")
                cons              = @("Ecosistema de tipos menos expresivo que Rust")
                anti_toy_defense  = "Binario autocontenido sin requerir instalación de frameworks en el host."
            }
        )
    }

    "Backend_Service_or_API" {
        $candidates = @(
            [PSCustomObject]@{
                id                = "python_fastapi_pydantic"
                name              = "Python + FastAPI + Pydantic v2 + SQLAlchemy 2.0"
                language          = "Python"
                runtime           = "Python 3.10+ (uvicorn)"
                framework         = "FastAPI"
                rendering_engine  = "JSON / OpenAPI 3.1 / WebSocket"
                entry_file        = "main.py"
                test_runner       = "pytest"
                package_manager   = "pip / uv"
                target_fps        = 0
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 96
                performance_score = 91
                pros              = @("Validación estricta de esquemas Pydantic v2 en Rust", "Documentación interactiva Swagger/Redoc automática", "Soporte async/await nativo")
                cons              = @("GIL en operaciones intensivas de CPU pura")
                anti_toy_defense  = "API robusta con circuit breakers, validación tipada y pruebas de integración."
            },
            [PSCustomObject]@{
                id                = "csharp_dotnet9_api"
                name              = "C# .NET 9 Minimal APIs + Entity Framework Core"
                language          = "C#"
                runtime           = ".NET 9 Kestrel"
                framework         = "ASP.NET Core Minimal APIs"
                rendering_engine  = "High-throughput JSON / gRPC"
                entry_file        = "Program.cs"
                test_runner       = "dotnet test"
                package_manager   = "NuGet"
                target_fps        = 0
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 98
                performance_score = 98
                pros              = @("Uno de los servidores HTTP más veloces del mundo (TechEmpower)", "Tipado estricto y Native AOT disponible", "Soporte gRPC y WebSockets de nivel empresarial")
                cons              = @("Sintaxis más verbosa")
                anti_toy_defense  = "Microservicio con resiliencia Polly, rate limiting y contratos OpenAPI formales."
            }
        )
    }

    Default {
        $candidates = @(
            [PSCustomObject]@{
                id                = "python_modern_modular"
                name              = "Python 3 Modular Architecture"
                language          = "Python"
                runtime           = "Python 3.10+"
                framework         = "Modular Clean Architecture"
                rendering_engine  = "Domain Driven Design Engine"
                entry_file        = "main.py"
                test_runner       = "pytest"
                package_manager   = "pip"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 92
                performance_score = 90
                pros              = @("Ecosistema masivo y limpio", "Facilidad de pruebas automatizadas", "Código legible y mantenible")
                cons              = @("Velocidad de ejecución dependiente del intérprete")
                anti_toy_defense  = "Diseño de software con capas desacopladas, modelos tipados y cero scripts planos de un solo archivo."
            },
            [PSCustomObject]@{
                id                = "csharp_clean_architecture"
                name              = "C# .NET 9 Enterprise Architecture"
                language          = "C#"
                runtime           = ".NET 9"
                framework         = "Clean Architecture"
                rendering_engine  = "Domain Engine"
                entry_file        = "Program.cs"
                test_runner       = "dotnet test"
                package_manager   = "NuGet"
                target_fps        = 60
                native_gpu        = $false
                multithreading    = $true
                fidelity_score    = 96
                performance_score = 96
                pros              = @("Seguridad de tipos estricta", "Patrones SOLID y Hexagonales", "Rendimiento óptimo")
                cons              = @("Mayor cantidad de código base")
                anti_toy_defense  = "Implementación formal con interfaces, inyección de dependencias y pruebas unitarias."
            }
        )
    }
}

# 4. Algoritmo de Selección del Stack Óptimo
$selected = $null

if ($explicitNativeMandate -or $PreferredEcosystem -eq "Native") {
    $selected = $candidates | Where-Object { $_.native_gpu -eq $true -or $_.runtime -match '(?i)(Native|Python|Cargo|NET)' } | Select-Object -First 1
} elseif ($explicitWebMandate -or $PreferredEcosystem -eq "Web") {
    $selected = $candidates | Where-Object { $_.id -match '(?i)web' } | Select-Object -First 1
} elseif ($explicitPythonMandate) {
    $selected = $candidates | Where-Object { $_.language -eq "Python" } | Select-Object -First 1
} elseif ($explicitDotNetMandate) {
    $selected = $candidates | Where-Object { $_.language -eq "C#" } | Select-Object -First 1
} elseif ($explicitRustMandate) {
    $selected = $candidates | Where-Object { $_.language -eq "Rust" } | Select-Object -First 1
}

if ($null -eq $selected) {
    $sorted = $candidates | Sort-Object -Property @{ Expression = { ($_.fidelity_score * 0.6) + ($_.performance_score * 0.4) } } -Descending
    $selected = $sorted[0]
}

# 5. Declaración de Veto y Prohibición de Anti-Patrones
$prohibitions = @(
    "PROHIBIDO el monocultivo de HTML/Canvas: Queda terminantemente vetado generar un archivo 'index.html' plano solitario para simulaciones, juegos o herramientas cuando la tecnología seleccionada sea nativa ($($selected.name)).",
    "PROHIBIDO el monocultivo de cajas 3D planas sin textura: Queda terminantemente vetado renderizar figuras primitivas con colores sólidos (DrawCube, MeshBasicMaterial) sin cargar texturas, generar texturas procedurales en GPU VRAM o mapear coordenadas UV con sombreado direccional.",
    "PROHIBIDO el fondo de vacío monocromático: Toda simulación o juego 3D debe implementar una cúpula celeste o skybox con gradiente cenit-horizonte y cúpula solar/estelar.",
    "PROHIBIDO en shooters/FPS viewmodels primitivos o desorientados: El arma debe ser un conjunto articulado con cañón orientado por cámara (DrawCylinderEx en Raylib), miras nocturnas de tritio 3-dot y guantes tácticos.",
    "PROHIBIDO rebajar la arquitectura a una maqueta no funcional: El proyecto debe incluir punto de entrada real ($($selected.entry_file)), dependencias declaradas y suite de pruebas ejecutables ($($selected.test_runner)).",
    "PROHIBIDO entregar código que requiera ejecución web si el usuario no pidió explícitamente un navegador: Usar los runtimes locales de alta eficiencia de la máquina (Python, .NET, Rust, PowerShell 7)."
)

# 6. Construcción del Contrato de Stack
$stackContract = [ordered]@{
    version                 = "5.4.0"
    goal_objective          = $GoalObjective
    detected_category       = $Category
    preferred_ecosystem     = $PreferredEcosystem
    ecosystem_classification= if ($selected.native_gpu) { "Native_Accelerated_Hardware" } else { "High_Fidelity_Ecosystem" }
    evaluated_candidates    = $candidates
    selected_stack          = [ordered]@{
        id                  = $selected.id
        name                = $selected.name
        language            = $selected.language
        runtime             = $selected.runtime
        framework           = $selected.framework
        rendering_engine    = $selected.rendering_engine
        entry_file          = $selected.entry_file
        test_runner         = $selected.test_runner
        package_manager     = $selected.package_manager
        target_fps          = $selected.target_fps
        native_gpu_access   = $selected.native_gpu
        multithreading      = $selected.multithreading
        selection_rationale = "Se seleccionó $($selected.name) porque ofrece la combinación más alta de fidelidad visual/arquitectónica ($($selected.fidelity_score)/100) y rendimiento ($($selected.performance_score)/100), superando las limitaciones de sandboxing y sobrecarga del monocultivo de maquetas HTML."
    }
    anti_toy_mandate        = "La IA DEBE implementar el proyecto utilizando $($selected.language) / $($selected.framework) con punto de entrada en '$($selected.entry_file)' y pruebas en '$($selected.test_runner)'."
    prohibited_anti_patterns= $prohibitions
    timestamp               = (Get-Date -Format "o")
}

$jsonOutput = $stackContract | ConvertTo-Json -Depth 10

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($OutputPath, $jsonOutput, [System.Text.Encoding]::UTF8)
}

Write-Output $jsonOutput
