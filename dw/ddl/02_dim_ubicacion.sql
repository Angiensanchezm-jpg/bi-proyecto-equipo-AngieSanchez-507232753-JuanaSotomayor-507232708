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
