--Realizado con MS SQL SERVER

--Clase 6

--Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 2 - 
--Ejercicio 10, donde unimos la cantidad de gente que ingresa a tienda usando los dos sistemas.
CREATE VIEW v_ejercicio10_clase2 AS 
SELECT tienda, CONVERT(VARCHAR(10), fecha) AS 'fecha', conteo
FROM market_count
UNION ALL
SELECT *
FROM super_store_count;

--Recibimos otro archivo con ingresos a tiendas de meses anteriores. Ingestar el archivo y agregarlo a la vista del ejercicio anterior 
--(Ejercicio 1 Clase 6). Cual hubiese sido la diferencia si hubiesemos tenido una tabla? 
--(contestar la ultima pregunta con un texto escrito en forma de comentario)

--Si hubiesemos tenido una nueva tabla se utiliza un SELECT * INTO nueva_tabla FROM vieja_tabla

--Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 3 - Ejercicio 10, 
--donde calculamos el margen bruto en dolares. Agregarle la columna de ventas, descuentos, 
--y creditos en dolares para poder reutilizarla en un futuro.
CREATE VIEW v_ejercicio3_clase_6_prueba AS
SELECT ols.*,
	   CASE WHEN moneda = 'ARS' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_peso) - c.costo_promedio_usd
	        WHEN moneda = 'URU' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_uru) - c.costo_promedio_usd
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (venta - COALESCE(descuento,0)) - c.costo_promedio_usd
		WHEN moneda = 'EUR' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_eur) - c.costo_promedio_usd
	   END AS margen,
	   CASE WHEN moneda = 'ARS' THEN venta / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN venta  / mafr.cotizacion_usd_uru
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN venta
		WHEN moneda = 'EUR' THEN venta / mafr.cotizacion_usd_eur
	   END AS ventas_en_dolares,
	   CASE WHEN moneda = 'ARS' THEN  COALESCE(descuento,0) / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN  COALESCE(descuento,0) / mafr.cotizacion_usd_uru
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN COALESCE(descuento,0)
		WHEN moneda = 'EUR' THEN COALESCE(descuento,0) / mafr.cotizacion_usd_eur
	   END AS descuentos_en_dolares,
	   CASE WHEN moneda = 'ARS' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_peso) - c.costo_promedio_usd
	        WHEN moneda = 'URU' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_uru) - c.costo_promedio_usd
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (venta - COALESCE(descuento,0)) - c.costo_promedio_usd
		WHEN moneda = 'EUR' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_eur) - c.costo_promedio_usd
	   END AS creditos_en_dolares
FROM order_line_sale AS ols
INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(mafr.mes) = MONTH(ols.fecha) AND YEAR(mafr.mes) = YEAR(ols.fecha)
INNER JOIN cost AS c ON c.codigo_producto = ols.producto;

--Generar una query que me sirva para verificar que el nivel de agregacion de la tabla de ventas (y de la vista) no se haya afectado. 
--Recordas que es el nivel de agregacion/detalle? Lo vimos en la teoria de la parte 1! Nota: La orden M999000061 parece tener un problema verdad?
--Lo vamos a solucionar mas adelante.

SELECT orden, COUNT(1)
FROM order_line_sale
GROUP BY orden
HAVING(COUNT(1)) > 1
ORDER BY orden

--Calcular el margen bruto a nivel Subcategoria de producto. Usar la vista creada.

SELECT pm.subcategoria,
       SUM(vec.ventas_en_dolares) - SUM(c.costo_promedio_usd)  AS margen_bruto
FROM product_master AS pm
INNER JOIN v_ejercicio3_clase_6 AS vec ON pm.codigo_producto = vec.producto
INNER JOIN cost AS c ON pm.codigo_producto = c.codigo_producto
GROUP BY subcategoria;

--Calcular la contribucion de las ventas brutas de cada producto al total de la orden. Por esta vez, si necesitas usar una subquery, 
--podes utilizarla.

SELECT 
       ols2.orden,
       ols2.producto,	   
       SUM(ols2.venta) / 
       (SELECT SUM(ols1.venta) FROM order_line_sale AS ols1 WHERE ols1.orden = ols2.orden GROUP BY ols1.orden) * 100 AS contribucion_ventas_brutas
FROM order_line_sale AS ols2
GROUP BY ols2.producto, ols2.orden
ORDER BY ols2.orden, ols2.producto

--Calcular las ventas por proveedor, para eso cargar la tabla de proveedores por producto. 

CREATE TABLE suppliers ( 
codigo_producto VARCHAR(20),
nombre VARCHAR(50),
is_primary VARCHAR(20));

INSERT INTO suppliers (codigo_producto, nombre, is_primary)
VALUES 
('p100014',	'Samsung', 'TRUE'),
('p100023', 'TodoTech', 'TRUE'),
('p100023', 'Soportes TV', 'FALSE'),
('p100023',	'La cueva de la tecnologia', 'FALSE'),
('p100022',	'Philips',	'TRUE'),
('p100015',	'Soportes TV',	'FALSE'),
('p100015',	'La cueva de la tecnologia', 'TRUE'),
('p200010',	'JBL',	'TRUE'),
('p200034',	'Philips',	'TRUE'),
('p200087',	'Compumundo',	'FALSE'),
('p200087',	'Acer',	'TRUE'),
('p200088',	'Motorola',	'TRUE'),
('p200089',	'Samsung',	'TRUE'),
('p300001',	'Levi''s',	'TRUE'),
('p300002',	'Levi''s',	'TRUE'),
('p300003',	'Levi''s',	'TRUE'),
('p300004',	'Tommy Hilfiger',	'TRUE'),
('p300005',	'Tommy Hilfiger',	'TRUE'),
('p300006',	'Tommy Hilfiger',	'TRUE'),
('p300007',	'Tommy Hilfiger',	'TRUE'),
('p300008',	'Tommy Hilfiger',	'TRUE'),
('p300009',	'Tommy Hilfiger',	'TRUE');

SELECT s.nombre,
	   SUM(ols.venta) AS venta
FROM order_line_sale AS ols
INNER JOIN suppliers AS s ON s.codigo_producto = ols.producto
GROUP BY s.nombre;

--Agregar el nombre del proveedor en la vista del punto 3.
ALTER VIEW v_ejercicio3_clase_6 AS
SELECT ols.*,
	   CASE WHEN moneda = 'ARS' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_peso) - c.costo_promedio_usd
	        WHEN moneda = 'URU' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_uru) - c.costo_promedio_usd
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (venta - COALESCE(descuento,0)) - c.costo_promedio_usd
		WHEN moneda = 'EUR' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_eur) - c.costo_promedio_usd
	   END AS margen,
	   CASE WHEN moneda = 'ARS' THEN venta / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN venta  / mafr.cotizacion_usd_uru
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN venta
		WHEN moneda = 'EUR' THEN venta / mafr.cotizacion_usd_eur
	   END AS ventas_en_dolares,
	   CASE WHEN moneda = 'ARS' THEN  COALESCE(descuento,0) / mafr.cotizacion_usd_peso
	        WHEN moneda = 'URU' THEN  COALESCE(descuento,0) / mafr.cotizacion_usd_uru
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN COALESCE(descuento,0)
		WHEN moneda = 'EUR' THEN COALESCE(descuento,0) / mafr.cotizacion_usd_eur
	   END AS descuentos_en_dolares,
	   CASE WHEN moneda = 'ARS' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_peso) - c.costo_promedio_usd
	        WHEN moneda = 'URU' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_uru) - c.costo_promedio_usd
		WHEN moneda = 'EUR' AND mafr.cotizacion_usd_eur = 0 THEN (venta - COALESCE(descuento,0)) - c.costo_promedio_usd
		WHEN moneda = 'EUR' THEN ((venta - COALESCE(descuento,0)) / mafr.cotizacion_usd_eur) - c.costo_promedio_usd
	   END AS creditos_en_dolares,
	   s.nombre
FROM order_line_sale AS ols
INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(mafr.mes) = MONTH(ols.fecha) AND YEAR(mafr.mes) = YEAR(ols.fecha)
INNER JOIN cost AS c ON c.codigo_producto = ols.producto
INNER JOIN suppliers AS s ON s.codigo_producto = ols.producto;

--Verificar que el nivel de detalle de la vista anterior no se haya modificado, en caso contrario que se deberia ajustar?
--Que decision tomarias para que no se genereren duplicados?
--Se debe crear una vista aparte con las ordenes, productos y proveedores.

SELECT orden, COUNT(1)
FROM v_ejercicio3_clase_6
GROUP BY orden
HAVING(COUNT(1)) > 1
ORDER BY orden

--Se pide correr la query de validacion.

SELECT orden,
       ROW_NUMBER() OVER(PARTITION BY orden ORDER BY orden)	   
FROM v_ejercicio3_clase_6


--Crear una nueva query que no genere duplicacion.

SELECT orden,
       producto,
       tienda,
       fecha,
       SUM(cantidad),
       SUM(venta),
       SUM(descuento),
       SUM(impuestos),
       SUM(creditos),
       moneda,
       pos,
       is_walkout,
       SUM(margen),
       SUM(ventas_en_dolares),
       SUM(descuentos_en_dolares),
       SUM(creditos_en_dolares),
       nombre
FROM v_ejercicio3_clase_6
GROUP BY orden, producto, tienda, fecha, moneda, pos, is_walkout, nombre

--Explicar brevemente (con palabras escrito tipo comentario) que es lo que sucedia.

--Hubo duplicidad de datos al insertar los valores de la columna "nombre" de la tabla "suppliers" en la vista, por lo que la forma en que no genere
--duplicacion es agrupar los valores no numericos y sumar los valores numericos.

--Clase 7

--Calcular el porcentaje de valores null de la tabla stg.order_line_sale para la columna creditos y descuentos. 
--porcentaje de nulls en cada columna)

SELECT 
	   (CAST(SUM(CASE WHEN creditos IS NULL THEN 1 ELSE 0 END) AS NUMERIC(10, 5)) / COUNT(*)) * 100 AS porcentaje_creditos_NULL,
	   (CAST(SUM(CASE WHEN descuento IS NULL THEN 1 ELSE 0 END) AS NUMERIC(10, 5)) / COUNT(*)) * 100 AS porcentaje_descuentos_NULL
FROM order_line_sale;

--La columna "is_walkout" se refiere a los clientes que llegaron a la tienda y se fueron con el producto en la mano
--(es decir habia stock disponible). Responder en una misma query:
--Cuantas ordenes fueron "walkout" por tienda?
--Cuantas ventas brutas en USD fueron "walkout" por tienda?
--Cual es el porcentaje de las ventas brutas "walkout" sobre el total de ventas brutas por tienda?

SELECT ols.tienda,
	   SUM(CASE WHEN ols.is_walkout = 'True' THEN 1 ELSE 0 END) AS ordenes_walkout_tienda,
	   SUM(CASE WHEN ols.moneda = 'ARS' AND ols.is_walkout = 'True' THEN ols.venta / mafr.cotizacion_usd_peso 
	   WHEN ols.moneda = 'EUR' AND mafr.cotizacion_usd_eur != 0 AND ols.is_walkout = 'True' THEN ols.venta / mafr.cotizacion_usd_eur 
	   WHEN ols.moneda = 'URU' AND ols.is_walkout = 'True' THEN ols.venta / mafr.cotizacion_usd_uru 
	   ELSE 0 END) AS ventas_brutas_USD_walkout_tienda,
	  (SUM(CASE WHEN ols.is_walkout = 'True' THEN venta ELSE 0 END) / SUM(venta)) * 100 AS ventas_walkout_total_ventas_tienda
FROM order_line_sale AS ols
INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(mafr.mes) = MONTH(ols.fecha) AND YEAR(mafr.mes) = YEAR(ols.fecha) 
GROUP BY ols.tienda;

--Siguiendo el nivel de detalle de la tabla ventas, hay una orden que no parece cumplirlo.
--Como identificarias duplicados utilizando una windows function? Nota: Esto hace referencia a la orden M999000061.
--Tenes que generar una forma de excluir los casos duplicados, para este caso particular y a nivel general, 
--si llegan mas ordenes con duplicaciones.

WITH cte_duplicados AS (
	SELECT orden,
		   ROW_NUMBER() OVER(PARTITION BY orden ORDER BY orden) AS duplicados
	FROM order_line_sale
)
SELECT 
	   orden,
	   duplicados
FROM cte_duplicados
WHERE duplicados > 1;

WITH cte_duplicados as (
	SELECT *, 
		   ROW_NUMBER() OVER (PARTITION BY orden ORDER BY orden) AS conteo
	FROM order_line_sale
)
SELECT * FROM cte_duplicados
WHERE conteo = 1

--Obtener las ventas totales en USD de productos que NO sean de la categoria "TV" NI esten en tiendas de Argentina.

WITH cte_ventas_USD AS (
SELECT  
        ols.producto AS producto,
		pm.subcategoria AS subcategoria,
		SUM(CASE WHEN ols.moneda = 'URU' THEN ols.venta / mafr.cotizacion_usd_uru ELSE 0 END) +
		SUM(CASE WHEN ols.moneda = 'EUR' AND cotizacion_usd_eur != 0 THEN ols.venta / mafr.cotizacion_usd_eur ELSE 0 END) AS ventas_usd
FROM order_line_sale AS ols
INNER JOIN product_master AS pm ON ols.producto = pm.codigo_producto
INNER JOIN monthly_average_fx_rate AS mafr ON MONTH(ols.fecha) = MONTH(mafr.mes) AND YEAR(ols.fecha) = YEAR(mafr.mes)
WHERE pm.subcategoria != 'TV' AND pm.origen != 'Argentina'
GROUP BY ols.producto, pm.subcategoria
)
SELECT 
	   producto,
	   subcategoria,
	   CAST(ventas_usd AS DECIMAL(10,5)) AS ventas_usd
FROM cte_ventas_USD
WHERE  ventas_usd != 0
GROUP BY producto, subcategoria, ventas_usd;

--El gerente de ventas quiere ver el total de unidades vendidas por dia junto con 
--otra columna con la cantidad de unidades vendidas una semana atras 
--y la diferencia entre ambos. Nota: resolver en dos querys usando en una CTEs y en la otra windows functions.

WITH cte_ventas_totales AS (
	SELECT ols.fecha AS fecha,
		   SUM(ols.cantidad) AS cantidad_total		   
	FROM order_line_sale AS ols
	GROUP BY ols.fecha
)
SELECT
	cte1.fecha,
	cte2.cantidad_total - cte1.cantidad_total AS diferencia
FROM cte_ventas_totales AS cte1
INNER JOIN cte_ventas_totales AS cte2 ON cte1.fecha = DATEADD(DAY,-7,cte2.fecha)

--Crear una vista de inventario con la cantidad de inventario por dia, tienda y producto, que ademas va a contar con los siguientes datos:
--Nombre y categorias de producto
--Pais y nombre de tienda
--Costo del inventario por linea (recordar que si la linea dice 4 unidades debe reflejar el costo total de esas 4 unidades)
--Una columna llamada "is_last_snapshot" para el ultimo dia disponible de inventario.
--Ademas vamos a querer calcular una metrica llamada "Average days on hand (DOH)" que mide cuantos dias de venta nos alcanza el inventario. 
--Para eso DOH = Unidades en Inventario Promedio / Promedio diario Unidades vendidas ultimos 7 dias.
--Notas:
--Antes de crear la columna DOH, conviene crear una columna que refleje el Promedio diario Unidades vendidas ultimos 7 dias.
--El nivel de agregacion es dia/tienda/sku.
--El Promedio diario Unidades vendidas los ultimos 7 dias tiene que calcularse para cada dia.

WITH cte_calculos AS (
SELECT 
	   i.fecha,
	   i.tienda,
	   i.sku,	     
	   sm.nombre,
	   sm.pais,
	   (inicial + final )/2 AS inventario_promedio,
	   AVG((i.inicial+i.final)/2) OVER (PARTITION BY i.fecha, i.tienda, i.sku) * c.costo_promedio_usd as costo_inventario_linea,
	   CASE WHEN LEAD(i.fecha) OVER (PARTITION BY i.tienda, i.sku ORDER BY i.tienda) IS NULL THEN 1 ELSE 0 END AS is_last_snapshot,
	   AVG(ols.cantidad) OVER (PARTITION BY i.fecha,i.tienda,i.sku ORDER BY ols.fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS promedio_siete_dias
FROM order_line_sale AS ols
LEFT JOIN store_master AS sm ON sm.codigo_tienda = ols.tienda
LEFT JOIN cost AS c ON c.codigo_producto = ols.producto
LEFT JOIN inventory AS i ON i.sku = ols.producto
)
SELECT fecha,
	   tienda,
	   sku,	     
	   nombre,
	   pais,
	   inventario_promedio,
	   costo_inventario_linea,
	   is_last_snapshot,
	   inventario_promedio / promedio_siete_dias AS DOH
FROM cte_calculos

--Clase 8

--Realizar el Ejercicio 5 de la clase 6 donde calculabamos la contribucion de las ventas brutas de cada producto utilizando una window function.

SELECT  orden,
	producto,		
		(venta / SUM(venta) OVER(PARTITION BY orden)) * 100 AS contribucion_venta
FROM order_line_sale;

--La regla de pareto nos dice que aproximadamente un 20% de los productos generan un 80% de las ventas. 
--Armar una vista a nivel sku donde se pueda identificar por orden de contribucion, ese 20% aproximado de SKU mas importantes. (Nota: En este ejercicios estamos construyendo una tabla que muestra la regla de Pareto)

WITH cte_calculos AS (
SELECT  
       producto,		
       (venta / SUM(venta) OVER()) * 100 AS contribucion_producto
FROM order_line_sale
)
SELECT 
	   producto,	  
	   SUM(contribucion_producto) AS contribucion_producto
FROM cte_calculos
GROUP BY producto
ORDER BY contribucion_producto DESC

--Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento.

WITH cte_venta_tienda AS (
SELECT 
       YEAR(ols.fecha) AS año, 
       MONTH(ols.fecha) AS mes,
       ols.tienda, 
       ols.moneda AS valor_nominal,
       SUM(venta) AS venta
FROM order_line_sale AS ols
GROUP BY tienda, moneda, YEAR(ols.fecha), MONTH(ols.fecha)
)
SELECT 
	año,
	mes,
	tienda,
	valor_nominal,	
	CASE WHEN venta > LAG(venta) OVER(PARTITION BY tienda ORDER BY tienda) 
	THEN ((venta - LAG(venta) OVER(PARTITION BY tienda ORDER BY tienda)) / venta) * 100
	ELSE ((venta - LAG(venta) OVER(PARTITION BY tienda ORDER BY tienda)) / LAG(venta) OVER(PARTITION BY tienda ORDER BY tienda)) * 100 END AS valor_crecimiento	
FROM cte_venta_tienda;

--Crear una vista a partir de la tabla "return_movements" que este a nivel Orden de venta, item y que contenga las siguientes columnas:
--Orden
--Sku
--Cantidad unidades retornadas
--Valor USD retornado (resulta de la cantidad retornada * valor USD del precio unitario bruto con que se hizo la venta)
--Nombre producto
--Primera_locacion (primer lugar registrado, de la columna "desde", para la orden/producto)
--Ultima_locacion (el ultimo lugar donde se registro, de la columna "hasta", el producto/orden)

WITH cte_costo_promedio	AS (	
	SELECT codigo_producto,
	       AVG(costo_promedio_usd) AS costo_promedio_usd
	FROM cost
	GROUP BY codigo_producto
)
SELECT rm.orden_venta,
	   rm.item,
	   rm.cantidad,
	   rm.cantidad * ccp.costo_promedio_usd AS costo_promedio,
	   pm.nombre,
	   FIRST_VALUE(desde) OVER(PARTITION BY orden_venta, item ORDER BY id_movimiento ASC) AS primera_locacion,
	   LAST_VALUE(hasta) OVER(PARTITION BY orden_venta, item ORDER BY id_movimiento ASC) AS ultima_locacion
FROM return_movements AS rm
INNER JOIN cte_costo_promedio  AS ccp ON ccp.codigo_producto = rm.item
INNER JOIN product_master AS pm ON pm.codigo_producto = rm.item

--Crear una tabla calendario llamada "date" con las fechas del 2022 incluyendo el año fiscal y trimestre fiscal (en ingles Quarter). El año fiscal de la empresa comienza el primero Febrero de cada año y dura 12 meses. Realizar la tabla para 2022 y 2023. La tabla debe contener:
--Fecha (date)
--Mes (date)
--Año (date)
--Dia de la semana (text, ejemplo: "Monday")
--"is_weekend" (boolean, indicando si es Sabado o Domingo)
--Mes (text, ejemplo: June)
--Año fiscal (date)
--Año fiscal (text, ejemplo: "FY2022")
--Trimestre fiscal (text, ejemplo: Q1)
--Fecha del año anterior (date, ejemplo: 2021-01-01 para la fecha 2022-01-01)
--Nota: En general una tabla date es creada para muchos años mas (minimo 10), por el momento nos ahorramos ese paso y de la creacion de feriados.

WITH cte_dates
AS
(
  SELECT CAST('20220101' AS DATETIME) AS fecha
  UNION ALL
  SELECT DATEADD(dd, 1, fecha)
  FROM cte_dates
  WHERE DATEADD(dd, 1, fecha) <= '20231231'
)
SELECT fecha,
	   YEAR(fecha) AS año,
	   MONTH(fecha) AS mes,
	   DATEPART(WEEKDAY, fecha) AS dia_semana,
	   DATENAME(MONTH, fecha) AS mes_texto,
	   CASE WHEN DATEPART(WEEKDAY, fecha) = 7 OR DATEPART(WEEKDAY, fecha) = 1 THEN 'True'	        
	   ELSE 'False' 
	   END AS is_weekend,
	   YEAR(DATEADD(MONTH, -3, fecha)) AS año_fiscal,
	   'FY' + CAST(YEAR(DATEADD(MONTH, -3, fecha)) AS VARCHAR(20)) AS año_fical_texto,
	   DATEPART(QUARTER, fecha) AS trimestre_fiscal,
	   'Q' + + CAST(DATEPART(QUARTER, fecha) AS VARCHAR(20)) AS trimestre_fical_texto
INTO date
FROM cte_dates
OPTION (MAXRECURSION 0);

--Clase 9

--Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento. Utilizar self join.

WITH cte_ols AS(
SELECT  
	    YEAR(fecha) AS año,
		MONTH(fecha) AS mes,
		tienda,
		moneda,
		SUM(venta) AS venta
FROM order_line_sale AS o1
GROUP BY o1.tienda, YEAR(fecha), MONTH(fecha), moneda
)
SELECT  
	    o1.año,
		o1.mes,
		o1.tienda,
		o1.moneda,		
		CASE WHEN o1.venta > o2.venta AND o1.mes > o2.mes THEN ((o1.venta - o2.venta) / o1.venta) * 100 
			 WHEN o1.venta < o2.venta THEN ((o1.venta - o2.venta) / o2.venta) * 100 
		END AS valor_crecimiento
FROM cte_ols AS o1
INNER JOIN cte_ols AS o2 ON o1.tienda = o2.tienda
WHERE  o1.mes > o2.mes
ORDER BY tienda, año, mes

--Hacer un update a la tabla de product_master agregando una columna llamada "marca", con la marca de cada producto con la primer letra en mayuscula. 
--Sabemos que las marcas que tenemos son: Levi's, Tommy Hilfiger, Samsung, Phillips, Acer, JBL y Motorola. En caso de no encontrarse en la lista usar 'Unknown'.

ALTER TABLE product_master
ADD marca VARCHAR(50) NULL;

UPDATE product_master 
SET marca = 
      CASE  
        WHEN marca = LOWER(LEFT(s.nombre, 1)) THEN UPPER(LEFT(s.nombre, 1)) + SUBSTRING(s.nombre, 2, 50)         
        ELSE 'Unknown'
      END 
FROM product_master AS pm
INNER JOIN suppliers AS s
ON s.codigo_producto = pm.codigo_producto;


--Un jefe de area tiene una tabla que contiene datos sobre las principales empresas de distintas industrias en rubros que pueden ser competencia:

--empresa	        rubro	        facturacion
--El Corte Ingles	Departamental	$110.99B
--Mercado Libre	    ECOMMERCE	    $115.86B
--Fallabela	        departamental	$20.46M
--Tienda Inglesa	Departamental	$10.78M
--Zara	            INDUMENTARIA	$999.98M

--Armar una query que refleje lo siguiente:

--Rubro
--FacturacionTotal (total de facturación por rubro).
--Ordenadas por la columna rubro en orden ascendente.
--La columna FacturacionTotal debe estar expresada en millones/billones según corresponda y con 2 decimales después de la coma. 
--Los elementos de la columna rubro debe estar expresados en letra minúscula.

--Output esperado:
--rubro	           facturacion_total
--departamental	   111.01B
--ecommerce	       115.86B
--indumentaria	   999.98M

CREATE TABLE empresas (
	empresa VARCHAR(50),
	rubro VARCHAR(50),
	facturacion VARCHAR(50)
)

INSERT INTO empresas (empresa, rubro, facturacion)
VALUES
('El Corte Ingles', 'Departamental', '$110.99B'),
('Mercado Libre', 'ECOMMERCE', '$115.86B'),
('Fallabela', 'departamental', '$20.46M'),
('Tienda Inglesa', 'Departamental', '$10,78M'),
('Zara', 'INDUMENTARIA', '$999.98M');


WITH cte_facturacion AS (
SELECT 	   
	   LOWER(rubro) AS rubro,
	   CASE 	    
		WHEN RIGHT(facturacion, 1) = 'B'  THEN CAST(REPLACE(REPLACE(REPLACE(REPLACE(facturacion, 'B', '0000000'), '$', ''), '.', ''), ',', '') AS DECIMAL(15,0))
		WHEN RIGHT(facturacion, 1) = 'M'  THEN CAST(REPLACE(REPLACE(REPLACE(REPLACE(facturacion, 'M', '0000'), '$', ''), '.', ''), ',', '') AS DECIMAL(15,0))
	   END AS facturacion
FROM empresas
),
cte_suma AS (
SELECT 
	   rubro,
	   CAST(SUM(facturacion) AS VARCHAR(20)) AS facturacion
FROM cte_facturacion
GROUP BY rubro
)
SELECT 
	  rubro,
	  CASE 
	      WHEN LEN(facturacion) = 12 THEN '$' + SUBSTRING(facturacion,1,3) + '.' +SUBSTRING(facturacion, 4, 2) + 'B'
		  WHEN LEN(facturacion) = 11 THEN '$' + SUBSTRING(facturacion,1,2) + '.' +SUBSTRING(facturacion, 3, 2) + 'B'
		  WHEN LEN(facturacion) = 10 THEN '$' + SUBSTRING(facturacion,1,1) + '.' +SUBSTRING(facturacion, 2, 2) + 'B'
		  WHEN LEN(facturacion) = 9 THEN '$' + SUBSTRING(facturacion,1,3) + '.' +SUBSTRING(facturacion, 4, 2) + 'M'
		  WHEN LEN(facturacion) = 8 THEN '$' + SUBSTRING(facturacion,1,2) + '.' +SUBSTRING(facturacion, 3, 2) + 'M'
		  WHEN LEN(facturacion) = 7 THEN '$' + SUBSTRING(facturacion,1,1) + '.' +SUBSTRING(facturacion, 2, 2) + 'M'		  
	  END AS facturacion
FROM cte_suma

