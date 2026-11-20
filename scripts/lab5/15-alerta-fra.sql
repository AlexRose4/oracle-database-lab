WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 160 PAGESIZE 100 FEEDBACK ON
SELECT name,
       ROUND(100 * space_used / NULLIF(space_limit, 0), 2) AS usado_pct,
       'FRA supera el 85 %' AS alerta
FROM v$recovery_file_dest
WHERE space_limit > 0
  AND space_used / space_limit > 0.85;
EXIT
