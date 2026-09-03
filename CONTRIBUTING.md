# 🤝 Contribuyendo a UltraGoal

¡Gracias por tu interés en contribuir a **UltraGoal**!

## Principios del Proyecto
1. **Invariante Cero-Conformismo:** Todo código, script o plantilla debe perseguir el 100% de solidez. No aceptamos pull requests con stubs incompletos o falta de tests.
2. **Multi-Agente First:** Las mejoras deben reforzar la colaboración entre el Agente Orquestador, el Constructor (Worker), el Auditor Crítico y el Motor de Visión.
3. **Compatibilidad:** Todos los scripts deben ser compatibles con PowerShell 7+ y plataformas multiplataforma cuando aplique.

## Pasos para Contribuir
1. Haz un fork del repositorio.
2. Crea una rama descriptiva (`git checkout -b feature/nueva-mejora`).
3. Ejecuta la suite de verificación local:
   ```powershell
   powershell -ExecutionPolicy Bypass -File examples/test_verification_suite.ps1
   ```
4. Asegúrate de que las 9 pruebas pasen en verde.
5. Realiza tus commits con mensajes convencionales (`feat: ...`, `fix: ...`, `docs: ...`).
6. Abre un Pull Request describiendo tu propuesta.