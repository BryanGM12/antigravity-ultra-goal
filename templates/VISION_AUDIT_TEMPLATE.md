# 👁️ Reporte de Auditoría Visual Adversarial (UltraGoal Vision Audit v2.1)

> **MANDATO INQUEBRANTABLE (Escrutinio Negativo Hostil):**
> La complacencia visual está estrictamente prohibida. Como Auditor de Visión, tu deber no es elogiar la escena ("se ve bonito"), sino **desarmarla meticulosamente en busca de defectos microscópicos**. 
> Si emites un veredicto de aprobación sin haber auditado individualmente el **Sector Suelo (C2)**, el **Sector HUD/Inventario (C3)** y el **Comportamiento Dinámico de Seguimiento**, tu reporte se considerará NULO y el hito será RECHAZADO.

---

## 1. Capturas y Recortes Inspeccionados
- **Captura Global con Cuadrícula:** `![Global Grid](scratch/vision_capture_XXXX.png)`
- **Recorte 1:1 Sector Suelo/Base (C2):** `![Ground Sector](scratch/sector_ground_XXXX.png)`
- **Recorte 1:1 Sector Centro/Raycast (B2):** `![Center Sector](scratch/sector_center_XXXX.png)`
- **Recorte 1:1 Sector HUD/Inventario (C3):** `![HUD Sector](scratch/sector_hud_XXXX.png)`
- **Mapa Diferencial de Interacción (Heatmap):** `![Diff Heatmap](scratch/diff_heatmap_XXXX.png)`

---

## 2. Los 7 Vectores Críticos de Falla Visual

| Vector Crítico | Estado | Evidencia y Veredicto del Auditor |
| :--- | :--- | :--- |
| **1. Continuidad de Suelo & Línea Base** | [ ] Aprobado / [ ] **VETO** | ¿Los bloques/entidades tocan el suelo real (Y=0) o flotan/desaparecen? ¿Hay vacíos negros o caras invertidas? |
| **2. Seguimiento de Cursor & Drag-and-Drop** | [ ] Aprobado / [ ] **VETO** | Al arrastrar un objeto del inventario o mover una tarjeta, ¿el elemento acompaña exactamente al cursor o se queda congelado en el slot original? *(Validar con compare_visuals.ps1)* |
| **3. Integridad de Assets & Texturas** | [ ] Aprobado / [ ] **VETO** | ¿Hay texturas faltantes (magenta/negro), UVs estiradas, costuras visibles entre voxels o artefactos de renderizado? |
| **4. Z-Index, Oclusión & Recorte** | [ ] Aprobado / [ ] **VETO** | ¿El inventario, modales o texto de la interfaz quedan tapados o se solapan con elementos del mundo 3D? |
| **5. Tipografía & Legibilidad Micro** | [ ] Aprobado / [ ] **VETO** | En el recorte HUD, ¿los números de cantidad de bloques (ej. x64) y nombres de ítems son 100% legibles sin pixelado borroso? |
| **6. Delta de Interacción Confirmado** | [ ] Aprobado / [ ] **VETO** | ¿La prueba diferencial generó un `delta_percent` > 0% con Bounding Box en la zona esperada? |
| **7. Rendimiento & Estabilidad de Cuadros** | [ ] Aprobado / [ ] **VETO** | ¿El renderizado mantiene fluidez sin pausas de Garbage Collector por instanciaciones en `animate()`? |

---

## 3. Matriz de Auditoría por Sectores (Detalle Microscópico)

### Sector [C2: Suelo y Terreno]
- **¿Se ven los bloques en el suelo?** `[ SÍ / NO ]`
- **¿Las caras superiores tienen la iluminación/textura correcta?** `[ SÍ / NO ]`
- **Anomalías detectadas:** [Detallar si hay huecos o fallas de chunk generation]

### Sector [C3: HUD e Inventario Interactivo]
- **¿Los slots de la barra de acceso rápido tienen bordes definidos?** `[ SÍ / NO ]`
- **Al hacer clic y arrastrar, ¿el sprite acompaña al puntero?** `[ SÍ / NO ]`
- **Anomalías detectadas:** [Detallar si el ítem seleccionado no sigue el cursor o si la selección visual falla]

---

## 4. Dictamen Final del Auditor de Visión
```text
[ VEREDICTO: APROBADO (7/7 Vectores sin fallo) / RECHAZADO (Requiere corrección del Builder) ]
Puntuación de Fidelidad Visual: [ XX / 100 ] (Mínimo 95)
```