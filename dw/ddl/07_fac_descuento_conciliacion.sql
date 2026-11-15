-- =============================================================================
-- Script 07: Creacion de tabla fac_descuento_conciliacion
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sanchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
--
-- JUSTIFICACION METODOLOGICA Y MODELADO DIMENSIONAL (RALPH KIMBALL):
-- 1. Grano de la tabla: Un registro por cada item fisico descontado en nomina (F2) que no
--    pudo ser vinculado de forma univoca a un caso formal de retiro en Paz y Salvos (F1).
-- 2. Preservacion del grano de fac_retiro: fac_retiro conserva su grano estricto de 1 fila
--    por caso formal de retiro en F1 (64.674 retiros). Insertar cobros contables huerfanos
--    o ambiguos con claves ficticias (-1) en fac_retiro falsearia el conteo de retiros de la
--    compañia (COUNT(*) inflado) e incurriria en mezcla de granos (caso vs. item serializado).
-- 3. Conservacion del 100% de los importes contables sin asignacion arbitraria:
--    - 124 items ambiguos ($69.547.011,08 COP): Colaboradores con multiples contratos donde
--      2 o mas contratos comparten la misma fecha de liquidacion (65 items: $32.519.328,08 COP),
--      reliquidacion (22 items: $14.243.219,00 COP) o flag 'Si' (37 items: $22.784.464,00 COP).
--    - 62 items sin coincidencia ($35.813.841,52 COP): Descuentos de colaboradores multi-contrato
--      cuyas fechas no coinciden y no tienen contratos con flag 'Si'.
--    - 47 items huerfanos ($35.471.331,00 COP): 9 colaboradores cobrados en nomina que no
--      figuran en la fuente de Paz y Salvos (pendientes de conciliar por Talento Humano).
--    Total en fac_descuento_conciliacion: 233 registros | $140.832.183,60 COP.
-- 4. Cuadre total de la fuente F2:
--    fac_retiro ($42.176.192.880,92) + fac_descuento_conciliacion ($140.832.183,60)
--    + Descartes de Calidad (#N/A, $663.649.300,00) = $42.980.674.364,52 COP (Diferencia: $0,00).
-- =============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS fac_descuento_conciliacion (
    DescuentoConciliacionKey INT NOT NULL AUTO_INCREMENT,
    CodigoColaborador VARCHAR(50) NOT NULL,
    FechaDescuentoKey INT NOT NULL DEFAULT -1,
    FechaReliqKey INT NOT NULL DEFAULT -1,
    FechaDescuentoOriginal DATE NULL,
    FechaReliqOriginal DATE NULL,
    IdActivo VARCHAR(50) NULL,
    NombreActivo VARCHAR(200) NULL,
    ValorDescontadoCOP DECIMAL(15,2) NULL DEFAULT NULL,
    ValorOriginalFuente VARCHAR(100) NULL,
    EstadoValor VARCHAR(50) NULL,
    MotivoRevisionValor VARCHAR(255) NULL,
    CategoriaAuditoria VARCHAR(50) NOT NULL,
    MotivoConciliacion VARCHAR(255) NOT NULL,
    PRIMARY KEY (DescuentoConciliacionKey),
    CONSTRAINT fk_conc_tiempo_desc FOREIGN KEY (FechaDescuentoKey) REFERENCES dim_tiempo(FechaKey),
    CONSTRAINT fk_conc_tiempo_reliq FOREIGN KEY (FechaReliqKey) REFERENCES dim_tiempo(FechaKey),
    INDEX idx_conc_categoria (CategoriaAuditoria),
    INDEX idx_conc_colaborador (CodigoColaborador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
