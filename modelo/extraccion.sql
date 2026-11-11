-- ============================================================================
-- PROYECTO FINAL BI & DATA ANALYTICS - ENTREGA 3: MODELO PREDICTIVO
-- Caso: BPO Alfa Colombia
-- Equipo: Angie Natali Sánchez Muñoz (507232753)
--         Juana Valentina Sotomayor Niño (507232708)
-- Descripción: Consulta SQL de extracción del conjunto de datos desde el
--              Data Warehouse (bi_entrega2) uniendo la tabla de hechos
--              fac_retiro con sus cuatro dimensiones (dim_tiempo,
--              dim_ubicacion, dim_contrato, dim_estado).
-- ============================================================================

SELECT
    -- 1. Llaves del modelo dimensional (para trazabilidad y despliegue en pred_*)
    f.CasoKey,
    f.ContratoKey,
    f.UbicacionKey,
    f.EstadoKey,
    f.FechaReporteKey,

    -- 2. Atributos temporales del reporte (dim_tiempo)
    t.Fecha                   AS FechaReporte,
    t.Anio                    AS AnioReporte,
    t.Trimestre               AS TrimestreReporte,
    t.Mes                     AS MesReporte,
    t.NombreMes               AS NombreMesReporte,
    t.SemanaAnio              AS SemanaReporte,
    t.EsFinDeSemana           AS ReporteFinDeSemana,

    -- 3. Atributos geográficos de la sede / colaborador (dim_ubicacion)
    u.CodigoDepartamento,
    u.NombreDepartamento,
    u.CodigoMunicipio,
    u.NombreMunicipio,
    u.TipoEntidad,

    -- 4. Atributos contractuales y operativos (dim_contrato)
    c.IDContrato,
    c.CodigoUnicoAnonimizado,
    c.MotivoRetiro,
    c.Cargo,
    c.Compania,
    c.Transportadora,
    c.CECO,

    -- 5. Atributos de estado operativo y métricas en la tabla de hechos
    e.EstadoDevolucion,
    e.EstadoLiquidacion,
    f.DiasReporteLiquidacion,
    f.LiquidadoEn10Dias_0_1,
    f.CantidadActivosPendientes,
    f.CasoConDescuento_0_1,
    f.ValorDescontadoCOP,

    -- 6. Variable Objetivo (Target) para el modelo de Clasificación (Pregunta BA)
    f.CasoConReliquidacion_0_1
FROM fac_retiro f
INNER JOIN dim_tiempo    t ON f.FechaReporteKey = t.FechaKey
INNER JOIN dim_ubicacion u ON f.UbicacionKey    = u.UbicacionKey
INNER JOIN dim_contrato  c ON f.ContratoKey     = c.ContratoKey
INNER JOIN dim_estado    e ON f.EstadoKey       = e.EstadoKey
ORDER BY t.Fecha ASC, f.CasoKey ASC;
