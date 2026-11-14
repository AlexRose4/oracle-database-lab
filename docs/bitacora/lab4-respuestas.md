# Laboratorio 4 · Oracle DBA Workflow I

## Preguntas de comprobación

### 1. ¿Por qué la copia en frío es consistente?

Ejecuté SHUTDOWN IMMEDIATE antes de copiar el volumen. Oracle cerró la base de datos de forma ordenada y dejó los archivos en un estado coherente. Si hubiera copiado los archivos con la base abierta, podrían haber cambiado durante la copia y corresponder a momentos distintos. Una copia en caliente requiere un procedimiento que permita recuperar la base con redo.

### 2. ¿Para qué sirven el manifiesto y SHA256SUMS?

El manifiesto identifica el respaldo y el entorno del que se tomó. SHA256SUMS registra las sumas de los archivos de la copia. Antes de restaurar, el script comprueba esas sumas para detectar archivos ausentes o alterados. En mi verificación, extras.lst, inventario.txt, manifiesto.txt y volumen.tar.gz devolvieron OK.

### 3. ¿Qué son el RPO y el RTO en este respaldo?

El RPO indica cuántos datos se admite perder. Con esta copia podría volver al estado del Lab 3 del 13 de noviembre de 2026 a las 11:37:19 UTC. Los cambios posteriores quedarían fuera de ese punto de restauración. El RTO indica cuánto tiempo se admite tardar en recuperar el servicio. En este laboratorio verifiqué la integridad de la copia y el arranque de la base original. Para medir el tiempo real de recuperación tendría que cronometrar una restauración completa.

Evidencia de las preguntas 1 a 3: [registro de la copia en frío y verificación SHA-256](lab4/evidencia/script/20261113T113718Z_00-backup-lab3.script.log).

### 4. ¿Dónde creó Oracle los datafiles de V000 y por qué?

V000 usaba nombres relativos para los archivos y `db_create_file_dest` estaba vacío. Oracle registró los cinco datafiles de negocio bajo `$ORACLE_HOME/dbs`. En mi instalación, `dbs` era un enlace simbólico a `/opt/oracle/oradata/dbconfig/FREE/dbs`, por lo que los archivos ya estaban físicamente dentro del volumen persistente. Configurar `DB_CREATE_FILE_DEST` y dejar que Oracle genere los nombres con OMF habría permitido usar un destino gestionado explícitamente.

Evidencia: [diagnóstico inicial](lab4/evidencia/script/20261113T115148Z_01-diagnostico-inicial.script.log), secciones 4 y 5 y comprobación de las rutas reales.

### 5. ¿Por qué ALTER TABLESPACE ... RENAME DATAFILE no basta para mover un archivo?

RENAME DATAFILE actualiza la ruta que Oracle tiene registrada. La copia física es un paso aparte. Puse cada tablespace fuera de línea, copié su archivo a la carpeta estándar de FREEPDB1 y actualicé la ruta en Oracle. Después volví a poner el tablespace en línea y eliminé el original. La comprobación final mostró los cinco archivos como AVAILABLE y un límite de crecimiento de 1024 MB por archivo.

Evidencia: [reubicación de los datafiles](lab4/evidencia/script/20261113T115757Z_03-reubicar-datafiles.script.log), sección 3.

### 6. ¿Por qué se crea V003 y se conserva V000? ¿Por qué hay que invalidar la contraseña antigua?

V000 ya se había aplicado en el Laboratorio 3. V003 deja constancia de la corrección y permite aplicarla sobre una base existente. Borrar una contraseña del archivo dejaría intacta la credencial que Oracle aceptaba y las copias que ya pudieran existir en el historial de Git. Con V003, las cinco cuentas propietarias quedaron con AUTHENTICATION_TYPE = NONE. Cuando probé la contraseña antigua de ADMIN_ACADEMIA, Oracle rechazó el inicio de sesión con ORA-01017.

Evidencia: [aplicación de V003](lab4/evidencia/spool/20261113T154957Z_04-V003__cuentas_esquema_sin_password.spool.log), tabla de tipos de autenticación. La captura del intento rechazado está en el apartado 3.c del informe.

### 7. ¿Qué demuestra la prueba de persistencia y por qué se realiza después de reubicar los archivos?

Recreé el contenedor conservando el mismo volumen. Antes y después, los cinco tablespaces estaban en línea, las rutas coincidían y los cinco esquemas conservaban el mismo número de tablas. En ambos casos había cero estudiantes porque aún no había aplicado V002. La prueba confirmó que las estructuras de negocio seguían disponibles al reemplazar el contenedor. La hice después de reubicar los archivos para comprobar que las rutas definitivas funcionaban y que los datafiles seguían accesibles desde el volumen reutilizado.

Evidencia: [prueba de persistencia](lab4/evidencia/script/20261113T160439Z_03-prueba-persistencia.script.log), secciones ANTES y DESPUÉS.

### 8. ¿Qué datos pertenecen a la instancia y cuáles a la base de datos?

De la instancia FREE identifiqué la hora de arranque (16:04:47 en la consulta de la evidencia 05), el tamaño de la SGA (1.603.392.144 bytes en el arranque de la evidencia 06) y el proceso LGWR (SPID 1527 en la evidencia 09). Son datos de la instancia en ejecución. De la base identifiqué su DBID (1510161217), sus 16 archivos de datos y sus 2 archivos de control. Los archivos persisten cuando se detiene la instancia.

Evidencias: [instancia y base](lab4/evidencia/spool/20261113T170921Z_05-instancia-y-base.spool.log), secciones 1, 2 y 5. [Arranque por etapas](lab4/evidencia/script/20261114T172942Z_06-arranque-por-etapas.script.log), sección 2. [Procesos](lab4/evidencia/spool/20261114T180312Z_09-procesos.spool.log), fila de LGWR.

### 9. ¿Qué lee Oracle en NOMOUNT, MOUNT y OPEN?

En NOMOUNT, Oracle lee el SPFILE, reserva la SGA e inicia los procesos. Pude consultar v$parameter, pero v$database devolvió ORA-01507 porque la base aún no estaba montada. En MOUNT, Oracle abrió los dos archivos de control y reconoció los 16 datafiles. Al consultar dba_tables obtuve ORA-01219 porque la base seguía cerrada y solo estaban disponibles las tablas y vistas fijas. En OPEN, Oracle abre los datafiles y los redo logs en línea. En mi prueba, FREE quedó en READ WRITE.

Evidencia: [arranque por etapas](lab4/evidencia/script/20261114T172942Z_06-arranque-por-etapas.script.log), secciones 2 a 4.

### 10. ¿Por qué FREEPDB1 se abrió sola? ¿Qué haría si quedara en MOUNTED?

FREEPDB1 tenía guardado el estado OPEN para la instancia FREE. Al abrir el CDB, Oracle recuperó ese estado y la PDB pasó automáticamente a READ WRITE. Si quedara en MOUNTED, desde CDB$ROOT la abriría con ALTER PLUGGABLE DATABASE FREEPDB1 OPEN y guardaría su estado con ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE. Después comprobaría el modo de apertura en v$pdbs.

Evidencia: [arranque por etapas](lab4/evidencia/script/20261114T172942Z_06-arranque-por-etapas.script.log), sección 4 y comprobación final READWRITE/READWRITE.

### 11. ¿Cómo clasifico ORA-00800 y ORA-20013 en el registro de alertas?

En mi arranque, ORA-00800 apareció con el mensaje Set Priority Failed para VKTM y LGWR. Lo clasifiqué como un aviso no bloqueante en esta prueba porque el montaje y la apertura se completaron y FREEPDB1 quedó en READ WRITE. ORA-20013 no apareció en el tramo de mi registro que recogí. Para clasificarlo en una ejecución concreta necesitaría el mensaje completo y el contexto en que se produjo.

Evidencia: [registro de alertas](lab4/evidencia/script/20261114T173254Z_06-alert-log.script.log), último ciclo de parada y arranque.

### 12. ¿Qué diferencia hay entre v$parameter y v$spparameter?

`v$parameter` muestra el valor efectivo del parámetro en la sesión y el contenedor desde los que se consulta. `v$spparameter` permite ver lo que está guardado en el SPFILE para el arranque. En mi prueba, `db_files` seguía en 200 en memoria tras guardar 300 con `SCOPE=SPFILE`. Después de ejecutar `RESET`, el valor efectivo seguía en 200 y ya no había un valor explícito para `db_files` en el SPFILE.

Evidencia: [prueba de cambios de parámetros](lab4/evidencia/script/20261114T174501Z_07-parametros-cambios.script.log), sección 3.

### 13. ¿Qué hace SCOPE=BOTH y cuál es el alcance por defecto con SPFILE?

`SCOPE=BOTH` aplica el cambio en memoria y lo guarda en el SPFILE para que se mantenga en el siguiente arranque. Es el alcance por defecto de `ALTER SYSTEM SET` cuando la instancia ha arrancado con SPFILE. En mi prueba, `open_cursors` pasó a 500 en memoria y en el SPFILE. Después lo devolví a 300. Los parámetros estáticos requieren `SCOPE=SPFILE` y un reinicio para que el cambio tenga efecto.

Evidencia: [prueba de cambios de parámetros](lab4/evidencia/script/20261114T174501Z_07-parametros-cambios.script.log), secciones 1 y 2.

### 14. ¿Por qué PROCESSES rechazó el cambio en memoria?

`processes` fija el límite de procesos de la instancia y el cambio requiere un reinicio. En mi consulta inicial, `v$parameter` mostró `SYS_MOD = FALSE` para `processes`. Al intentar subirlo de 200 a 250 con `SCOPE=MEMORY`, Oracle devolvió `ORA-02097` junto con `ORA-02095`. Para cambiar ese límite en la raíz del CDB tendría que guardarlo con `SCOPE=SPFILE` y reiniciar la instancia.

Evidencias: [parámetros iniciales](lab4/evidencia/spool/20261114T174230Z_07-parametros-lectura.spool.log), fila de `processes`, y [prueba de cambios](lab4/evidencia/script/20261114T174501Z_07-parametros-cambios.script.log), sección 4.

### 15. ¿Para qué sirve versionar el PFILE? ¿Qué es configuration drift?

Un PFILE es una copia legible de los parámetros de Oracle. Al guardarlo en Git puedo comparar versiones, revisar qué parámetros cambiaron y documentar la configuración de referencia. El configuration drift ocurre cuando la configuración efectiva de un entorno se aparta de esa referencia, por ejemplo, tras un cambio manual sin registrar. Guardé un PFILE de 32 líneas generado desde el SPFILE y otro de 122 líneas generado desde memoria. Esa diferencia por sí sola no demuestra que haya drift, porque la memoria también incluye valores derivados o por defecto.

Evidencia: [copia y comparación de los PFILE](lab4/evidencia/script/20261114T175054Z_07-copiar-pfile.script.log).

### 16. ¿Qué modelo de gestión de memoria usa la instancia?

La instancia FREE usa ASMM para repartir la memoria entre los componentes de la SGA. `sga_target` estaba en 1536 MB, mientras que `memory_target` y `memory_size` estaban en cero. La PGA tenía un objetivo separado de 512 MB, definido por `pga_aggregate_target`.

Evidencia: [consulta de memoria](lab4/evidencia/spool/20261114T175647Z_08-memoria.spool.log), secciones 1, 4 y 6.

### 17. ¿Cómo interpreto las lecturas y la tasa de acierto del experimento de caché?

Ambas rondas devolvieron 17.600 estudiantes activos. Con la caché fría registré 355 lecturas lógicas y 261 físicas. Con la caché caliente registré 247 lógicas y cero físicas. Con la fórmula aproximada `1 − lecturas físicas / lecturas lógicas`, obtuve un 26,5 % en la primera ronda y un 100 % en la segunda. Son estimaciones para esas dos rondas de la sesión. La consulta final identificó 245 bloques de ACA_ESTUDIANTES en la caché.

Evidencia: [experimento de caché](lab4/evidencia/script/20261114T175843Z_08-experimento-cache.script.log), secciones 3 y 4.

### 18. ¿Por qué no se debe sumar el RSS de todos los procesos?

El RSS mide la memoria residente que tiene mapeada cada proceso. Varios procesos de Oracle comparten páginas de la SGA y esas páginas pueden aparecer en el RSS de cada uno. Sumarlos contaría esas páginas varias veces. Para analizar la memoria de Oracle consulté la SGA en `v$sga` y las estadísticas agregadas de PGA en `v$pgastat`.

Evidencias: [procesos del contenedor](lab4/evidencia/script/20261114T180451Z_09-procesos-so.script.log), sección 1, y [consulta de memoria](lab4/evidencia/spool/20261114T175647Z_08-memoria.spool.log), secciones 2 y 6.

### 19. ¿Cómo coincide el SPID de LGWR con el PID de /proc?

En Oracle, LGWR tenía el SPID 1527. Dentro del contenedor, `/proc` mostró `db_lgwr_FREE` con el PID 1527. Ambos identificadores corresponden al espacio de PID del contenedor. `docker top` puede mostrar un número distinto para ese mismo proceso porque usa los PID del sistema Linux que ejecuta Docker.

Evidencias: [procesos en Oracle](lab4/evidencia/spool/20261114T180312Z_09-procesos.spool.log), fila de LGWR, y [procesos del contenedor](lab4/evidencia/script/20261114T180451Z_09-procesos-so.script.log), sección 4.

### 20. ¿Qué hacen PMON y SMON?

PMON participa en la detección de procesos terminados de forma anormal y coordina su limpieza con el grupo de procesos encargado de esa tarea. Por ejemplo, si termina inesperadamente el proceso servidor de una sesión, esa limpieza libera los recursos que quedaron asociados a él. SMON realiza tareas de mantenimiento y participa en la recuperación de la instancia cuando hace falta. Por ejemplo, después de una caída, Oracle usa el redo para recuperar los cambios necesarios al volver a abrir la base. Mi consulta identificó PMON con SPID 1475 y SMON con SPID 1533.

Evidencia: [procesos en Oracle](lab4/evidencia/spool/20261114T180312Z_09-procesos.spool.log), filas de PMON y SMON.

### 21. ¿Por qué usar C##OPS_RO en lugar de SYSTEM para observar Oracle?

Usé C##OPS_RO para aplicar el principio de mínimo privilegio. La cuenta pudo conectarse a CDB$ROOT y consultar v$instance, que mostró la instancia FREE en estado OPEN. En FREEPDB1, la consulta a SESSION_PRIVS devolvió cero coincidencias para CREATE TABLE. Así pude comprobar el estado de Oracle con una cuenta que carecía de ese privilegio. SYSTEM dispone de privilegios administrativos innecesarios para esas consultas.

Evidencias: [conexión de observabilidad](lab4/evidencia/script/20261113T163710Z_02-conexion-ops-ro.script.log) y [comprobación de permisos](lab4/evidencia/script/20261113T163846Z_02-permisos-ops-ro.script.log).

### 22. ¿Qué dos vías de exposición de contraseñas corrige este laboratorio?

La primera era guardar contraseñas de los propietarios de esquemas en V000. Esos valores quedan accesibles en el historial de Git. V003 deshabilitó la autenticación por contraseña de los cinco propietarios. La consulta posterior mostró AUTHENTICATION_TYPE = NONE en las cinco cuentas.

La segunda era pasar la contraseña de SYS como parte del comando de conexión. Eso podía exponerla en la lista de procesos. La versión 2 del ejecutor de migraciones usa autenticación del sistema operativo dentro del contenedor mediante `/ as sysdba`, por lo que la contraseña de SYS ya no se pasa en la línea de comandos.

Evidencias: [aplicación de V003](lab4/evidencia/spool/20261113T154957Z_04-V003__cuentas_esquema_sin_password.spool.log) y [ejecutor de migraciones v2](../../scripts/deployment/env/08-aplicar-migraciones.sh).

## Preguntas tipo examen

### P1. Copia en frío · A y D

`SHUTDOWN IMMEDIATE` deja la base cerrada de forma consistente. Si restauro juntos los archivos de esa copia, puedo abrir la base con `STARTUP` sin aplicar redo para hacerlos consistentes.

### P2. Reubicación de un datafile · B

Pongo el tablespace fuera de línea, copio físicamente el archivo, actualizo la ruta con `RENAME DATAFILE` y vuelvo a poner el tablespace en línea.

### P3. Instancia y base de datos · A y C

`STARTUP_TIME` indica cuándo arrancó la instancia actual. `CREATED` indica la fecha de creación de la base de datos.

### P4. Operaciones en NOMOUNT · A y C

En `NOMOUNT` puedo consultar `v$parameter` porque los parámetros ya están cargados. También puedo ejecutar `CREATE CONTROLFILE` con la instancia arrancada y la base aún sin montar.

### P5. Cambio a ARCHIVELOG · B

Para ejecutar `ALTER DATABASE ARCHIVELOG`, la base debe estar en `MOUNT`, con los archivos de control accesibles y la base todavía cerrada.

### P6. Alcance predeterminado con SPFILE · B

Con la instancia arrancada desde un SPFILE, el alcance predeterminado es `BOTH`. Como `open_cursors` admite cambios dinámicos, el nuevo valor se aplica en memoria y se guarda en el SPFILE.

### P7. Cambio de PROCESSES desde FREEPDB1 · C

Oracle devuelve `ORA-65040` porque `processes` es un parámetro de instancia que no se puede modificar desde una PDB.

### P8. Recuperación ante un SPFILE incorrecto · A y C

Puedo arrancar con un PFILE válido mediante `STARTUP PFILE` y regenerar el SPFILE desde ese mismo archivo con `CREATE SPFILE FROM PFILE`.

### P9. Tamaño de la caché con ASMM · B

Con `MEMORY_TARGET = 0` y `SGA_TARGET = 2G`, ASMM gestiona la SGA. El valor explícito de `DB_CACHE_SIZE = 512M` fija el mínimo de la caché de bloques y Oracle puede asignarle más memoria.

### P10. Memoria de un servidor dedicado · A y D

En un servidor dedicado, la PGA contiene las áreas de trabajo de las consultas, como el área de ordenación, y la memoria de sesión.

### P11. Escritura del redo en COMMIT · C

En un `COMMIT` síncrono, LGWR debe escribir en los redo logs el registro de confirmación y el redo necesario de la transacción antes de que Oracle devuelva el control al usuario.

### P12. Procesos de segundo plano obligatorios · B y D

PMON y SMON son procesos de segundo plano de la instancia. PMON participa en la limpieza de procesos terminados y SMON realiza tareas de mantenimiento y recuperación.
