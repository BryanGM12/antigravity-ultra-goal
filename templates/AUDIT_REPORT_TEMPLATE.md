# 🛡️ Reporte de Auditoría y Calidad Adversarial (UltraGoal Universal Audit v3.1)

> **Regla de Oro:** El Agente Auditor opera como Red Team e Inspector de Calidad autónomo. Su objetivo es encontrar defectos, fragilidad técnica, maquetas incompletas o fugas de rendimiento. Si la puntuación global es menor a **95/100**, el hito es **RECHAZADO internamente** y devuelto al Constructor sin molestar al usuario.

---

## 1. Metadatos de Auditoría
- **Hito Evaluado:** [Ej. Hito 2: Modelo de Dominio & Reglas de Negocio]
- **Auditor:** Gemini Critic (Overseer Subagent)
- **Fecha:** [YYYY-MM-DD HH:mm:ss]
- **Veredicto Final:** `[ APROBADO (Score >= 95) / RECHAZADO (Score < 95) ]`
- **Puntuación Global:** `[ XX / 100 ]`

---

## 2. Matriz de Evaluación Detallada (Rúbrica Universal de 100 Puntos)

| Dimensión de Ingeniería | Puntos Máx. | Puntos Obtenidos | Observaciones del Auditor |
| :--- | :--- | :--- | :--- |
| **1. Profundidad de Dominio & Extensibilidad** | 20 | [ ] | [Entidades tipadas, esquemas y lógica extensible (no hardcodeada)] |
| **2. Shell de Usuario, Navegación & UX** | 15 | [ ] | [Menú de inicio, navegación fluida, panel de ajustes o CLI help] |
| **3. Higiene de Recursos & Rendimiento** | 15 | [ ] | [Cero allocations en bucles calientes, sin fugas ni GC spikes] |
| **4. Robustez & Blindaje ante Errores** | 15 | [ ] | [Cero catch vacíos, error boundaries y reintentos en red/E/S] |
| **5. Sincronización de Interacción & Estado** | 10 | [ ] | [Drag-and-drop, filtros en vivo y estado reactivo sin lag] |
| **6. Completitud Funcional (0 TODOs/Stubs)** | 10 | [ ] | [0 TODOs, 0 FIXMEs, 0 stubs NotImplemented, 0 secretos] |
| **7. Rigor de Pruebas Automatizadas** | 15 | [ ] | [Suites de tests con aserciones reales y exit code 0] |
| **TOTAL** | **100** | **[ ]** | **Umbral requerido: >= 95** |

---

## 3. Hallazgos Críticos y Casos Borde Identificados
1. **[Defecto / Vulnerabilidad 1]:** [Descripción precisa del fallo, archivo y línea]
2. **[Defecto / Vulnerabilidad 2]:** [Descripción precisa del fallo, archivo y línea]

---

## 4. Plan de Autocorrección Obligatorio (Para el Constructor - Sin Feedback del Usuario)
> El Constructor DEBE resolver cada uno de estos puntos de forma autónoma antes de la re-auditoría.
- [ ] Acción Correctiva 1: [Detalle exacto de la solución técnica]
- [ ] Acción Correctiva 2: [Detalle exacto de la solución técnica]

---

## 5. Dictamen del Auditor
```text
[ FIRMA DIGITAL DEL AUDITOR: APROBADO (>= 95) / RECHAZADO (< 95) ]
```