---
name: goal
description: "Motor Autónomo Perfeccionista Universal v5.5.0 (UltraGoal Engine - Anti-Flat-Box 3D Graphics Engine, Procedural GPU VRAM Textures, Tactical FPS Viewmodel & Decal Pipeline, OmniThink 5-Perspective Hyper-Cognition, Tech Stack Selector & Erradicación de Monocultivo HTML, Multi-Runtime Boot Verifier, DWM Native Window Capture, Advanced CV Metrics: Varianza Laplaciana, Entropía Shannon & Contraste WCAG, Escrutinio Empírico V-HEX7, Asset & Sensory Orchestrator, Procedural Audio Synthesis & 5-Phase Rigorous Test Harness). Obliga a la IA a 'pensar en todo pero absolutamente todo' mediante Razonamiento por Primeros Principios (omnithink_analyzer.ps1), selección activa del mejor stack tecnológico por dominio (tech_stack_selector.ps1), verificación multi-runtime (Python, .NET, Rust, Web), visión computacional cuantitativa (capture_vision.ps1) y Rúbrica >= 95/100."
author: BryanGM12 & Antigravity Autonomous Systems
version: 5.5.0
metadata:
  category: orchestration
  skills: ["goal", "omnithink-hypercognition", "anti-flat-box-graphics", "tactical-fps-pipeline", "tech-stack-selector", "multi-runtime-verifier", "dwm-native-vision", "advanced-cv-metrics", "asset-orchestrator", "procedural-audio", "cinematic-flight-director", "rigorous-test-harness", "kinetic-integrity", "live-boot-verifier", "multi-photo-vision", "synthetic-vision-scrutiny", "quality-gate"]
---

# ⚡ UltraGoal Universal Engine v5.5.0
### Anti-Flat-Box 3D Graphics Engine • OmniThink System 2 Hyper-Cognition • Tech Stack Selector • Multi-Runtime Boot Verifier • DWM Native Window & Advanced CV Metrics • Asset & Sensory Orchestrator • 5-Phase Rigorous Test Harness

Cuando el usuario invoca `/goal <objetivo>`, se activa **UltraGoal Universal v5.5.0**. Esta versión erradica por completo los prototipos 3D horrendos de cajas planas monocolor, el monocultivo de maquetas HTML y la complacencia visual: **obliga a la IA a implementar generadores procedurales de texturas en GPU VRAM o mapas UV para toda superficie 3D, sombreado solar direccional por cara, cúpulas atmosféricas con gradiente y sol radiante, viewmodels tácticos articulados con miras nocturnas de tritio 3-dot orientados con precisión (`DrawCylinderEx`), calcomanías de impacto dinámicas y audio procedural, verificando rigurosamente que el resultado sea visualmente impecable antes de cualquier dictamen**.

---

## 🛑 FASE 0.75: PROTOCOLO ANTI-CAJAS PLANAS Y TEXTURIZADO 3D OBLIGATORIO

> 🛑 **MANDATO DE FIDELIDAD GRÁFICA Y CERO CAJAS PLANAS MONOCOLOR:**
> Queda **TERMINANTEMENTE PROHIBIDO** entregar o renderizar escenas 3D compuestas de figuras primitivas desnudas o cubos con colores sólidos planos sin texturas (`DrawCube`, `MeshBasicMaterial({color})`, quads planos sin textura).
> Todo proyecto con renderizado 3D (juegos FPS, simulaciones espaciales, vóxeles, juegos de acción, arcades 3D) **DEBE CUMPLIR OBLIGATORIAMENTE LOS 7 INVARIANTES GRÁFICOS**:

### 1. Invariante de Texturizado Universal en GPU (`TextureManager`):
- **TODA superficie visible** (paredes, suelos, techos, cajas de cobertura, contenedores, puertas, armas, avatares) **DEBE estar texturizada**.
- Si el proyecto no incluye archivos de imagen externos empaquetados, la IA **DEBE implementar un generador procedural de texturas en VRAM** (en C# Raylib, Python ModernGL o WebGL/Three.js) que sintetice en tiempo de arranque texturas con detalle micro-estructural:
  - **Muros (Arenisca / Ladrillo / Yeso):** Variación de grano árido, líneas de mortero y micro-grietas.
  - **Suelos (Adoquines / Pavimento / Hierba):** Piedras con hendiduras oscuras, variación tonal y relieve.
  - **Cajas Tácticas (Madera militar):** Tablones con vetas, remaches metálicos y refuerzos angulares.
  - **Contenedores de Carga:** Paneles acanalados de metal y franjas diagonales amarillas/negras de advertencia (*hazard stripes*).
  - **Puertas Dobles:** Paneles de acero reforzado, manijas y placas remachadas.
- Todas las mallas 3D deben proyectar coordenadas UV a escala de mundo real (`tileScale = 2.0m - 2.5m`) para evitar estiramientos o texturas borrosas.

### 2. Invariante de Iluminación Solar Direccional y Sombreado por Cara:
- **PROHIBIDO el renderizado plano sin luces (*unlit*).**
- En motores sin sombreado diferido automático (como Raylib en modo inmediato), es **MANDATORIO** calcular sombreado direccional solar multiplicando el color de cada cara según su vector normal:
  - Caras superiores / Techos: $1.00\times$ (máxima insolación cenital).
  - Caras Sur / Frontales: $0.88\times$ (insolación rasante directa).
  - Caras Este: $0.80\times$ (iluminación difusa).
  - Caras Norte y Oeste: $0.50\times - 0.54\times$ (zonas de penumbra táctica).
- Esto garantiza relieve volumétrico tridimensional, evitando que cubos y esquinas se fusionen en siluetas planas.

### 3. Invariante de Cúpula Atmosférica o Skybox:
- **PROHIBIDO dejar el fondo como un vacío negro, gris o color plano.**
- Se exige implementar una cúpula atmosférica o skybox con:
  - Gradiente vertical continuo que desvanece de azul cenital a tono arena/cálido en el horizonte.
  - Disco solar radiante de 32 segmentos con halo áureo difuso o estrellas/luna según la hora.
  - Siluetas distantes de montañas o cordilleras en el horizonte para dar profundidad y escala.

### 4. Invariante de Viewmodel Táctico Articulado en Primera Persona (FPS):
- En shooters o vistas en primera persona, el arma y manos en pantalla **NO PUEDEN ser un cubo flotante o un cilindro simple**.
- Se exige modelar un ensamblaje táctico articulado:
  - Cañón, corredera/cajón de mecanismos con ranuras mecanizadas y ventana de expulsión con casquillo de latón.
  - **Miras nocturnas tácticas de tritio 3-dot** con puntos en verde luminiscente de alta visibilidad para apuntado intuitivo.
  - Guantes de combate texturizados a dos manos con agarre táctico Weaver.
  - **Orientación Matemática Estricta:** El arma DEBE orientarse a lo largo del vector frontal de la cámara.
  - ⚠️ **ALERTA DE ERROR EN RAYLIB:** En C# Raylib, `Raylib.DrawCylinder` siempre dibuja verticalmente en el eje Y. **DEBE usarse obligatoriamente `Raylib.DrawCylinderEx(startPos, endPos, radius, radius, sides, color)`** especificando posiciones iniciales y finales a lo largo del eje del arma.
  - Animación de retroceso (*recoil kickback*) con muelle elástico (*spring lerp*) al disparar.

### 5. Invariante de Game Feel, Calcomanías 3D Dinámicas (Decals) & Partículas:
- Los disparos o impactos de proyectiles **DEBEN estampar calcomanías 3D de impacto de bala (*decals*)** en muros y cajas con orientación de normal.
- El disparo debe producir destello de fogonazo (*muzzle flash*) con luz dinámica puntual y partículas de polvo/virutas de madera en el impacto.
- El crosshair debe reaccionar dinámicamente con dispersión al caminar o disparar.

### 6. Invariante de Diseño Sonoro Procedural Obligatorio:
- Ningún juego o simulación puede ser mudo. Se exige síntesis de audio procedural (Web Audio API o audio nativo) si no hay pistas de audio empaquetadas:
  - Disparo con percusión inicial + burst de ruido blanco + decay en filtro paso bajo.
  - Recarga con click metálico de cerrojo.
  - Pasos Foley sobre piedra o madera.
  - Beep de confirmación de impacto (*hit ping*).

### 7. Invariante de Encuadre de Spawn con Profundidad Visual:
- El punto de aparición inicial (spawn) **DEBE tener un campo visual despejado** de al menos 8 a 15 metros, orientado a lo largo de un pasillo principal, plaza o vista táctica con perspectiva y horizonte, **NUNCA encarando un muro a menos de 3 metros**.

---

## 🛠️ FASE 0.5: SELECCIÓN DEL STACK TECNOLÓGICO ÓPTIMO (`tech_stack_selector.ps1`)

> 🛑 **PROHIBICIÓN ABSOLUTA DEL MONOCULTIVO HTML / CANVAS:**
> Queda **TERMINANTEMENTE PROHIBIDO** recurrir por inercia o complacencia a un archivo `index.html` con `<canvas>` básico para cualquier proyecto.
> La IA debe invocar y acatar la selección de tecnología óptima:
> ```powershell
> powershell -ExecutionPolicy Bypass -File scripts/tech_stack_selector.ps1 -GoalObjective "<Objetivo del Usuario>"
> ```
> 
> El Selector evalúa la meta frente a las matrices de rendimiento y fidelidad:
> 1. **Juegos 3D / Simulaciones / Vóxeles:**
>    - **Python 3 + ModernGL / Pygame-ce / Ursina:** Acceso directo a shaders OpenGL/Vulkan sin sandbox de navegador, vectores NumPy ultra-rápidos.
>    - **C# .NET 9 + Raylib-cs / Godot .NET / Silk.NET:** Rendimiento nativo AOT extremo, 120+ FPS, gestión de memoria sin GC pauses.
>    - **Rust + Bevy Engine / WGPU:** Cero costo de abstracción, arquitectura ECS, gráficos DirectX 12 / Vulkan de última generación.
>    - **Web (TypeScript + Vite + WebGPU / Three.js PBR):** Únicamente si el usuario solicita explícitamente ejecución en navegador; PROHIBIDAS maquetas planas sin bundler.
> 2. **Aplicaciones de Escritorio (Desktop GUIs):**
>    - **Rust + Tauri v2 / Slint:** Consumo <30MB RAM frente a Electron (>200MB), integración con APIs del SO.
>    - **C# .NET 9 + Avalonia UI / Modern WPF:** Arquitectura MVVM empresarial, renderizado GPU SkiaSharp.
>    - **Python + PyQt6 / CustomTkinter:** Interfaces reactivas con widgets nativos pulidos y gráficos interactivos.
> 3. **Herramientas de Consola y CLI:**
>    - **Rust (clap + ratatui), Go (cobra + bubbletea), PowerShell 7 con aceleración RTK Turbo.**
> 4. **Microservicios y APIs Backend:**
>    - **Python (FastAPI + Pydantic v2 + SQLAlchemy 2.0), C# (.NET 9 Minimal APIs + EF Core), Rust (Axum).**

---

## 🧠 FASE 0: OMNITHINK HYPER-COGNITION (5 PERSPECTIVAS CRÍTICAS)

> 🛑 **PROHIBICIÓN ABSOLUTA DE PROGRAMACIÓN IMPULSIVA:**
> Queda **TERMINANTEMENTE PROHIBIDO** saltar a programar sin haber ejecutado primero el motor de hiper-cognición:
> ```powershell
> powershell -ExecutionPolicy Bypass -File scripts/omnithink_analyzer.ps1 -GoalObjective "<Objetivo del Usuario>" -OutputPath "HYPER_COGNITION_SPEC.json"
> ```
> 
> El Orquestador analiza la meta de forma obligatoria desde **5 Perspectivas Críticas**:
> 1. **Arquitecto de Sistemas:** Selecciona el stack óptimo, define máquinas de estados finitos (Init, Loading, Ready, Active, Paused, Error), separación estricta de la vista y contratos inmutables.
> 2. **Red Team Adversarial:** Anticipa degradación por monocultivo HTML, trampa de cajas planas sin textura, trampa del vacío infinito, bug de orientación vertical de cilindros de Raylib, trampa del muro a bocajarro en spawn, caídas por 404, teclas pegadas en `window.blur` y fugas de memoria.
> 3. **Especialista en Ergonomía Visual & Cinética:** Exige limitación de cabeceo de cámara en primera persona (-1.5 a 1.5 rad), avance horizontal neutralizado (`dir.y = 0`), física escalada con `DeltaTime`, texturas UV universales con sombreado direccional y miras de tritio 3-dot.
> 4. **Perfilador de Rendimiento:** Fija un presupuesto de 60-120 FPS estables sin pausas de GC, CERO allocations en bucles `loop()`, pooling de calcomanías y tiempos de respuesta < 100ms.
> 5. **Arquitecto Sensorial & Orquestador de Assets:** Veto total a cajas y cilindros planos desnudas. Exige modelos compuestos detallados (etapas desacoplables, toberas, miras nocturnas, guantes), generador procedural de texturas en VRAM (`TextureManager`), diseño sonoro procedural y transiciones suaves.

---

## 📦 APROVISIONAMIENTO DE RECURSOS CON ASSET ORCHESTRATOR (`asset_orchestrator.ps1`)

Para aprovisionar código probado de texturas, viewmodels, audio procedural o skybox:
```powershell
# Para Shooters / FPS tácticos / Counter-Strike clones:
powershell -ExecutionPolicy Bypass -File scripts/asset_orchestrator.ps1 -Domain "Tactical_FPS"

# Para Simulaciones espaciales / Naves / Vuelo:
powershell -ExecutionPolicy Bypass -File scripts/asset_orchestrator.ps1 -Domain "Space_Rocket"
```

---

## 👁️ MOTOR DE VISIÓN POTENCIADO & CAPTURA NATIVA DWM (`capture_vision.ps1`)

El motor de visión v5.5.0 opera tanto en aplicaciones web como en ventanas nativas de juegos y software de escritorio:
```powershell
# Captura de ventana nativa de juego o app por proceso o título con bordes DWM exactos
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -ProcessName "<nombre_proceso>" -Mode MultiStateAudit
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -WindowTitle "<titulo_ventana>" -Mode MultiStateAudit

# Captura de aplicación web en Chrome Headless
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -TargetDirectory "<ruta>" -Mode MultiStateAudit
```

### Métricas Avanzadas de Visión por Computadora:
1. **Detección de Polígonos 3D Planos Sin Textura (`flat_surface_pct` <= 15.0%):**
   - Evalúa el gradiente de textura en sectores centrales y de suelo.
   - Detecta y veta instantáneamente escenas donde más del 15% de la superficie esté compuesta por polígonos monocolor lisos sin mapeo UV ni textura.
2. **Varianza Laplaciana de Nitidez (`sharpness_score` >= 15.0):**
   - Convoluciona un kernel Laplaciano 3x3 sobre el canal de luminancia.
   - Detecta con precisión matemática imágenes borrosas, texturas desenfocadas o falta de definición de aristas.
3. **Ratio de Contraste en HUD bajo Norma WCAG 2.1 (`hud_contrast_ratio` >= 3.0:1):**
   - Muestreo denso en el sector de interfaz y cálculo del ratio de contraste entre percentiles 99 y 1.
   - Garantiza que la tipografía, contadores y menús sean legibles y accesibles frente a fondos dinámicos.
4. **Entropía Cromática de Shannon (`shannon_entropy` >= 0.70):**
   - Análisis de distribución tonal en histograma de 256 niveles para erradicar escenas monocromáticas planas o posterizadas.
5. **Captura DWM Nativa de Ventana (`DwmGetWindowAttribute` 9):**
   - Extrae los límites reales de la ventana del juego o aplicación de escritorio (`DWMWA_EXTENDED_FRAME_BOUNDS`), descartando sombras invisibles o marcos deformados de Windows 10/11.

---

## 🧪 LA BATERÍA DE PRUEBAS RIGUROSA DE 5 FASES (`rigorous_test_harness.ps1`)

Antes de entregar cualquier hito o meta final, el agente **DEBE ejecutar obligatoriamente**:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/rigorous_test_harness.ps1 -TargetDirectory "<Ruta_del_Proyecto>"
```

El arnés somete al proyecto a **5 Fases Inquebrantables de Prueba**:

| Fase de Prueba | Qué Audita Empíricamente | Criterio de Rechazo Inmediato |
| :--- | :--- | :--- |
| **Fase 1: Estático & AST** | Sintaxis, stubs, TODOs, detección estática de cajas 3D sin textura y bug vertical de Raylib DrawCylinder | 3D render sin texturas, DrawCylinder en viewmodel de armas, declaraciones `import` sin `type="module"`, TODOs o catch vacíos. |
| **Fase 2: Arranque en Vivo Multi-Runtime** | Ejecución real en Chrome Headless o validación de runtime (Python `py_compile`, .NET `dotnet build`, Rust `cargo check`) | Si la app no arranca, crashea, tiene errores de compilación/sintaxis o genera pantalla muerta. |
| **Fase 3: Escrutinio Visual & Texturas** | Varianza de luminancia, entropía Shannon, nitidez Laplaciana, filtrado NearestFilter y anti-polígonos planos | Pantallazo negro/blanco, escena unlit (<15 niveles dinámicos), monocromo plano, más de 10% de superficie plana sin textura en centro/suelo o falta de `NearestFilter` en vóxel. |
| **Fase 4: Estabilidad Cinética & Sensorial** | Cámara, física DeltaTime, audio procedural, decals y mallas compuestas | Volteos de cámara en primera persona, avance sin neutralizar eje Y (`dir.y = 0`), simulaciones mudas o cilindros planos solitarios. |
| **Fase 5: Pruebas Automatizadas** | Ejecución de suite de tests con aserciones formales | Exit code distinto de 0 o menos de 3 aserciones verificadas. |

> 🛑 **Veto Inapelable:** Si cualquiera de las 5 fases reporta un fallo, el veredicto es **`RIGOROUS_TEST_FAILED`** y el proyecto queda bloqueado. El Constructor debe resolver el defecto internamente sin molestar al usuario.

---

## 👁️ PROTOCOLO DE HIPER-ESTRICTEZ VISUAL V-HEX7 (PROHIBIDO APROBAR A LA LIGERA)

> 🛑 **MANDATO DE HIPER-ESTRICTEZ ADVERSARIAL (PROHIBIDO ENTREGAR A CIEGAS):**
> La complacencia visual está terminantemente prohibida. La IA cuenta con capacidades de visión multimodal de última generación. Queda **ESTRICTAMENTE PROHIBIDO** entregar o declarar completado cualquier proyecto con interfaz visual, canvas 3D, juego, simulación, animación o dashboard sin haber inspeccionado visualmente el renderizado real con sus propios ojos a través de `view_file` bajo el **Protocolo V-HEX7**.
>
> ⚠️ **El Arnés (`rigorous_test_harness.ps1` Fase 3) vetará y reprobará automáticamente el proyecto si:**
> - El reporte visual carece de análisis técnico en al menos 4 de los 7 vectores V-HEX7.
> - No cita cuadrantes espaciales de la cuadrícula taxonómica (`[A1]`..`[C3]`).
> - Contiene frases complacientes ("todo se ve bien", "funciona correctamente", "se ve bien") sin justificación técnica.
> - La escena presenta pantalla muerta, monocromo plano (>92% del mismo color) o iluminación plana unlit (<15 niveles dinámicos).
> - La puntuación final otorgada es inferior a **90/100**.

### Los 4 Pasos Obligatorios de Visión Hiper-Estricta:
1. **Paso 1 (Captura Automática y Métricas Cuantitativas):** Ejecutar `capture_vision.ps1 -TargetDirectory "<Ruta_del_Proyecto>"` (o `-ProcessName` / `-WindowTitle` para apps nativas).
2. **Paso 2 (Invocación Innegociable de `view_file`):** La IA **DEBE LLAMAR OBLIGATORIAMENTE A LA HERRAMIENTA `view_file`** con la ruta absoluta de `1_overview_grid` y `2_sector_center` (o `boot_rendered_screenshot.png`).
3. **Paso 3 (Escrutinio Adversarial bajo los 7 Vectores V-HEX7):**
   - **V1 - Geometría y Jerarquía de Malla:** ¿Es una primitiva básica simple (cubo o cilindro plano) o un modelo jerárquico compuesto de alta fidelidad? Detalla componentes visibles (toque de toberas, aletas, alerones, articulaciones, biseles, miras de tritio).
   - **V2 - Materiales, Shaders e Iluminación PBR:** ¿Hay fuentes de luz direccionales con sombreado por cara, brillos especulares y sombras proyectadas, o se aprecia un sombreado plano (unlit)?
   - **V3 - Nitidez de Texturas y Filtrado:** ¿Las superficies tienen textura UV rica (ladrillo, arenisca, adoquines, madera con remaches, peligro)? ¿NearestFilter activo en voxel?
   - **V4 - Integración con Suelo (Y=0) y Sombras de Contacto:** ¿El avatar, vehículo o bloques se apoyan con precisión sobre el plano Y=0 o flotan en el aire / se clipean contra el suelo?
   - **V5 - Composición de Fondo y Skybox:** ¿El fondo es un color plano estático o cuenta con skybox, domo celeste con gradiente, sol con halo, estrellas o niebla?
   - **V6 - HUD, Tipografía y Legibilidad:** ¿El texto de la interfaz y contadores tienen suficiente contraste (WCAG >= 3:1) y nitidez frente al fondo dinámico?
   - **V7 - Efectos Visuales Dinámicos y Partículas (VFX):** ¿Existen calcomanías de bala en muros (decals), partículas de impacto, humo, fuego o fogonazos (*muzzle flash*)?
4. **Paso 4 (Documentación Rigurosa en `VISUAL_INSPECTION_REPORT.md`):** Redactar `<Ruta_del_Proyecto>\VISUAL_INSPECTION_REPORT.md` basándose en la plantilla oficial `templates/STRICT_VISUAL_INSPECTION_TEMPLATE.md` con puntuación >= 95/100.

---

## 📜 RÚBRICA INQUEBRANTABLE (100 PUNTOS, CORTE >= 95)

1. **Domain_Depth_Extensibility (15 pts):** Cero maquetas de juguete. Mínimo 8-15 variantes de datos reales o entidades interactivas.
2. **Presentation_Shell_UX (15 pts):** Shell estructurado, navegación completa, configuración accesible y botón/handshake de audio.
3. **Kinetic_Asset_Integrity (15 pts):** Pitch clamp (-1.5 a 1.5 rad), `dir.y = 0`, `DeltaTime`, `NearestFilter` en voxel, texturizado 3D universal obligatorio (-10 pts si usa cajas planas sin textura), orientación correcta de cañones con `DrawCylinderEx` (-8 pts si usa cilindro vertical), calcomanías y destellos en shooters (-6 pts), audio procedural activo.
4. **Performance_Resource_Hygiene (15 pts):** Cero instanciaciones en bucles de renderizado, pooling de calcomanías, 60-120 FPS estables.
5. **Robustness_Error_Handling (15 pts):** Cero catch vacíos, error boundaries activos y validación estricta de entradas.
6. **Functional_Completeness (10 pts):** Cero TODOs/FIXMEs, cero stubs incompletos.
7. **Automated_Testing (15 pts):** Batería de pruebas automatizadas con aserciones rigurosas.
