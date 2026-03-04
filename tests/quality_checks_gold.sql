/*
===============================================================================
Controles de Calidad (Quality Checks)
===============================================================================
Propósito del Script:
    Este script realiza controles de calidad para validar la integridad, 
    consistencia y precisión de la Capa Gold. Estas validaciones aseguran:

    - Unicidad de las claves sustitutas (surrogate keys) en las tablas de dimensiones.
    - Integridad referencial entre la tabla de hechos y las dimensiones.
    - Validación de las relaciones del modelo de datos con fines analíticos.

Notas de Uso:
    - Se deben investigar y corregir cualquier discrepancia encontrada 
      durante la ejecución de estos controles.
===============================================================================
*/

-- ====================================================================
-- Verificación de 'gold.dim_customers'
-- ====================================================================
-- Validar la unicidad de la clave de cliente en gold.dim_customers
-- Resultado esperado: No debe retornar filas
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificación de 'gold.dim_products'
-- ====================================================================
-- Validar la unicidad de la clave de producto en gold.dim_products
-- Resultado esperado: No debe retornar filas
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Verificación de 'gold.fact_sales'
-- ====================================================================
-- Validar la conectividad del modelo de datos entre la tabla de hechos 
-- y las tablas de dimensiones (integridad referencial)
-- Resultado esperado: No debe retornar filas
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
