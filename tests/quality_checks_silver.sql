/*
===============================================================================
Controles de Calidad
===============================================================================
Propósito del Script:
    Este script realiza varios controles de calidad para verificar la consistencia, precisión 
    y estandarización de los datos en la capa 'silver'. Incluye validaciones para:
    - Claves primarias nulas o duplicadas.
    - Espacios no deseados en campos de texto.
    - Estandarización y consistencia de datos.
    - Rangos y ordenes de fechas inválidos.
    - Consistencia de datos entre campos relacionados.

Notas de Uso:
    - Ejecutar estas validaciones después de cargar la Capa Silver.
    - Investigar y resolver cualquier discrepancia encontrada durante las verificaciones.
===============================================================================
*/

-- ====================================================================
-- Verificando 'silver.crm_cust_info'
-- ====================================================================
-- Verificar NULLs o Duplicados en la Clave Primaria
-- Resultado Esperado: Sin resultados
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Verificar Espacios No Deseados
-- Resultado Esperado: Sin resultados
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Estandarización y Consistencia de Datos
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Verificando 'silver.crm_prd_info'
-- ====================================================================
-- Verificar NULLs o Duplicados en la Clave Primaria
-- Resultado Esperado: Sin resultados
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Verificar Espacios No Deseados
-- Resultado Esperado: Sin resultados
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Verificar NULLs o Valores Negativos en el Costo
-- Resultado Esperado: Sin resultados
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Estandarización y Consistencia de Datos
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Verificar Orden de Fechas Inválido (Fecha Inicio > Fecha Fin)
-- Resultado Esperado: Sin resultados
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Verificando 'silver.crm_sales_details'
-- ====================================================================
-- Verificar Fechas Inválidas
-- Resultado Esperado: Sin fechas inválidas
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Verificar Orden de Fechas Inválido (Fecha de Orden > Fecha de Envío/Vencimiento)
-- Resultado Esperado: Sin resultados
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Verificar Consistencia de Datos: Ventas = Cantidad * Precio
-- Resultado Esperado: Sin resultados
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Verificando 'silver.erp_cust_az12'
-- ====================================================================
-- Identificar Fechas Fuera de Rango
-- Resultado Esperado: Fechas de nacimiento entre 1924-01-01 y hoy
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Estandarización y Consistencia de Datos
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Verificando 'silver.erp_loc_a101'
-- ====================================================================
-- Estandarización y Consistencia de Datos
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Verificando 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Verificar Espacios No Deseados
-- Resultado Esperado: Sin resultados
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Estandarización y Consistencia de Datos
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
