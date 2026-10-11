**1. ¿Por qué un Issue sin criterios de aceptación es un problema, aunque la descripción general parezca clara?**
Porque al no tener criterios de aceptación es más difícil saber cuándo el trabajo está terminado. Permite al autor revisar de forma sencilla si cumple los criterios y al revisor validar la pull request de una forma más objetiva y rápida.

**2. Explica la diferencia entre "Refs #N" y "Closes #N" en un mensaje de commit o en la descripción de un Pull Request.**
`Refs #N` crea una referencia en GitHub que vincula el commit con el Issue, pero el Issue permanece abierto. Por el contrario, `Closes #N` cierra el Issue automáticamente en el momento exacto en el que el PR o commit se integra en la rama main.

**3. ¿Qué ocurre exactamente si intentas hacer git push directamente sobre una branch main protegida? ¿Es un error tuyo o un fallo del sistema?**
Se bloqueará la subida y devolverá un error (tipo `Protected branch update failed`). No es ni un error por parte del usuario ni del sistema, simplemente es un aviso de restricción sobre la rama main que te obliga a realizar una pull request.

**4. Un compañero te dice: "he aprobado el PR sin mirar los archivos, total ya me fío". ¿Qué riesgo tiene esa forma de revisar?**
El riesgo que presenta es que se pueden introducir errores o código no probado que pase directamente a producción.

**5. Si el reviewer pide un cambio y tú ya habías hecho push de tu branch, ¿tienes que abrir un Pull Request nuevo? Explica qué ocurre técnicamente con el PR existente cuando haces un nuevo commit.**
No, el PR está vinculado a la rama y al hacer un nuevo commit y push en esa misma rama, los cambios se añaden de forma automática a la PR.

**6. Describe con tus palabras la diferencia entre Merge commit, Squash and merge y Rebase and merge. ¿Cuál usarías para una branch con commits "wip", "fix", "fix2", "ok ya"?**
*   **Merge commit**: Deja el historial de la rama y añade un commit del merge que se realiza.
*   **Squash and merge**: Aglutina todos los commits de la rama en uno antes de aplicarlo.
*   **Rebase and merge**: Aplica los commits de la rama uno a uno y sin crear uno de merge.

Si hay muchos commits que no son cambios relevantes y son un poco “sucios” aplicaría rebase and merge así eliminaría ruido.

**7. ¿Por qué borrar una branch después del merge no elimina el trabajo realizado en ella?**
Porque una vez se ha realizado el merge, los cambios ya están en la rama main. Aunque eliminemos la rama que se creó para trabajar, todo está ya integrado en main.

**8. ¿Qué información debería contener siempre la descripción de un Pull Request, como mínimo?**
Debe seguir esta plantilla:
*   **Summary**: Resumen breve de lo que hace el cambio.
*   **Related Issue**: Enlace al problema o ticket que resuelve.
*   **Testing**: Instrucciones sobre cómo probarlo.
*   Evidencia visual (si el cambio afecta a la interfaz).

**9. Un reviewer escribe solo "esto está mal" como comentario. ¿Qué le falta a ese comentario para ser útil? Reescríbelo tú con un ejemplo inventado.**
Le falta contexto. Ese comentario genera ambigüedad y la obligación de solicitar información del error, además no aporta una enseñanza al autor.

*Ejemplo:*
> `issue (blocking): Este bucle realiza una consulta a la base de datos en cada iteración, lo que saturará el pool de conexiones. Propongo que extraigamos la consulta fuera del bucle usando un IN clause.`

**10. ¿Qué diferencia hay entre que main esté protegida y que simplemente el equipo "se ponga de acuerdo" en no hacer push directo?**
La diferencia principal es que uno es una regla acordada que puede dar pie a errores en los que se realiza la acción sin querer (en este caso hacer push sobre main) y si main simplemente tiene una regla y está protegida, no se puede cometer nunca ese error. Por lo que es mucho más seguro.

**11. Explica con un ejemplo propio la diferencia entre un comentario issue: (blocking) y uno nitpick: (if-minor) en formato Conventional Comments.**
La diferencia es el nivel de criticidad y bloqueo.
*   **`issue (blocking)`**: Identifica un error crítico que impide la aprobación hasta que se solucione. *Ejemplo:* `issue (blocking): La credencial de la API de producción está expuesta en texto plano en este archivo. Habría que moverla al gestor de secretos de Azure Key Vault.`
*   **`nitpick (if-minor)`**: Es un detalle pequeño que el autor puede elegir si implementar o ignorar. *Ejemplo:* `nitpick (if-minor): Has usado comillas dobles aquí y simples en el resto del script. Se debería unificar para cumplir con el estándar.`

**12. Si tu próximo commit es feat!: cambia la firma de la función principal de la API, ¿qué tipo de versión SemVer se dispara y por qué?**
El símbolo `!` indica BREAKING CHANGE, indica un cambio que rompe compatibilidad y fuerza un lanzamiento MAJOR (por ejemplo, pasar de la 2.1.0 a la 3.0.0).

**13. ¿Por qué abrir un Draft PR desde el primer commit estructural puede ahorrar tiempo al equipo, aunque parezca más lento para el autor individual?**
Porque un Draft PR permite que varios compañeros validen a nivel de arquitectura desde el inicio. Y es más barato que refactorizar una arquitectura equivocada. Esto se conoce como principio de Fail Fast.
