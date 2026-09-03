# 📐 Especificación Técnica Exhaustiva & Análisis Pre-Mortem (UltraGoal Spec v3.0)

> **Invariante Anti-Juguete:** Toda meta compleja debe expandirse en sus **6 Pilares Canónicos** antes de escribir código. Se prohíbe terminantemente reducir una aplicación completa a una demo superficial de 2 pantallas.

---

## 1. Identificación del Objetivo & Dominio Canónico
- **Objetivo del Usuario:** [Texto exacto del usuario, ej. "has un clon de minecraft tal cual"]
- **Categoría Detectada:** `[ Interactive_Game / Web_Application / Backend_Service / General_Software ]`
- **Software Canónico de Referencia:** [Ej. Minecraft Java Edition / Trello / Stripe API]

---

## 2. Análisis Pre-Mortem: Las 5 Trampas de "Demo de Juguete"
*¿De qué maneras este proyecto podría quedar como una maqueta mediocre si no nos auto-exigimos?*
1. **Trampa 1 (Shell/Menús):** [Ej. Poner solo "Haz clic para continuar" en vez de un menú con título, opciones y música] -> **Defensa Obligatoria:** [Menú de inicio completo con settings]
2. **Trampa 2 (Entidades/Vida):** [Ej. Dejar el mundo completamente estático sin animales] -> **Defensa Obligatoria:** [Al menos 2 mobs con máquina de estados de deambulación]
3. **Trampa 3 (Perspectiva):** [Ej. Solo cámara en primera persona] -> **Defensa Obligatoria:** [Soporte para 1ra y 3ra persona con tecla F5]
4. **Trampa 4 (Pobreza de Contenido):** [Ej. Solo 2 o 3 tipos de bloques] -> **Defensa Obligatoria:** [Catálogo de al menos 10 bloques con caras y propiedades distintas]
5. **Trampa 5 (Mecánicas Incompletas):** [Ej. Crafteo de 1 botón hardcodeado] -> **Defensa Obligatoria:** [Cuadrícula de crafteo 2x2 y 3x3 con motor de recetas]

---

## 3. Desglose de los 6 Pilares Canónicos de Ingeniería

| Pilar Canónico | Requisitos No Negociables | Responsable | Criterio de Verificación Empírica |
| :--- | :--- | :--- | :--- |
| **P1: Shell, Menús & Audio** | Menú de inicio real, menú de pausa (ESC), ajustes y audio | Builder | Captura visual del menú y comprobación de eventos de botón |
| **P2: Controles & Perspectiva** | 1ra/3ra persona (F5), mira con wireframe, física sólida AABB | Builder | Pruebas de movimiento y toggling de cámara |
| **P3: Entidades & IA** | Al menos 2 criaturas vivas con IA de deambulación y colisión | Builder | Test de spawn y actualización de coordenadas de mobs |
| **P4: Riqueza de Contenido** | >= 10 tipos de bloques/materiales con texturas diferenciadas | Builder | Verificación de array de texturas y registro de bloques |
| **P5: Mecánicas & Crafteo** | Cuadrícula 2x2 / 3x3, motor de recetas, inventario drag & drop | Builder | Prueba diferencial con compare_visuals y unit tests de recetas |
| **P6: Ambiente & Guardado** | Ciclo día/noche, partículas y guardado en disco/LocalStorage | Builder | Test de serialización JSON y recarga de estado |

---

## 4. Desglose de Hitos en goal_state.json
*El proyecto se ejecuta en un mínimo de 6 a 7 hitos profundos, asegurando la cobertura total del dominio.*