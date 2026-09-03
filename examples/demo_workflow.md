# 🎯 Ejemplo de Flujo de Trabajo con UltraGoal

Este ejemplo demuestra cómo el arnés autónomo de UltraGoal gestiona un proyecto complejo: **Creación de una API Resiliente de Procesamiento de Pagos con Dashboard Visual**.

---

## 1. El Usuario lanza el Goal
```text
/goal Desarrolla un microservicio de procesamiento de cobros con autenticación HMAC, reintentos con backoff exponencial, suite de pruebas unitarias al 100% y un dashboard web con métricas en tiempo real.
```

---

## 2. El Orquestador desglosa y bloquea el Contrato
El Agente Orquestador no empieza a tirar código a lo loco. Primero inicializa los hitos:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action init `
  -GoalTitle "Payment Microservice & Dashboard" `
  -Milestones "1. Arquitectura & Seguridad HMAC; 2. Motor de Reintentos & Pagos; 3. Suite de Pruebas Rigurosas; 4. Dashboard Web & Verificación Visual"
```

---

## 3. Ciclo del Hito 2: Constructor -> Auditoría -> Rechazo -> Corrección

### Turno del Constructor (Worker Subagent)
El Constructor programa la lógica, pero por descuido deja un bloque `try/except: pass` y un comentario `TODO: agregar webhook`.
Envía el hito:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action submit `
  -MilestoneIndex 2 -Notes "Lógica central de pagos implementada"
```

### Turno del Auditor Crítico (Gemini Critic)
El Auditor ejecuta el escáner de rúbrica:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/evaluate_rubric.ps1 -TargetPath "./src"
```
**Resultado del Escáner:**
```json
{
  "verdict": "REJECTED",
  "score": 82,
  "threshold": 95,
  "summary": "RECHAZADO: Calidad insuficiente (82/100). Se detectaron TODOs y silenciamiento de errores."
}
```
El Auditor rechaza formalmente el hito:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action audit `
  -MilestoneIndex 2 -Score 82 -Verdict "REJECTED" `
  -Notes "Rechazado por TODO en webhook.py y catch vacío en retry.py. Mínimo requerido: 95 pts."
```

### Turno de Corrección del Constructor
El Constructor recibe el dictamen, elimina el `TODO`, implementa el webhook real y añade manejo explícito de excepciones con logging estructurado.
Vuelve a enviar. El Auditor reevalúa:
```json
{
  "verdict": "APPROVED",
  "score": 98,
  "threshold": 95,
  "summary": "CALIDAD DE EXCELENCIA: Proyecto validado y aprobado (Score 98/100)."
}
```
¡Hito Aprobado!

---

## 4. Ciclo del Hito 4: Verificación Visual con Gemini Vision
El Agente levanta el dashboard web en `http://localhost:3000` y lanza la captura de visión:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -ProcessName "chrome" -ConversationId "current-id"
```
Gemini carga la imagen con `view_file`. Analiza:
- ¿Los botones de acción están alineados?
- ¿La gráfica de transacciones por segundo es legible?
- ¿Hay algún texto superpuesto en resoluciones 1080p y 4K?
Tras confirmar que la interfaz es limpia y profesional, el Auditor firma la aprobación visual.

---

## 5. Cierre y Finalización
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action complete
```
El Orquestador emite el resumen final y la señal de completitud definitiva:
`<!-- GOAL_COMPLETE -->`