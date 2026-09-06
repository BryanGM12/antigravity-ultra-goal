<div align="center">

# ⚡ UltraGoal Universal Engine v5.4.0
### The Autonomous Software Engineering Triad for Google Antigravity & OpenClaw
**OmniThink 5-Perspective Hyper-Cognition • Tech Stack Selector & Anti-HTML Monoculture • Multi-Runtime Boot Verifier • DWM Native Window & Advanced CV Metrics • 5-Phase Test Harness**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Antigravity](https://img.shields.io/badge/Antigravity-2.0%20Ready-blue.svg)](https://deepmind.google/technologies/gemini/)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-purple.svg)](https://github.com/openclaw)
[![Cognition](https://img.shields.io/badge/Hyper--Cognition-OmniThink%205--Perspective-red.svg)](#-fase-0-omnithink-hyper-cognition-5-perspectivas)
[![TechStack](https://img.shields.io/badge/Tech%20Stack-Anti--HTML%20Monoculture-orange.svg)](#-fase-05-tech-stack-selector--anti-html-monoculture)
[![Vision](https://img.shields.io/badge/Vision-DWM%20Native%20%26%20Advanced%20CV-purple.svg)](#-motor-de-visión-potenciado--captura-nativa-dwm-v540)
[![Harness](https://img.shields.io/badge/Test%20Harness-5--Phase%20Rigorous-brightgreen.svg)](#-la-batería-de-pruebas-rigurosa-de-5-fases)
[![Tests](https://img.shields.io/badge/Tests-77%2F77%20Passing-brightgreen.svg)](#-verification-suite-7777-passing)

**Autonomous engineering harness that "thinks through absolutely everything" before coding, actively selects the optimal technology stack (eradicating HTML monoculture), supports multi-runtime boot verification (Python, .NET, Rust, Web), captures native desktop/game windows via DWM Extended Frame Bounds, computes Laplacian variance, Shannon entropy, and WCAG contrast, and tests through 5 relentless phases.**

[Español](#-visión-general-en-español-v540) • [English](#-english-overview-v540) • [Tech Stack Selector](#-fase-05-tech-stack-selector--anti-html-monoculture) • [DWM Vision & CV Metrics](#-motor-de-visión-potenciado--captura-nativa-dwm-v540) • [5-Phase Harness](#-la-batería-de-pruebas-rigurosa-de-5-fases) • [Verification Suite](#-verification-suite-7777-passing)

---

</div>

## 🇪🇸 Visión General en Español (v5.4.0)

**UltraGoal Universal v5.4.0** expande radicalmente las capacidades del motor autónomo para proyectos de cualquier naturaleza:
1. **Erradicación del Monocultivo HTML (`tech_stack_selector.ps1`):** Prohíbe recurrir por defecto a maquetas en `index.html` con `<canvas>` básico. Evalúa y selecciona activamente stacks de alto rendimiento nativos (Python ModernGL/Pygame-ce, C# Raylib-cs/Godot, Rust Bevy/WGPU, Tauri, FastAPI, .NET 9).
2. **Verificación de Arranque Multi-Runtime (`verify_runtime_boot.ps1`):** Inspección y validación de arranque no solo para aplicaciones web con Chrome Headless, sino también validación de sintaxis y pre-vuelo en Python (`main.py`, `py_compile`), compilación .NET (`dotnet build`) y Rust (`cargo check`).
3. **Captura Nativa DWM de Ventanas (`capture_vision.ps1`):** Captura pixel-perfect de ventanas de escritorio o juegos mediante la API Win32 `DwmGetWindowAttribute` con `DWMWA_EXTENDED_FRAME_BOUNDS` (flag 9), descartando bordes invisibles o sombras de Windows 10/11.
4. **Métricas Avanzadas de Visión por Computadora:**
   - *Varianza Laplaciana de Nitidez (`sharpness_score` >= 15.0)*: Convolución de kernel 3x3 para detectar imágenes borrosas, texturas fuera de foco o falta de definición de bordes.
   - *Ratio de Contraste en HUD bajo Norma WCAG 2.1 (`hud_contrast_ratio` >= 3.0:1)*: Muestreo denso de percentiles 99 y 1 en la interfaz gráfica para certificar legibilidad accesible.
   - *Entropía Cromática de Shannon (`shannon_entropy` >= 0.70)*: Histograma de 256 niveles de luminancia para erradicar escenas monocromáticas planas o posterizadas.
5. **Escrutinio Empírico de Imágenes Sintéticas & Protocolo V-HEX7:** Detección de pantallazo negro, monocromo plano, unlit, congelamiento (`FROZEN_OR_NO_CHANGE`) y auditoría visual de 7 vectores obligatorios.
6. **Suite de Verificación Exhaustiva al 100%:** 77 de 77 pruebas automatizadas aprobadas.

---

## 🛠️ Fase 0.5: Tech Stack Selector & Anti-HTML Monoculture

```powershell
powershell -ExecutionPolicy Bypass -File scripts/tech_stack_selector.ps1 -GoalObjective "Haz un clon de voxel 3D nativo"
```

El selector analiza los requisitos funcionales y el dominio del problema:
- **Juegos / Simulaciones 3D:** Prioriza binarios nativos con acceso directo a GPU (Python + ModernGL, C# + Raylib-cs, Rust + Bevy) frente al sandbox del navegador.
- **Herramientas de Consola / CLI:** Rust (clap + ratatui), Go (cobra + bubbletea), PowerShell 7 + RTK Turbo.
- **Aplicaciones de Escritorio:** Rust + Tauri v2, C# + Avalonia UI / WPF XAML, Python + PyQt6.
- **Servicios Backend / APIs:** FastAPI (Pydantic v2 + SQLAlchemy 2.0), ASP.NET Core 9 Minimal APIs.

---

## 👁️ Motor de Visión Potenciado & Captura Nativa DWM (v5.4.0)

```powershell
# Captura de ventana nativa de juego o app por proceso o título con bordes DWM exactos
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -ProcessName "<nombre_proceso>" -Mode MultiStateAudit
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -WindowTitle "<titulo_ventana>" -Mode MultiStateAudit

# Captura de aplicación web en Chrome Headless
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -TargetDirectory "<ruta>" -Mode MultiStateAudit
```

| Métrica Cuantitativa de Visión | Algoritmo / Fórmula | Umbral Estricto |
| :--- | :--- | :--- |
| **Varianza Laplaciana** | $\sigma^2(\nabla^2 I)$ con kernel 3x3 | `sharpness_score >= 15.0` (Rechaza desenfoque) |
| **Ratio Contraste HUD (WCAG)** | $(L_{99} + 0.05) / (L_{01} + 0.05)$ | `hud_contrast_ratio >= 3.0:1` (Rechaza HUD ilegible) |
| **Entropía de Shannon** | $H = -\sum p_i \log_2 p_i$ | `shannon_entropy >= 0.70` (Rechaza monocromos) |
| **Bordes de Ventana DWM** | `DwmGetWindowAttribute(hWnd, 9)` | Bounding box exacto sin sombras de Windows |

---

## 🧪 La Batería de Pruebas Rigurosa de 5 Fases

```powershell
powershell -ExecutionPolicy Bypass -File scripts/rigorous_test_harness.ps1 -TargetDirectory "<Ruta_del_Proyecto>"
```

1. **Fase 1: Estático & AST:** Cero imports sin `type="module"`, cero TODOs, cero stubs.
2. **Fase 2: Arranque en Vivo Multi-Runtime:** Chrome Headless para Web, `py_compile` para Python, `dotnet build` para .NET, `cargo check` para Rust.
3. **Fase 3: Escrutinio Visual & Texturas:** Anti-pantallazo negro, anti-monocromo, anti-unlit, nitidez Laplaciana, contraste WCAG y `NearestFilter` en vóxel.
4. **Fase 4: Estabilidad Cinética & Sensorial:** Pitch clamping (-1.5 a 1.5 rad), `dir.y = 0`, física `DeltaTime`, audio procedural Web Audio API y mallas compuestas PBR.
5. **Fase 5: Pruebas Automatizadas:** Suite de unit/integration tests con aserciones formales.

---

## 🏆 Verification Suite (77/77 Passing)

```powershell
pwsh -File examples/test_verification_suite.ps1
```

```text
=================================================================
   ULTRAGOAL EXHAUSTIVE SYSTEM-WIDE VERIFICATION SUITE v5.4.0   
=================================================================

[Test 1]  OmniThink Hyper-Cognition (5 Perspectivas)........... [PASS]
[Test 2]  Universal Deep Domain Planner (7 Tiers)............. [PASS]
[Test 3]  Milestone Tracker Full Lifecycle..................... [PASS]
[Test 4]  Live Runtime Boot Verifier........................... [PASS]
[Test 5]  Rigorous 5-Phase Test Harness Core................... [PASS]
[Test 6]  Escrutinio Empírico de Imágenes Sintéticas.......... [PASS]
[Test 7]  Visual Capture Engine Multi-Mode..................... [PASS]
[Test 8]  Differential Visual Analysis & Freezing Detection.... [PASS]
[Test 9]  Asset & Sensory Resource Orchestrator................ [PASS]
[Test 10] Space Flight Simulation Sensory & Composite Gates.... [PASS]
[Test 11] Universal Quality & Anti-Toy Rubric Gatekeeper....... [PASS]
[Test 12] Procedural Web Audio Engine File Integrity.......... [PASS]
[Test 13] Architectural Templates & Contracts Integrity........ [PASS]
[Test 14] Universal Tech Stack Selector & Anti-HTML Monoculture [PASS]
[Test 15] Multi-Runtime Boot Verifier (Python, .NET, Rust)..... [PASS]
[Test 16] Advanced Computer Vision Metrics & DWM Native Engine. [PASS]

=================================================================
   RESULTADOS DE VERIFICACIÓN TOTAL: 77 PASADAS, 0 FALLIDAS
=================================================================
```

---

## 📜 Licencia

MIT License © 2026 BryanGM12 & Antigravity Autonomous Systems.
