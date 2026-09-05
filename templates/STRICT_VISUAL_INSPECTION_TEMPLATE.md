# 👁️ Reporte de Inspección Visual Hiper-Estricto (Protocolo V-HEX7)

> **MANDATO DE HIPER-ESTRICTEZ (PROHIBIDO APROBAR A LA LIGERA):**
> La complacencia visual está terminantemente prohibida. Este reporte debe evaluar de forma implacable el renderizado real obtenido con capture_vision.ps1 e inspeccionado visualmente con view_file.
> **Reglas de Aprobación Innegociables:**
> 1. Debes citar al menos **2 cuadrantes taxonómicos** de la cuadrícula (ej. [B2], [C2], [A1]).
> 2. Debes auditar exhaustivamente al menos **5 de los 7 vectores V-HEX7** detallando anomalías o excelencia técnica.
> 3. Queda prohibido el fluff o frases vacías como todo se ve bien, funciona correctamente o se ve bien sin justificación técnica.
> 4. El veredicto debe incluir una **Puntuación de Fidelidad Visual: X/100** (mínimo 90/100 para aprobar).

---

## 📸 1. Capturas y Cuadrantes Inspeccionados con view_file
- **Vista General con Cuadrícula Taxonómica:** scratch/vision_capture_XXXX.png
- **Recorte 1:1 Sector Centro (Foco/Modelo):** scratch/sector_center_XXXX.png
- **Recorte 1:1 Sector Suelo (Física Y=0/Sombras):** scratch/sector_ground_XXXX.png
- **Recorte 1:1 Sector HUD (Interfaz/Legibilidad):** scratch/sector_hud_XXXX.png

---

## 🔍 2. Auditoría Detallada por Vectores V-HEX7

### [GEOMETRÍA Y COMPLEJIDAD DE MALLA]
- **Cuadrante analizado:** ej. [B2] (Centro)
- **Evaluación:** ¿Es una primitiva básica simple (cubo o cilindro plano) o un modelo jerárquico compuesto de alta fidelidad? Detalla las piezas visibles (etapas, toberas, aletas, articulaciones, biseles).
- **Hallazgos:** [Descripción técnica detallada]

### [MATERIALES, SHADERS E ILUMINACIÓN PBR]
- **Cuadrante analizado:** ej. [B2] / [B1]
- **Evaluación:** ¿Hay iluminación direccional activa, brillos especulares, gradientes de luz y sombras proyectadas, o se aprecia un sombreado plano (unlit/MeshBasicMaterial)?
- **Hallazgos:** [Descripción técnica detallada]

### [NITIDEZ DE TEXTURAS Y FILTRADO]
- **Cuadrante analizado:** ej. [B2] / [C2]
- **Evaluación:** ¿Las texturas son nítidas (NearestFilter en voxel, mapas de normales/albedo en modelos realistas)? ¿Hay texturas borrosas, UVs deformadas o texturas magenta faltantes (#ff00ff)?
- **Hallazgos:** [Descripción técnica detallada]

### [INTEGRACIÓN CON SUELO Y SOMBRAS DE CONTACTO]
- **Cuadrante analizado:** ej. [C2] (Suelo Y=0)
- **Evaluación:** ¿El avatar, vehículo o bloques se apoyan con precisión sobre el plano Y=0 o flotan en el aire / se clipean contra el suelo? ¿Se proyecta sombra de contacto (ambient occlusion)?
- **Hallazgos:** [Descripción técnica detallada]

### [COMPOSICIÓN DE FONDO Y SKYBOX]
- **Cuadrante analizado:** ej. [A1] / [A3] (Cielo/Horizonte)
- **Evaluación:** ¿El fondo es un color plano sólido estático o cuenta con skybox, gradiente atmosférico, estrellas o niebla de profundidad?
- **Hallazgos:** [Descripción técnica detallada]

### [HUD, TIPOGRAFÍA Y LEGIBILIDAD DE INTERFAZ]
- **Cuadrante analizado:** ej. [C2] / [C3] (Barra inferior/HUD)
- **Evaluación:** ¿El texto de la interfaz y contadores tienen suficiente contraste y nitidez frente al fondo? ¿Los iconos de hotbar/inventario están alineados y definidos?
- **Hallazgos:** [Descripción técnica detallada]

### [EFECTOS VISUALES DINÁMICOS Y PARTÍCULAS (VFX)]
- **Cuadrante analizado:** ej. [B3] / [C2]
- **Evaluación:** ¿Existen partículas dinámicas (humo, fuego de propulsión, chispas, polvo o estelas) o la escena carece de dinamismo visual?
- **Hallazgos:** [Descripción técnica detallada]

---

## ⚖️ 3. Veredicto Final de Hiper-Estrictez Visual
- **Vectores Evaluados Satisfactoriamente:** X / 7
- **Defectos Críticos Detectados:** [Ninguno / Lista de defectos]
- **Puntuación de Fidelidad Visual:** [ 95 / 100 ]
- **Dictamen:** APROBADO_ESTRICTO / RECHAZADO_CALIDAD_INSUFICIENTE
