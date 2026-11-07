-- =============================================================================
-- Script 03: Consultas de Conciliación - Descartes y Calidad de Datos (CO3 / E3 / E4)
-- Proyecto Final de Business Intelligence - Entrega 2
-- Objetivo: Identificar, auditar y explicar cada regla de calidad y los registros afectados.
--
-- NOTA METODOLÓGICA OBLIGATORIA:
-- Todas las cifras y conteos derivados del análisis exploratorio con scripts de Python
-- se consideran PRELIMINARES hasta la ejecución efectiva del flujo ETL (j_carga_dw.kjb)
-- y su consulta y validación física directa contra el motor MySQL Server 8.0.
-- =============================================================================

USE bi_entrega2;

-- -----------------------------------------------------------------------------
-- 1. Regla F1.R1: Normalización de Municipio y Departamento con DIVIPOLA
-- En F1 existían inconsistencias como 'CUNDINAMARCA | BOGOTÁ, D.C.' y '0 | MEDELLÍN'.
-- Se estandarizaron al maestro DIVIPOLA: 'BOGOTÁ, D.C. | BOGOTÁ, D.C.' y 'ANTIOQUIA | MEDELLÍN'.
-- -----------------------------------------------------------------------------
SELECT 
    u.NombreDepartamento,
    u.NombreMunicipio,
    COUNT(f.CasoKey) AS Total_Casos
FROM fac_retiro f
JOIN dim_ubicacion u ON f.UbicacionKey = u.UbicacionKey
GROUP BY u.NombreDepartamento, u.NombreMunicipio
ORDER BY Total_Casos DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- 2. Regla F1.R2: Casos con ID Nulo y Duplicados en F1
-- - 1 fila con ID nulo/no numérico descartada en la carga.
-- - 6 filas con ID duplicado eliminadas conservando el primer registro.
-- Persistidos físicamente en bitacora_calidad_descartes para trazabilidad total.
-- Total retiros válidos cargados en fac_retiro: 64.674 casos.
-- -----------------------------------------------------------------------------
SELECT 
    'F1 Id Duplicados o Nulos' AS Regla,
    '7 registros descartados (1 nulo + 6 duplicados)' AS Detalle,
    COUNT(*) AS Total_Hechos_Cargados,
    64674 AS Esperado_Preliminar
FROM fac_retiro;

SELECT 
    ReglaCalidad,
    DescripcionAnomalia,
    AccionTomada,
    COUNT(*) AS Total_Registros_Descartados,
    SUM(ValorMonetarioCOP) AS Monto_Total_COP
FROM bitacora_calidad_descartes
WHERE FuenteOrigen = 'F1: Paz y Salvos'
GROUP BY ReglaCalidad, DescripcionAnomalia, AccionTomada;

-- -----------------------------------------------------------------------------
-- 3. Regla F2.R1: 861 Registros con error #N/A en Código Único de Cruce (F2)
-- Persistidos físicamente en bitacora_calidad_descartes para garantizar
-- trazabilidad contable total y cuadre del 100% de la fuente F2 ($663.649.300,00 COP).
-- -----------------------------------------------------------------------------
SELECT 
    ReglaCalidad,
    DescripcionAnomalia,
    AccionTomada,
    COUNT(*) AS Total_Registros_Descartados,
    SUM(ValorMonetarioCOP) AS Monto_Total_COP
FROM bitacora_calidad_descartes
WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA'
GROUP BY ReglaCalidad, DescripcionAnomalia, AccionTomada;

-- Resumen unificado de bitacora_calidad_descartes (868 registros en total: 861 de F2 + 7 de F1):
SELECT 
    COALESCE(FuenteOrigen, 'TOTAL GENERAL') AS FuenteOrigen,
    COALESCE(ReglaCalidad, 'TODAS') AS ReglaCalidad,
    COUNT(*) AS Total_Registros,
    SUM(ValorMonetarioCOP) AS Monto_Total_COP
FROM bitacora_calidad_descartes
GROUP BY FuenteOrigen, ReglaCalidad WITH ROLLUP;

-- -----------------------------------------------------------------------------
-- 4. Regla F2.R2: Auditoría de Descuentos Asignados Unívocamente vs. Conciliación
-- Se aplicó la jerarquía determinística fila a fila:
-- 1. Mono-contrato (1:1 directo): 64.591 filas -> $42.154.384.943,70 COP
-- 2. Multi-contrato con Fecha Liq única: 4.077 filas -> $2.528.930.210,25 COP
-- 3. Multi-contrato con Fecha Reliq única: 500 filas -> $357.365.029,00 COP
-- 4. Multi-contrato con Flag 'Sí' único: 44 filas -> $22.592.252,00 COP
-- Total asignado a fac_retiro: 69.212 filas | $45.063.272.434,95 COP (en 13.836 contratos)
-- -----------------------------------------------------------------------------
SELECT 
    TipoVinculacionDescuento,
    MotivoAjusteDescuento,
    COUNT(*) AS Cantidad_Casos,
    SUM(ValorDescontadoCOP) AS Total_COP
FROM fac_retiro
WHERE ValorDescontadoCOP > 0
GROUP BY TipoVinculacionDescuento, MotivoAjusteDescuento
ORDER BY Total_COP DESC;

-- -----------------------------------------------------------------------------
-- 5. Regla F2.R3: Auditoría de Descuentos Preservados en fac_descuento_conciliacion
-- 233 ítems ($143.484.024,00 COP) que no se atribuyeron a un contrato específico
-- para evitar falsos retiros o imputaciones arbitrarias:
-- - 124 ambiguos (65 fecha liq duplicada + 22 fecha reliq duplicada + 37 flag 'Sí' múltiple)
-- - 62 sin coincidencia de fechas ni flag
-- - 47 huérfanos sin contrato en F1 (9 colaboradores cobrados en nómina)
-- -----------------------------------------------------------------------------
SELECT 
    CategoriaAuditoria,
    COUNT(*) AS Cantidad_Items,
    SUM(ValorDescontadoCOP) AS Total_Descontado_COP,
    MIN(MotivoConciliacion) AS Motivo_Preservacion
FROM fac_descuento_conciliacion
GROUP BY CategoriaAuditoria
ORDER BY Total_Descontado_COP DESC;

-- -----------------------------------------------------------------------------
-- 6. Regla F3.R1: 92 Filas sin Código Único en Adobe (#N/A)
-- Se filtraron en PDI para asegurar integridad referencial en la capa documental.
-- -----------------------------------------------------------------------------
SELECT 
    'F3 Filas sin Codigo Unico' AS Regla,
    '92 registros con #N/A aislados' AS Detalle,
    48745 AS Registros_Validos_Procesados;

-- -----------------------------------------------------------------------------
-- 7. Regla F4.R1: 651 Registros con Códigos Inválidos en Cubic ('-', '0', vacíos)
-- Se filtraron en PDI - los 27.468 registros válidos cubren eventos de 2026.
-- -----------------------------------------------------------------------------
SELECT 
    'F4 Codigos Invalidos Cubic' AS Regla,
    '651 registros con -, 0 o vacio descartados' AS Detalle,
    27468 AS Registros_Validos_Procesados;

-- -----------------------------------------------------------------------------
-- 8. Distribución de Estados del Proceso (dim_estado)
-- -----------------------------------------------------------------------------
SELECT 
    e.EstadoDevolucion,
    e.EstadoLiquidacion,
    COUNT(f.CasoKey) AS Cantidad_Casos
FROM fac_retiro f
JOIN dim_estado e ON f.EstadoKey = e.EstadoKey
GROUP BY e.EstadoDevolucion, e.EstadoLiquidacion
ORDER BY Cantidad_Casos DESC;
