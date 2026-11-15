-- =============================================================================
-- Script 06: Poblado sin huecos de la dimensión de tiempo (dim_tiempo)
-- Periodo: 2020-01-01 a 2026-12-31 (2.557 días sin huecos) + Fila especial -1
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
--
-- NOTA TÉCNICA DE COBERTURA:
-- Cubre desde 2020-01-01 para respaldar las 9 fechas de reliquidación históricas reales
-- presentes en F1 (cubre desde 2020 incluyendo registros historicos de F2 y F3), evitando errores de integridad referencial
-- en FechaReliquidacionKey de fac_retiro.
-- =============================================================================

USE bi_entrega2;

-- 1. Registro especial para fechas no aplicables o pendientes (ej. retiros aún no liquidados o sin devolución)
INSERT INTO dim_tiempo (FechaKey, Fecha, Dia, Mes, NombreMes, Trimestre, NombreTrimestre, Anio, SemanaAnio, EsFinDeSemana)
VALUES (-1, NULL, NULL, NULL, 'Sin fecha/Pendiente', NULL, 'N/A', NULL, NULL, 0)
ON DUPLICATE KEY UPDATE NombreMes = 'Sin fecha/Pendiente';

-- 2. Poblado completo y sin huecos para todo el rango de hechos con CTE recursiva de MySQL 8
-- Requiere 2.556 niveles de recursión; se amplía el límite de sesión a 2500
SET SESSION cte_max_recursion_depth = 3000;

INSERT INTO dim_tiempo (FechaKey, Fecha, Dia, Mes, NombreMes, Trimestre, NombreTrimestre, Anio, SemanaAnio, EsFinDeSemana)
WITH RECURSIVE calendario AS (
    SELECT DATE('2020-01-01') AS fecha_val
    UNION ALL
    SELECT DATE_ADD(fecha_val, INTERVAL 1 DAY)
    FROM calendario
    WHERE fecha_val < DATE('2026-12-31')
)
SELECT 
    CAST(DATE_FORMAT(fecha_val, '%Y%m%d') AS SIGNED) AS FechaKey,
    fecha_val AS Fecha,
    DAY(fecha_val) AS Dia,
    MONTH(fecha_val) AS Mes,
    CASE MONTH(fecha_val)
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END AS NombreMes,
    QUARTER(fecha_val) AS Trimestre,
    CONCAT('T', QUARTER(fecha_val)) AS NombreTrimestre,
    YEAR(fecha_val) AS Anio,
    WEEKOFYEAR(fecha_val) AS SemanaAnio,
    CASE WHEN DAYOFWEEK(fecha_val) IN (1, 7) THEN 1 ELSE 0 END AS EsFinDeSemana
FROM calendario
ON DUPLICATE KEY UPDATE Dia = VALUES(Dia);
