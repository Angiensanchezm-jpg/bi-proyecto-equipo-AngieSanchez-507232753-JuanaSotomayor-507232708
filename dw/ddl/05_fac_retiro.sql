-- =============================================================================
-- Script 05: Creacion de tabla de hechos fac_retiro
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sanchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
--
-- TRAZABILIDAD DE FECHAS Y JUSTIFICACION DE EXCLUSIONES:
-- 1. FechaReporteKey: Mapea F1 'Fecha Reportado' (Rango real: 2024-10-14 a 2026-10-15).
--    Hito inicial que activa la ventana de liquidacion y control de activos.
-- 2. FechaLiquidacionKey: Mapea F1 'Fecha liquidacion' (Rango real: 2023-01-23 a 2026-10-16).
--    Hito de cierre formal del pago laboral. Casos no liquidados (480) van a FechaKey = -1.
-- 3. FechaDevolucionKey: Mapea F4 'Fecha Registro' en Cubic (Rango real: 2026-01-02 a 2026-10-05).
--    Fecha efectiva de ingreso del activo en bodega. Casos sin retorno en Cubic (59.015) van a FechaKey = -1.
-- 4. FechaReliquidacionKey: Mapea F1 'Fecha de Reliquidacion' (Rango real: 2021-08-24 a 2026-10-16).
--    Casos sin reliquidacion (51.999) van a FechaKey = -1. Casos reliquidados: 12.675 (19,60%).
--
-- JUSTIFICACION DE EXCLUSION DE 'Fecha Final' (Paz y Salvos F1):
-- - 'Fecha Final' corresponde a un cierre administrativo interno de la carpeta del caso, no a un
--   hito normativo ni operativo del proceso de retiro.
-- - Las preguntas de negocio P0 a P4 y los indicadores de la rubrica evaluan exclusivamente:
--   a) Tiempo entre Fecha Reportado y Fecha liquidacion (meta corporativa <= 10 dias).
--   b) Tiempo entre Fecha Reportado y Fecha Registro en Cubic (tiempo de retorno de activos).
-- - 'Fecha Final' presenta severas anomalias en los datos crudos (fechas de agosto de 2021
--   en desvinculaciones ocurridas en 2025/2026, documentadas en el Anexo A.1 de la Entrega 1).
--   Su inclusion como clave foranea generaria dispersion y ruido analitico innecesario.
--
-- MANEJO DE DESCUENTOS Y VINCULACION UNIVOCA CONTRACTUAL (F2 Activos y Descuentos):
-- - Granularidad de fac_retiro: Exactamente 1 fila por caso/contrato de retiro formal en F1 (64.674 casos).
-- - Jerarquia deterministica de vinculacion fila a fila (sin ventanas inventadas ni primer contrato por defecto):
--   1. Vinculo 1:1 Directo Mono-contrato: $39.474.185.081,27 COP asignados univocamente a 12.936 contratos.
--   2. Vinculo por Fecha Liquidacion Exacta: $2.432.615.613,93 COP asignados a 827 contratos con fecha coincidente.
--   3. Vinculo por Fecha Reliquidacion Exacta: $248.424.493,72 COP asignados a 65 contratos con reliquidacion coincidente.
--   4. Vinculo por Indicador '¿Con descuento? = Si' Unico: $20.967.692,00 COP asignados a 8 contratos especificos.
--   Subtotal Vinculado en fac_retiro: 69.212 items de F2 asignados univocamente a 13.836 contratos de F1 ($42.176.192.880,92 COP).
-- - Contratos de F1 sin descuento vinculado (50.838 casos): registran ValorDescontadoCOP = 0.00.
-- - Descuentos no vinculados univocamente (233 items, $140.832.183,60 COP):
--   Preservados integramente en la tabla separada fac_descuento_conciliacion para no romper el grano de fac_retiro.
-- - Registros invalidos con #N/A en Codigo Unico (861 filas, $663.649.300,00 COP):
--   Aislados en la bitacora de descartes y calidad.
-- - Balance Contable Cerrado: $42.176.192.880,92 + $140.832.183,60 + $663.649.300,00 = $42.980.674.364,52 COP (Diferencia: $0,00).
-- =============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS fac_retiro (
    CasoKey INT NOT NULL AUTO_INCREMENT,
    ContratoKey INT NOT NULL,
    UbicacionKey INT NOT NULL,
    EstadoKey INT NOT NULL,
    FechaReporteKey INT NOT NULL,
    FechaLiquidacionKey INT NULL,
    FechaDevolucionKey INT NULL,
    FechaReliquidacionKey INT NULL,
    DiasReporteLiquidacion INT NULL,
    DiasReporteDevolucion INT NULL,
    ValorDescontadoCOP DECIMAL(15,2) DEFAULT 0.00,
    CantidadActivosPendientes INT DEFAULT 0,
    LiquidadoEn10Dias_0_1 TINYINT(1) DEFAULT 0,
    CasoConDescuento_0_1 TINYINT(1) DEFAULT 0,
    CasoConReliquidacion_0_1 TINYINT(1) DEFAULT 0,
    TipoVinculacionDescuento VARCHAR(50) NOT NULL DEFAULT 'SIN_DESCUENTO',
    MotivoAjusteDescuento VARCHAR(150) NULL,
    PRIMARY KEY (CasoKey),
    CONSTRAINT fk_fac_contrato FOREIGN KEY (ContratoKey) REFERENCES dim_contrato(ContratoKey),
    CONSTRAINT fk_fac_ubicacion FOREIGN KEY (UbicacionKey) REFERENCES dim_ubicacion(UbicacionKey),
    CONSTRAINT fk_fac_estado FOREIGN KEY (EstadoKey) REFERENCES dim_estado(EstadoKey),
    CONSTRAINT fk_fac_tiempo_rep FOREIGN KEY (FechaReporteKey) REFERENCES dim_tiempo(FechaKey),
    CONSTRAINT fk_fac_tiempo_liq FOREIGN KEY (FechaLiquidacionKey) REFERENCES dim_tiempo(FechaKey),
    CONSTRAINT fk_fac_tiempo_dev FOREIGN KEY (FechaDevolucionKey) REFERENCES dim_tiempo(FechaKey),
    CONSTRAINT fk_fac_tiempo_reliq FOREIGN KEY (FechaReliquidacionKey) REFERENCES dim_tiempo(FechaKey),
    INDEX idx_fac_tipo_vinculacion (TipoVinculacionDescuento),
    INDEX idx_fac_rep_liq (FechaReporteKey, FechaLiquidacionKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
