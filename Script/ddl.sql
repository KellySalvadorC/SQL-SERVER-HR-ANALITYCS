-- -- -- -- -- -- --
-- DATA EXTRACCION --
-- -- -- -- -- -- --

CREATE DATABASE BD_Ecommerce
USE BD_Ecommerce

---------------------------------
-- CARGA ORDENES
---------------------------------

IF OBJECT_ID('orders_dataset', 'U') IS NOT NULL
    DROP TABLE dbo.orders_dataset;

CREATE TABLE dbo.orders_dataset (
  order_id VARCHAR(36) NOT NULL PRIMARY KEY,  -- ids hex (~32 chars), se deja margen
  customer_id VARCHAR(36) NOT NULL,           -- ids hex
  order_status VARCHAR(20) NOT NULL,         -- 'delivered','invoiced', etc.
  order_purchase_timestamp DATETIME2(0) NOT NULL,
  order_approved_at DATETIME2(0) NULL,
  order_delivered_carrier_date DATETIME2(0) NULL,
  order_delivered_customer_date DATETIME2(0) NULL,
  order_estimated_delivery_date DATETIME2(0) NULL
);

--IMPORTANDO DATOS DE CSV
BULK INSERT orders_dataset
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\dbo.orders_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  -- ¡Verifica en el bloc de notas si realmente es una coma!
    ROWTERMINATOR = '0x0a'  -- Esto es un truco técnico: obliga a SQL a reconocer el salto de línea (LF / Unix) de forma más limpia, o usa '\r\n'
);

select * from orders_dataset