-- ============================================================================
-- PROYECTO FINAL BI & DATA ANALYTICS - ENTREGA 3: MODELO PREDICTIVO
-- Archivo: dw/ddl/08_pred_reliquidacion.sql
-- Base de datos: bi_entrega2 (MySQL 8.0)
-- Descripción: Creación de la tabla de despliegue de predicciones del modelo
--              elegido (Bosque Aleatorio / Random Forest Classifier) con las
--              llaves foráneas hacia las dimensiones del Data Warehouse para
--              su integración directa en el tablero de Power BI.
-- ============================================================================

USE bi_entrega2;

CREATE TABLE IF NOT EXISTS pred_reliquidacion (
    PrediccionKey               INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Llave subrogada única de la predicción',
    CasoKey                     INT NOT NULL COMMENT 'Llave hacia fac_retiro (identificador del caso)',
    ContratoKey                 INT NOT NULL COMMENT 'Llave foránea hacia dim_contrato',
    UbicacionKey                INT NOT NULL COMMENT 'Llave foránea hacia dim_ubicacion',
    EstadoKey                   INT NOT NULL COMMENT 'Llave foránea hacia dim_estado',
    FechaReporteKey             INT NOT NULL COMMENT 'Llave foránea hacia dim_tiempo (fecha de reporte del retiro)',
    ConjuntoDatos               VARCHAR(20) NOT NULL COMMENT 'Partición temporal: ENTRENAMIENTO o PRUEBA',
    RealReliquidacion_0_1       TINYINT(1) NOT NULL COMMENT 'Valor real observado en el DW (0 = Sin reliquidación, 1 = Reliquidado)',
    PrediccionReliquidacion_0_1 TINYINT(1) NOT NULL COMMENT 'Clase predicha por el modelo elegido (0 o 1)',
    ProbabilidadReliquidacion   DECIMAL(6,4) NOT NULL COMMENT 'Probabilidad estimada de reliquidación entre 0.0000 y 1.0000',
    NivelRiesgoPreventivo       VARCHAR(20) NOT NULL COMMENT 'Categoría operativa para priorización: ALTO (>=0.60), MEDIO (0.30-0.59), BAJO (<0.30)',
    ResultadoEvaluacion         VARCHAR(30) NOT NULL COMMENT 'Clasificación del acierto: Verdadero Positivo, Verdadero Negativo, Falso Positivo, Falso Negativo',
    AlgoritmoElegido            VARCHAR(50) NOT NULL DEFAULT 'RandomForestClassifier' COMMENT 'Nombre del modelo desplegado',
    FechaGeneracionPrediccion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Marca de tiempo de ejecución del despliegue',

    UNIQUE KEY uk_pred_caso (CasoKey),
    INDEX idx_pred_fecha (FechaReporteKey),
    INDEX idx_pred_ubicacion (UbicacionKey),
    INDEX idx_pred_contrato (ContratoKey),
    INDEX idx_pred_estado (EstadoKey),
    INDEX idx_pred_conjunto (ConjuntoDatos),

    CONSTRAINT fk_pred_tiempo    FOREIGN KEY (FechaReporteKey) REFERENCES dim_tiempo(FechaKey),
    CONSTRAINT fk_pred_ubicacion FOREIGN KEY (UbicacionKey)    REFERENCES dim_ubicacion(UbicacionKey),
    CONSTRAINT fk_pred_contrato  FOREIGN KEY (ContratoKey)     REFERENCES dim_contrato(ContratoKey),
    CONSTRAINT fk_pred_estado    FOREIGN KEY (EstadoKey)       REFERENCES dim_estado(EstadoKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla de despliegue de predicciones del modelo analítico (Entrega 3)';
