-- -- -- -- -- -- --
-- DATA EXTRACCION --
-- -- -- -- -- -- --

CREATE DATABASE BD_Ecommerce
USE BD_Ecommerce

---------------------------------
-- CARGA ORDENES
---------------------------------

IF OBJECT_ID('orders_dataset', 'U') IS NOT NULL
    DROP TABLE orders_dataset;

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
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\orders_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  -- ¡Verifica en el bloc de notas si realmente es una coma!
    ROWTERMINATOR = '0x0a'  -- Esto es un truco técnico: obliga a SQL a reconocer el salto de línea (LF / Unix) de forma más limpia, o usa '\r\n'
);

select * from orders_dataset

---------------------------------
-- CARGA PRODUCTOS
---------------------------------
IF OBJECT_ID('products_dataset', 'U') IS NOT NULL
    DROP TABLE products_dataset;

CREATE TABLE products_dataset (
    product_id VARCHAR(100) NOT NULL PRIMARY KEY,
    product_category_name VARCHAR(100) NULL,
    product_name_lenght INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g INT NULL,
    product_length_cm INT NULL,
    product_height_cm INT NULL,
    product_width_cm INT NULL
);

BULK INSERT products_dataset
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\products_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

select * from products_dataset

---------------------------------
-- CARGA CLIENTES
---------------------------------
IF OBJECT_ID('customers_dataset', 'U') IS NOT NULL
    DROP TABLE customers_dataset;

CREATE TABLE customers_dataset (
    customer_id VARCHAR(36) NOT NULL PRIMARY KEY,
    customer_unique_id VARCHAR(36) NOT NULL,
    customer_zip_code_prefix INT NULL,
    customer_city VARCHAR(100) NULL,
    customer_state VARCHAR(2) NULL
);

BULK INSERT customers_dataset
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\customers_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

select * from customers_dataset

---------------------------------
-- CARGA ARTÍCULOS
---------------------------------

IF OBJECT_ID('orders_items_dataset', 'U') IS NOT NULL
    DROP TABLE orders_items_dataset;

CREATE TABLE orders_items_dataset (
    order_id VARCHAR(36) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    seller_id VARCHAR(36) NOT NULL,
    shipping_limit_date DATETIME2(0) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_Order_Items PRIMARY KEY (order_id, order_item_id)
);

BULK INSERT orders_items_dataset
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\order_items_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

Select * from orders_items_dataset

---------------------------------
-- CARGA RESEÑAS
---------------------------------

IF OBJECT_ID('orders_reviews_dataset', 'U') IS NOT NULL
    DROP TABLE orders_reviews_dataset;

CREATE TABLE order_reviews_dataset (
    review_id varchar(50) NULL,
    order_id varchar(50) NULL,
    review_score varchar(50) NULL,
    review_comment_title varchar(50) NULL,
    review_comment_message varchar(50) NULL,
    review_creation_date varchar(50) NULL,
    review_answer_timestamp varchar(50) NULL
);

BULK INSERT order_reviews_dataset
FROM 'C:\Users\kelly\OneDrive\Documentos\SQL SERVER DATA ACADEMY\PROYECTO SQL\SQL-SERVER-HR-ANALITYCS\Data\order_reviews_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

select * from order_reviews_dataset

-----------------------------------
-- Verificar valores duplicados  --
-----------------------------------

--Verificar valores duplicados en la tabla orders_dataset

SELECT order_id, count(*)
FROM orders_dataset
GROUP BY order_id
HAVING count(*) > 1

--Verificar valores duplicados en la tabla products_dataset

SELECT product_id, count(*)
FROM products_dataset
GROUP BY product_id
HAVING count(*) >1 

--Verificar valores duplicados en la tabla customers_dataset

SELECT customer_id, count(*)
FROM customers_dataset
GROUP BY customer_id
HAVING count(*) > 1

-----------------------------------
-- Verificar valores nulos  --
-----------------------------------

--Verificar valores nulos en las fechas de entrega, aprobación y entrega a socio logístico en la tabla orders_dataset

SELECT 
    COUNT(*) AS total_pedidos,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS pedidos_sin_fecha_entrega,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS pedidos_sin_fecha_aprobacion,
	SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS pedidos_sin_fecha_entrega_logistico
FROM orders_dataset;


--Verificar valores nulos en las categorias de la tabla products_dataset

SELECT COUNT(*) AS productos_sin_categoria
FROM products_dataset
WHERE product_category_name IS NULL;

-----------------------------------
-- Transformación de datos  --
-----------------------------------

--Transformando la tabla de dimensiones producto de la tabla products_dataset

Select product_id, (product_length_cm * product_height_cm * product_width_cm) as volume_product,
       ( case 
	     when (product_length_cm * product_height_cm * product_width_cm) <= 5000 then 'Pequeño'
		 when (product_length_cm * product_height_cm * product_width_cm) <= 20000 then 'Mediano'
		 else 'Grande'
		 end ) as Categoria_tamaño
		 into dim_product
		from products_dataset

Select * from dim_product