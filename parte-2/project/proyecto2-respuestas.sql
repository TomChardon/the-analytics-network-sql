--Realizado con SQL Server.

USE Ceroamessi;


WITH cte_devoluciones AS (
	SELECT DISTINCT orden_venta,
		   item,
		   cantidad	
	FROM return_movements
),
cte_ols AS (
	SELECT	
		ols.orden,
		ols.fecha,
		ols.producto,
		ols.tienda,	
		SUM(CASE WHEN ols.moneda = 'ARS' THEN ols.venta / mafr.cotizacion_usd_peso
		WHEN ols.moneda = 'URU' THEN ols.venta  / mafr.cotizacion_usd_uru
		WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN venta
		WHEN ols.moneda = 'EUR' THEN ols.venta / mafr.cotizacion_usd_eur
		END) OVER(PARTITION BY ols.fecha, ols.producto, ols.tienda) AS ventas_brutas_dolares,
		SUM(CASE WHEN ols.moneda = 'ARS' THEN  COALESCE(ols.descuento, 0) / mafr.cotizacion_usd_peso
		WHEN ols.moneda = 'URU' THEN  COALESCE(ols.descuento, 0) / mafr.cotizacion_usd_uru
		WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN COALESCE(ols.descuento,0)
		WHEN ols.moneda = 'EUR' THEN COALESCE(ols.descuento, 0) / mafr.cotizacion_usd_eur
		END) OVER(PARTITION BY ols.fecha, ols.producto, ols.tienda) AS descuentos_dolares,
		SUM(CASE WHEN ols.moneda = 'ARS' THEN COALESCE(ols.creditos, 0)  / mafr.cotizacion_usd_peso
		WHEN ols.moneda = 'URU' THEN COALESCE(ols.creditos, 0) / mafr.cotizacion_usd_uru
		WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN COALESCE(ols.creditos, 0)
		WHEN ols.moneda = 'EUR' THEN COALESCE(ols.creditos, 0) / mafr.cotizacion_usd_eur
		END) OVER(PARTITION BY ols.fecha, ols.producto, ols.tienda) AS creditos_dolares,		  		  
		SUM(CASE WHEN ols.moneda = 'ARS' THEN ols.impuestos / mafr.cotizacion_usd_peso
		WHEN ols.moneda = 'URU' THEN ols.impuestos / mafr.cotizacion_usd_uru
		WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN ols.impuestos 
		WHEN ols.moneda = 'EUR' THEN ols.impuestos / mafr.cotizacion_usd_eur
		END) OVER(PARTITION BY ols.fecha, ols.producto, ols.tienda) AS impuestos_dolares,
		ols.cantidad,
		DAY(ols.fecha) AS dia,
		MONTH(ols.fecha) AS mes,
		YEAR(ols.fecha) AS año,
		YEAR(DATEADD(MONTH, -3, ols.fecha)) AS año_fiscal,		  
		DATEPART(QUARTER, ols.fecha) AS trimestre_fiscal
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
),
cte_tele AS (
	SELECT orden,
		   producto,
		   AVG(ventas_brutas_dolares/cantidad) AS precio_television	
	FROM cte_ols
	WHERE producto = 'p100022'	
	GROUP BY orden, producto
), 
cte_productos_philips AS (
	SELECT
		  orden,
		  producto,
		  SUM(CASE WHEN nombre LIKE LOWER('%PHILIPS%') THEN 1 ELSE 0 END) AS cantidad_philips
	FROM order_line_sale AS ols
	INNER JOIN product_master AS pm
	ON ols.producto = pm.codigo_producto
	GROUP BY orden, producto
),
cte_market_count AS (
	SELECT tienda,
		   CAST(CAST(fecha AS VARCHAR(10)) AS DATE) AS fecha,
		   conteo
	FROM market_count
),
cte_super_store_count AS (
	SELECT tienda,
		   CONVERT(DATE,fecha, 103) AS fecha,
		   conteo
	FROM super_store_count
),
cte_ssot AS (
	 SELECT
		  ols.orden,
		  ols.fecha,
		  ols.producto,
		  ols.tienda,
		  ols.ventas_brutas_dolares,
		  ols.descuentos_dolares,
		  ols.creditos_dolares,
		  ols.impuestos_dolares,
		  sm.pais,
		  sm.provincia,	  
		  sm.nombre AS nombre_tienda,
		  pm.categoria,
		  pm.subcategoria,
		  pm.subsubcategoria,
		  ols.dia,
		  ols.mes,
		  ols.año,
		  ols.año_fiscal,		  
		  ols.trimestre_fiscal,		
		  c.costo_promedio_usd,
		  ((i.inicial + i.final)/2) / COUNT(i.inicial) OVER(PARTITION BY ols.fecha, ols.tienda, ols.producto)  AS inventario_promedio,	
		  ols.cantidad,
		  COUNT(rm.cantidad) OVER(PARTITION BY rm.orden_venta) AS cantidad_devolucion,
		  rm.cantidad * c.costo_promedio_usd AS valor_retorno_usd,
		  t.precio_television,
		  pp.cantidad_philips,
		  COALESCE(mc.conteo,0) + COALESCE(ssc.conteo,0) AS conteo_total		  
	FROM cte_ols AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	LEFT JOIN store_master AS sm ON ols.tienda = sm.codigo_tienda
	LEFT JOIN product_master AS  pm ON ols.producto = pm.codigo_producto
	LEFT JOIN suppliers AS s ON ols.producto = s.codigo_producto AND s.is_primary = 'True'	
	LEFT JOIN cost AS c ON ols.producto = c.codigo_producto
	LEFT JOIN inventory AS i ON i.sku = ols.producto AND i.tienda = ols.tienda AND ols.fecha = i.fecha
	LEFT JOIN cte_devoluciones AS rm ON ols.orden = rm.orden_venta AND ols.producto = rm.item
	LEFT JOIN cte_tele AS t ON t.producto = ols.producto AND ols.orden = t.orden
	LEFT JOIN cte_productos_philips AS pp ON pp.producto =  ols.producto AND ols.orden = pp.orden
	LEFT JOIN cte_market_count AS mc ON mc.tienda = ols.tienda AND mc.fecha = ols.fecha
	LEFT JOIN cte_super_store_count AS ssc ON ssc.tienda = ols.tienda AND ssc.fecha = ols.fecha
)
SELECT * INTO proyecto_2
FROM cte_ssot


--Ventas brutas.
--SELECT SUM(ventas_brutas_dolares) AS ventas_brutas
--FROM cte_ssot

--Descuentos.
--SELECT SUM(descuentos_dolares) AS descuentos
--FROM cte_ssot

--Impuestos.
--SELECT SUM(impuestos_dolares) AS impuestos
--FROM cte_ssot

--Creditos.
--SELECT SUM(creditos_dolares) AS creditos
--FROM cte_ssot

--Ventas netas.
--SELECT SUM(ventas_brutas_dolares) + SUM(descuentos_dolares) AS ventas_netas
--FROM cte_ssot

--Valor final.
--SELECT SUM(ventas_brutas_dolares) + SUM(descuentos_dolares) + SUM(impuestos_dolares) + SUM(creditos_dolares) AS valor_final
--FROM cte_ssot

--ROI.
--SELECT ((ventas_brutas_dolares + descuentos_dolares) / (inventario_promedio * costo_promedio_usd)) * 100 AS ROI
--FROM cte_ssot

--Days on Hand.
--SELECT fecha, tienda, producto, cantidad, inventario_promedio, inventario_promedio / SUM(cantidad) OVER (PARTITION BY tienda, producto ORDER BY fecha ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) / 7 AS doh
--FROM cte_ssot
--ORDER BY fecha

--Costos.
--SELECT SUM(inventario_promedio * costo_promedio_usd) as costo_inventario,
	   --SUM(cantidad * costo_promedio_usd) as costo_venta
--FROM cte_ssot

--Margen bruto.
--SELECT SUM(ventas_brutas_dolares) + SUM(descuentos_dolares) - SUM(costo_promedio_usd * cantidad) as margen_bruto
--FROM cte_ssot

--AGM (adjusted gross margin).
--SELECT SUM(ventas_brutas_dolares) + SUM(descuentos_dolares) + SUM(creditos_dolares) + SUM(impuestos_dolares) - SUM(cantidad * costo_promedio_usd) - SUM(valor_retorno_usd) + SUM(precio_television) AS agm
--FROM cte_ssot

--AOV.
--SELECT SUM(ventas_brutas_dolares) / COUNT(DISTINCT orden) AS aov
--FROM cte_ssot

--Numero de devoluciones.
--SELECT SUM(cantidad_devolucion) AS numero_devoluciones
--FROM cte_ssot

--Ratio de conversion.
--SELECT ROUND(CAST((COUNT(orden))AS FLOAT) / CAST(SUM(conteo_total) AS FLOAT),4) * 100 AS ratio_conversion
--FROM cte_ssot
