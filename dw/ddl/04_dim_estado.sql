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
