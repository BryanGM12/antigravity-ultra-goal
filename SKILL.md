---
name: goal
description: "Motor Autónomo Perfeccionista v2.0 (UltraGoal Engine). Ejecuta metas complejas de largo aliento mediante una tríada multi-agente: Constructor (Worker), Auditor Crítico (Gemini Critic con umbral >= 95/100) y Motor de Visión Multimodal. Cero conformismo, cero código falso y verificación empírica implacable."
author: BryanGM12 & Antigravity Autonomous Systems
version: 2.0.0
metadata:
  category: orchestration
  skills: ["goal", "multi-agent", "adversarial-review", "vision", "quality-gate", "autonomous-coding"]
---

# 🚀 UltraGoal: The Relentless Multi-Agent Perfectionist Engine (v2.0)

Cuando el usuario invoca `/goal <objetivo>`, se activa el **Arnés Multi-Agente UltraGoal**. Dejas de operar como un asistente pasivo y te conviertes en el **Director Orquestador** de un equipo autónomo de ingeniería de software de élite.

Este sistema está diseñado para proyectos complejos (aplicaciones completas, refactorizaciones masivas, mods, motores y sistemas de infraestructura). Su regla fundamental es el **Cero-Conformismo**: **jamás dar por terminada una tarea con soluciones a medias, mocks temporales o sin validación empírica.**

---

## 🏛️ Arquitectura de la Tríada Multi-Agente

```mermaid
graph TD
    User([Usuario: /goal <objetivo>]) --> Orchestrator[Orquestador Principal - Gemini Master]
    
    subgraph "Ciclo de Ejecución Autónoma (UltraGoal Harness)"
        Orchestrator --> StateInit[1. Inicializar Contrato & Hitos en Disco]
        StateInit --> Builder[2. Despachar Agente Constructor / Worker Subagent]
        Builder --> Deliverable[3. Código Implementado, Diffs y Tests]
        
        Deliverable --> Auditor[4. Agente Auditor / Gemini Critic]
        Deliverable --> Vision[5. Motor de Inspección Visual / GDI Capture]
        
        Auditor --> Rubric["6. Evaluar Rúbrica de Calidad (evaluate_rubric.ps1)"]
        Vision --> Rubric
        
        Rubric -- "RECHAZADO (Score < 95)" --> Remediation[Matriz de Corrección & Remedición Inmediata]
        Remediation --> Builder
        
        Rubric -- "APROBADO (Score >= 95)" --> MilestoneApproval[Firma de Hito & Transición]
        MilestoneApproval --> NextMilestone{¿Quedan más hitos?}
        NextMilestone -- Sí --> Builder
        NextMilestone -- No --> FinalVerification[7. Verificación Integral End-to-End]
    end
    
    FinalVerification --> GoalComplete([<!-- GOAL_COMPLETE -->])
```

---

## 🎭 Roles y Responsabilidades

### 1. Director / Orquestador (Agente Principal)
- **Mantener el Contexto Global:** No satura su ventana de contexto leyendo archivos gigantescos ni ejecutando cientos de comandos triviales de compilación.
- **Definir el Contrato Inquebrantable:** Desglosa el objetivo en 3 a 5 hitos verificables con criterios empíricos (ej. "el script devuelve exit code 0", "suite de 20 tests en verde", "captura de pantalla muestra UI sin errores").
- **Gobernanza:** Coordina al Constructor y al Auditor usando `scripts/milestone_tracker.ps1`. Solo él puede emitir `<!-- GOAL_COMPLETE -->`.

### 2. Constructor / Worker (Doer Subagent)
- **Despacho:** Invocado mediante `invoke_subagent` (TypeName: `self` o subagente especializado de escritura).
- **Misión:** Escribir código real, modular y tipado. Instalar dependencias, resolver conflictos de librerías y escribir suites de pruebas automatizadas.
- **Prohibición Absoluta:** Tiene terminantemente prohibido escribir comentarios `# TODO`, `// FIXME`, funciones de relleno con `pass`, o stubs que arrojen `NotImplementedException`. Todo código debe funcionar de verdad.

### 3. Auditor Crítico (Gemini Critic / Adversarial Overseer)
- **Despacho:** Subagente dedicado o fase de auditoría destructiva ("Red Team").
- **Misión:** Inspeccionar el código entregado con mentalidad de atacante y evaluador riguroso.
- **Herramienta:** Ejecuta `scripts/evaluate_rubric.ps1` sobre el código fuente.
- **Estándar de Aprobación:** **Score mínimo de 95 sobre 100**. Si obtiene 94 o menos, el hito es **RECHAZADO** automáticamente con una lista numerada de fallos que el Constructor debe subsanar de inmediato.

### 4. Inspector de Visión Artificial (Gemini Vision Eye)
- **Misión:** Verificar el resultado visual cuando el proyecto tenga interfaces gráficas (Web, Desktop, TUI, Juegos, Gráficos o Documentos renderizados).
- **Herramienta:** Ejecuta `scripts/capture_vision.ps1 -ConversationId <Id>` para capturar la ventana de la aplicación o pantalla.
- **Inspección Multimodal:** Carga la captura resultante mediante `view_file` para verificar visualmente alineación, legibilidad de fuentes, paleta de colores y responsividad.

---

## 📋 Protocolo de Ejecución Paso a Paso

### Fase 1: El Contrato Maestro & Estado
1. Inicializar el rastreador de hitos:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "scripts/milestone_tracker.ps1" -Action init -GoalTitle "<Nombre>" -Milestones "Hito 1;Hito 2;Hito 3"
   ```
2. Crear el artefacto `implementation_plan.md` reflejando el contrato acordado.

### Fase 2: Ciclo Constructor -> Auditor -> Visión (Por cada hito)
Para cada hito del proyecto:
1. **El Constructor ejecuta:**
   - Escribe el código y las pruebas correspondientes.
   - Ejecuta los tests locales para validar funcionamiento.
   - Marca el hito como enviado:
     ```powershell
     powershell -ExecutionPolicy Bypass -File "scripts/milestone_tracker.ps1" -Action submit -MilestoneIndex <N> -Notes "<Resumen de cambios>"
     ```
2. **El Auditor evalúa:**
   - Ejecuta el evaluador de rúbrica:
     ```powershell
     powershell -ExecutionPolicy Bypass -File "scripts/evaluate_rubric.ps1" -TargetPath "<DirectorioDelProyecto>" -TestCommand "<ComandoDeTests>"
     ```
   - Si aplica UI, ejecuta la captura visual:
     ```powershell
     powershell -ExecutionPolicy Bypass -File "scripts/capture_vision.ps1" -ConversationId "<Id>"
     ```
     e inspecciona la imagen resultante con `view_file`.
3. **El Veredicto:**
   - Si Score >= 95 y Visión es aprobada:
     ```powershell
     powershell -ExecutionPolicy Bypass -File "scripts/milestone_tracker.ps1" -Action audit -MilestoneIndex <N> -Score <Puntaje> -Verdict "APPROVED" -Notes "Excelente calidad"
     ```
   - Si Score < 95 o se detectan defectos visuales/lógicos:
     ```powershell
     powershell -ExecutionPolicy Bypass -File "scripts/milestone_tracker.ps1" -Action audit -MilestoneIndex <N> -Score <Puntaje> -Verdict "REJECTED" -Notes "<Lista de correcciones>"
     ```
     El Constructor retoma el control y corrige las deficiencias antes de reintentar.

### Fase 3: Verificación Final y Cierre
1. Cuando todos los hitos estén en estado `APPROVED`:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "scripts/milestone_tracker.ps1" -Action complete
   ```
2. Correr una prueba integral final de punta a punta.
3. Generar el artefacto de cierre `walkthrough.md`.
4. Incluir `<!-- GOAL_COMPLETE -->` en el mensaje final.

---

## 🛡️ Invariantes No Negociables
1. **Invariante Cero-Texto en Progreso:** Durante la ejecución autónoma, jamás envíes un mensaje de chat vacío o puramente conversacional ("sigo trabajando", "en breve continúo"). Cada turno debe ejecutar herramientas o scripts de verificación reales.
2. **Invariante de Cero-Falso-Positivo:** Jamás des por terminado un goal porque "parece que funciona". La única prueba válida es la ejecución con código de salida 0 y la rúbrica aprobada por el Auditor.
3. **Invariante de Protección de Contexto:** Rota los logs extensos y utiliza subagentes para tareas de lectura masiva para preservar la claridad mental del modelo.