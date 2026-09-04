# 🎯 Ejemplo de Flujo de Trabajo con UltraGoal Universal v3.1

Este ejemplo demuestra cómo el arnés autónomo de UltraGoal gestiona un proyecto complejo de extremo a extremo **sin pedir feedback al usuario cada 5 minutos**: **Desarrollo de una Plataforma SaaS de Gestión de Inventarios & Facturación en Tiempo Real**.

---

## 1. El Usuario lanza el Goal
```text
/goal Desarrolla una plataforma SaaS de gestión de inventarios y facturación con autenticación JWT, panel con métricas en tiempo real, exportación a JSON/PDF y suite de pruebas rigurosas.
```

---

## 2. Fase 0: Mapeo Canónico con los 7 Niveles de Ingeniería
El Agente Orquestador no escribe código a ciegas. Primero ejecuta la investigación profunda:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/deep_planner.ps1 `
  -GoalObjective "Plataforma SaaS de Inventarios y Facturacion" `
  -OutputPath "SPECIFICATION.json"
```

El planificador detecta el dominio (`Web_or_FullStack_Application`) y descompone los 7 niveles:
1. **H1:** Shell de Navegación, Barra Superior, Menú de Ajustes y Feedback Visual.
2. **H2:** Modelo de Dominio (Entidades Invoice, Item, Customer tipadas y lógica de cálculo).
3. **H3:** Interacción Reactiva (Filtros en vivo, ordenamiento de columnas y modal de facturación).
4. **H4:** Amplitud de Contenido (Catálogo poblado con al menos 15 productos reales y estados).
5. **H5:** Resiliencia (Error boundaries, validación de formularios y reintentos en red).
6. **H6:** Rendimiento (Cero fugas de memoria, debouncing de búsqueda y cancelación de listeners).
7. **H7:** Persistencia (Almacenamiento en LocalStorage/DB con exportación/importación).
8. **H8:** Auditoría Adversarial, Visión 1:1 & Certificación Final.

El Orquestador inicializa el estado auditable:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action init `
  -GoalTitle "SaaS Inventory & Invoicing Platform" `
  -Milestones "H1;H2;H3;H4;H5;H6;H7;H8"
```

---

## 3. Autocorrección en Bucle Cerrado ("Cero Babysitting")

### Turno del Constructor (Worker Subagent)
El Constructor programa la capa de presentación y el dashboard, pero olvida el panel de ajustes (Settings) y deja una asignación dentro de un listener de scroll continuo.
Envía el hito H1:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action submit `
  -MilestoneIndex 1 -Notes "Navbar y tabla de facturas implementadas"
```

### Turno del Auditor Crítico (Gemini Critic)
El Auditor corre el escáner universal:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/evaluate_rubric.ps1 -TargetPath "./src"
```
**Resultado de la Rúbrica:**
```json
{
  "verdict": "REJECTED",
  "score": 84,
  "threshold": 95,
  "violations": [
    { "Category": "Presentation_Shell_UX", "Issue": "Falta panel de configuración/ajustes en la navegación" },
    { "Category": "Performance_Resource_Hygiene", "Issue": "Listener de scroll continuo sin debouncing" }
  ]
}
```

> 🛑 **Acción Clave de Cero Babysitting:**
> El agente **NO** envía un mensaje al usuario preguntando *"¿Quieres que agregue los ajustes?"*.
> El Auditor emite el rechazo internamente:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action audit `
  -MilestoneIndex 1 -Score 84 -Verdict "REJECTED" `
  -Notes "Rechazado internamente: falta panel de ajustes y debounce en scroll. Subsanar de inmediato."
```

### Turno de Corrección Inmediata del Constructor
En el mismo ciclo, el Constructor implementa la vista de ajustes (`SettingsModal.tsx`), aplica `lodash.debounce` al listener de scroll, y vuelve a someter a auditoría.
El Auditor reevalúa:
```json
{
  "verdict": "APPROVED",
  "score": 98,
  "threshold": 95,
  "summary": "CALIDAD DE EXCELENCIA: Hito 1 aprobado con 98/100."
}
```
¡Hito 1 Aprobado sin molestar al usuario!

---

## 4. Validación Visual 1:1 y Mapa de Calor Diferencial
Para el hito H3 (Interacción y arrastre de filas de inventario):
1. Captura inicial antes del arrastre:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -OutputPath "frame1.png"
   ```
2. Acción de arrastre simulada / movimiento.
3. Captura secundaria:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/capture_vision.ps1 -OutputPath "frame2.png"
   ```
4. Verificación diferencial:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/compare_visuals.ps1 -ImageA "frame1.png" -ImageB "frame2.png" -OutputPath "diff_heatmap.png"
   ```
5. El mapa de calor confirma con una caja delimitadora amarilla que la fila se reordenó correctamente en la interfaz.

---

## 5. Certificación Final y Entrega
Una vez completados los 8 hitos con puntuación >= 95/100:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/milestone_tracker.ps1 -Action complete
```
El agente entrega la aplicación completa, documentada y verificada:
`<!-- GOAL_COMPLETE -->`