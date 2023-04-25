--Clase 1

--Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
SELECT *
FROM product_master
WHERE categoria = 'Electro'

--Cuales son los producto producidos en China?
SELECT *
FROM product_master
WHERE categoria = 'Electro' AND origen = 'China'

--Mostrar todos los productos de Electro ordenados por nombre.
SELECT *
FROM product_master
WHERE categoria = 'Electro'
ORDER BY nombre

--Cuales son las TV que se encuentran activas para la venta?
SELECT *
FROM product_master
WHERE nombre LIKE '%TV%' AND is_active = 'TRUE'

--Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
SELECT *
FROM store_master
ORDER BY fecha_apertura

--Cuales fueron las ultimas 5 ordenes de ventas?
SELECT TOP 5 *
FROM store_master
ORDER BY fecha_apertura DESC

--Mostrar los primeros 10 registros del conteo de trafico por Super store ordenados por fecha.
SELECT TOP 10 *
FROM super_store_count
ORDER BY fecha DESC

--Cuales son los productos de electro que no son Soporte de TV ni control remoto.
SELECT *
FROM product_master
WHERE nombre NOT LIKE '%Soporte TV%' 
AND nombre NOT LIKE '%Control Remoto%'

--Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
SELECT *
FROM order_line_sale
WHERE venta > 100000 AND moneda = 'ARS'

--Mostrar todas las lineas de ventas de Octubre 2022.
SELECT *
FROM order_line_sale
WHERE MONTH(fecha) = 10 AND YEAR(fecha) = 2022

--Mostrar todos los productos que tengan EAN.
SELECT *
FROM product_master
WHERE ean IS NOT NULL

--Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
SELECT *
FROM order_line_sale
WHERE fecha BETWEEN '2022-10-01' AND '2022-11-10';

--Clase 2

--Cuales son los paises donde la empresa tiene tiendas?
SELECT DISTINCT(pais)
FROM store_master

--Cuantos productos por subcategoria tiene disponible para la venta?
SELECT COUNT(subcategoria), subcategoria
FROM product_master
GROUP BY subcategoria

--Cuales son las ordenes de venta de Argentina de mayor a $100.000?
SELECT orden, venta, moneda
FROM order_line_sale
WHERE moneda = 'ARS' AND venta > 100000

--Obtener los descuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
SELECT COALESCE(SUM(descuento),0) AS descuento, moneda
FROM order_line_sale
WHERE MONTH(fecha) = 11 AND YEAR(fecha) = 2022
GROUP BY moneda

--Obtener los impuestos pagados en Europa durante el 2022.
SELECT fecha, impuestos
FROM order_line_sale
WHERE moneda = 'EUR' AND YEAR(fecha) = 2022

--En cuantas ordenes se utilizaron creditos?
SELECT COUNT(orden) AS orden
FROM order_line_sale
WHERE creditos IS NOT NULL

--Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT tienda, ((SUM(descuento) / SUM(venta)) * -1) * 100 AS descuento
FROM order_line_sale
GROUP BY tienda

--Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, AVG((inicial+final) / 2) AS inventario_promedio
FROM inventory
GROUP BY tienda
ORDER BY tienda

--Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
SELECT producto, venta, ((SUM(descuento) / SUM(venta)) * -1) * 100 AS descuento
FROM order_line_sale
GROUP BY producto, venta
HAVING 'descuento' IS NOT NULL

--Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa 
--para contar la cantidad de gente que ingresa a tienda, uno para las tiendas 
--de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
SELECT tienda, CONVERT(VARCHAR(10), fecha) AS 'fecha', conteo
FROM market_count
UNION ALL
SELECT *
FROM super_store_count

--Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
SELECT *
FROM product_master
WHERE nombre LIKE '%Philips%' AND is_active = 'True'

--Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
SELECT tienda, moneda, SUM(venta - impuestos) AS valor_nominal
FROM order_line_sale
GROUP BY tienda, moneda
ORDER BY 'valor nominal' DESC

--Cual es el precio promedio de venta de cada producto en las distintas monedas? 
--Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
SELECT producto, AVG(venta + impuestos + COALESCE(descuento, 0) + COALESCE(creditos, 0)) AS precio_promedio_de_venta
FROM order_line_sale
GROUP BY producto

--Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, SUM(impuestos / venta) * 100 AS tasa_de_impuestos
FROM order_line_sale
GROUP BY orden


--Clase 3

--Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, 
--mostrando la leyenda "Unknown" cuando no hay un color disponible
SELECT nombre, codigo_producto, categoria, COALESCE(color, 'Unknown')
FROM product_master
WHERE nombre LIKE '%Philips%' OR nombre LIKE '%Samsung%'

--Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
SELECT SUM(ols.venta) AS venta, SUM(ols.impuestos) AS impuestos, ols.moneda, sm.pais, sm.provincia
FROM order_line_sale AS ols
INNER JOIN store_master AS sm ON ols.tienda = sm.codigo_tienda
GROUP BY sm.pais, sm.provincia, ols.moneda

--Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
SELECT SUM(ols.venta) AS 'ventas totales' , pm.subcategoria, ols.moneda
FROM order_line_sale AS ols
INNER JOIN product_master AS pm ON ols.producto = pm.codigo_producto
GROUP BY pm.subcategoria, ols.moneda
ORDER BY pm.subcategoria, ols.moneda

--Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; 
--usar guion como separador y usarla para ordernar el resultado.
SELECT SUM(ols.venta) AS venta, pm.subcategoria, sm.pais + ' - ' + sm.provincia AS region
FROM order_line_sale AS ols 
INNER JOIN product_master AS pm ON  ols.producto = pm.codigo_producto
INNER JOIN store_master AS sm ON ols.tienda = sm.codigo_tienda
GROUP BY subcategoria, sm.pais + ' - ' + sm.provincia
ORDER BY sm.pais + ' - ' + sm.provincia

--Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de --apertura para el sistema 
--"super_store".
SELECT sm.nombre, SUM(ssc.conteo) AS conteo
FROM store_master AS sm
INNER JOIN super_store_count AS ssc ON sm.codigo_tienda = ssc.tienda
GROUP BY sm.nombre

--Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
SELECT sm.nombre, iv.sku, AVG((iv.inicial + iv.final)/2) AS inventario, MONTH(iv.fecha) AS mes
FROM inventory AS iv 
INNER JOIN store_master AS sm ON iv.tienda = sm.codigo_tienda
GROUP BY MONTH(iv.fecha), iv.sku, sm.nombre
ORDER BY sm.nombre

--Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', 
--homogeneizar los textos si es necesario.
SELECT ols.producto, 
       SUM(ols.cantidad) AS cantidad, 
	   LOWER(COALESCE(pm.material, 'Unknown')) AS material
FROM order_line_sale AS ols
INNER JOIN product_master AS pm ON pm.codigo_producto = ols.producto
GROUP BY producto, LOWER(COALESCE(pm.material, 'Unknown'))
ORDER BY producto

--Mostrar la tabla order_line_sale agregando una columna que represente el valor de venta bruta en 
--cada linea convertido a dolares usando la tabla de tipo de cambio.
SELECT *,	   
	   CASE WHEN moneda = 'ARS' THEN venta / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN venta / mafr.cotizacion_usd_uru
			WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN venta
			WHEN moneda = 'EUR' THEN venta / mafr.cotizacion_usd_eur		
	   END AS venta_bruta_en_dolares
FROM order_line_sale AS ols
INNER JOIN 
monthly_average_fx_rate AS mafr ON MONTH(mafr.mes) = MONTH(ols.fecha) AND YEAR(mafr.mes) = YEAR(ols.fecha)
;

--Calcular cantidad de ventas totales de la empresa en dolares.
SELECT 	   
	   SUM(CASE WHEN moneda = 'ARS' THEN venta / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN venta / mafr.cotizacion_usd_uru
			WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN venta
			WHEN moneda = 'EUR' THEN venta / mafr.cotizacion_usd_eur
	   END) AS venta_bruta_en_dolares
FROM order_line_sale AS ols
INNER JOIN 
monthly_average_fx_rate AS mafr ON MONTH(mafr.mes) = MONTH(ols.fecha) AND YEAR(mafr.mes) = YEAR(ols.fecha)
;

--Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
--SELECT 
	   ols.orden AS orden,
           pm.subsubcategoria AS subsubcategoria,
	   (SELECT COUNT(orden) + 1 FROM order_line_sale AS ols2
	   INNER JOIN product_master AS pm2 ON ols2.producto = pm2.codigo_producto
	   WHERE orden = ols.orden AND subsubcategoria != pm.subsubcategoria)
FROM order_line_sale AS ols 
INNER JOIN product_master AS pm ON ols.producto = pm.codigo_producto
GROUP BY ols.orden, pm.subsubcategoria
