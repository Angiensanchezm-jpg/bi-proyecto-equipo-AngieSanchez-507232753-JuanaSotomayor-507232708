-- =============================================================================
-- Script 08: Creación de tabla bitacora_calidad_descartes
-- Proyecto Final de Business Intelligence - Entrega 2
-- Integrantes: Angie Natali Sánchez Muñoz (507232753), Juana Valentina Sotomayor Niño (507232708)
--
-- JUSTIFICACIÓN METODOLÓGICA Y AUDITORÍA DE CALIDAD (E3 / E4 / CO3):
-- 1. Grano de la tabla: Un registro por cada fila descartada o anómala de las fuentes crudas
--    que no cumple con los estándares de integridad referencial o completitud requeridos
--    para ingresar al modelo analítico principal (fac_retiro o dimensiones).
-- 2. Trazabilidad de los 861 registros inválidos de F2 (Activos y Descuentos):
--    - En F2 existen 861 filas con '#N/A' en el campo 'Codigo unico' (monto: $663.649.300,00 COP).
--    - Al no tener código de colaborador ni identificador de contrato, vincularlos a retiros
--      generaría registros espurios o imputaciones arbitrarias prohibidas.
--    - En lugar de descartarlos silenciosamente o eliminarlos del control, se persisten físicamente
--      en esta bitácora para garantizar auditoría contable completa y cuadre del 100% de la fuente.
-- 3. Ecuación de cuadre total de F2:
--    fac_retiro ($45.063.272.434,95) + fac_descuento_conciliacion ($143.484.024,00)
--    + bitacora_calidad_descartes ($663.649.300,00) = $45.870.405.758,95 COP (70.306 filas).
-- 4. Trazabilidad de los 7 registros descartados de F1 (Paz y Salvos):
--    - 1 fila con Id de contrato nulo/vacío (colaborador 6163448).
--    - 6 filas con Id de contrato duplicado (Ids 3242845, 3250857, 3250898, 3260931, 3261888, 3288383).
--    - Ecuación de cuadre total de F1:
--      fac_retiro / dim_contrato (64.674) + bitacora_calidad_descartes (7) = 64.681 filas leídas.
--    - Total general en bitacora_calidad_descartes: 868 filas (861 de F2 + 7 de F1).
-- =============================================================================

USE bi_entrega2;

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
