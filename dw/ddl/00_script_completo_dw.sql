-- =============================================================================
-- SCRIPT COMPLETO DE DEFINICIÓN Y POBLADO DEL DATA WAREHOUSE (MySQL 8.0)
-- Base de datos: bi_entrega2
-- Usuario del proyecto: bi_entrega2_user
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
-- Cobertura Temporal: 2020-01-01 al 2026-12-31 (2.557 días continuos) + Fila -1 (Sin fecha/Pendiente)
-- Cubre el 100% de fechas históricas identificadas en las cinco fuentes del proyecto.
-- =============================================================================

-- ====================================================================
-- SECCION: 00_crear_base_datos.sql
-- ====================================================================
-- =============================================================================
-- Script 00: Creación de base de datos bi_entrega2
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS bi_entrega2
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bi_entrega2;

-- Configuración del usuario del proyecto (bi_entrega2_user) para Pentaho y Power BI
CREATE USER IF NOT EXISTS 'bi_entrega2_user'@'localhost';
GRANT ALL PRIVILEGES ON bi_entrega2.* TO 'bi_entrega2_user'@'localhost';
FLUSH PRIVILEGES;

-- ====================================================================
-- SECCION: 01_dim_tiempo.sql
-- ====================================================================
-- =============================================================================
-- Script 01: Creación y Poblado de dim_tiempo
-- Cobertura: 2020-01-01 a 2026-12-31 (2.557 días continuos) + Fila especial -1
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
--
-- NOTA TÉCNICA DE COBERTURA:
-- Cubre desde 2020-01-01 para respaldar las 9 fechas de reliquidación históricas reales
-- presentes en F1 (cubre desde 2020 incluyendo registros historicos de F2 y F3), evitando errores de integridad referencial
-- en FechaReliquidacionKey de fac_retiro.
-- =============================================================================

USE bi_entrega2;

-- 1. Creación de la estructura física de la tabla dimensional
CREATE TABLE IF NOT EXISTS dim_tiempo (
    FechaKey INT NOT NULL,
    Fecha DATE NULL,
    Dia INT NULL,
    Mes INT NULL,
    NombreMes VARCHAR(20) NULL,
    Trimestre INT NULL,
    NombreTrimestre VARCHAR(10) NULL,
    Anio INT NULL,
    SemanaAnio INT NULL,
    EsFinDeSemana TINYINT(1) DEFAULT 0,
    PRIMARY KEY (FechaKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Inserción de la fila especial para fechas faltantes o pendientes (-1)
INSERT INTO dim_tiempo (FechaKey, Fecha, Dia, Mes, NombreMes, Trimestre, NombreTrimestre, Anio, SemanaAnio, EsFinDeSemana)
VALUES (-1, NULL, NULL, NULL, 'Sin fecha/Pendiente', NULL, 'N/A', NULL, NULL, 0)
ON DUPLICATE KEY UPDATE NombreMes = 'Sin fecha/Pendiente';

-- 3. Poblado continuo sin huecos mediante CTE recursivo (2020-01-01 a 2026-12-31)
-- Requiere 2.556 niveles de recursión; se amplía el límite de sesión a 3000
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

-- ====================================================================
-- SECCION: 02_dim_ubicacion.sql
-- ====================================================================
-- =============================================================================
-- Script 02: Creación de tabla dim_ubicacion
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
-- =============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS dim_ubicacion (
    UbicacionKey INT NOT NULL AUTO_INCREMENT,
    CodigoMunicipio VARCHAR(10) NULL,
    NombreMunicipio VARCHAR(100) NOT NULL,
    CodigoDepartamento VARCHAR(10) NULL,
    NombreDepartamento VARCHAR(100) NOT NULL,
    TipoEntidad VARCHAR(50) NULL,
    PRIMARY KEY (UbicacionKey),
    KEY idx_municipio_depto (NombreMunicipio, NombreDepartamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SECCION: 03_dim_contrato.sql
-- ====================================================================
-- =============================================================================
-- Script 03: Creación de tabla dim_contrato
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
-- =============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS dim_contrato (
    ContratoKey INT NOT NULL AUTO_INCREMENT,
    IDContrato VARCHAR(50) NOT NULL,
    CodigoUnicoAnonimizado VARCHAR(50) NULL,
    MotivoRetiro VARCHAR(100) NULL,
    Cargo VARCHAR(150) NULL,
    Compania VARCHAR(150) NULL,
    Transportadora VARCHAR(100) NULL,
    CECO VARCHAR(100) NULL,
    PRIMARY KEY (ContratoKey),
    UNIQUE KEY uk_id_contrato (IDContrato)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SECCION: 04_dim_estado.sql
-- ====================================================================
-- =============================================================================
-- Script 04: Creación de tabla dim_estado
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
-- =============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS dim_estado (
    EstadoKey INT NOT NULL AUTO_INCREMENT,
    EstadoDevolucion VARCHAR(50) NOT NULL,
    EstadoLiquidacion VARCHAR(50) NOT NULL,
    PRIMARY KEY (EstadoKey),
    UNIQUE KEY uk_estado_combinado (EstadoDevolucion, EstadoLiquidacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SECCION: 05_fac_retiro.sql
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


-- SECCION: 07_fac_descuento_conciliacion.sql
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


-- SECCION: 08_bitacora_calidad_descartes.sql
-- ====================================================================
CREATE TABLE IF NOT EXISTS bitacora_calidad_descartes (
    DescarteKey INT NOT NULL AUTO_INCREMENT,
    FuenteOrigen VARCHAR(50) NOT NULL,
    NumeroFilaOrigen INT NULL,
    CodigoColaboradorOrigen VARCHAR(50) NULL,
    IdActivo VARCHAR(50) NULL,
    NombreActivo VARCHAR(200) NULL,
    ValorMonetarioCOP DECIMAL(15,2) NULL DEFAULT 0.00,
    ReglaCalidad VARCHAR(50) NOT NULL,
    DescripcionAnomalia VARCHAR(255) NOT NULL,
    AccionTomada VARCHAR(100) NOT NULL,
    FechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (DescarteKey),
    INDEX idx_descarte_fuente (FuenteOrigen),
    INDEX idx_descarte_regla (ReglaCalidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

