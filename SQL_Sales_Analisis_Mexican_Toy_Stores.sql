-- Identificamos datos nulos dentro de los data sets
-- I look for null values on the date sets

-- Busco valores nulos en la tabla calendar.
-- I look for null values on the calendar table.
SELECT 
	date
FROM calendar
WHERE date IS NULL
;

-- Busco valores nulos en la tabla products.
-- I look for null values on the products table.

SELECT 
	product_id,
	product_name,
	product_category,
	product_cost,
	product_price
FROM
	products
WHERE
	product_id IS NULL
	OR product_name IS NULL
	OR product_category IS NULL
	OR product_cost IS NULL
	OR product_price IS NULL
;

-- Busco valores nulos en la tabla stores.
-- I look for null values on the stores table.

SELECT 
	store_id,
	store_name,
	store_city,
	store_location,
	store_open_date
FROM
	stores
WHERE 
	store_id IS NULL
	OR store_name IS NULL
	OR store_city IS NULL
	OR store_location IS NULL
	OR store_open_date IS NULL
;

-- Busco valores nulos en la tabla inventory.
-- I look for null values on the inventory table.

SELECT
	store_id,
	product_id,
	stock_on_hand	
FROM
	inventory
WHERE	
	store_id IS NULL
	OR product_id IS NULL
	OR stock_on_hand IS NULL	
	;

-- Busco valores nulos en la tabla sales.
-- I look for null values on the sales table.
SELECT
	sale_id,
	date,
	store_id,
	product_id,
	units
FROM sales
WHERE 
	sale_id IS NULL
	OR date IS NULL
	OR store_id IS NULL
	OR product_id IS NULL
	OR units IS NULL
 ;


/*  -Encontramos que no hay valores nulos dentro de los data sets.
	-No NULL values were found in any of the datasets.*/

-- Buscamos datos duplicados dentro de los diferentes datasets.
-- Checking for duplicate records in all datasets.

-- Calendare table

WITH duplicates AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY Date ORDER BY Date) AS rn
	FROM 
		calendar
)
SELECT
	*
FROM 
	duplicates
WHERE 
	rn > 1;

-- Products table
WITH duplicates AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID) AS rn
	FROM 
		products
)
SELECT
	*
FROM 
	duplicates
WHERE 
	rn > 1;

-- Stores table
WITH duplicates AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY Store_ID ORDER BY Store_ID) AS rn
	FROM 
		stores
)
SELECT
	*
FROM 
	duplicates
WHERE 
	rn > 1;

-- Inventory table
WITH duplicates AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY store_id,Product_ID ORDER BY store_id,Product_ID) AS rn
	FROM 
		inventory
)
SELECT
	*
FROM 
	duplicates
WHERE 
	rn > 1;	

-- Sales table
WITH duplicates AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY sale_id) AS rn
	FROM 
		sales
)
SELECT
	*
FROM 
	duplicates
WHERE 
	rn > 1;	
	
-- Exploramos las primeras 5 filas de cada data set, para conocer la estructura de los datos.
-- We explored the first 5 rows of each dataset to understand the data structure.

-- Tabla Calendar
-- Calendar Table
SELECT *
FROM calendar
LIMIT 5;

-- Tabla Products
-- Products Table
SELECT *
FROM products
LIMIT 5;

-- Tabla Stores
-- Stores Table
SELECT *
FROM stores 
LIMIT 5;

-- Tabla Inventory
-- Inventory Table
SELECT *
FROM inventory
LIMIT 5;

-- Tabla Sales
-- Sales Table
SELECT *
FROM sales
LIMIT 5; 


/* Estandarizamos los tipos de datos en los distintos datasets, convirtiendo columnas de texto a DATE
y ajustando columnas numéricas de INTEGER a DECIMAL para asegurar consistencia y precisión en el modelo*/

/* Standardize data types across the different datasets by converting text-based date columns to DATE
and adjusting numeric columns from INTEGER to DECIMAL to ensure consistency and analytical precision.*/



/* Standardize date formats across Calendar and Sales tables by converting
   text-based dates to DATE.

   Setting DateStyle ensures PostgreSQL interprets incoming dates correctly
   (MM/DD/YYYY).*/

ALTER DATABASE "Mexico Toy Sales" SET DateStyle = 'ISO, MDY';

/*	-Transformamos los valores de la columna 'date' del dataset Calendar
	al tipo DATE.
	
	-Convert raw text dates in the Calendar table to proper DATE values.*/
	
UPDATE calendar
SET date = TO_DATE(date, 'MM/DD/YYYY');

-- Verificamos la conversión mostrando la columna ya como tipo DATE.
-- Validate the conversion by selecting the normalized DATE values.
SELECT CAST(date AS DATE) AS Date_format
FROM calendar;


-- Transformamos los valores de la columna 'date' del dataset Sales al tipo DATE.
-- Convert raw text dates in the Sales table to proper DATE values.
UPDATE sales
SET date = TO_DATE(date, 'YYYY/MM/DD');.

-- Verificamos la conversión mostrando la columna ya como tipo DATE.
-- Validate the conversion by selecting the normalized DATE values.
SELECT CAST(date AS DATE) AS Date_format
FROM sales;

/* 	-Convertimos columnas almacenadas como texto a tipo DECIMAL para 
	garantizar precisión numérica y consistencia en los distintos datasets.
	
	-Convert text-based columns to DECIMAL to ensure numerical precision
	and maintain consistency across the datasets.*/



UPDATE products
SET product_cost = REPLACE(REPLACE(product_cost, '$', ''), ',', '')::DECIMAL;

SELECT
CAST(product_cost AS DECIMAL(10,2))
FROM products;

UPDATE products
SET product_price = REPLACE(REPLACE(product_price, '$', ''), ',', '')::DECIMAL;

SELECT
CAST(product_price AS DECIMAL(10,2))
FROM products;

/* 	-Fase de Análisis Exploratorio de Datos (EDA)

	-Exploratory Data Analysis (EDA) Phase. */
/*
	- Resumen de Desempeño de Ventas por Tienda
	- Store Sales Performance Summary
	
	- Calcula estadísticas de ventas por tienda (conteo, máximo, mínimo, promedio, 
	  desviación estándar) para identificar variabilidad y diferencias de 
	  desempeño entre ubicaciones.

	- Computes sales statistics per store (count, max, min, average, std dev) 
	  to identify variability and performance differences across locations.
*/

WITH transactions AS (
	SELECT 
		s.sale_id,
		s.date AS transaction_date,
		CAST(s.store_id AS integer),
		s.units,
		st.store_name,
		st.store_city,
		st.store_location,
		p.product_id,
		p.product_name,
		p.product_price,
		(s.units * CAST(p.product_price AS DECIMAL(10,2))) AS total_sale
	FROM sales AS s
	LEFT JOIN products AS p 
		ON s.product_id = p.product_id
	LEFT JOIN stores AS st
		ON s.store_id = st.store_id
),
agg AS (
    SELECT 
		store_id,
		store_name,
		store_location,
        COUNT(sale_id) AS number_of_sales,
		MAX(total_sale) AS max_sale,
		MIN(total_sale) AS min_sale,
		ROUND (AVG (total_sale),2) AS average_sale,
		ROUND (STDDEV(total_sale),2) AS std_sale,
		(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_sale)) AS quartile_1,
		(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sale)) AS median_sales, 
		(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_sale)) AS quartile_3 
	FROM transactions
    GROUP BY store_id, store_name, store_location
)
SELECT
    store_id,
	store_name,
    number_of_sales,
	Max_sale,
    Min_sale,
	average_sale,
	std_sale,
	quartile_1,
	median_sales,
	quartile_3
FROM 
	agg
ORDER BY 
	store_id ASC
;

/*
	- El resumen de desempeño abarca 50 tiendas Maven Toys con un total de 829,262 ventas
	  en toda la cadena, con un ticket promedio simple de $17.33 MXN entre tiendas; sin 
	  embargo, el dato que más salta a la vista es Maven Toys Guanajuato 3, que registra 
	  la venta individual más alta de toda la cadena ($879.78, casi el doble que la segunda
	  más alta) junto con la desviación estándar más grande ($27.90) y el coeficiente de 
	  variación más extremo (147.2%, el doble que cualquier otra tienda) —esto significa que 
	  su promedio de $18.96 está siendo distorsionado por unas pocas transacciones atípicas,
	  no por un comportamiento de venta real consistente, y antes de usar esa tienda como 
	  referencia de desempeño valdría la pena auditar esa transacción de $879.78 
	  (¿fue una venta al por mayor, un error de captura, o una devolución mal registrada?).
	  En volumen, Ciudad de México 2 lidera con 29,024 ventas, casi el doble que las tiendas 
	  de menor volumen como Toluca 2 (12,776) y Campeche 2 (12,805), una brecha de más de 2x
	  entre la tienda más y menos activa que sugiere diferencias de tamaño de mercado o 
	  superficie de venta, no necesariamente de eficiencia. Finalmente, varias tiendas 
	  (Hermosillo 3, Guadalajara 3, Ciudad de México 2, Monterrey 4) muestran una brecha 
	  notable entre su promedio y su mediana (hasta $5.84 de diferencia en Hermosillo 3), 
	  confirmando que sus promedios están sesgados hacia arriba por ventas grandes ocasionales
	  —la mediana es la métrica más confiable para comparar el "ticket típico" entre tiendas,
	  no el promedio.

	- The performance summary covers 50 Maven Toys stores with a combined total of 829,262
	  sales across the chain, with a simple average ticket of $17.33 MXN across stores; 
	  however, the standout finding is Maven Toys Guanajuato 3, which records the single 
	  highest sale in the entire chain ($879.78, nearly double the second-highest) along 
	  with the largest standard deviation ($27.90) and the most extreme coefficient of variation
	  (147.2%, double any other store) — meaning its $18.96 average is being distorted by a 
	  handful of outlier transactions rather than reflecting consistent real sales behavior, 
	  and before using that store as a performance benchmark it's worth auditing that $879.78
	  transaction (was it a bulk sale, a data-entry error, or a mislogged return?). In volume,
	  Ciudad de México 2 leads with 29,024 sales, nearly double the lowest-volume stores like
	  Toluca 2 (12,776) and Campeche 2 (12,805), a gap of over 2x between the most and least active 
	  store that likely reflects market size or store footprint differences rather than 
	  necessarily operational efficiency. Finally, several stores (Hermosillo 3, Guadalajara 3
	  , Ciudad de México 2, Monterrey 4) show a notable gap between their average and median
	  (up to $5.84 in Hermosillo 3), confirming their averages are skewed upward by occasional
	  large sales — median is the more reliable metric for comparing the "typical ticket" across
	  stores, not the average.
*/


/*	- Cuál categoría de producto es responsable de la utilidad más alta?
	- Which product categories drive the biggest profits? */

WITH transactions AS (
	SELECT 
		s.sale_id,
		s.date AS transaction_date,
		s.store_id,
		s.units,
		p.product_id,
		p.product_name,
		p.product_category,
		p.product_cost,
		p.product_price,
		(s.units * CAST(p.product_cost AS DECIMAL(10,2))) AS total_cost,
		(s.units * CAST(p.product_price AS DECIMAL(10,2))) AS total_sale
	FROM sales AS s
	LEFT JOIN products AS p 
		ON s.product_id = p.product_id
),
agg AS (
    SELECT 
        product_category,
        SUM(total_cost) AS total_cost,
        SUM(total_sale) AS total_sale,
        SUM(total_sale - total_cost) AS total_profit
    FROM transactions
    GROUP BY product_category
)
SELECT
    product_category,
    total_sale,
	total_cost,
    total_profit,
	CAST((total_profit / SUM(total_profit) OVER ()) AS DECIMAL(10,2)) AS percent_of_total
FROM 
	agg
ORDER BY 
	percent_of_total DESC
;

/*

	- La categoría de Juguetes representa aproximadamente el 27% de la contribución
   	  total a las ganancias, lo que la convierte en uno de los principales 
	  Impulsores del rendimiento general.

	- The Toys category accounts for approximately 27% of the overall profit
	  contribution, making it one of the key drivers of total performance.

*/

/* 	
	- Cuál categoría de producto representa la mayor utilidad por tienda.
	- Which product categories drive the biggest profits by store locations?
*/

WITH transactions AS (
	SELECT 
		s.sale_id,
		st.store_location AS store_location,
		s.date AS transaction_date,
		s.store_id,
		s.units,
		p.product_id,
		p.product_name,
		p.product_category,
		p.product_cost,
		p.product_price,
		(s.units * CAST(p.product_cost AS DECIMAL(10,2))) AS total_cost,
		(s.units * CAST(p.product_price AS DECIMAL(10,2))) AS total_sale
	FROM sales AS s
	LEFT JOIN products AS p 
		ON s.product_id = p.product_id
	LEFT JOIN stores AS st 
		ON s.store_id = st.store_id
),
 agg AS (
    SELECT 
        store_location,
        product_category,
        SUM(total_cost) AS total_cost,
        SUM(total_sale) AS total_sale,
        SUM(total_sale - total_cost) AS total_profit
    FROM transactions
    GROUP BY store_location, product_category
),
ranked AS (
    SELECT
        store_location,
        product_category,
        total_cost,
        total_sale,
        total_profit,
        DENSE_RANK() OVER (
            PARTITION BY store_location 
            ORDER BY total_profit DESC
        ) AS ranking
    FROM agg
)
SELECT *
FROM ranked
WHERE ranking = 1
ORDER BY store_location;

/* 	- Como podemos observar, la categoría de Juguetes se mantiene como la 
	principal generadora de utilidad en las tiendas Downtown y Residential.
	En contraste, la categoría de Electrónica se convierte en el principal
	impulsor de ganancias en las tiendas Airport y Commercial.
	
	- As we can observe, the Toys category remains the top profit maker in
	both the Downtown and Residential stores. In contrast, the Electronics
	category becomes the number one profit driver in the Airport and 
	Commercial stores.”
*/	 


/*
	- Tendencias y Patrones Estacionales en las Ventas
	- Seasonal Trends & Patterns in Sales Data
*/

/*  - Agregamos columnas de Año, Trimestre y Mes a la tabla Calendar
	- We add columns Year, Quarter, and Month to the Calendar table.
*/

ALTER TABLE calendar
ADD COLUMN month_name TEXT;
UPDATE calendar
SET month_name = TO_CHAR(date::DATE, 'Month');

ALTER TABLE calendar
ADD COLUMN month_number TEXT;
UPDATE calendar
SET month_number = EXTRACT(MONTH FROM date::DATE)

ALTER TABLE calendar
ADD COLUMN quarter TEXT;
UPDATE calendar
SET quarter = EXTRACT(QUARTER FROM date::DATE);

ALTER TABLE calendar
ADD COLUMN year TEXT;
UPDATE calendar
SET year = EXTRACT(YEAR FROM date::DATE);

ALTER TABLE calendar
    ALTER COLUMN year TYPE INTEGER USING year::INTEGER,
    ALTER COLUMN quarter TYPE INTEGER USING quarter::INTEGER,
    ALTER COLUMN month_number TYPE INTEGER USING month_number::INTEGER;

/* 
	- Esta consulta calcula el rendimiento de ventas Mes contra Mes (MoM).
       
    - This query calculates Month-over-Month (MoM) sales performance.
*/

WITH transactions AS (
	SELECT 
		s.sale_id,
		s.date AS transaction_date,
		c.month_name,
		c.month_number,
		c.year,
		c.quarter,
		s.store_id,
		s.units,
		p.product_id,
		p.product_cost,
		p.product_price,
		(s.units * CAST(p.product_cost AS DECIMAL(10,2))) AS total_cost,
		(s.units * CAST(p.product_price AS DECIMAL(10,2))) AS total_sales
	FROM sales AS s
	LEFT JOIN products AS p 
		ON s.product_id = p.product_id
	LEFT JOIN calendar AS c
		ON s.date=c.date
),
agg AS (
    SELECT 
		sale_id,
        SUM(t.total_cost) AS total_cost,
        SUM(t.total_sales) AS total_sales,
        SUM(t.total_sales - t.total_cost) AS total_profit
    FROM transactions AS t
	GROUP BY 
		sale_id
),
monthly AS (
    SELECT
        t.year,
        t.quarter,
        t.month_name,
        t.month_number,
        SUM(t.total_sales) AS total_sales
    FROM transactions AS t
    LEFT JOIN agg a ON t.sale_id = a.sale_id
    GROUP BY 
        t.year,
        t.quarter,
        t.month_name,
        t.month_number
)
SELECT 
	year,
	quarter,
	month_number,
	month_name,
	total_sales,
	LAG(total_sales) OVER (ORDER BY year, month_number) AS last_month_sales,
	total_sales - LAG(total_sales) OVER (ORDER BY year, month_number) AS MoM_change,
	ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year, month_number)) / NULLIF(LAG(total_sales) OVER (ORDER BY year, month_number), 0) * 100, 2) AS MoM_pct_change

FROM monthly
ORDER BY year, quarter, month_number
;


/*
	1. Pico de marzo (fin de Q1) — $883,516, el mes más alto de los 9. Marzo rompe un patrón de meseta: enero y febrero están cerca de $747K/$723K, y luego marzo salta +22% vs. febrero. Esto es consistente con un comportamiento de "cierre de trimestre" (push de ventas antes del fin de Q1), pero con un solo trimestre de evidencia no puedo confirmar si es recurrente.
	2. Meseta estable en Q2 — abril, mayo y junio están prácticamente planos: $827.7K, $825.3K, $808.3K (variación de apenas ~2.3% entre el más alto y el más bajo). El crecimiento YoY también se estabiliza en una banda muy estrecha: 21.5%, 22.8%, 22.1%. Esta consistencia en 3 meses seguidos — tanto en nivel como en tasa de crecimiento — es el patrón más "limpio" de todo el dataset.
	3. Spike de julio, seguido de caída marcada en agosto-septiembre — julio repite el nivel de Q2 (~$828K) pero con un salto brusco en YoY (48.97%, el segundo más alto del año). Después, agosto y septiembre caen fuerte tanto en nivel ($660.9K, $658.2K — los dos meses más bajos del período) como en crecimiento YoY (35.0% → 12.35%, la caída más pronunciada de toda la serie).
	4. Desaceleración acumulada hacia fin de Q3 — el 12.35% de septiembre es menos de un tercio del 37.72% con que arrancó el año en enero. Si esta trayectoria continúa, octubre podría acercarse a crecimiento plano o negativo — vale la pena monitorear en cuanto tengas el dato.
	
	
	1. March spike (end of Q1) — $883,516, the highest month of the 9. March breaks a plateau pattern: January and February sit close together ($747K / $723K), then March jumps +22% vs. February. This is consistent with "quarter-end push" behavior (sales concentrated before Q1 closes), but with only one quarter of evidence I can't confirm whether it's recurring.
	2. Stable plateau in Q2 — April, May, and June are nearly flat: $827.7K, $825.3K, $808.3K (only ~2.3% spread between the highest and lowest). YoY growth also settles into a tight band: 21.5%, 22.8%, 22.1%. This consistency across 3 straight months — both in level and growth rate — is the cleanest pattern in the whole dataset.
	3. July spike, followed by a sharp drop in August-September — July matches Q2's level (~$828K) but with a sudden jump in YoY growth (48.97%, the second-highest of the year). Then August and September both fall hard in level ($660.9K, $658.2K — the two lowest months in the period) and in YoY growth (35.0% → 12.35%, the steepest drop in the entire series).
	4. Cumulative deceleration toward the end of Q3 — September's 12.35% is less than a third of the 37.72% the year started with in January. If this trajectory continues, October could approach flat or negative growth — worth monitoring once that data is available.
*/

/*
	
	- Estima el ingreso diario perdido por cada combinación tienda-producto que está sin stock,
	  usando el promedio histórico de unidades vendidas por día como proxy de la demanda no satisfecha.

	- Estimates daily revenue lost per store-product combination currently out of stock,
	  using historical average daily units sold as a proxy for unmet demand.
*/

WITH avg_sales AS (
    SELECT
        store_id,
        product_id,
        AVG(units) AS avg_daily_units
    FROM sales
    GROUP BY store_id, product_id
),
oos AS ( --Out of Stock = oos-- 
    SELECT
        store_id,
        product_id
    FROM inventory
    WHERE stock_on_hand = 0
)
SELECT
    o.store_id,
    o.product_id,
    ROUND(a.avg_daily_units,2) AS estimated_lost_units,
    p.product_price,
    ROUND((a.avg_daily_units * CAST(p.product_price AS numeric)),2) AS estimated_lost_revenue
FROM oos o
JOIN avg_sales a
    ON o.store_id = a.store_id
   AND o.product_id = a.product_id
JOIN products p
    ON o.product_id = p.product_id
ORDER BY estimated_lost_revenue DESC;


/*
	- Entre las 77 combinaciones tienda-producto actualmente sin 
	  stock, el ingreso perdido estimado total es ~$1,123.15/día. Esto es una foto de 
	  un solo día (no acumulado) — si alguno de estos productos lleva varios días sin 
	  stock, la pérdida real acumulada es proporcionalmente mayor (la query no registra 
	  cuántos días lleva cada quiebre).

		- Mayor oportunidad individual: Tienda 4 / Producto 34 ($29.30/día) y 
		  Tienda 33 / Producto 13 ($26.35/día) son los dos quiebres de mayor valor 
		  individual.
		  	 	
	- Across the 77 store-product combinations currently out of stock, the estimated 
	  total lost revenue is ~$1,123.15/day. This is a snapshot 
	  (one day's worth of lost demand), not cumulative — if any of these items have been
	  out of stock for multiple days, the real cumulative loss is proportionally higher
	  (the query doesn't track stockout duration). 
		
		-Highest single opportunity: Store 4 / Product 34 ($29.30/day) and 
		 Store 33 / Product 13 ($26.35/day) are the two single highest-value 
		 stockouts.
*/

/*

How much money is tied up in inventory at the toy stores? How long will it last?
*/

/*
	- Calcula el valor monetario total del inventario disponible por tienda 
	  (stock_on_hand × product_price), ordenado de mayor a menor valor.

	- Calculates the total monetary value of on-hand inventory per store 
	  (stock_on_hand × product_price), ranked from highest to lowest value.
*/


WITH iis AS( --Inventory in Stock = iis--
	SELECT
		i.store_id,
		i.product_id,
		i.stock_on_hand,
		p.product_name,
		p.product_category,
		p.product_price,
		s.store_name,
		s.store_city,
		s.store_location
	FROM
		inventory AS i
	LEFT JOIN
		products  AS p 
		ON i.product_id = p.product_id
	LEFT JOIN
		stores AS s 
		ON i.store_id = s.store_id
)
SELECT
	store_id,
	store_name,
	store_city,
	store_location,
	SUM ((stock_on_hand) * (CAST(product_price AS numeric))) AS Inventory_in_Store
FROM 
	iis
GROUP BY
	store_id,
	store_name,
	store_city,
	store_location
ORDER BY
	Inventory_in_Store DESC;


/*

-Días de Cobertura de Inventario por Tienda-Producto.

	- Calcula cuántos días de venta cubriría el stock actual de cada combinación 
	  tienda-producto, basado en el promedio histórico de unidades vendidas por día
	  (stock_on_hand / avg_daily_units).

-Days of Inventory Cover by Store-Product.

	- Calculates how many days of sales each store-product's current stock would cover,
	  based on historical average daily units sold (stock_on_hand / avg_daily_units).
*/ 

WITH avg_sales AS (
    SELECT
        store_id,
        product_id,
        AVG(units) AS avg_daily_units
    FROM sales
    GROUP BY store_id, product_id
)
SELECT
    i.store_id,
    i.product_id,
    i.stock_on_hand,
    ROUND(a.avg_daily_units,2) AS avg_daily_units_sale,
    CASE 
        WHEN a.avg_daily_units > 0 
            THEN ROUND(i.stock_on_hand / a.avg_daily_units, 2)
        ELSE NULL
    END AS days_of_cover
FROM inventory AS i
JOIN avg_sales AS a
    ON i.store_id = a.store_id
   AND i.product_id = a.product_id
JOIN stores AS s
    ON i.store_id = s.store_id
GROUP BY
	i.store_id,
    i.product_id,
	i.stock_on_hand,
	a.avg_daily_units
ORDER BY
	i.store_id, i.product_id, a.avg_daily_units  DESC;


/*
	- El análisis de 1,590 combinaciones tienda-producto revela dos problemas opuestos
	  de inventario que afectan de forma desproporcionada a los mismos actores: 
	  por un lado, 209 combinaciones (13.1% del total) están en zona de riesgo de 
	  quiebre (menos de 3 días de cobertura o ya en $0$), con el Producto 28 liderando
	  con 26 apariciones en riesgo —más del doble que el segundo lugar— lo que apunta a
	  un problema de proveedor o cadena de suministro más que a errores de pedido
	  individuales, mientras que la Tienda 13 concentra 10 productos en riesgo, 
	  el doble que el promedio del top 10, confirmando (con una muestra 20 veces mayor 
	  al análisis anterior) que ambos son problemas sistémicos recurrentes y no ruido 
	  estadístico; por otro lado, en el extremo opuesto, 30 combinaciones (1.9%) tienen
	  más de 60 días de cobertura —hasta 113.5 días en Tienda 31/Producto 10— sumando
	  2,712 unidades de capital de trabajo inmovilizado, con el Producto 10 destacando
	  en 6 de los 10 peores casos de sobre-stock, sugiriendo un posible error de 
	  pronóstico de demanda específico para ese producto que merece revisión junto con
	  el caso del Producto 28.

	- The analysis of 1,590 store-product combinations reveals two opposite inventory 
	  problems disproportionately affecting the same actors: on one hand, 
	  209 combinations (13.1% of the total) sit in stockout-risk territory 
	  (under 3 days of cover or already at zero), with Product 28 leading at 26 at-risk
	  occurrences —more than double the runner-up— pointing to a vendor or supply-chain
	  issue rather than individual store ordering mistakes, while Store 13 concentrates
	  10 at-risk products, double the top-10 average, confirming (with a sample 20 times
	  larger than the previous analysis) that both are recurring systemic problems rather
	  than statistical noise; on the other hand, at the opposite extreme, 30 combinations
	  (1.9%) carry over 60 days of cover —up to 113.5 days at Store 31/Product 10— totaling
	  2,712 units of tied-up working capital, with Product 10 standing out in 6 of the 
	  10 worst overstock cases, suggesting a possible demand-forecasting error specific to 
	  that product worth investigating alongside the Product 28 issue.
*/


/*

Conclusión.
	El análisis integral del desempeño de Maven Toys revela patrones claros tanto en ventas
	como en inventario. A nivel cadena, las 50 tiendas acumulan 829,262 transacciones con un
	ticket promedio de $17.33 MXN; sin embargo, destacan anomalías importantes como el caso
	de Maven Toys Guanajuato 3, cuya venta individual de $879.78 —la más alta de toda la 
	cadena— distorsiona su promedio y genera una desviación estándar y coeficiente de 
	variación excepcionalmente altos. Este comportamiento sugiere la presencia de transacciones
	atípicas que deben auditarse antes de usar esta tienda como referencia de desempeño.
	
	En términos de volumen, Ciudad de México 2 lidera con 29,024 ventas, casi el doble que
	tiendas de menor actividad como Toluca 2 y Campeche 2, lo que apunta más a diferencias
	de mercado y superficie de venta que a eficiencia operativa. Asimismo, varias tiendas 
	muestran brechas significativas entre promedio y mediana, confirmando que el ticket 
	promedio está sesgado por ventas grandes ocasionales; la mediana emerge como la métrica
	más confiable para evaluar el “ticket típico”.
	
	En cuanto a categorías, Juguetes representa aproximadamente el 27% de la utilidad total
	y se mantiene como el principal impulsor de ganancias en tiendas Downtown y Residential,
	mientras que Electrónica domina en tiendas Airport y Commercial.
	
	El análisis temporal muestra un pico marcado en marzo (+22% vs. febrero), una meseta 
	estable en Q2 y un comportamiento volátil en Q3, con un fuerte spike en julio seguido 
	de caídas pronunciadas en agosto y septiembre, donde el crecimiento YoY se reduce a
	12.35%, menos de un tercio del valor observado en enero. Esta desaceleración sugiere
	la necesidad de monitorear de cerca el inicio de Q4.

	En inventario, las 77 combinaciones tienda-producto sin stock generan una pérdida 
	estimada de ~$1,123.15 MXN por día, con los mayores impactos en Tienda 4/Producto 34 y 
	Tienda 33/Producto 13. El análisis de días de cobertura revela dos problemas sistémicos:
	riesgo de quiebre, donde 209 combinaciones (13.1%) tienen menos de 3 días de 
	stock —destacando el Producto 28 y la Tienda 13 como focos críticos— y sobre-stock,
	donde 30 combinaciones (1.9%) superan los 60 días de cobertura, inmovilizando 
	2,712 unidades de capital de trabajo, con el Producto 10 como principal contribuyente.
	Ambos extremos sugieren fallas recurrentes en la cadena de suministro y pronósticos de
	demanda que requieren intervención.
	
	En conjunto, los hallazgos muestran una cadena con buen volumen general, pero con 
	variabilidad significativa entre tiendas, sesgos estadísticos en métricas de venta, 
	y problemas estructurales de inventario que deben atenderse para mejorar eficiencia,
	rentabilidad y estabilidad operativa.
	
	Conclusion.
	The comprehensive performance analysis of Maven Toys reveals clear patterns across sales
	and inventory. Chain‑wide, the 50 stores generated 829,262 transactions with an average 
	ticket of $17.33 MXN; however, notable anomalies emerge, particularly Maven Toy
	s Guanajuato 3, whose single transaction of $879.78 —the highest in the entire chain— 
	inflates its average and produces an unusually high standard deviation and coefficient 
	of variation. This indicates the presence of outlier transactions that should be 
	audited before using this store as a benchmark for performance.
	
	In terms of volume, Mexico City 2 leads with 29,024 sales, nearly double lower‑volume 
	stores such as Toluca 2 and Campeche 2, suggesting differences in market size or store
	footprint rather than operational efficiency. Several stores also show large gaps 
	between mean and median ticket values, confirming that averages are skewed upward by 
	occasional large sales; the median is therefore the most reliable metric for comparing 
	the “typical ticket” across stores.
	
	Category analysis shows Toys contributing roughly 27% of total profit and acting as 
	the main performance driver in Downtown and Residential stores, while Electronics 
	dominates in Airport and Commercial locations.
	
	The temporal analysis reveals a strong March spike (+22% vs. February), a stable 
	plateau throughout Q2, and volatility in Q3, with a sharp jump in July followed by
	steep declines in August and September, where YoY growth drops to 12.35%, less than 
	one‑third of January’s level. This deceleration suggests that early Q4 should be 
	monitored closely.
	
	Inventory analysis shows that the 77 store‑product combinations currently out of stock
	generate an estimated ~$1,123.15 MXN in daily lost revenue, with the largest impacts 
	occurring in Store 4/Product 34 and Store 33/Product 13. Days‑of‑cover calculations 
	reveal two systemic issues: stockout risk, where 209 combinations (13.1%) have fewer 
	than 3 days of inventory —with Product 28 and Store 13 as critical hotspots— and
	overstock, where 30 combinations (1.9%) exceed 60 days of coverage, immobilizing 2,712 
	units of working capital, with Product 10 appearing in most of the worst cases. 
	Both extremes point to recurring supply chain and demand‑forecasting issues that require 
	corrective action.
	
	Overall, the findings depict a chain with strong total volume but significant variability
	across stores, statistical distortions in sales metrics, and structural inventory 
	imbalances that must be addressed to improve efficiency, profitability, and operational 
	stability.*/
