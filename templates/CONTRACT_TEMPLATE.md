# 📜 Contrato Maestro de Finalización (UltraGoal Contract)

> **Invariante Cero-Conformismo:** Ninguna tarea bajo `/goal` se considera finalizada hasta que todos los criterios de aceptación sean validados empíricamente por el Agente Auditor con una calificación >= 95/100.

## 1. Identificación de la Meta
- **Nombre del Proyecto / Meta:** [Ej. Refactorización Integral de Motor de Red]
- **Objetivo Principal:** [Descripción exacta y no ambigua del entregable]
- **Fecha de Inicio:** [YYYY-MM-DD]
- **Director / Orquestador:** Gemini Master (Antigravity)

---

## 2. Criterios de Aceptación Empíricos (No Negociables)
Los siguientes criterios deben ser demostrables mediante ejecución de scripts o herramientas:
- [ ] **Compilación / Sintaxis:** Código compila o ejecuta sin errores (`exit code 0`).
- [ ] **Cobertura de Pruebas:** Suites de tests completas ejecutándose en verde (mínimo 95% de assertions exitosas).
- [ ] **Ausencia de Antipatrones:** 0 TODOs, 0 FIXMEs, 0 stubs (`NotImplemented`), 0 bloques `catch` vacíos.
- [ ] **Inspección Visual (UI/UX):** Captura de pantalla verificada con `view_file` (sin solapamientos, responsivo, estética impecable).
- [ ] **Seguridad e Higiene:** 0 credenciales en texto plano, dependencias limpias.

---

## 3. Desglose de Hitos (Milestones)

| Hito | Responsable | Entregable Esperado | Umbral Mínimo | Estado |
| :--- | :--- | :--- | :--- | :--- |
| **M1: Arquitectura & Diseño** | Orquestador | Especificación técnica y diagramas | 95/100 | PENDIENTE |
| **M2: Implementación Central** | Builder (Subagente) | Código modular en producción | 95/100 | PENDIENTE |
| **M3: Pruebas & Casos Borde** | Builder + QA | Suite de tests automatizada | 95/100 | PENDIENTE |
| **M4: Auditoría & Visión** | Auditor (Critic) | Reporte adversarial + Captura UI | 95/100 | PENDIENTE |

---

## 4. Firma de Cierre
- **Firma del Agente Constructor (Doer):** `[PENDIENTE]`
- **Firma del Agente Auditor (Critic):** `[PENDIENTE]`
- **Validación del Orquestador:** `[NO EMITIDA HASTA APROBACIÓN DOBLE]`