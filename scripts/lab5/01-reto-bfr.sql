WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK OFF
ALTER SESSION SET CONTAINER = FREEPDB1;

PROMPT === Filas reales por bloque de PEDIDO ===
WITH filas_por_bloque AS (
  SELECT bloque, COUNT(*) AS filas
  FROM (
    SELECT /*+ NO_MERGE */
           DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID, 'BIGFILE') AS bloque
    FROM tiendasur.pedido
  )
  GROUP BY bloque
)
SELECT COUNT(*) AS bloques_con_filas,
       MIN(filas) AS minimo,
       ROUND(AVG(filas), 2) AS media,
       MAX(filas) AS maximo,
       SUM(filas) AS total_filas
FROM filas_por_bloque;

PROMPT === Comparacion con las estadisticas de la tabla ===
SELECT num_rows, blocks,
       ROUND(num_rows / NULLIF(blocks, 0), 2) AS filas_por_bloque
FROM dba_tables
WHERE owner = 'TIENDASUR' AND table_name = 'PEDIDO';

PROMPT === Estado del paquete de medida ===
SELECT object_name, object_type, status
FROM dba_objects
WHERE owner = 'LAB_TOOLS' AND object_name = 'MEDIR'
ORDER BY object_type;
EXIT
