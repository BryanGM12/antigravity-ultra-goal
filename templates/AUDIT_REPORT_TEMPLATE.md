# 🛡️ Reporte de Auditoría y Calidad Adversarial (UltraGoal Audit)

> **Regla de Oro:** El Agente Auditor opera como Red Team/Inspector de Calidad. Su objetivo es encontrar defectos, casos borde no contemplados, fragilidad y deuda técnica. Si la puntuación global es menor a **95/100**, el hito es **RECHAZADO**.

---

## 1. Metadatos de Auditoría
- **Hito Evaluado:** [Ej. Hito 2: Implementación Central del Motor]
- **Auditor:** Gemini Critic (Overseer Subagent)
- **Fecha:** [YYYY-MM-DD HH:mm:ss]
- **Veredicto Final:** `[ APROBADO (Score >= 95) / RECHAZADO (Score < 95) ]`
- **Puntuación Global:** `[ XX / 100 ]`

---

## 2. Matriz de Evaluación Detallada

| Dimensión | Puntos Máx. | Puntos Obtenidos | Observaciones del Auditor |
| :--- | :--- | :--- | :--- |
| **1. Completitud Funcional** (0 TODOs, 0 Stubs) | 30 | [ ] | [Verificación de que todo lo especificado existe] |
| **2. Robustez & Manejo de Errores** | 20 | [ ] | [Resiliencia ante entradas inválidas, fallos de red/I/O] |
| **3. Arquitectura, Modularidad & SOLID** | 15 | [ ] | [Código limpio, sin duplicación ni dependencias circulares] |
| **4. Rigor de Pruebas Automatizadas** | 15 | [ ] | [Tests unitarios/integración con aserciones reales] |
| **5. Fidelidad Visual & UX / Terminal** | 10 | [ ] | [Verificación de interfaces o salidas de consola legibles] |
| **6. Seguridad & Cero Secretos** | 10 | [ ] | [Sin tokens, llaves expuestas ni vulnerabilidades obvias] |
| **TOTAL** | **100** | **[ ]** | **Umbral requerido: >= 95** |

---

## 3. Hallazgos Críticos y Casos Borde Identificados
1. **[Defecto / Vulnerabilidad 1]:** [Descripción precisa del fallo, archivo y línea]
2. **[Defecto / Vulnerabilidad 2]:** [Descripción precisa del fallo, archivo y línea]

---

## 4. Plan de Remediación Obligatorio (Para el Agente Constructor)
> El Builder DEBE resolver cada uno de estos puntos antes de solicitar una nueva auditoría.
- [ ] Acción Correctiva 1: [Detalle exacto]
- [ ] Acción Correctiva 2: [Detalle exacto]

---

## 5. Dictamen del Auditor
```text
[ FIRMA DIGITAL DEL AUDITOR: APROBADO / RECHAZADO ]
```