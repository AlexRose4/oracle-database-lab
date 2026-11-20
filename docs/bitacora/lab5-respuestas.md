# Laboratorio 5. Respuestas y retrospectiva

Alejandro López Gracia. Issue #9. Rama `chore/9-oracle-dba-workflow-ii`.

Las cifras corresponden a las ejecuciones de este laboratorio. Las referencias apuntan a los registros conservados en el repositorio. Las letras de las partes corresponden al PDF y pueden diferir de la numeración del Word.

## 1. Preguntas de comprobación

### 1. Comparación de las copias del Lab 3 y del Lab 4

La copia `20261113T113719Z_lab3-final` indica `archivos_fuera_del_volumen=0` en su manifiesto. La copia del Lab 4 también informa de que no hay archivos fuera del volumen. En mi entorno ambos puntos de restauración cubrían todos los archivos inventariados dentro del volumen. La diferencia de cinco archivos externos que describe el ejemplo del enunciado no se produjo en estas copias. El manifiesto de la copia del Lab 3 permanece en `backups/`, fuera de Git. Evidencia del Lab 4, paso 6: [00-backup-lab4](lab5/evidencia/script/20261119T225615Z_00-backup-lab4.script.log).

### 2. Factor de bloqueo

CLIENTE tiene 100.000 / 1.517 = 65,92 filas por bloque y PEDIDO tiene 1.000.000 / 5.320 = 187,97. PEDIDO contiene aproximadamente 2,85 veces más filas por bloque. Su longitud media de fila es de 32 bytes, frente a 102 de CLIENTE. El espacio de cabeceras, la ocupación y la distribución explican que la proporción no dependa exclusivamente del cociente de longitudes. Evidencia: [01-perfil-tiendasur](lab5/evidencia/script/20261119T231310Z_01-perfil-tiendasur.script.log).

### 3. Dos ejecuciones por medida

La primera ejecución incluye análisis y calentamiento de caché. Se mide la segunda para comparar alternativas en condiciones calientes. La prueba de PK devolvió una fila con 4 lecturas lógicas y 0 físicas. Los tiempos dependen más del estado del equipo. Evidencia: [01-herramienta-medir](lab5/evidencia/script/20261119T231311Z_01-herramienta-medir.script.log).

### 4. Altura y ramificación

IX_PED_CLIENTE tiene altura 3, 2.216 hojas y 6 bloques de rama. Su factor de ramificación medio es (2.216 + 6 - 1) / 6, aproximadamente 370; el máximo calculado es 543. La proyección del script para mil millones de entradas da altura 4 y unas 5 lecturas para una búsqueda individual incluyendo la tabla. Es una proyección, no una carga ejecutada de mil millones de filas. Evidencia: [02-anatomia-indice](lab5/evidencia/script/20261119T232324Z_02-anatomia-indice.script.log).

### 5. ROWID de una entrada de hoja

La primera entrada de PK_CLIENTE tiene clave `c1 02`, correspondiente al cliente 1, y datos `00 00 03 1b 00 00`. Los cuatro primeros bytes identifican el bloque hexadecimal 31B, decimal 795, y los dos últimos la ranura 0. La consulta del ROWID confirmó bloque 795 y ranura 0. Es un ROWID restringido de seis bytes en un tablespace bigfile de un único archivo de datos, por lo que no necesita un campo separado para seleccionar entre varios archivos del tablespace. Evidencia: [02-anatomia-indice](lab5/evidencia/script/20261119T232324Z_02-anatomia-indice.script.log), sección 4.

### 6. Tres comparaciones de tipos de índice

- DNI: el recorrido completo necesitó 1.486 lecturas y el índice único 3. Además, el intento de duplicar el DNI produjo ORA-00001.
- Historial: el índice simple necesitó 15 lecturas, el compuesto 7 y el cubriente 3. El compuesto evita ordenar y el cubriente evita también visitar la tabla.
- Sesiones: tabla convencional con PK, 4 lecturas; IOT, 3; clúster hash, 1. La ventaja del hash corresponde a la igualdad por token. Su consulta de caducidad necesitó 2.770 lecturas mediante recorrido completo.

Evidencia: [03-tipos-indice](lab5/evidencia/script/20261119T233559Z_03-tipos-indice.script.log).

### 7. Factor de agrupamiento y REBUILD

IX_PED_FECHA tiene CF 5.220, cercano a los 5.320 bloques estadísticos, porque las fechas siguen el orden físico de carga. IX_PED_CLIENTE tiene CF 999.041, cercano al millón de filas, porque sus claves se distribuyen entre bloques de la tabla. Reconstruir el índice no cambia la organización física de las filas de la tabla y por sí solo no corrige esa causa del CF alto. Evidencia: [04-agrupamiento-equilibrio](lab5/evidencia/script/20261119T234346Z_04-agrupamiento-equilibrio.script.log).

### 8. Punto de equilibrio

El recorrido completo costó 5.232 lecturas. Con mal CF, el acceso por índice costó 4.875 lecturas al 0,5 % y 9.920 al 1 %; el cruce medido queda entre esos porcentajes. Con buen CF, el 50 % costó 3.938 y el 100 % costó 7.875; el cruce queda entre el 50 % y el 100 % de los puntos ensayados. La aproximación teórica de 1/188 da 0,53 % con costes iguales, o 0,11 % si la lectura aleatoria cuesta cinco veces más. El optimizador eligió recorrido completo desde el 0,2 % para mal CF. El coste estimado y el número de lecturas lógicas calientes son magnitudes diferentes. Evidencia: [04-agrupamiento-equilibrio](lab5/evidencia/script/20261119T234346Z_04-agrupamiento-equilibrio.script.log).

### 9. LIKE con prefijo

`Gonz%` permite delimitar un rango de claves, pero requirió 2.024 lecturas para 2.056 filas por los accesos a la tabla. El recorrido completo del caso `%ez` necesitó 1.523 lecturas y devolvió 18.902 filas. Son condiciones diferentes y sus resultados no son equivalentes. La prueba muestra que habilitar un índice no garantiza reducir las lecturas. Evidencia: [05-sargabilidad](lab5/evidencia/script/20261119T234647Z_05-sargabilidad.script.log), regla 4.

### 10. Escritura y propuesta de índices

Por INSERT, los diseños con 4, 9 y 5 índices modificaron respectivamente 10,1; 20,2 y 12,1 bloques por fila. Rechacé la propuesta global de nueve índices por su coste. IX_PED_CANAL no se utilizó en la carga observada y tenía tres valores, una selectividad media del 33,333 %. No conservé IX_PED_FEC_CLI, tampoco utilizado en esa carga; mantuve IX_PED_FECHA, usado por Q2, Q8 y Q9. El compuesto IX_PED_CLI_FEC se sustituyó por el cubriente que ya había reducido Q7 a 3 lecturas. El índice general de estado se sustituyó por el parcial de pendientes, de 54 hojas y 20.000 entradas. IX_PED_CP sí se conservó: Q3 necesitó 106 lecturas. El resultado final tiene un coste mayor de UPDATE de estado, 8,1 bloques por fila, que debe asumirse como contrapartida del diseño. Evidencias: [06-indices](lab5/evidencia/script/20261119T235021Z_06-indices.script.log) y [03-tipos-indice](lab5/evidencia/script/20261119T233559Z_03-tipos-indice.script.log).

### 11. Patrones de crecimiento

Las claves aleatorias produjeron 595 divisiones, ninguna 90/10, y una ocupación final del 75,4 %. Las crecientes produjeron 398 divisiones, todas 90/10, y ocupación del 99,9 %. La cola mostró 198 hojas vacías a la izquierda y hojas llenas a la derecha; obtener el siguiente mensaje costó 200 lecturas. El índice REVERSE tuvo 511 divisiones y ocupación del 77,9 %, con inserciones repartidas. Evidencia y mapas: [07-ejecucion-completa](lab5/evidencia/script/20261120T151211Z_07-ejecucion-completa.script.log).

### 12. Remedio para el patrón cola

Elegiría primero COALESCE, previa comprobación y planificación operativa, porque en esta prueba redujo las hojas de 399 a 201 y las lecturas de 200 a 2 sin reconstruir el índice. No redujo el segmento, que siguió en 4 MB. SHRINK SPACE recuperó espacio hasta 1,69 MB. El REBUILD posterior dejó 2 MB y las mismas 2 lecturas, sin mejora adicional de esa consulta. Son medidas sucesivas sobre el mismo índice. Para una cola sostenida revisaría el diseño y la posibilidad de particionar. Evidencia: [07c-remedios](lab5/evidencia/script/20261120T151211Z_07c-remedios.script.log).

### 13. Checkpoints y apertura

Oracle contrasta la información de checkpoint registrada para los archivos en el control file con sus cabeceras, junto con su estado y el redo disponible, para determinar la recuperación necesaria. En mi prueba, el checkpoint pasó de 3.361.664 a 3.365.792, coincidiendo este último con las cabeceras de los archivos de lectura/escritura consultados. El SCN actual alcanzó 3.365.903. PDB$SEED conservó 1.948.348 por estar en solo lectura. Evidencia: [08-scn-checkpoint](lab5/evidencia/script/20261120T151853Z_08-scn-checkpoint.script.log).

### 14. Alcance de la multiplexación

Las tres copias permiten reconstruir una copia individual perdida a partir de otra sana. Al compartir volumen, una pérdida de ese volumen afectaría a las tres. En producción se distribuirían en dominios de fallo independientes, con copias de seguridad y recuperación probada. Mi prueba recuperó control03.ctl desde control01.ctl en 4 segundos sin retroceder datos. Evidencias: [09-multiplexar-controlfile](lab5/evidencia/script/20261120T152116Z_09-multiplexar-controlfile.script.log) y [14b-perdida-controlfile](lab5/evidencia/script/20261120T155027Z_14b-perdida-controlfile.script.log).

### 15. Estados y restricciones de borrado de redo

CURRENT es el grupo donde escribe LGWR; ACTIVE contiene redo todavía necesario para recuperación de instancia; INACTIVE ya no es necesario para esa recuperación. El archivado es una condición adicional que debe comprobarse. Tras la rotación, observé los grupos 1 INACTIVE, 2 ACTIVE y 3 CURRENT, con secuencias 16, 17 y 18. Los tres tenían dos miembros y no había miembros INVALID.

El borrado del grupo CURRENT devolvió ORA-01623. Las otras dos pruebas del kit se adaptaron a comprobaciones explicativas sin borrado: no se ejecutaron tres rechazos. La premisa del enunciado no se cumple siempre, porque con tres grupos eliminar uno elegible puede dejar los dos mínimos. Tampoco se puede asumir que eliminar un miembro redundante falle en cualquier estado. Deben comprobarse estado, archivado, miembros válidos y número de grupos antes de retirar un archivo. Evidencias: [10-redo](lab5/evidencia/script/20261120T152543Z_10-redo.script.log) y [10-verificacion-miembros](lab5/evidencia/script/20261120T152643Z_10-verificacion-miembros.script.log).

### 16. Cadena de fallo de FRA

La FRA tenía 20,1 MB usados y reduje su límite en memoria a 2 MB. ORA-19815 avisó del agotamiento, ORA-19809 indicó el límite excedido y ORA-16038 informó de que la secuencia 20 no podía archivarse. Si la situación continúa, los grupos pendientes de archivar no pueden reutilizarse y las sesiones pueden esperar por archivado. En mi prueba se observó el fallo de archivado; no medí un bloqueo general de sesiones. Restauré 4.096 MB y las secuencias 20 y 21 se archivaron; el uso final fue 21,9 MB. Evidencia: [11-fra-llena](lab5/evidencia/script/20261120T153131Z_11-fra-llena.script.log).

### 17. Lectores y escritores

Mientras A cambiaba el estudiante 101 sin confirmar, B leyó ACTIVO mediante lectura consistente. A consumía un bloque y un registro de undo y mantenía bloqueos TM modo 3 y TX modo 6. La lectura ordinaria no esperó al escritor. En cambio, SELECT FOR UPDATE WAIT 3 intentó adquirir un bloqueo y terminó en ORA-00054, con detalle ORA-40097. Después del COMMIT, B vio EGRESADO; el flashback permitió restaurar ACTIVO. Evidencia: [12-lectura-consistente](lab5/evidencia/script/20261120T153620Z_12-lectura-consistente.script.log).

### 18. Undo del borrado y redo del ROLLBACK

Para 10.000 filas, DELETE consumió 427 bloques de undo frente a 141 de INSERT: debe conservar información para reconstruir filas y entradas eliminadas. UPDATE consumió 71 bloques. El ROLLBACK también modifica bloques y sus cambios necesitan protección mediante redo. Los ROLLBACK generaron 4.701 KB tras DELETE, 355 KB tras INSERT y 751 KB tras UPDATE. Evidencia: [12-undo-y-redo](lab5/evidencia/script/20261120T153854Z_12-undo-y-redo.script.log).

### 19. Durabilidad tras COMMIT y checkpoint

Con la confirmación habitual y síncrona, la durabilidad se apoya en la persistencia del redo necesario. Después de UPDATE y COMMIT medí 1.779 KB de redo, dos escrituras de redo, cero escrituras físicas desde caché y 231 bloques sucios de la tabla. Tras CHECKPOINT hubo 348 escrituras desde caché y cero bloques sucios de la tabla. Los contadores incluyen toda la instancia. El redo correspondiente debe persistirse antes de escribir los bloques de datos: es la regla de escritura anticipada. Evidencia: [13-lgwr-dbwn](lab5/evidencia/script/20261120T154052Z_13-lgwr-dbwn.script.log).

### 20. Roll forward y roll back en la caída

Tras SHUTDOWN ABORT, Oracle rehízo cambios mediante redo y deshizo los que no estaban confirmados utilizando undo. El estudiante 102 conservó EGRESADO confirmado y el 103 volvió a ACTIVO. El alert log mostró Beginning crash recovery, análisis de 1.741 KB de redo, 303 bloques necesitados de recuperación y Completed crash recovery. El arranque hasta disponibilidad tardó 4 segundos. Evidencia: [14a-caida-instancia](lab5/evidencia/script/20261120T154839Z_14a-caida-instancia.script.log).

### 21. Restauración completa y recuperación de archivo

En C restauré el volumen completo en 68 segundos y recuperé las 60.000 matrículas. La copia precedió al fallo en un segundo según el cronómetro del script; ese intervalo es la ventana potencial de cambios perdidos, no un recuento de transacciones perdidas. En D, la reparación del archivo tardó 8 segundos y la disponibilidad volvió 9 segundos después del fallo. El estudiante 104 conservó el cambio confirmado después de la copia RMAN: RPO observado 0. C vuelve al estado de la copia; D combina copia y redo posterior para recuperar el archivo. Evidencias: [14c-restauracion](lab5/evidencia/script/20261120T155208Z_14c-simulacro-restauracion.script.log) y [14d-datafile](lab5/evidencia/script/20261120T155910Z_14d-perdida-datafile.script.log).

### 22. Clasificación de los errores del runbook

En el extracto de salud aparecen ORA-00205 y ORA-00202 por el simulacro B de pérdida de control03.ctl. ORA-01110, ORA-01113 y ORA-63999 corresponden al diagnóstico y recuperación del simulacro D; el extracto incluye también una entrada histórica sobre el archivo 21. No deduzco un fallo activo únicamente de ese mensaje histórico. ORA-00800 con Set Priority Failed en LGWR/VKTM se clasifica como aviso del entorno sobre prioridad de procesos, separado de los fallos de archivos provocados. Su repetición o impacto en un entorno real requeriría revisión. El estado final confirma la CDB y la PDB abiertas, la copia RMAN completada y todas las verificaciones del laboratorio en OK. Evidencias: [15-healthcheck-ops-ro](lab5/evidencia/script/20261120T160418Z_15-healthcheck-ops-ro.script.log) y [16-verificacion-final](lab5/evidencia/script/20261120T160944Z_16-verificacion-final.script.log).

## 2. Simulacro de examen S1–S26

La tabla indica la respuesta elegida y su justificación. Donde el escenario exacto no se provocó, se distingue el fundamento teórico de la observación realizada. No se presenta una calificación automática ni una ejecución cronometrada.

| Pregunta | Respuesta | Justificación y parte relacionada |
|---|---|---|
| S1 | B | Un CF próximo a las filas implica frecuentes cambios de bloque al recorrer el índice. Parte E, CF 999.041. |
| S2 | A y C | El índice funcional admite UPPER(email); con correo normalizado, aplicar LOWER al parámetro permite usar EMAIL. Partes D y F, 4 lecturas en ambos ejemplos. |
| S3 | B | La comparación numérica introduce TO_NUMBER sobre la columna de texto. Parte F, regla 3, 5.232 frente a 106 lecturas. |
| S4 | B | Bitmap es apropiado para combinar dimensiones de baja cardinalidad con pocas escrituras concurrentes. Parte D, 4.073 frente a 528 lecturas. |
| S5 | B | SKIP SCAN permite explorar las combinaciones de la primera columna ausente. Parte D, Q6 solo ciudad, 144 lecturas. |
| S6 | B | INVISIBLE permite observar el comportamiento y revertir con VISIBLE sin reconstruir. Parte G, prueba de IX_PED_IMPORTE. |
| S7 | A y C | COALESCE fusiona hojas y SHRINK recupera espacio con operaciones en línea. Parte H, 200 a 2 lecturas; requieren considerar bloqueos breves de metadatos y condiciones operativas. |
| S8 | B | REVERSE reparte las inserciones y elimina el orden útil para rangos. Parte H, 4 frente a 878 lecturas. |
| S9 | C | Una actualización que no afecta claves ni expresiones indexadas evita el mantenimiento de esos índices. Parte G, UPDATE de estado inicial, 2 bloques por fila. |
| S10 | B | El fan-out depende de las entradas que caben en los bloques de rama. Parte C, máximo calculado 543 y altura 3. |
| S11 | A y C | La IOT almacena los datos en el árbol de su PK y evita el acceso a otra tabla para esa búsqueda. Parte D, 3 frente a 4 lecturas. |
| S12 | B | Se contrasta el checkpoint del control file con la cabecera del datafile. Parte I, sincronización observada en 3.365.792. |
| S13 | C | CKPT actualiza la información de checkpoint; DBWn escribe los bloques. Fundamento de las Partes I y N; no se trazó directamente la llamada interna de CKPT. |
| S14 | B y E | En NOMOUNT existen la instancia y los parámetros; aún no se ha montado el control file. Lab 4, arranque por etapas, y simulacro B de la Parte O, estado STARTED. |
| S15 | B | El cambio a ARCHIVELOG se hace en MOUNT. Parte L; mi base ya estaba en ARCHIVELOG, por lo que no repetí el cambio de modo. |
| S16 | B | CLEAR LOGFILE puede recrear el grupo INACTIVE ya archivado descrito. Fundamento de la Parte K; no provoqué la pérdida de un miembro único. |
| S17 | A y C | Undo proporciona lectura consistente y versiones para AS OF. Parte M, estudiante 101 ACTIVO mientras A escribía y en el flashback. |
| S18 | B | Los bloques de undo necesitan rehacerse tras una caída para poder deshacer las transacciones pendientes. Parte M, redo del undo medido. |
| S19 | A | En la confirmación síncrona habitual se ha persistido el redo necesario, aunque queden datos sucios en caché. Parte N, 231 bloques sucios tras COMMIT. |
| S20 | A | Un objetivo de MTTR menor exige mayor trabajo de checkpoint para acortar la recuperación. Fundamento de la Parte I; no cambié el parámetro de 300 a 30. |
| S21 | B | La falta de archivado impide reutilizar redo, por ejemplo por FRA llena. Parte L, ORA-19809 y ORA-16038. |
| S22 | B | Si la base/PDB permanece abierta, se aísla el archivo afectado antes de RESTORE y RECOVER. Parte O, simulacro D; en mi caso Oracle cerró la PDB y se utilizó el camino MOUNTED. |
| S23 | B | La pérdida de SYSTEM de la raíz requiere recuperación con la base montada. Fundamento de la Parte O; el archivo perdido en mi prueba fue de TBS_ACADEMIA, no SYSTEM. |
| S24 | B | Sin redo archivado, la opción general del escenario es restaurar la copia consistente y perder cambios posteriores. Fundamento de L y O; el simulacro C restauró una copia fría, pero mi base estaba en ARCHIVELOG. |
| S25 | B y D | Más capacidad y retención de undo ayudan a conservar versiones; RETENTION GUARANTEE evita sobrescribir undo no expirado, con riesgo de afectar DML si se agota espacio. Parte M como fundamento; no provoqué ORA-01555 ni activé GUARANTEE. |
| S26 | A | V$RECOVERY_AREA_USAGE desglosa la FRA por tipo de archivo. Parte L, consulta de ARCHIVED LOG. |

## 3. Tabla de recuperación y retrospectiva

| Simulacro | Medida obtenida | RPO y observación | Mejora del procedimiento |
|---|---|---|---|
| A, caída | 4 s desde el inicio del arranque hasta disponibilidad | RPO 0 observado: 102 conservó EGRESADO y 103 quedó ACTIVO. | Añadir medición desde el fallo y comprobación explícita del estado final. |
| B, control file | 4 s desde la eliminación hasta disponibilidad | RPO 0 observado; se recuperó control03.ctl desde control01.ctl. | Distribuir copias en dominios de fallo independientes en producción. |
| C, tabla con PURGE | 68 s de restauración | Vuelta al estado de la copia; ventana potencial medida de 1 s. Se recuperaron 60.000 matrículas. | Evaluar recuperación de tabla puntual cuando se deba conservar el resto de cambios. |
| D, datafile | 8 s de reparación; 9 s desde el fallo | RPO 0 observado; sobrevivió el cambio posterior a la copia. FREEPDB1 quedó MOUNTED durante la reparación. | Mantener en el runbook los caminos de PDB abierta y PDB montada. |

La recuperación de un archivo mediante RMAN fue más breve que la restauración del volumen completo y conservó el cambio posterior a la copia. Los intervalos de cronometraje no son idénticos entre pruebas; una mejora es medir en todos los casos desde la pérdida de servicio hasta su validación funcional. Las copias se comprobaron mediante restauración real.

## 4. Retrospectiva de FRA llena

- Impacto observado: fallo al archivar la secuencia 20. No se midió un bloqueo general de DML ni pérdida de datos confirmados.
- Detección: ORA-16038 y ORA-19809 en la sesión; ORA-19815 en el alert log.
- Causa de esta prueba: reducción deliberada del límite de la FRA de 4.096 MB a 2 MB, teniendo 20,1 MB utilizados.
- Mitigación aplicada: devolver el límite en memoria a 4 GB y solicitar de nuevo el archivado. Las secuencias 20 y 21 quedaron archivadas; uso final 21,9 MB.
- Prevención: consulta de alerta al superar el 85 %, vigilancia de capacidad y política de copias y archivados. La alerta devolvió cero filas con la ocupación final observada.
- Caso L.3 del enunciado: repetir cargas masivas en ARCHIVELOG puede llenar una FRA de 4 GB y dejar sesiones esperando archivado. Es el caso explicado por el profesor; mi reproducción fue la reducción controlada del límite descrita arriba.

Evidencias: [11-fra-llena](lab5/evidencia/script/20261120T153131Z_11-fra-llena.script.log) y [15-alerta-fra](lab5/evidencia/script/20261120T160941Z_15-alerta-fra.script.log). Consulta de alerta en `scripts/lab5/15-alerta-fra.sql`; procedimiento de recuperación en `docs/runbooks/perdida-datafile.md`.

## 5. Comprobaciones complementarias

- Reto B: 5.220 bloques con filas, mínimo 2, media 191,57 y máximo 200 filas por bloque. La media NUM_ROWS/BLOCKS es 187,97 al usar 5.320 bloques estadísticos. Evidencia: [01-reto-bfr](lab5/evidencia/script/20261119T232037Z_01-reto-bfr.script.log).
- Salud: CDB y PDB abiertas, FRA 88/4.096 MB, tres control files, cero grupos con un único miembro, copia RMAN COMPLETED y cero ORA-01555 y faltas de espacio de undo. Los índices sin estadísticas en otros esquemas requieren considerar si las tablas contienen datos. Evidencia: [15-healthcheck-ops-ro](lab5/evidencia/script/20261120T160418Z_15-healthcheck-ops-ro.script.log).
- Los 11 cambios de log observados en la franja de pruebas incluyen rotaciones forzadas y simulacros. Una frecuencia elevada sostenida en producción se interpretaría junto con el tamaño del redo, la carga y las esperas. Si no hubiera copias RMAN recientes, comprobaría los trabajos y sus errores, avisaría al responsable y priorizaría generar y verificar una copia conforme al procedimiento del servicio.
- Verificación final: todas las comprobaciones en OK. Evidencia: [16-verificacion-final](lab5/evidencia/script/20261120T160944Z_16-verificacion-final.script.log).
