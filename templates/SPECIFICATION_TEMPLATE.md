# 📐 Especificación Técnica Universal & Análisis Pre-Mortem (UltraGoal Universal v3.1)

> **Invariante de Autodeterminación:** El agente ejecuta de forma completamente autónoma sin solicitar feedback constante al usuario, resolviendo internamente los defectos mediante el bucle Constructor-Auditor hasta cumplir los 7 Niveles Universales con una calificación >= 95/100.

---

## 1. Identificación del Proyecto & Clasificación de Dominio
- **Objetivo del Usuario:** [Texto exacto del usuario]
- **Categoría Detectada:** `[ Web_or_FullStack_Application / Backend_Service_or_API / CLI_or_Systems_Tool / Desktop_Application / Interactive_Simulation_or_Game / General_Software_System ]`
- **Patrón de Arquitectura:** [Ej. Clean Architecture, MVC, Hexagonal, Event-Driven, Micro-Frontend]

---

## 2. Análisis Pre-Mortem: Las 5 Trampas de "Demo de Juguete"
*¿De qué 5 maneras este proyecto parecería una maqueta de juguete si tomáramos atajos?*
1. **Trampa 1 (Shell & Navegación):** [Ej. Contenedor plano sin rutas, sin menú de inicio ni opciones de configuración] -> **Defensa Obligatoria:** [Shell estructurado con navegación completa y ajustes]
2. **Trampa 2 (Profundidad de Lógica):** [Ej. Lógica hardcodeada para 1 solo caso estático] -> **Defensa Obligatoria:** [Modelos tipados y registros extensibles]
3. **Trampa 3 (Interacción & Estado):** [Ej. Clics que no actualizan el estado o arrastre que no acompaña al cursor] -> **Defensa Obligatoria:** [Sincronización bidireccional reactiva verificable con mapas diferenciales]
4. **Trampa 4 (Pobreza de Contenido):** [Ej. Solo 2 o 3 elementos de prueba] -> **Defensa Obligatoria:** [Catálogo de al menos 8 a 15 entidades o datos realistas]
5. **Trampa 5 (Resiliencia):** [Ej. Silenciamiento de errores o pantallas en blanco al fallar] -> **Defensa Obligatoria:** [Error boundaries, reintentos con backoff y validación de entradas]

---

## 3. Desglose de los 7 Niveles Universales de Ingeniería

| Nivel Universal | Requisitos Técnicos Obligatorios | Criterio de Aceptación Empírico |
| :--- | :--- | :--- |
| **N1: Shell & Presentación** | Menú/Navbar, opciones de configuración, feedback de carga y pantallas de error | Interfaz navegable con rutas y ajustes funcionales |
| **N2: Dominio & Reglas** | Entidades tipadas, validación de esquemas y lógica desacoplada de la vista | Cobertura de pruebas unitarias de todas las reglas |
| **N3: Interacción & Estado** | Drag-and-drop, filtros en vivo, atajos y reactividad fluida | Mapa diferencial de interacción verificado sin desfase |
| **N4: Contenido & Variedad** | Catálogo rico (>= 8-15 variantes representativas) | Registro de datos poblado con propiedades diversas |
| **N5: Resiliencia & Fallos** | Manejo de excepciones, error boundaries y reintentos en red/E/S | Pruebas de estrés ante entradas inválidas |
| **N6: Rendimiento & Higiene** | Cero allocations en bucles calientes, cancelación de listeners, fluidez 60 FPS / <100ms | Escáner de rúbrica sin alertas de allocations en render |
| **N7: Persistencia & Ciclo** | Persistencia entre sesiones (LocalStorage/DB/JSON) y cierre limpio | El estado se recupera intacto tras reiniciar el proceso |

---

## 4. Compromiso de Autonomía Total (Zero Babysitting)
El Constructor y el Auditor se comprometen a iterar de manera continua hasta que todos los hitos alcancen el estado `APPROVED` con puntaje >= 95/100, sin trasladar la carga de validación al usuario.