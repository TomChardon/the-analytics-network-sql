--REALIZADO CON SQL SERVER

--Por cada KPI listado vamos a tener que generar al menos una query (pueden ser mas de una) 
--que nos devuelva el valor del KPI en cada mes, mostrando el resultado para todos los meses disponibles.

--Todos los valores monetarios deben ser calculados en dolares usando el tipo de cambio promedio mensual.El objetivo no es 
--solo encontrar la query que responda la metrica sino entender que datos necesitamos, que es lo que significa y como armar el KPI General

--Ventas brutas, netas y margen
--Margen por categoria de producto
--ROI por categoria de producto. ROI = Valor promedio de inventario / ventas netas
--AOV (Average order value), valor promedio de la orden.

--Ventas brutas, netas y margen

WITH cte_ventas_brutas AS (
	SELECT  
	       YEAR(fecha) AS año,
	       MONTH(fecha) AS mes,
		     SUM(CASE WHEN ols.moneda = 'ARS' THEN ols.venta / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN ols.venta / mafr.cotizacion_usd_uru 
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN ols.venta
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN ols.venta / mafr.cotizacion_usd_eur 
				 ELSE 0
				 END) AS ventas_brutas
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	GROUP BY YEAR(ols.fecha), MONTH(ols.fecha)
),
cte_ventas_netas AS (
	SELECT 
		   YEAR(fecha) AS año,
	     MONTH(fecha) AS mes,
		   SUM(CASE WHEN ols.moneda = 'ARS'  THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_uru
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN ols.venta + COALESCE(ols.descuento,0)
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_eur 
				END) AS ventas_netas
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	GROUP BY YEAR(ols.fecha), MONTH(ols.fecha)
),
cte_margen AS (
	SELECT 
	       YEAR(fecha) AS año,
	       MONTH(fecha) AS mes,
		     SUM(CASE WHEN ols.moneda = 'ARS'  THEN ((ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_peso) - c.costo_promedio_usd
		        WHEN ols.moneda = 'URU'THEN ((ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_uru) - c.costo_promedio_usd
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (ols.venta + COALESCE(ols.descuento,0)) - c.costo_promedio_usd
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN ((ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_eur) - c.costo_promedio_usd 
				END) AS margen
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	INNER JOIN cost AS c ON c.codigo_producto = ols.producto
	GROUP BY YEAR(ols.fecha), MONTH(ols.fecha), c.costo_promedio_usd
),
cte_fecha AS (
	SELECT YEAR(fecha) AS fecha_año,
	       MONTH(fecha) AS fecha_mes
	FROM order_line_sale
	GROUP BY YEAR(fecha), MONTH(fecha)
)
SELECT 	   
	   fecha_año,
	   fecha_mes,
	   ventas_brutas,
     ventas_netas,
	   margen
FROM cte_ventas_brutas AS cvb
INNER JOIN cte_ventas_netas AS cvn ON cvn.año = cvb.año AND cvn.mes = cvb.mes
INNER JOIN cte_margen AS cm ON cvn.año = cm.año AND cvn.mes = cm.mes
INNER JOIN cte_fecha AS cf ON cvn.año = cf.fecha_año AND cvn.mes = cf.fecha_mes;

--Margen por categoria de producto

SELECT 
	    YEAR(fecha) AS año,
	    MONTH(fecha) AS mes,
		  pm.categoria AS categoria,
		  SUM(CASE WHEN ols.moneda = 'ARS'  THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_peso 
		    WHEN ols.moneda = 'URU'THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_uru
		    WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd)
		    WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_eur 
			END) AS margen
FROM order_line_sale AS ols
INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
INNER JOIN cost AS c ON c.codigo_producto = ols.producto
INNER JOIN product_master AS pm ON pm.codigo_producto = ols.producto
GROUP BY YEAR(ols.fecha), MONTH(ols.fecha), pm.categoria, c.codigo_producto;

--ROI por categoria de producto. ROI = Valor promedio de inventario / ventas netas

WITH cte_ventas_netas AS (
	SELECT 
		   YEAR(fecha) AS año,
	     MONTH(fecha) AS mes,
		   SUM(CASE WHEN ols.moneda = 'ARS'  THEN (ols.venta - COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN (ols.venta - COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_uru
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN ols.venta - COALESCE(ols.descuento,0)
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (ols.venta - COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_eur 
				END) AS ventas_netas
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	GROUP BY YEAR(ols.fecha), MONTH(ols.fecha)
)
SELECT 
	    YEAR(ols.fecha) AS año,
	    MONTH(ols.fecha) AS mes,
		  pm.categoria AS categoria,
		(((SUM(i.inicial) + SUM(i.final))/2) / ventas_netas) AS ROI_categoria_producto
FROM order_line_sale AS ols
INNER JOIN cte_ventas_netas AS cvn ON cvn.año = YEAR(ols.fecha) AND cvn.mes = MONTH(ols.fecha)
INNER JOIN product_master AS pm ON ols.producto = pm.codigo_producto
INNER JOIN inventory AS i ON ols.producto = i.sku
GROUP BY YEAR(ols.fecha), MONTH(ols.fecha), pm.categoria, ventas_netas;

--AOV (Average order value), valor promedio de la orden.

WITH cte_margen AS (
	SELECT 		   
		   ols.orden,
		   SUM(CASE WHEN ols.moneda = 'ARS'  THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_uru
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd)
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (ols.venta - COALESCE(ols.descuento,0) - c.costo_promedio_usd) / mafr.cotizacion_usd_eur 
				ELSE 0
				END) AS margen
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	INNER JOIN cost AS c ON c.codigo_producto = ols.producto	
	GROUP BY ols.orden, c.costo_promedio_usd, ols.orden, YEAR(ols.fecha), MONTH(ols.fecha)
)
SELECT 
	   YEAR(ols.fecha) AS año,
	   MONTH(ols.fecha) AS mes,
	   ols.orden,
	   SUM(cm.margen) / COUNT(ols.orden) AS aov
FROM order_line_sale AS ols
INNER JOIN cte_margen AS cm ON cm.orden = ols.orden
GROUP BY YEAR(ols.fecha), MONTH(ols.fecha), ols.orden;

--Contabilidad
--Impuestos pagados
--Tasa de impuesto. Impuestos / Ventas netas
--Cantidad de creditos otorgados
--Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito

WITH cte_ventas_netas AS (
	SELECT 
		   YEAR(fecha) AS año,
	     MONTH(fecha) AS mes,
		   SUM(CASE WHEN ols.moneda = 'ARS'  THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_uru
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN ols.venta + COALESCE(ols.descuento,0)
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (ols.venta + COALESCE(ols.descuento,0)) / mafr.cotizacion_usd_eur 
				END) AS ventas_netas,
			SUM(CASE WHEN ols.moneda = 'ARS'  THEN (venta + COALESCE(descuento,0) - impuestos + COALESCE(creditos,0)) / mafr.cotizacion_usd_peso 
		        WHEN ols.moneda = 'URU'THEN (venta + COALESCE(descuento,0) - impuestos + COALESCE(creditos,0)) / mafr.cotizacion_usd_uru
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (venta + COALESCE(descuento,0) - impuestos + COALESCE(creditos,0))
		        WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (venta + COALESCE(descuento,0) - impuestos + COALESCE(creditos,0)) / mafr.cotizacion_usd_eur 
				END) AS valor_pagado_final
	FROM order_line_sale AS ols
	INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
	GROUP BY YEAR(ols.fecha), MONTH(ols.fecha)
)
SELECT 
     mes,
	   año,
	   SUM(ols.impuestos) AS impuestos,
	   SUM(ols.impuestos) / ventas_netas AS tasa_impuesto,	   
	   COUNT(ols.creditos) AS creditos_otorgados,
	   valor_pagado_final
FROM order_line_sale AS ols
INNER JOIN cte_ventas_netas AS cvn ON cvn.año = YEAR(ols.fecha) AND cvn.mes = MONTH(ols.fecha)
GROUP BY año, mes, ventas_netas, valor_pagado_final;

--Supply Chain
--Costo de inventario promedio por tienda
--Costo del stock de productos que no se vendieron por tienda
--Cantidad y costo de devoluciones


--Costo de inventario promedio por tienda

WITH cte_inventario_promedio AS (
	SELECT 
       YEAR(i.fecha) AS año,
		   MONTH(i.fecha) AS mes,	   
		   i.tienda,
		   (SUM(i.inicial + i.final) / 2) * c.costo_promedio_usd AS costo_inventario_promedio
	FROM inventory AS i
	LEFT JOIN cost AS c ON i.sku = c.codigo_producto
	GROUP BY YEAR(i.fecha), MONTH(i.fecha),  i.tienda, c.costo_promedio_usd	
)
SELECT 
     año,
	   mes,
	   i.tienda,
	   SUM(costo_inventario_promedio) AS costo_inventario_promedio
FROM inventory AS i
INNER JOIN cte_inventario_promedio AS cip ON cip.tienda = i.tienda
GROUP BY año, mes, i.tienda
ORDER BY año, mes, i.tienda

--Costo del stock de productos que no se vendieron por tienda

SELECT 
    s1.codigo_producto, 
	  (SELECT COUNT(is_primary) FROM suppliers AS s2 WHERE is_primary = 'False' AND s1.codigo_producto = s2.codigo_producto) * c.costo_promedio_usd	AS costo_no_vendidos
FROM suppliers AS s1
INNER JOIN cost AS c ON c.codigo_producto = s1.codigo_producto
WHERE s1.is_primary = 'False'
GROUP BY c.codigo_producto, c.costo_promedio_usd, s1.codigo_producto, s1.is_primary;

--Cantidad y costo de devoluciones

WITH cte_costo_devoluciones AS (
SELECT 
		SUM(CASE WHEN ols.moneda = 'ARS'  THEN (rm.cantidad * c.costo_promedio_usd) / mafr.cotizacion_usd_peso 
		    WHEN ols.moneda = 'URU'THEN (rm.cantidad * c.costo_promedio_usd) / mafr.cotizacion_usd_uru
		    WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN rm.cantidad * c.costo_promedio_usd
		    WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 THEN (rm.cantidad * c.costo_promedio_usd) / mafr.cotizacion_usd_eur 
			END) AS costo_devoluciones			
FROM return_movements AS rm
INNER JOIN monthly_average_fx_rate AS mafr ON YEAR(mafr.mes) = YEAR(rm.fecha) AND MONTH(mafr.mes) = MONTH(rm.fecha)
INNER JOIN cost AS c ON c.codigo_producto = rm.item
INNER JOIN order_line_sale AS ols ON ols.producto = rm.item	
),
cte_cantidad_devoluciones AS (
	SELECT SUM(cantidad) AS cantidad_devoluciones
	FROM return_movements
)
SELECT 
     cantidad_devoluciones, 
	   costo_devoluciones
FROM cte_costo_devoluciones, cte_cantidad_devoluciones;

--Tiendas
--Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra

WITH ordenes_generadas AS (
	SELECT tienda, 
	       COUNT(DISTINCT orden) AS ordenes_por_tienda
	FROM order_line_sale ols 
	GROUP BY  tienda
),
entradas AS (
	SELECT tienda, 
	       AVG(conteo) AS promedio_entradas
	FROM super_store_count
	GROUP BY tienda
	UNION ALL
	SELECT tienda,
		   AVG(conteo) AS promedio_entradas
	FROM market_count
	GROUP BY tienda
)
SELECT
	   COALESCE(og.tienda, 0) AS tiendas_ordenes,
	   COALESCE (e.tienda, 0) AS tiendas_entradas,
	   COALESCE(promedio_entradas, 0) AS promedio_entradas,
	   COALESCE(ordenes_por_tienda, 0) AS ordenes_generadas,
	   COALESCE(ordenes_por_tienda / promedio_entradas, 0) AS ordenes_gente_promedio
FROM entradas AS e
FULL OUTER JOIN ordenes_generadas AS og ON og.tienda = e.tienda
ORDER BY e.tienda;

