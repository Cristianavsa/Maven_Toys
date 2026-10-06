
<body>
<main>
<h1 id="maven-toys-méxico--análisis-sql-de-ventas-rentabilidad-e-inventario">Maven Toys México — Análisis SQL de ventas, rentabilidad e inventario</h1>
<h1 id="maven-toys-mexico--sql-analysis-of-sales-profitability-and-inventory">Maven Toys Mexico — SQL Analysis of Sales, Profitability and Inventory</h1>
<p><img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-SQL-336791?logo=postgresql&amp;logoColor=white" />
<img alt="Specialty" src="https://img.shields.io/badge/Specialty-Data%20Analytics-0a7ea4" /></p>
<p><strong>Español</strong> | <a href="#english-summary">English</a></p>
<hr />
<h2 id="índice--table-of-contents">Índice / Table of contents</h2>
<ol>
<li><a href="#1-información-general--general-information">Información general / General information</a></li>
<li><a href="#2-objetivo--objective">Objetivo / Objective</a></li>
<li><a href="#3-plan-de-trabajo--work-plan">Plan de trabajo / Work plan</a></li>
<li><a href="#4-preguntas-clave--key-questions">Preguntas clave / Key questions</a></li>
<li><a href="#5-estructura-del-repositorio--repository-structure">Estructura del repositorio / Repository structure</a></li>
<li><a href="#6-preparación-de-datos--data-preparation">Preparación de datos / Data preparation</a></li>
<li><a href="#7-análisis-consulta-por-consulta--analysis-query-by-query">Análisis, consulta por consulta / Analysis, query by query</a></li>
<li><a href="#8-resultados-clave--key-results">Resultados clave / Key results</a></li>
<li><a href="#9-conclusiones--conclusions">Conclusiones / Conclusions</a></li>
<li><a href="#10-limitaciones-y-próximos-pasos--limitations-and-next-steps">Limitaciones y próximos pasos / Limitations and next steps</a></li>
</ol>
<hr />
<h2 id="1-información-general--general-information">1. Información general / General information</h2>
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Proyecto / Project</strong></td>
<td>Maven Toys México — SQL Sales &amp; Inventory Analysis</td>
</tr>
<tr>
<td><strong>Especialidad / Specialty</strong></td>
<td>Data Analytics</td>
</tr>
<tr>
<td><strong>Herramienta / Tool</strong></td>
<td>PostgreSQL (base de datos <code>Mexico Toy Sales</code>)</td>
</tr>
<tr>
<td><strong>Dataset</strong></td>
<td><a href="https://mavenanalytics.io/data-playground/mexico-toy-sales">Maven Analytics — Mexico Toy Sales</a> (dataset educativo / practice dataset)</td>
</tr>
<tr>
<td><strong>Tablas / Tables</strong></td>
<td><code>calendar</code>, <code>products</code>, <code>stores</code>, <code>inventory</code>, <code>sales</code></td>
</tr>
<tr>
<td><strong>Repositorio / Repository</strong></td>
<td>https://github.com/Cristianavsa/Maven_Toys</td>
</tr>
</tbody>
</table>
<hr />
<h2 id="2-objetivo--objective">2. Objetivo / Objective</h2>
<p><strong>ES:</strong> Analizar el desempeño comercial y de inventario de una cadena de 50 jugueterías en México para identificar qué tiendas y categorías generan más utilidad, cómo evolucionan las ventas en el tiempo y dónde hay quiebres de stock o sobre-stock. Apoya decisiones de reabastecimiento, surtido por tipo de ubicación y monitoreo de tendencia. Útil para operaciones, compras y finanzas.</p>
<p><strong>EN:</strong> Analyze the sales and inventory performance of a 50-store toy chain in Mexico to identify which stores and categories drive profit, how sales evolve over time, and where stockouts or overstock occur. It supports replenishment decisions, assortment by location type, and trend monitoring. Useful for operations, purchasing and finance teams.</p>
<hr />
<h2 id="3-plan-de-trabajo--work-plan">3. Plan de trabajo / Work plan</h2>
<table>
<thead>
<tr>
<th>#</th>
<th>ES</th>
<th>EN</th>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td><strong>Exploración:</strong> estructura de las 5 tablas, nulos y duplicados</td>
<td><strong>Exploration:</strong> structure of the 5 tables, nulls and duplicates</td>
</tr>
<tr>
<td>2</td>
<td><strong>Preparación:</strong> conversión de tipos (fechas, moneda) y columnas de calendario</td>
<td><strong>Preparation:</strong> type conversion (dates, currency) and calendar columns</td>
</tr>
<tr>
<td>3</td>
<td><strong>Construcción:</strong> ventas por tienda, utilidad por categoría y ubicación, tendencia MoM/YoY, inventario</td>
<td><strong>Build:</strong> sales per store, profit by category and location, MoM/YoY trend, inventory</td>
</tr>
<tr>
<td>4</td>
<td><strong>Evaluación:</strong> media vs. mediana, desviación estándar, coeficiente de variación, consistencia entre análisis</td>
<td><strong>Evaluation:</strong> mean vs. median, standard deviation, coefficient of variation, consistency across analyses</td>
</tr>
<tr>
<td>5</td>
<td><strong>Conclusiones:</strong> hallazgos, limitaciones y próximos pasos</td>
<td><strong>Conclusions:</strong> findings, limitations and next steps</td>
</tr>
</tbody>
</table>
<hr />
<h2 id="4-preguntas-clave--key-questions">4. Preguntas clave / Key questions</h2>
<ol>
<li><strong>¿Qué tan representativo es el dataset? / How representative is the dataset?</strong>
   Es un dataset educativo con periodo acotado; los patrones estacionales no pueden confirmarse como recurrentes. / It is a practice dataset covering a limited period; seasonal patterns cannot be confirmed as recurring.</li>
<li><strong>¿Qué sesgos tienen las métricas? / What biases do the metrics have?</strong>
   El promedio se distorsiona por transacciones atípicas; la mediana describe mejor la venta típica. / The mean is distorted by outlier transactions; the median better describes the typical sale.</li>
<li><strong>¿Qué decisión depende del análisis? / Which decision depends on this analysis?</strong>
   Dónde reponer inventario con urgencia, qué producto o tienda revisar con proveedores y qué categoría priorizar por tipo de ubicación. / Where to restock urgently, which product or store to review with suppliers, and which category to prioritize by location type.</li>
</ol>
<hr />
<h2 id="5-estructura-del-repositorio--repository-structure">5. Estructura del repositorio / Repository structure</h2>
<pre><code>Maven_Toys/
├── README.md
├── sql/
│   ├── database_setup.sql                       -- creación de tablas / table creation
│   └── SQL_Sales_Analisis_Mexican_Toy_Stores.sql -- análisis completo / full analysis
└── images/                                      -- gráficas exportadas / exported charts
</code></pre>
<hr />
<h2 id="6-preparación-de-datos--data-preparation">6. Preparación de datos / Data preparation</h2>
<h3 id="61-carga-y-conversión-de-tipos--loading-and-type-conversion">6.1 Carga y conversión de tipos / Loading and type conversion</h3>
<p><strong>ES:</strong> Los datos se cargan en bruto (fechas y montos con <code>$</code> y <code>,</code> como <code>TEXT</code>) y se convierten con <code>ALTER TABLE … ALTER COLUMN … TYPE … USING</code>. Un <code>UPDATE</code> por sí solo reescribe el valor pero <strong>no cambia el tipo</strong> de la columna; por eso se usa <code>ALTER</code>.</p>
<p><strong>EN:</strong> Data is loaded raw (dates and amounts with <code>$</code> and <code>,</code> as <code>TEXT</code>) and converted with <code>ALTER TABLE … ALTER COLUMN … TYPE … USING</code>. A plain <code>UPDATE</code> rewrites the value but <strong>does not change the column type</strong>, which is why <code>ALTER</code> is used.</p>
<pre><code class="language-sql">-- Opcional: interpretación de fechas MM/DD/YYYY en la sesión

``` sql
-- Optional: MM/DD/YYYY date interpretation for the session
ALTER DATABASE &quot;Mexico Toy Sales&quot; SET DateStyle = 'ISO, MDY';

-- Fechas / Dates

ALTER TABLE calendar
    ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'MM/DD/YYYY');

ALTER TABLE sales
    ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'YYYY/MM/DD');

-- Moneda: quitar &quot;$&quot; y &quot;,&quot; y convertir a DECIMAL
-- Currency: strip &quot;$&quot; and &quot;,&quot; and convert to DECIMAL

ALTER TABLE products
    ALTER COLUMN product_cost  TYPE DECIMAL(10,2)
        USING REPLACE(REPLACE(TRIM(product_cost),  '$', ''), ',', '')::DECIMAL,
    ALTER COLUMN product_price TYPE DECIMAL(10,2)
        USING REPLACE(REPLACE(TRIM(product_price), '$', ''), ',', '')::DECIMAL;
```
``` sql
-- Columnas de calendario / Calendar columns
ALTER TABLE calendar
    ADD COLUMN month_name   TEXT,
    ADD COLUMN month_number INTEGER,
    ADD COLUMN quarter      INTEGER,
    ADD COLUMN year         INTEGER;

UPDATE calendar
SET month_name   = TRIM(TO_CHAR(date, 'Month')),
    month_number = EXTRACT(MONTH   FROM date),
    quarter      = EXTRACT(QUARTER FROM date),
    year         = EXTRACT(YEAR    FROM date);
```
</code></pre>
<h3 id="62-calidad-de-datos-nulos-y-duplicados--data-quality-nulls-and-duplicates">6.2 Calidad de datos: nulos y duplicados / Data quality: nulls and duplicates</h3>
<p><strong>ES:</strong> Se revisan nulos en todas las columnas de las 5 tablas y duplicados por clave natural (<code>sale_id</code>, <code>product_id</code>, <code>store_id</code>, <code>date</code> y la pareja <code>store_id + product_id</code> en <code>inventory</code>). <strong>Resultado: sin nulos ni duplicados.</strong> Abajo se muestra el patrón con <code>sales</code>; el resto de tablas sigue la misma lógica (ver <code>/sql</code>).</p>
<p><strong>EN:</strong> Nulls are checked across all columns of the 5 tables, and duplicates by natural key (<code>sale_id</code>, <code>product_id</code>, <code>store_id</code>, <code>date</code>, and the <code>store_id + product_id</code> pair in <code>inventory</code>). <strong>Result: no nulls and no duplicates.</strong> The pattern is shown below with <code>sales</code>; the other tables follow the same logic (see <code>/sql</code>).</p>
<pre><code class="language-sql">-- Nulos / Nulls

``` sql
SELECT sale_id, date, store_id, product_id, units
FROM sales
WHERE sale_id IS NULL OR date IS NULL OR store_id IS NULL
   OR product_id IS NULL OR units IS NULL;

-- Duplicados / Duplicates
WITH duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY sale_id) AS rn
    FROM sales
)
SELECT * FROM duplicates WHERE rn &gt; 1;
```
</code></pre>
<hr />
<h2 id="7-análisis-consulta-por-consulta--analysis-query-by-query">7. Análisis, consulta por consulta / Analysis, query by query</h2>
<blockquote>
<p><strong>Nota metodológica / Methodology note.</strong>
<strong>ES:</strong> las cifras de las consultas 6 y 8 (inventario) provienen de una primera versión que promediaba las <em>unidades por transacción</em>. Las consultas de este README ya usan la <strong>demanda diaria real</strong> (unidades totales ÷ días del periodo). Las cifras marcadas con ⚠️ deben recalcularse al ejecutar la versión corregida.
<strong>EN:</strong> the figures for queries 6 and 8 (inventory) came from a first version that averaged <em>units per transaction</em>. The queries in this README now use <strong>true daily demand</strong> (total units ÷ days in the period). Figures marked ⚠️ must be recalculated when running the corrected version.</p>
</blockquote>
<hr />
<h3 id="consulta-1--resumen-de-ventas-por-tienda--query-1--store-sales-summary">Consulta 1 — Resumen de ventas por tienda / Query 1 — Store sales summary</h3>
<p><strong>ES:</strong> Calcula por tienda el número de ventas, máximo, mínimo, promedio, desviación estándar, cuartiles y <strong>coeficiente de variación (CV)</strong>. Sirve para detectar tiendas con ventas atípicas y para decidir si usar promedio o mediana al comparar.</p>
<p><strong>EN:</strong> Computes per-store number of sales, max, min, average, standard deviation, quartiles and <strong>coefficient of variation (CV)</strong>. It helps detect stores with outlier sales and decide whether to compare using the mean or the median.</p>
<pre><code class="language-sql">WITH transactions AS (

   ``` sql    
   SELECT
        s.sale_id,
        s.store_id::INT                AS store_id,
        st.store_name,
        st.store_location,
        s.units * p.product_price      AS total_sale
    FROM sales s
    LEFT JOIN products p  ON s.product_id = p.product_id
    LEFT JOIN stores   st ON s.store_id   = st.store_id
)
SELECT
    store_id,
    store_name,
    COUNT(sale_id)                                                  AS number_of_sales,
    MAX(total_sale)                                                 AS max_sale,
    MIN(total_sale)                                                 AS min_sale,
    ROUND(AVG(total_sale), 2)                                       AS average_sale,
    ROUND(STDDEV(total_sale), 2)                                    AS std_sale,
    ROUND((STDDEV(total_sale) / NULLIF(AVG(total_sale), 0) * 100)::NUMERIC, 1) AS cv_pct,
    ROUND((PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_sale))::NUMERIC, 2) AS quartile_1,
    ROUND((PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_sale))::NUMERIC, 2) AS median_sale,
    ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_sale))::NUMERIC, 2) AS quartile_3
FROM transactions
GROUP BY store_id, store_name, store_location
ORDER BY store_id;
```
</code></pre>
<p><strong>Gráfica / Chart — tiendas con mayor y menor volumen / highest- and lowest-volume stores</strong></p>
<pre class="mermaid">xychart-beta
    title &quot;Número de ventas / Number of sales&quot;
    x-axis [&quot;CDMX 2&quot;, &quot;Campeche 2&quot;, &quot;Toluca 2&quot;]
    y-axis &quot;Ventas / Sales&quot; 0 --&gt; 32000
    bar [29024, 12805, 12776]
   
   ```mermaid
pie title Número de ventas por tienda
    "CDMX 2" : 29024
    "Campeche 2" : 12805
    "Toluca 2" : 12776
```
</pre>
<p><img alt="Distribución de ventas por tienda" src="images/store_sales_distribution.png" />
<em>Distribución de la venta por tienda (mín, Q1, mediana, Q3, máx) / Sale distribution per store (min, Q1, median, Q3, max).</em></p>
<p><strong>Resultados / Results</strong></p>
<table>
<thead>
<tr>
<th>Métrica / Metric</th>
<th>Valor / Value</th>
</tr>
</thead>
<tbody>
<tr>
<td>Tiendas / Stores</td>
<td>50</td>
</tr>
<tr>
<td>Ventas totales / Total sales</td>
<td>829,262</td>
</tr>
<tr>
<td>Venta promedio simple entre tiendas / Simple average across stores</td>
<td>$17.33 MXN</td>
</tr>
<tr>
<td>Venta máxima / Highest sale</td>
<td>$879.78 — Maven Toys Guanajuato 3</td>
</tr>
<tr>
<td>Mayor desviación estándar / Highest std. dev.</td>
<td>$27.90 — Guanajuato 3 (CV 147.2%)</td>
</tr>
<tr>
<td>Mayor brecha promedio–mediana / Largest mean–median gap</td>
<td>$5.84 — Hermosillo 3</td>
</tr>
</tbody>
</table>
<p><strong>ES:</strong> Guanajuato 3 tiene un promedio ($18.96) distorsionado por pocas transacciones atípicas; conviene auditar la venta de $879.78 (¿mayoreo, error de captura o devolución mal registrada?). Ciudad de México 2 vende más del doble que Toluca 2 y Campeche 2, lo que apunta a diferencias de mercado o superficie, no necesariamente de eficiencia. Para comparar el "ticket típico", la <strong>mediana</strong> es más confiable que el promedio.</p>
<p><strong>EN:</strong> Guanajuato 3's average ($18.96) is distorted by a few outlier transactions; the $879.78 sale should be audited (bulk sale, data-entry error, or a mislogged return?). Mexico City 2 sells more than twice as much as Toluca 2 and Campeche 2, pointing to market or floor-space differences rather than efficiency. To compare the "typical ticket", the <strong>median</strong> is more reliable than the mean.</p>
<hr />
<h3 id="consulta-2--utilidad-por-categoría--query-2--profit-by-category">Consulta 2 — Utilidad por categoría / Query 2 — Profit by category</h3>
<p><strong>ES:</strong> Calcula venta, costo, utilidad y el porcentaje que aporta cada categoría a la utilidad total (<code>SUM() OVER ()</code>).</p>
<p><strong>EN:</strong> Computes revenue, cost, profit and each category's share of total profit (<code>SUM() OVER ()</code>).</p>
<pre><code class="language-sql">WITH agg AS (
    
   ``` sql
   SELECT
        p.product_category,
        SUM(s.units * p.product_cost)                       AS total_cost,
        SUM(s.units * p.product_price)                      AS total_sale,
        SUM(s.units * (p.product_price - p.product_cost))   AS total_profit
    FROM sales s
    LEFT JOIN products p ON s.product_id = p.product_id
    GROUP BY p.product_category
)
SELECT
    product_category,
    total_sale,
    total_cost,
    total_profit,
    ROUND(100 * total_profit / SUM(total_profit) OVER (), 1) AS pct_of_total_profit
FROM agg
ORDER BY total_profit DESC;
```
</code></pre>
<p><strong>Gráfica / Chart</strong></p>
<pre class="mermaid">pie title Aporte de Juguetes a la utilidad total / Toys' share of total profit
    &quot;Juguetes / Toys (~27%)&quot; : 27
    &quot;Otras categorías / Other categories (~73%)&quot; : 73
</pre>
<p><strong>ES:</strong> Juguetes aporta ~27% de la utilidad total y es uno de los principales impulsores del desempeño.
<strong>EN:</strong> Toys contributes ~27% of total profit and is one of the key performance drivers.</p>
<hr />
<h3 id="consulta-3--categoría-líder-por-tipo-de-ubicación--query-3--top-category-by-store-location">Consulta 3 — Categoría líder por tipo de ubicación / Query 3 — Top category by store location</h3>
<p><strong>ES:</strong> Para cada tipo de ubicación (<code>Downtown</code>, <code>Residential</code>, <code>Airport</code>, <code>Commercial</code>) identifica la categoría con mayor utilidad usando <code>DENSE_RANK() OVER (PARTITION BY …)</code>.</p>
<p><strong>EN:</strong> For each location type (<code>Downtown</code>, <code>Residential</code>, <code>Airport</code>, <code>Commercial</code>) it identifies the most profitable category using <code>DENSE_RANK() OVER (PARTITION BY …)</code>.</p>
<pre><code class="language-sql">WITH agg AS (
   
   ``` sql
   SELECT
        st.store_location,
        p.product_category,
        SUM(s.units * p.product_cost)                     AS total_cost,
        SUM(s.units * p.product_price)                    AS total_sale,
        SUM(s.units * (p.product_price - p.product_cost)) AS total_profit
    FROM sales s
    LEFT JOIN products p  ON s.product_id = p.product_id
    LEFT JOIN stores   st ON s.store_id   = st.store_id
    GROUP BY st.store_location, p.product_category
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY store_location ORDER BY total_profit DESC) AS ranking
    FROM agg
)
SELECT *
FROM ranked
WHERE ranking = 1
ORDER BY store_location;
```

</code></pre>
<p><strong>Resultado / Result</strong></p>
<table>
<thead>
<tr>
<th>Ubicación / Location</th>
<th>Categoría líder / Top category</th>
</tr>
</thead>
<tbody>
<tr>
<td>Downtown</td>
<td>Juguetes / Toys</td>
</tr>
<tr>
<td>Residential</td>
<td>Juguetes / Toys</td>
</tr>
<tr>
<td>Airport</td>
<td>Electrónica / Electronics</td>
</tr>
<tr>
<td>Commercial</td>
<td>Electrónica / Electronics</td>
</tr>
</tbody>
</table>
<p><strong>ES:</strong> El surtido debería adaptarse al tipo de ubicación: Juguetes en zonas Downtown y Residential, Electrónica en Airport y Commercial.
<strong>EN:</strong> Assortment should adapt to the location type: Toys in Downtown and Residential, Electronics in Airport and Commercial.</p>
<hr />
<h3 id="consulta-4--ventas-mensuales-y-variación-mom--query-4--monthly-sales-and-mom-change">Consulta 4 — Ventas mensuales y variación MoM / Query 4 — Monthly sales and MoM change</h3>
<p><strong>ES:</strong> Calcula las ventas por mes y su variación contra el mes anterior con <code>LAG()</code>.</p>
<p><strong>EN:</strong> Computes sales per month and the change against the previous month using <code>LAG()</code>.</p>
<pre><code class="language-sql">WITH monthly AS (
  
   ``` sql
   SELECT
        c.year,
        c.quarter,
        c.month_number,
        c.month_name,
        SUM(s.units * p.product_price) AS total_sales
    FROM sales s
    LEFT JOIN products p ON s.product_id = p.product_id
    LEFT JOIN calendar c ON s.date       = c.date
    GROUP BY c.year, c.quarter, c.month_number, c.month_name
)
SELECT
    year,
    quarter,
    month_number,
    month_name,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, month_number)                     AS last_month_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY year, month_number)       AS mom_change,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year, month_number))
        / NULLIF(LAG(total_sales) OVER (ORDER BY year, month_number), 0) * 100, 2
    ) AS mom_pct_change
FROM monthly
ORDER BY year, month_number;
```
</code></pre>
<p><strong>Gráfica / Chart — ventas mensuales (miles de MXN; julio aproximado) / monthly sales (thousands of MXN; July approximate)</strong></p>
<pre class="mermaid">xychart-beta
    title &quot;Ventas mensuales / Monthly sales (miles MXN / thousand MXN)&quot;
    x-axis [&quot;Ene/Jan&quot;, &quot;Feb&quot;, &quot;Mar&quot;, &quot;Abr/Apr&quot;, &quot;May&quot;, &quot;Jun&quot;, &quot;Jul&quot;, &quot;Ago/Aug&quot;, &quot;Sep&quot;]
    y-axis &quot;Miles MXN / Thousand MXN&quot; 500 --&gt; 950
    bar [747, 723, 884, 828, 825, 808, 828, 661, 658]
</pre>
<p><strong>ES:</strong>
1. <strong>Pico en marzo:</strong> $883,516 (+22% vs. febrero); consistente con un posible empuje de cierre de trimestre, aunque con tan poca evidencia no se puede confirmar que sea recurrente.
2. <strong>Meseta en Q2:</strong> abril–junio ($827.7K, $825.3K, $808.3K), variación de ~2.3%.
3. <strong>Julio repite el nivel de Q2; agosto y septiembre caen</strong> (~$661K y ~$658K, los dos meses más bajos).</p>
<p><strong>EN:</strong>
1. <strong>March peak:</strong> $883,516 (+22% vs. February); consistent with a possible quarter-end push, but with so little evidence it cannot be confirmed as recurring.
2. <strong>Q2 plateau:</strong> April–June ($827.7K, $825.3K, $808.3K), ~2.3% spread.
3. <strong>July repeats Q2's level; August and September drop</strong> (~$661K and ~$658K, the two lowest months).</p>
<hr />
<h3 id="consulta-5--crecimiento-anual-yoy--query-5--year-over-year-growth">Consulta 5 — Crecimiento anual (YoY) / Query 5 — Year-over-year growth</h3>
<p><strong>ES:</strong> Compara cada mes con el mismo mes del año anterior (<code>LAG(…, 12)</code>). Requiere más de un año de datos; si algún mes no tiene su par, el resultado es <code>NULL</code>.</p>
<p><strong>EN:</strong> Compares each month with the same month of the previous year (<code>LAG(…, 12)</code>). It requires more than one year of data; if a month has no counterpart, the result is <code>NULL</code>.</p>
<pre><code class="language-sql">WITH monthly AS (
    
   ```sql
   SELECT
        c.year,
        c.month_number,
        c.month_name,
        SUM(s.units * p.product_price) AS total_sales
    FROM sales s
    LEFT JOIN products p ON s.product_id = p.product_id
    LEFT JOIN calendar c ON s.date       = c.date
    GROUP BY c.year, c.month_number, c.month_name
)
SELECT
    year,
    month_number,
    month_name,
    total_sales,
    LAG(total_sales, 12) OVER (ORDER BY year, month_number) AS same_month_last_year,
    ROUND(
        (total_sales - LAG(total_sales, 12) OVER (ORDER BY year, month_number))
        / NULLIF(LAG(total_sales, 12) OVER (ORDER BY year, month_number), 0) * 100, 2
    ) AS yoy_pct_change
FROM monthly
ORDER BY year, month_number;
```
</code></pre>
<p><img alt="Crecimiento YoY" src="images/yoy_growth.png" />
<em>Crecimiento interanual por mes / Year-over-year growth by month.</em></p>
<table>
<thead>
<tr>
<th>Mes / Month</th>
<th>Ene/Jan</th>
<th>Abr/Apr</th>
<th>May</th>
<th>Jun</th>
<th>Jul</th>
<th>Ago/Aug</th>
<th>Sep</th>
</tr>
</thead>
<tbody>
<tr>
<td>YoY %</td>
<td>37.72</td>
<td>21.5</td>
<td>22.8</td>
<td>22.1</td>
<td>48.97</td>
<td>35.0</td>
<td>12.35</td>
</tr>
</tbody>
</table>
<p><strong>ES:</strong> El crecimiento se estabiliza en ~22% durante Q2, sube a 48.97% en julio y se desacelera a 12.35% en septiembre (menos de un tercio del de enero). Conviene monitorear de cerca el inicio de Q4.
<strong>EN:</strong> Growth settles around 22% in Q2, jumps to 48.97% in July and slows to 12.35% in September (less than a third of January's). The start of Q4 should be monitored closely.</p>
<hr />
<h3 id="consulta-6--ingreso-perdido-por-quiebre-de-stock--query-6--revenue-lost-to-stockouts">Consulta 6 — Ingreso perdido por quiebre de stock / Query 6 — Revenue lost to stockouts</h3>
<p><strong>ES:</strong> Para cada combinación tienda-producto con <code>stock_on_hand = 0</code>, estima el ingreso diario perdido como demanda diaria histórica × precio. La <strong>demanda diaria</strong> se calcula como unidades totales ÷ días del periodo (no como promedio por transacción).</p>
<p><strong>EN:</strong> For each store-product combination with <code>stock_on_hand = 0</code>, estimates daily lost revenue as historical daily demand × price. <strong>Daily demand</strong> is total units ÷ days in the period (not an average per transaction).</p>
<pre><code class="language-sql">WITH period AS (
   
   ``` sql
   SELECT (MAX(date) - MIN(date) + 1) AS days
    FROM sales
),
demand AS (
    SELECT
        store_id,
        product_id,
        SUM(units)::NUMERIC / (SELECT days FROM period) AS avg_daily_units
    FROM sales
    GROUP BY store_id, product_id
)
SELECT
    i.store_id,
    i.product_id,
    ROUND(d.avg_daily_units, 2)                     AS est_lost_units_per_day,
    p.product_price,
    ROUND(d.avg_daily_units * p.product_price, 2)   AS est_lost_revenue_per_day
FROM inventory i
JOIN demand   d ON i.store_id   = d.store_id AND i.product_id = d.product_id
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_on_hand = 0
ORDER BY est_lost_revenue_per_day DESC;
```
</code></pre>
<p><img alt="Ingreso perdido por quiebre" src="images/lost_revenue_top10.png" />
<em>Top 10 combinaciones tienda-producto por ingreso diario perdido / Top 10 store-product combinations by daily lost revenue.</em></p>
<p><strong>Resultados del cálculo original ⚠️ / Results from the original calculation ⚠️</strong></p>
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td>Combinaciones sin stock / Out-of-stock combinations</td>
<td>77</td>
</tr>
<tr>
<td>Ingreso perdido estimado / Estimated lost revenue</td>
<td>~$1,123.15 MXN / día (day)</td>
</tr>
<tr>
<td>Mayores casos / Largest cases</td>
<td>Tienda 4 / Producto 34 ($29.30), Tienda 33 / Producto 13 ($26.35)</td>
</tr>
</tbody>
</table>
<p><strong>ES:</strong> Es una foto de un solo día: si un producto lleva varios días agotado, la pérdida acumulada es proporcionalmente mayor (la consulta no mide la duración del quiebre).
<strong>EN:</strong> This is a one-day snapshot: if a product has been out of stock for several days, the cumulative loss is proportionally higher (the query does not measure stockout duration).</p>
<hr />
<h3 id="consulta-7--valor-del-inventario-por-tienda--query-7--inventory-value-per-store">Consulta 7 — Valor del inventario por tienda / Query 7 — Inventory value per store</h3>
<p><strong>ES:</strong> Calcula el capital inmovilizado en inventario por tienda (<code>stock_on_hand × product_price</code>), de mayor a menor.</p>
<p><strong>EN:</strong> Computes the capital tied up in inventory per store (<code>stock_on_hand × product_price</code>), from highest to lowest.</p>
<pre><code class="language-sql">
   
   ``` sql 
   SELECT
    i.store_id,
    s.store_name,
    s.store_city,
    s.store_location,
    SUM(i.stock_on_hand * p.product_price) AS inventory_value
FROM inventory i
LEFT JOIN products p ON i.product_id = p.product_id
LEFT JOIN stores   s ON i.store_id   = s.store_id
GROUP BY i.store_id, s.store_name, s.store_city, s.store_location
ORDER BY inventory_value DESC;
```
</code></pre>
<p><img alt="Valor de inventario por tienda" src="images/inventory_value_by_store.png" />
<em>Valor del inventario por tienda / Inventory value per store.</em></p>
<hr />
<h3 id="consulta-8--días-de-cobertura-de-inventario--query-8--days-of-inventory-cover">Consulta 8 — Días de cobertura de inventario / Query 8 — Days of inventory cover</h3>
<p><strong>ES:</strong> Calcula cuántos días de venta cubre el stock actual de cada combinación tienda-producto (<code>stock_on_hand ÷ demanda diaria</code>) y la clasifica: <em>Stockout</em> (0), <em>En riesgo</em> (&lt; 3 días), <em>Sobre-stock</em> (&gt; 60 días) o <em>Normal</em>.</p>
<p><strong>EN:</strong> Computes how many days of sales the current stock of each store-product combination covers (<code>stock_on_hand ÷ daily demand</code>) and classifies it: <em>Stockout</em> (0), <em>At risk</em> (&lt; 3 days), <em>Overstock</em> (&gt; 60 days) or <em>Normal</em>.</p>
<pre><code class="language-sql">
   
   ``` sql
   WITH period AS (
    SELECT (MAX(date) - MIN(date) + 1) AS days
    FROM sales
),
demand AS (
    SELECT
        store_id,
        product_id,
        SUM(units)::NUMERIC / (SELECT days FROM period) AS avg_daily_units
    FROM sales
    GROUP BY store_id, product_id
)
SELECT
    i.store_id,
    i.product_id,
    i.stock_on_hand,
    ROUND(d.avg_daily_units, 2)                                   AS avg_daily_units,
    ROUND(i.stock_on_hand / NULLIF(d.avg_daily_units, 0), 1)      AS days_of_cover,
    CASE
        WHEN i.stock_on_hand = 0                                  THEN 'Stockout'
        WHEN i.stock_on_hand / NULLIF(d.avg_daily_units, 0) &lt; 3   THEN 'At risk (&lt;3 days)'
        WHEN i.stock_on_hand / NULLIF(d.avg_daily_units, 0) &gt; 60  THEN 'Overstock (&gt;60 days)'
        ELSE 'Normal'
    END AS cover_status
FROM inventory i
JOIN demand d ON i.store_id = d.store_id AND i.product_id = d.product_id
ORDER BY days_of_cover;
```
</code></pre>
<p><strong>Gráfica / Chart ⚠️ — 1,590 combinaciones tienda-producto / store-product combinations (cálculo original / original calculation)</strong></p>
<pre class="mermaid">pie title Cobertura de inventario / Inventory cover
    &quot;En riesgo (&lt;3 días) / At risk: 209 (13.1%)&quot; : 209
    &quot;Normal (3-60 días) / Normal: 1351 (85.0%)&quot; : 1351
    &quot;Sobre-stock (&gt;60 días) / Overstock: 30 (1.9%)&quot; : 30
</pre>
<p><strong>Resultados del cálculo original ⚠️ / Results from the original calculation ⚠️</strong></p>
<ul>
<li><strong>Riesgo de quiebre / Stockout risk:</strong> 209 combinaciones (13.1%). El <strong>Producto 28</strong> aparece 26 veces (más del doble que el segundo) y la <strong>Tienda 13</strong> concentra 10 productos en riesgo. / 209 combinations (13.1%). <strong>Product 28</strong> appears 26 times (more than double the runner-up) and <strong>Store 13</strong> concentrates 10 at-risk products.</li>
<li><strong>Sobre-stock / Overstock:</strong> 30 combinaciones (1.9%) con más de 60 días, hasta 113.5 días (Tienda 31 / Producto 10); 2,712 unidades inmovilizadas. El <strong>Producto 10</strong> está en 6 de los 10 peores casos. / 30 combinations (1.9%) above 60 days, up to 113.5 days (Store 31 / Product 10); 2,712 units tied up. <strong>Product 10</strong> appears in 6 of the 10 worst cases.</li>
</ul>
<p><strong>ES:</strong> Que el Producto 28 y la Tienda 13 reaparezcan en dos análisis independientes sugiere un problema recurrente de proveedor o cadena de suministro, y el Producto 10 sugiere un posible error de pronóstico de demanda.
<strong>EN:</strong> Product 28 and Store 13 reappearing across two independent analyses suggests a recurring supplier or supply-chain issue, and Product 10 suggests a possible demand-forecasting error.</p>
<hr />
<h2 id="8-resultados-clave--key-results">8. Resultados clave / Key results</h2>
<table>
<thead>
<tr>
<th>Área / Area</th>
<th>Hallazgo / Finding</th>
</tr>
</thead>
<tbody>
<tr>
<td>Ventas / Sales</td>
<td>50 tiendas, 829,262 ventas, $17.33 MXN promedio / 50 stores, 829,262 sales, $17.33 MXN average</td>
</tr>
<tr>
<td>Atípicos / Outliers</td>
<td>Guanajuato 3: venta de $879.78 y CV de 147.2% / Guanajuato 3: $879.78 sale and 147.2% CV</td>
</tr>
<tr>
<td>Rentabilidad / Profitability</td>
<td>Juguetes ~27% de la utilidad; Electrónica lidera en Airport y Commercial / Toys ~27% of profit; Electronics leads in Airport and Commercial</td>
</tr>
<tr>
<td>Tendencia / Trend</td>
<td>Pico en marzo, meseta en Q2, caída en ago–sep; YoY de 37.72% a 12.35% / March peak, Q2 plateau, Aug–Sep drop; YoY from 37.72% to 12.35%</td>
</tr>
<tr>
<td>Inventario ⚠️ / Inventory ⚠️</td>
<td>77 quiebres (~$1,123.15/día), 209 en riesgo, 30 en sobre-stock / 77 stockouts (~$1,123.15/day), 209 at risk, 30 overstocked</td>
</tr>
</tbody>
</table>
<hr />
<h2 id="9-conclusiones--conclusions">9. Conclusiones / Conclusions</h2>
<p><strong>ES:</strong> La cadena tiene buen volumen total, pero con variabilidad significativa entre tiendas, sesgos estadísticos en las métricas de venta y desequilibrios estructurales de inventario. El promedio engaña cuando hay atípicos (usar mediana y CV), el surtido debe adaptarse al tipo de ubicación, la desaceleración del crecimiento YoY exige monitoreo en Q4, y el inventario debe vigilarse en sus dos extremos: quiebre y sobre-stock.</p>
<p><strong>EN:</strong> The chain has strong total volume, but significant variability across stores, statistical distortions in sales metrics, and structural inventory imbalances. The mean misleads when outliers exist (use the median and CV), assortment should adapt to location type, the slowdown in YoY growth calls for Q4 monitoring, and inventory must be watched at both extremes: stockout and overstock.</p>
<hr />
<h2 id="10-limitaciones-y-próximos-pasos--limitations-and-next-steps">10. Limitaciones y próximos pasos / Limitations and next steps</h2>
<p><strong>ES</strong>
- Dataset educativo con periodo acotado: no se puede confirmar estacionalidad.
- La demanda diaria asume un promedio constante en todo el periodo; no considera estacionalidad ni promociones.
- <code>inventory</code> es una foto de un momento: no hay historial para medir la duración de los quiebres.
- Próximos pasos: auditar transacciones atípicas, cruzar inventario con margen por producto y construir un dashboard en Power BI o Tableau sobre estas consultas.</p>
<p><strong>EN</strong>
- Practice dataset with a limited period: seasonality cannot be confirmed.
- Daily demand assumes a constant average across the period; it ignores seasonality and promotions.
- <code>inventory</code> is a single-moment snapshot: there is no history to measure stockout duration.
- Next steps: audit outlier transactions, cross inventory with per-product margin, and build a Power BI or Tableau dashboard on top of these queries.</p>
<hr />
<h2 id="english-summary">English summary</h2>
<p>This project analyzes sales, profitability and inventory for <strong>Maven Toys</strong>, a 50-store toy chain in Mexico, using <strong>PostgreSQL</strong> (CTEs, window functions such as <code>LAG</code>, <code>DENSE_RANK</code> and <code>SUM() OVER</code>, <code>PERCENTILE_CONT</code>, and conditional logic). Every query above includes a Spanish and English explanation, the SQL code and a chart. Data source: <a href="https://mavenanalytics.io/data-playground/mexico-toy-sales">Maven Analytics — Mexico Toy Sales</a>.</p>
</main>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"></script>
<script>
mermaid.initialize({ startOnLoad:true, theme: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default' });
</script>
</body>
</html>
