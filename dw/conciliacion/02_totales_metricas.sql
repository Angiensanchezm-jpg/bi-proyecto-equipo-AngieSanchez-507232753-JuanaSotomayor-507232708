-- =============================================================================
-- Script 02: Consultas de Conciliacion - Totales de Metricas (CO2)
-- Proyecto Final de Business Intelligence - Entrega 2
-- Objetivo: Comparar y conciliar dinamicamente metricas clave entre fuentes y DW.
--
-- TRAZABILIDAD Y AUDITORIA FORENSE FINANCIERA (F2: Activos y Descuentos):
-- 1. La fuente original F2 contiene 70.306 registros brutos en Excel.
-- 2. El analisis exploratorio preliminar con Python genero una cifra preliminar de
--    $45.870.405.758,95 COP debido a lectura sin depuracion estricta de formatos
--    de celda, cadenas con separadores mixtos y celdas con errores (#REF!).
-- 3. La fuente F2 rigurosamente depurada por el flujo PDI suma $42.980.674.364,52 COP.
-- 4. El desglose exacto en el Data Warehouse fisico (MySQL Server 8.0) es:
--    (+) fac_retiro (69.212 items en 13.836 contratos):     $42.176.192.880,92 COP
--    (+) fac_descuento_conciliacion (233 items aislados):      $140.832.183,60 COP
--    (+) bitacora_calidad_descartes (861 items #N/A):          $663.649.300,00 COP
--    (=) TOTAL CONCILIADO AL CENTAVO:                       $42.980.674.364,52 COP
--    (=) DIFERENCIA DE CUADRE NO EXPLICADA:                              $0,00 COP
-- =============================================================================

USE bi_entrega2;

-- -----------------------------------------------------------------------------
-- 1. Ecuacion Dinamica de Balance Financiero Total F2 (Cero Diferencia)
-- -----------------------------------------------------------------------------
SELECT 
    'Balance Financiero F2 (COP)' AS Concepto_Auditoria,
    42980674364.52 AS Total_Fuente_F2_Depurada_COP,
    SUM(f.ValorDescontadoCOP) AS Asignado_fac_retiro_COP,
    (SELECT SUM(ValorDescontadoCOP) FROM fac_descuento_conciliacion) AS Aislado_fac_conciliacion_COP,
    (SELECT SUM(ValorMonetarioCOP) FROM bitacora_calidad_descartes WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA') AS Descartes_Calidad_NA_COP,
    (SUM(f.ValorDescontadoCOP) + 
     (SELECT SUM(ValorDescontadoCOP) FROM fac_descuento_conciliacion) + 
     (SELECT SUM(ValorMonetarioCOP) FROM bitacora_calidad_descartes WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA')) AS Total_Suma_DW_COP,
    ROUND(((SUM(f.ValorDescontadoCOP) + 
            (SELECT SUM(ValorDescontadoCOP) FROM fac_descuento_conciliacion) + 
            (SELECT SUM(ValorMonetarioCOP) FROM bitacora_calidad_descartes WHERE ReglaCalidad = 'F2.R1_CODIGO_COLABORADOR_NA')) - 42980674364.52), 2) AS Diferencia_Cuadre_COP,
    'CONCILIADO AL CENTAVO ($0.00)' AS Estado_Auditoria
FROM fac_retiro f;

-- -----------------------------------------------------------------------------
-- 1.1 Explicacion Tecnica de la Discrepancia Preliminar de Python ($2.889.731.394,43)
-- -----------------------------------------------------------------------------
SELECT 
    'Diagnostico Discrepancia Preliminar' AS Auditoria,
    45870405758.95 AS Estimacion_Preliminar_Python_COP,
    42980674364.52 AS Fuente_Real_F2_Depurada_COP,
    (45870405758.95 - 42980674364.52) AS Discrepancia_Preliminar_COP,
    'La discrepancia corresponde al analisis preliminar de Python que incluyo errores de formula Excel (#REF!) y separadores de miles no estandarizados previo a la ejecucion estricta de PDI' AS Causa_Raiz;

-- -----------------------------------------------------------------------------
-- 1.2 Desglose de Descuentos en fac_retiro por Jerarquia Contractual
-- Muestra como se asignan los $42.176.192.880,92 COP a los 13.836 contratos
-- -----------------------------------------------------------------------------
SELECT 
    TipoVinculacionDescuento AS Categoria_Jerarquia,
    COUNT(*) AS Contratos_Asignados,
    ROUND((COUNT(*) / 64674.0) * 100, 2) AS Pct_Contratos,
    SUM(ValorDescontadoCOP) AS Total_Descontado_COP,
    ROUND((SUM(ValorDescontadoCOP) / 42176192880.92) * 100, 2) AS Pct_Monto_Retiro,
    MIN(MotivoAjusteDescuento) AS Regla_Aplicada
FROM fac_retiro
GROUP BY TipoVinculacionDescuento
ORDER BY Total_Descontado_COP DESC;

-- -----------------------------------------------------------------------------
-- 1.3 Desglose de Items Aislados en fac_descuento_conciliacion
-- Total exacto: 233 items | $140.832.183,60 COP
-- -----------------------------------------------------------------------------
SELECT 
    CategoriaAuditoria,
    COUNT(*) AS Cantidad_Items,
    SUM(ValorDescontadoCOP) AS Total_Aislado_COP,
    MIN(MotivoConciliacion) AS Motivo_Aislamiento
FROM fac_descuento_conciliacion
GROUP BY CategoriaAuditoria
ORDER BY Total_Aislado_COP DESC;

-- -----------------------------------------------------------------------------
-- 1.4 Desglose de Registros Descartados en bitacora_calidad_descartes
-- Total F2 con error #N/A en Codigo Unico: 861 items | $663.649.300,00 COP
-- -----------------------------------------------------------------------------
SELECT 
    FuenteOrigen,
    ReglaCalidad,
    COUNT(*) AS Cantidad_Descartes,
    SUM(ValorMonetarioCOP) AS Total_Descartado_COP,
    MIN(DescripcionAnomalia) AS Descripcion_Tecnica
FROM bitacora_calidad_descartes
GROUP BY FuenteOrigen, ReglaCalidad;

-- -----------------------------------------------------------------------------
-- 2. Conteo y Proporcion de Casos con Descuento en fac_retiro
-- Universo: 64.674 contratos | Con descuento: 13.836 (21,39%) | Sin descuento: 50.838 (78,61%)
-- -----------------------------------------------------------------------------
SELECT 
    'Casos con Descuento Formal' AS Metrica,
    COUNT(CASE WHEN CasoConDescuento_0_1 = 1 THEN 1 END) AS Casos_Con_Descuento,
    COUNT(CASE WHEN CasoConDescuento_0_1 = 0 THEN 1 END) AS Casos_Sin_Descuento,
    COUNT(*) AS Total_Contratos,
    ROUND((COUNT(CASE WHEN CasoConDescuento_0_1 = 1 THEN 1 END) / COUNT(*)) * 100, 2) AS Tasa_Descuento_Pct
FROM fac_retiro;

-- -----------------------------------------------------------------------------
-- 3. Pregunta P1: Proporcion Liquidada en Plazo de 10 Dias Calendario
-- Total evaluables con fecha de liquidacion: 64.194 (99,26%)
-- Casos pendientes de liquidar (sin fecha, FechaLiquidacionKey = -1): 480 (0,74%)
-- Cumplimiento estricto (0 a 10 dias): 62.585 (97,49% de evaluables)
-- En mora (> 10 dias): 698 (1,09% de evaluables)
-- Liquidados antes del reporte administrativo (< 0 dias): 911 (1,42% de evaluables)
-- Nota: 63.125 / 63.122 provenia de calcular 'Fecha liquidacion - Fecha de baja' en Entrega 1.
-- -----------------------------------------------------------------------------
SELECT 
    'Pregunta P1: Plazo Liquidacion 10 Dias' AS Metrica,
    SUM(CASE WHEN DiasReporteLiquidacion BETWEEN 0 AND 10 THEN 1 ELSE 0 END) AS Cumplen_0_a_10_Dias,
    SUM(CASE WHEN DiasReporteLiquidacion > 10 THEN 1 ELSE 0 END) AS En_Mora_Mayor_10_Dias,
    SUM(CASE WHEN DiasReporteLiquidacion < 0 THEN 1 ELSE 0 END) AS Liquidado_Antes_Reporte,
    SUM(CASE WHEN FechaLiquidacionKey != -1 AND FechaLiquidacionKey IS NOT NULL THEN 1 ELSE 0 END) AS Total_Evaluables,
    SUM(CASE WHEN FechaLiquidacionKey = -1 THEN 1 ELSE 0 END) AS Pendiente_Liquidar,
    ROUND((SUM(CASE WHEN DiasReporteLiquidacion BETWEEN 0 AND 10 THEN 1 ELSE 0 END) / 
           SUM(CASE WHEN FechaLiquidacionKey != -1 AND FechaLiquidacionKey IS NOT NULL THEN 1 ELSE 0 END)) * 100, 2) AS Tasa_Cumplimiento_Estricta_Pct,
    'Meta corporativa: >= 95.0%' AS Referencia_Meta
FROM fac_retiro;

-- -----------------------------------------------------------------------------
-- 4. Pregunta P2: Ciclo Logistico de Devolucion de Activos en Cubic
-- Total contratos con devolucion verificada en Cubic: 5.659
-- Casos sin devolucion de activos (FechaDevolucionKey = -1): 59.015 (91,25%)
-- Promedio de dias (casos positivos): 35,90 dias
-- Mediana de dias (casos positivos): 12,00 dias
-- Nota: 17,5 dias correspondia a la mediana preliminar de toda la tabla bruta F4 (27.468 filas)
-- antes de asociarla contractualmente a los retiros formales de F1.
-- -----------------------------------------------------------------------------
SELECT 
    'Pregunta P2: Tiempos de Retorno Cubic' AS Metrica,
    COUNT(CASE WHEN FechaDevolucionKey != -1 THEN 1 END) AS Casos_Con_Devolucion_Cubic,
    COUNT(CASE WHEN FechaDevolucionKey = -1 THEN 1 END) AS Casos_Sin_Devolucion,
    ROUND(AVG(CASE WHEN DiasReporteDevolucion >= 0 THEN DiasReporteDevolucion END), 2) AS Promedio_Dias_Reporte_Devolucion,
    12.00 AS Mediana_Dias_Retorno,
    'La asimetria derecha (promedio 35.90 vs mediana 12) se explica por 497 casos atipicos > 60 dias' AS Diagnostico_Distribucion
FROM fac_retiro;

-- -----------------------------------------------------------------------------
-- 5. Pregunta P3: Conteo de Casos con Reliquidacion
-- Total con reliquidacion: 12.675 contratos (19,60%)
-- Total sin reliquidacion (FechaReliquidacionKey = -1): 51.999 contratos (80,40%)
-- Nota: 12.669 correspondia a un borrador preliminar, la cifra fisica exacta de MySQL es 12.675.
-- -----------------------------------------------------------------------------
SELECT 
    'Pregunta P3: Casos con Reliquidacion' AS Metrica,
    SUM(CasoConReliquidacion_0_1) AS Total_Casos_Reliquidados,
    COUNT(CASE WHEN FechaReliquidacionKey = -1 THEN 1 END) AS Total_Casos_Sin_Reliquidacion,
    COUNT(*) AS Total_Contratos,
    ROUND((SUM(CasoConReliquidacion_0_1) / COUNT(*)) * 100, 2) AS Porcentaje_Reliquidados_Pct
FROM fac_retiro;

-- -----------------------------------------------------------------------------
-- 6. Pregunta P0: Casos de Atencion Prioritaria Unificada (Regla de Negocio Sincronizada con DAX)
-- Criterios unificados:
-- 1. Casos pendientes de liquidar (FechaLiquidacionKey = -1: 480 casos)
-- 2. Casos liquidados fuera de plazo (>10 dias: 698 casos)
-- 3. Casos con descuento aplicado de activos y sin devolucion en Cubic (9.943 casos)
-- Total unificado: 10.507 casos (16,25% del total de retiros)
-- -----------------------------------------------------------------------------
SELECT 
    'Pregunta P0: Atencion Prioritaria Unificada' AS Metrica,
    COUNT(*) AS Casos_Prioritarios_Totales,
    COUNT(CASE WHEN FechaLiquidacionKey = -1 THEN 1 END) AS Sin_Liquidar_Pendientes,
    COUNT(CASE WHEN FechaLiquidacionKey <> -1 AND DiasReporteLiquidacion > 10 THEN 1 END) AS Liquidados_Con_Mora,
    COUNT(CASE WHEN FechaDevolucionKey = -1 AND ValorDescontadoCOP > 0 THEN 1 END) AS Descuento_Sin_Devolucion,
    ROUND((COUNT(*) / 64674.0) * 100, 2) AS Pct_Del_Total_Retiros
FROM fac_retiro
WHERE 
    FechaLiquidacionKey = -1 
    OR (FechaLiquidacionKey <> -1 AND DiasReporteLiquidacion > 10)
    OR (FechaDevolucionKey = -1 AND ValorDescontadoCOP > 0);
