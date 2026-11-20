# Recuperación de un datafile de aplicación

## Síntoma y aviso
ORA-01116, ORA-01110 y ORA-27041 identifican el archivo inaccesible.
ORA-63999 puede cerrar la PDB. Avisar al DBA responsable y al responsable
de la aplicación con la hora, el archivo y el alcance del fallo.
Procedimiento para un tablespace de aplicación en ARCHIVELOG.

## Comprobaciones previas
Abrir SQL*Plus desde Terminal con:
    docker exec -it oralab-26ai sqlplus / as sysdba

Consultar desde CDB$ROOT:
    SELECT log_mode FROM v$database;
    SELECT con_id, file#, name, status FROM v$datafile ORDER BY con_id, file#;
    SELECT name, open_mode FROM v$pdbs;

Confirmar la copia desde RMAN:
    docker exec -it oralab-26ai rman target /
    LIST BACKUP OF DATAFILE 16;

En el simulacro, el archivo 16 era academia01.dbf de FREEPDB1.
Verificar el número real antes de usarlo. Si faltan copia o redo,
escalar al DBA antes de continuar.

## Camino A, FREEPDB1 abierta
En SQL*Plus:
    ALTER SESSION SET CONTAINER = FREEPDB1;
    ALTER DATABASE DATAFILE 16 OFFLINE;

En RMAN conectado a la raíz:
    RESTORE DATAFILE 16;
    RECOVER DATAFILE 16;

En SQL*Plus:
    ALTER SESSION SET CONTAINER = FREEPDB1;
    ALTER DATABASE DATAFILE 16 ONLINE;

## Camino B, FREEPDB1 cerrada por el fallo
Esperar hasta que quede MOUNTED. Ejecutar RESTORE y RECOVER desde
RMAN como en el camino A. Después, en SQL*Plus:
    ALTER SESSION SET CONTAINER = FREEPDB1;
    ALTER DATABASE DATAFILE 16 ONLINE;
    ALTER SESSION SET CONTAINER = CDB$ROOT;
    ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;

## Verificación y cierre
    SELECT name, open_mode FROM v$pdbs;
    ALTER SESSION SET CONTAINER = FREEPDB1;
    SELECT estudiante_id, estado FROM admin_academia.aca_estudiantes
    WHERE estudiante_id = 104;
    SELECT COUNT(*) FROM admin_academia.aca_estudiantes;

El simulacro recuperó EGRESADO y 20.000 estudiantes; después se
devolvió el estudiante 104 a ACTIVO. Registrar RTO, RPO y estado final,
revisar el alert log y comunicar la recuperación al DBA y a la aplicación.
