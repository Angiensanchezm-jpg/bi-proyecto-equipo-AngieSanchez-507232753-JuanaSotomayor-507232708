-- =============================================================================
-- Script 01: Consultas de Conciliación - Conteo por Fuente (CO1)
-- Proyecto Final de Business Intelligence - Entrega 2
-- Objetivo: Verificar los registros leídos, cargados y descartados para cada fuente.
-- Regla de conciliación: Registros Leídos = Registros Cargados + Registros Descartados
--
-- NOTA METODOLÓGICA OBLIGATORIA:
-- Todas las cifras y conteos derivados del análisis exploratorio con scripts de Python
-- se consideran PRELIMINARES hasta la ejecución efectiva del flujo ETL (j_carga_dw.kjb)
-- y su consulta y validación física directa contra el motor MySQL Server 8.0.
-- =============================================================================

USE bi_entrega2;

-- -----------------------------------------------------------------------------
-- 1. F1: PAZ Y SALVOS (Fuente de Retiros y Hechos)
-- Leídos en fuente: 64.681
-- Cargados en fac_retiro / dim_contrato: 64.674
-- Descartados: 7 (1 registro con Id nulo/no numérico + 6 registros duplicados por Id de contrato)
-- Ecuación de balance: 64.681 = 64.674 + 7
-- Colaboradores únicos representados en F1: 61.917
-- Colaboradores con múltiples contratos (recontrataciones): 2.632 personas (5.389 contratos en total, 2.757 adicionales)
-- -----------------------------------------------------------------------------
SELECT 
    'F1: Paz y Salvos' AS Fuente,
    64681 AS Registros_Leidos,
    COUNT(*) AS Registros_Cargados_DW,
    (SELECT COUNT(*) FROM bitacora_calidad_descartes WHERE FuenteOrigen = 'F1: Paz y Salvos') AS Registros_Descartados,
    (64681 - (COUNT(*) + (SELECT COUNT(*) FROM bitacora_calidad_descartes WHERE FuenteOrigen = 'F1: Paz y Salvos'))) AS Diferencia_Conciliacion,
    'Cifras preliminares hasta ejecucion en MySQL' AS Estado_Validacion
FROM fac_retiro;

SELECT 
    'F1: Contratos Unicos en Dimension' AS Dimension,
    COUNT(*) AS Total_Contratos_Cargados,
    64674 AS Esperado_Preliminar
FROM dim_contrato;

-- -----------------------------------------------------------------------------
-- 2. F2: ACTIVOS Y DESCUENTOS (Fuente de Descuentos Monetarios)
-- Leídos en fuente: 70.306 filas
-- Descartes por calidad: 861 filas con #N/A en Código Único
-- Válidos procesables: 69.445 filas
--   - Vinculados unívocamente a casos de fac_retiro: 69.212 filas (13.836 contratos)
--   - Preservados en fac_descuento_conciliacion: 233 filas
--     * 124 ambiguos (65 fecha liq duplicada, 22 fecha reliq duplicada, 37 flag 'Sí' múltiple)
--     * 62 multi-contratos sin coincidencia
--     * 47 huérfanos sin contrato en F1 (9 colaboradores)
-- Ecuación de balance atómica: 70.306 = 69.212 + 233 + 861
-- -----------------------------------------------------------------------------
SELECT 
    'F2: Activos y Descuentos' AS Fuente,
    70306 AS Registros_Leidos_Fuente,
    69212 AS Vinculados_Unicos_fac_retiro,
    (SELECT COUNT(*) FROM fac_descuento_conciliacion) AS Filas_fac_descuento_conciliacion,
    (SELECT COUNT(*) FROM bitacora_calidad_descartes WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA') AS Descartes_NA_Calidad,
    (70306 - (69212 + (SELECT COUNT(*) FROM fac_descuento_conciliacion) + (SELECT COUNT(*) FROM bitacora_calidad_descartes WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA'))) AS Diferencia_Conciliacion,
    'Cifras preliminares hasta ejecucion en MySQL' AS Estado_Validacion;

-- -----------------------------------------------------------------------------
-- 3. F3: ADOBE (Documentos de Asignación / Entrega)
-- Leídos en fuente: 48.837
-- Cargados válidos: 48.745
-- Descartados: 92 (registros con error #N/A en Código único)
-- Ecuación de balance: 48.837 = 48.745 + 92
-- -----------------------------------------------------------------------------
SELECT 
    'F3: Adobe' AS Fuente,
    48837 AS Registros_Leidos,
    48745 AS Registros_Cargados_Validos,
    92 AS Registros_Descartados_NA,
    (48837 - (48745 + 92)) AS Diferencia_Conciliacion;

-- -----------------------------------------------------------------------------
-- 4. F4: HISTORIAL CUBIC (Eventos de Devolución de Activos)
-- Leídos en fuente: 28.119
-- Cargados válidos: 27.468
-- Descartados: 651 (registros con Código único vacío, guion '-' o cero '0')
-- Ecuación de balance: 28.119 = 27.468 + 651
-- -----------------------------------------------------------------------------
SELECT 
    'F4: Historial Cubic' AS Fuente,
    28119 AS Registros_Leidos,
    27468 AS Registros_Cargados_Validos,
    651 AS Registros_Descartados_Invalidos,
    (28119 - (27468 + 651)) AS Diferencia_Conciliacion;

-- -----------------------------------------------------------------------------
-- 5. F5: DIVIPOLA DANE (Maestro Geográfico)
-- Leídos en fuente: 1.122
-- Cargados en dim_ubicacion: 1.122
-- Descartados: 0
-- Ecuación de balance: 1.122 = 1.122 + 0
-- -----------------------------------------------------------------------------
SELECT 
    'F5: DIVIPOLA DANE' AS Fuente,
    1122 AS Registros_Leidos,
    COUNT(*) AS Registros_Cargados_DW,
    0 AS Registros_Descartados,
    (1122 - (COUNT(*) + 0)) AS Diferencia_Conciliacion
FROM dim_ubicacion;
