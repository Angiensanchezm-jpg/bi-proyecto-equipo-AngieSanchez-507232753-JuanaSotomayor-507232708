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
