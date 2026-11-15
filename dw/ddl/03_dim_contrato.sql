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
