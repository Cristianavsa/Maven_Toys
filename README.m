# Maven Toys México — Análisis SQL de ventas, rentabilidad e inventario
# Maven Toys Mexico — SQL Analysis of Sales, Profitability and Inventory

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQL-336791?logo=postgresql&logoColor=white)
![Specialty](https://img.shields.io/badge/Specialty-Data%20Analytics-0a7ea4)

**Español** | [English](#english-summary)

---

## Índice / Table of contents

1. [Información general / General information](#1-información-general--general-information)
2. [Objetivo / Objective](#2-objetivo--objective)
3. [Plan de trabajo / Work plan](#3-plan-de-trabajo--work-plan)
4. [Preguntas clave / Key questions](#4-preguntas-clave--key-questions)
5. [Estructura del repositorio / Repository structure](#5-estructura-del-repositorio--repository-structure)
6. [Preparación de datos / Data preparation](#6-preparación-de-datos--data-preparation)
7. [Análisis, consulta por consulta / Analysis, query by query](#7-análisis-consulta-por-consulta--analysis-query-by-query)
8. [Resultados clave / Key results](#8-resultados-clave--key-results)
9. [Conclusiones / Conclusions](#9-conclusiones--conclusions)
10. [Limitaciones y próximos pasos / Limitations and next steps](#10-limitaciones-y-próximos-pasos--limitations-and-next-steps)

---

## 1. Información general / General information

| | |
|---|---|
| **Proyecto / Project** | Maven Toys México — SQL Sales & Inventory Analysis |
| **Especialidad / Specialty** | Data Analytics |
| **Herramienta / Tool** | PostgreSQL (base de datos `Mexico Toy Sales`) |
| **Dataset** | [Maven Analytics — Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales) (dataset educativo / practice dataset) |
| **Tablas / Tables** | `calendar`, `products`, `stores`, `inventory`, `sales` |
| **Repositorio / Repository** | https://github.com/Cristianavsa/Maven_Toys |

---

## 2. Objetivo / Objective

**ES:** Analizar el desempeño comercial y de inventario de una cadena de 50 jugueterías en México para identificar qué tiendas y categorías generan más utilidad, cómo evolucionan las ventas en el tiempo y dónde hay quiebres de stock o sobre-stock. Apoya decisiones de reabastecimiento, surtido por tipo de ubicación y monitoreo de tendencia. Útil para operaciones, compras y finanzas.

**EN:** Analyze the sales and inventory performance of a 50-store toy chain in Mexico to identify which stores and categories drive profit, how sales evolve over time, and where stockouts or overstock occur. It supports replenishment decisions, assortment by location type, and trend monitoring. Useful for operations, purchasing and finance teams.

---

## 3. Plan de trabajo / Work plan

| # | ES | EN |
|---|---|---|
| 1 | **Exploración:** estructura de las 5 tablas, nulos y duplicados | **Exploration:** structure of the 5 tables, nulls and duplicates |
| 2 | **Preparación:** conversión de tipos (fechas, moneda) y columnas de calendario | **Preparation:** type conversion (dates, currency) and calendar columns |
| 3 | **Construcción:** ventas por tienda, utilidad por categoría y ubicación, tendencia MoM/YoY, inventario | **Build:** sales per store, profit by category and location, MoM/YoY trend, inventory |
| 4 | **Evaluación:** media vs. mediana, desviación estándar, coeficiente de variación, consistencia entre análisis | **Evaluation:** mean vs. median, standard deviation, coefficient of variation, consistency across analyses |
| 5 | **Conclusiones:** hallazgos, limitaciones y próximos pasos | **Conclusions:** findings, limitations and next steps |

---

## 4. Preguntas clave / Key questions

1. **¿Qué tan representativo es el dataset? / How representative is the dataset?**
   Es un dataset educativo con periodo acotado; los patrones estacionales no pueden confirmarse como recurrentes. / It is a practice dataset covering a limited period; seasonal patterns cannot be confirmed as recurring.
2. **¿Qué sesgos tienen las métricas? / What biases do the metrics have?**
   El promedio se distorsiona por transacciones atípicas; la mediana describe mejor la venta típica. / The mean is distorted by outlier transactions; the median better describes the typical sale.
3. **¿Qué decisión depende del análisis? / Which decision depends on this analysis?**
   Dónde reponer inventario con urgencia, qué producto o tienda revisar con proveedores y qué categoría priorizar por tipo de ubicación. / Where to restock urgently, which product or store to review with suppliers, and which category to prioritize by location type.

---

## 5. Estructura del repositorio / Repository structure

```
Maven_Toys/
├── README.md
├── sql/
│   ├── database_setup.sql                       -- creación de tablas / table creation
│   └── SQL_Sales_Analisis_Mexican_Toy_Stores.sql -- análisis completo / full analysis
└── images/                                      -- gráficas exportadas / exported charts
```

---

## 6. Preparación de datos / Data preparation

### 6.1 Carga y conversión de tipos / Loading and type conversion

**ES:** Los datos se cargan en bruto (fechas y montos con `$` y `,` como `TEXT`) y se convierten con `ALTER TABLE … ALTER COLUMN … TYPE … USING`. Un `UPDATE` por sí solo reescribe el valor pero **no cambia el tipo** de la columna; por eso se usa `ALTER`.

**EN:** Data is loaded raw (dates and amounts with `$` and `,` as `TEXT`) and converted with `ALTER TABLE … ALTER COLUMN … TYPE … USING`. A plain `UPDATE` rewrites the value but **does not change the column type**, which is why `ALTER` is used.

```sql
-- Opcional: interpretación de fechas MM/DD/YYYY en la sesión
-- Optional: MM/DD/YYYY date interpretation for the session
ALTER DATABASE "Mexico Toy Sales" SET DateStyle = 'ISO, MDY';

-- Fechas / Dates
ALTER TABLE calendar
    ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'MM/DD/YYYY');

ALTER TABLE sales
    ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'YYYY/MM/DD');

-- Moneda: quitar "$" y "," y convertir a DECIMAL
-- Currency: strip "$" and "," and convert to DECIMAL
ALTER TABLE products
    ALTER COLUMN product_cost  TYPE DECIMAL(10,2)
        USING REPLACE(REPLACE(TRIM(product_cost),  '$', ''), ',', '')::DECIMAL,
    ALTER COLUMN product_price TYPE DECIMAL(10,2)
        USING REPLACE(REPLACE(TRIM(product_price), '$', ''), ',', '')::DECIMAL;

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

### 6.2 Calidad de datos: nulos y duplicados / Data quality: nulls and duplicates

**ES:** Se revisan nulos en todas las columnas de las 5 tablas y duplicados por clave natural (`sale_id`, `product_id`, `store_id`, `date` y la pareja `store_id + product_id` en `inventory`). **Resultado: sin nulos ni duplicados.** Abajo se muestra el patrón con `sales`; el resto de tablas sigue la misma lógica (ver `/sql`).

**EN:** Nulls are checked across all columns of the 5 tables, and duplicates by natural key (`sale_id`, `product_id`, `store_id`, `date`, and the `store_id + product_id` pair in `inventory`). **Result: no nulls and no duplicates.** The pattern is shown below with `sales`; the other tables follow the same logic (see `/sql`).

```sql
-- Nulos / Nulls
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
SELECT * FROM duplicates WHERE rn > 1;
```

---

## 7. Análisis, consulta por consulta / Analysis, query by query

> **Nota metodológica / Methodology note.**
> **ES:** las cifras de las consultas 6 y 8 (inventario) provienen de una primera versión que promediaba las *unidades por transacción*. Las consultas de este README ya usan la **demanda diaria real** (unidades totales ÷ días del periodo). Las cifras marcadas con ⚠️ deben recalcularse al ejecutar la versión corregida.
> **EN:** the figures for queries 6 and 8 (inventory) came from a first version that averaged *units per transaction*. The queries in this README now use **true daily demand** (total units ÷ days in the period). Figures marked ⚠️ must be recalculated when running the corrected version.

---

### Consulta 1 — Resumen de ventas por tienda / Query 1 — Store sales summary

**ES:** Calcula por tienda el número de ventas, máximo, mínimo, promedio, desviación estándar, cuartiles y **coeficiente de variación (CV)**. Sirve para detectar tiendas con ventas atípicas y para decidir si usar promedio o mediana al comparar.

**EN:** Computes per-store number of sales, max, min, average, standard deviation, quartiles and **coefficient of variation (CV)**. It helps detect stores with outlier sales and decide whether to compare using the mean or the median.

```sql
WITH transactions AS (
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

**Gráfica / Chart — tiendas con mayor y menor volumen / highest- and lowest-volume stores**

```mermaid
xychart-beta
    title "Número de ventas / Number of sales"
    x-axis ["CDMX 2", "Campeche 2", "Toluca 2"]
    y-axis "Ventas / Sales" 0 --> 32000
    bar [29024, 12805, 12776]
```

![Distribución de ventas por tienda](images/store_sales_distribution.png)
*Distribución de la venta por tienda (mín, Q1, mediana, Q3, máx) / Sale distribution per store (min, Q1, median, Q3, max).*

**Resultados / Results**

| Métrica / Metric | Valor / Value |
|---|---|
| Tiendas / Stores | 50 |
| Ventas totales / Total sales | 829,262 |
| Venta promedio simple entre tiendas / Simple average across stores | $17.33 MXN |
| Venta máxima / Highest sale | $879.78 — Maven Toys Guanajuato 3 |
| Mayor desviación estándar / Highest std. dev. | $27.90 — Guanajuato 3 (CV 147.2%) |
| Mayor brecha promedio–mediana / Largest mean–median gap | $5.84 — Hermosillo 3 |

**ES:** Guanajuato 3 tiene un promedio ($18.96) distorsionado por pocas transacciones atípicas; conviene auditar la venta de $879.78 (¿mayoreo, error de captura o devolución mal registrada?). Ciudad de México 2 vende más del doble que Toluca 2 y Campeche 2, lo que apunta a diferencias de mercado o superficie, no necesariamente de eficiencia. Para comparar el "ticket típico", la **mediana** es más confiable que el promedio.

**EN:** Guanajuato 3's average ($18.96) is distorted by a few outlier transactions; the $879.78 sale should be audited (bulk sale, data-entry error, or a mislogged return?). Mexico City 2 sells more than twice as much as Toluca 2 and Campeche 2, pointing to market or floor-space differences rather than efficiency. To compare the "typical ticket", the **median** is more reliable than the mean.

---

### Consulta 2 — Utilidad por categoría / Query 2 — Profit by category

**ES:** Calcula venta, costo, utilidad y el porcentaje que aporta cada categoría a la utilidad total (`SUM() OVER ()`).

**EN:** Computes revenue, cost, profit and each category's share of total profit (`SUM() OVER ()`).

```sql
WITH agg AS (
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

**Gráfica / Chart**

```mermaid
pie title Aporte de Juguetes a la utilidad total / Toys' share of total profit
    "Juguetes / Toys (~27%)" : 27
    "Otras categorías / Other categories (~73%)" : 73
```

**ES:** Juguetes aporta ~27% de la utilidad total y es uno de los principales impulsores del desempeño.
**EN:** Toys contributes ~27% of total profit and is one of the key performance drivers.

---

### Consulta 3 — Categoría líder por tipo de ubicación / Query 3 — Top category by store location

**ES:** Para cada tipo de ubicación (`Downtown`, `Residential`, `Airport`, `Commercial`) identifica la categoría con mayor utilidad usando `DENSE_RANK() OVER (PARTITION BY …)`.

**EN:** For each location type (`Downtown`, `Residential`, `Airport`, `Commercial`) it identifies the most profitable category using `DENSE_RANK() OVER (PARTITION BY …)`.

```sql
WITH agg AS (
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

**Resultado / Result**

| Ubicación / Location | Categoría líder / Top category |
|---|---|
| Downtown | Juguetes / Toys |
| Residential | Juguetes / Toys |
| Airport | Electrónica / Electronics |
| Commercial | Electrónica / Electronics |

**ES:** El surtido debería adaptarse al tipo de ubicación: Juguetes en zonas Downtown y Residential, Electrónica en Airport y Commercial.
**EN:** Assortment should adapt to the location type: Toys in Downtown and Residential, Electronics in Airport and Commercial.

---

### Consulta 4 — Ventas mensuales y variación MoM / Query 4 — Monthly sales and MoM change

**ES:** Calcula las ventas por mes y su variación contra el mes anterior con `LAG()`.

**EN:** Computes sales per month and the change against the previous month using `LAG()`.

```sql
WITH monthly AS (
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

**Gráfica / Chart — ventas mensuales (miles de MXN; julio aproximado) / monthly sales (thousands of MXN; July approximate)**

```mermaid
xychart-beta
    title "Ventas mensuales / Monthly sales (miles MXN / thousand MXN)"
    x-axis ["Ene/Jan", "Feb", "Mar", "Abr/Apr", "May", "Jun", "Jul", "Ago/Aug", "Sep"]
    y-axis "Miles MXN / Thousand MXN" 500 --> 950
    bar [747, 723, 884, 828, 825, 808, 828, 661, 658]
```

**ES:**
1. **Pico en marzo:** $883,516 (+22% vs. febrero); consistente con un posible empuje de cierre de trimestre, aunque con tan poca evidencia no se puede confirmar que sea recurrente.
2. **Meseta en Q2:** abril–junio ($827.7K, $825.3K, $808.3K), variación de ~2.3%.
3. **Julio repite el nivel de Q2; agosto y septiembre caen** (~$661K y ~$658K, los dos meses más bajos).

**EN:**
1. **March peak:** $883,516 (+22% vs. February); consistent with a possible quarter-end push, but with so little evidence it cannot be confirmed as recurring.
2. **Q2 plateau:** April–June ($827.7K, $825.3K, $808.3K), ~2.3% spread.
3. **July repeats Q2's level; August and September drop** (~$661K and ~$658K, the two lowest months).

---

### Consulta 5 — Crecimiento anual (YoY) / Query 5 — Year-over-year growth

**ES:** Compara cada mes con el mismo mes del año anterior (`LAG(…, 12)`). Requiere más de un año de datos; si algún mes no tiene su par, el resultado es `NULL`.

**EN:** Compares each month with the same month of the previous year (`LAG(…, 12)`). It requires more than one year of data; if a month has no counterpart, the result is `NULL`.

```sql
WITH monthly AS (
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

![Crecimiento YoY](images/yoy_growth.png)
*Crecimiento interanual por mes / Year-over-year growth by month.*

| Mes / Month | Ene/Jan | Abr/Apr | May | Jun | Jul | Ago/Aug | Sep |
|---|---|---|---|---|---|---|---|
| YoY % | 37.72 | 21.5 | 22.8 | 22.1 | 48.97 | 35.0 | 12.35 |

**ES:** El crecimiento se estabiliza en ~22% durante Q2, sube a 48.97% en julio y se desacelera a 12.35% en septiembre (menos de un tercio del de enero). Conviene monitorear de cerca el inicio de Q4.
**EN:** Growth settles around 22% in Q2, jumps to 48.97% in July and slows to 12.35% in September (less than a third of January's). The start of Q4 should be monitored closely.

---

### Consulta 6 — Ingreso perdido por quiebre de stock / Query 6 — Revenue lost to stockouts

**ES:** Para cada combinación tienda-producto con `stock_on_hand = 0`, estima el ingreso diario perdido como demanda diaria histórica × precio. La **demanda diaria** se calcula como unidades totales ÷ días del periodo (no como promedio por transacción).

**EN:** For each store-product combination with `stock_on_hand = 0`, estimates daily lost revenue as historical daily demand × price. **Daily demand** is total units ÷ days in the period (not an average per transaction).

```sql
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
    ROUND(d.avg_daily_units, 2)                     AS est_lost_units_per_day,
    p.product_price,
    ROUND(d.avg_daily_units * p.product_price, 2)   AS est_lost_revenue_per_day
FROM inventory i
JOIN demand   d ON i.store_id   = d.store_id AND i.product_id = d.product_id
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_on_hand = 0
ORDER BY est_lost_revenue_per_day DESC;
```

![Ingreso perdido por quiebre](images/lost_revenue_top10.png)
*Top 10 combinaciones tienda-producto por ingreso diario perdido / Top 10 store-product combinations by daily lost revenue.*

**Resultados del cálculo original ⚠️ / Results from the original calculation ⚠️**

| | |
|---|---|
| Combinaciones sin stock / Out-of-stock combinations | 77 |
| Ingreso perdido estimado / Estimated lost revenue | ~$1,123.15 MXN / día (day) |
| Mayores casos / Largest cases | Tienda 4 / Producto 34 ($29.30), Tienda 33 / Producto 13 ($26.35) |

**ES:** Es una foto de un solo día: si un producto lleva varios días agotado, la pérdida acumulada es proporcionalmente mayor (la consulta no mide la duración del quiebre).
**EN:** This is a one-day snapshot: if a product has been out of stock for several days, the cumulative loss is proportionally higher (the query does not measure stockout duration).

---

### Consulta 7 — Valor del inventario por tienda / Query 7 — Inventory value per store

**ES:** Calcula el capital inmovilizado en inventario por tienda (`stock_on_hand × product_price`), de mayor a menor.

**EN:** Computes the capital tied up in inventory per store (`stock_on_hand × product_price`), from highest to lowest.

```sql
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

![Valor de inventario por tienda](images/inventory_value_by_store.png)
*Valor del inventario por tienda / Inventory value per store.*

---

### Consulta 8 — Días de cobertura de inventario / Query 8 — Days of inventory cover

**ES:** Calcula cuántos días de venta cubre el stock actual de cada combinación tienda-producto (`stock_on_hand ÷ demanda diaria`) y la clasifica: *Stockout* (0), *En riesgo* (< 3 días), *Sobre-stock* (> 60 días) o *Normal*.

**EN:** Computes how many days of sales the current stock of each store-product combination covers (`stock_on_hand ÷ daily demand`) and classifies it: *Stockout* (0), *At risk* (< 3 days), *Overstock* (> 60 days) or *Normal*.

```sql
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
        WHEN i.stock_on_hand / NULLIF(d.avg_daily_units, 0) < 3   THEN 'At risk (<3 days)'
        WHEN i.stock_on_hand / NULLIF(d.avg_daily_units, 0) > 60  THEN 'Overstock (>60 days)'
        ELSE 'Normal'
    END AS cover_status
FROM inventory i
JOIN demand d ON i.store_id = d.store_id AND i.product_id = d.product_id
ORDER BY days_of_cover;
```

**Gráfica / Chart ⚠️ — 1,590 combinaciones tienda-producto / store-product combinations (cálculo original / original calculation)**

```mermaid
pie title Cobertura de inventario / Inventory cover
    "En riesgo (<3 días) / At risk: 209 (13.1%)" : 209
    "Normal (3-60 días) / Normal: 1351 (85.0%)" : 1351
    "Sobre-stock (>60 días) / Overstock: 30 (1.9%)" : 30
```

**Resultados del cálculo original ⚠️ / Results from the original calculation ⚠️**

- **Riesgo de quiebre / Stockout risk:** 209 combinaciones (13.1%). El **Producto 28** aparece 26 veces (más del doble que el segundo) y la **Tienda 13** concentra 10 productos en riesgo. / 209 combinations (13.1%). **Product 28** appears 26 times (more than double the runner-up) and **Store 13** concentrates 10 at-risk products.
- **Sobre-stock / Overstock:** 30 combinaciones (1.9%) con más de 60 días, hasta 113.5 días (Tienda 31 / Producto 10); 2,712 unidades inmovilizadas. El **Producto 10** está en 6 de los 10 peores casos. / 30 combinations (1.9%) above 60 days, up to 113.5 days (Store 31 / Product 10); 2,712 units tied up. **Product 10** appears in 6 of the 10 worst cases.

**ES:** Que el Producto 28 y la Tienda 13 reaparezcan en dos análisis independientes sugiere un problema recurrente de proveedor o cadena de suministro, y el Producto 10 sugiere un posible error de pronóstico de demanda.
**EN:** Product 28 and Store 13 reappearing across two independent analyses suggests a recurring supplier or supply-chain issue, and Product 10 suggests a possible demand-forecasting error.

---

## 8. Resultados clave / Key results

| Área / Area | Hallazgo / Finding |
|---|---|
| Ventas / Sales | 50 tiendas, 829,262 ventas, $17.33 MXN promedio / 50 stores, 829,262 sales, $17.33 MXN average |
| Atípicos / Outliers | Guanajuato 3: venta de $879.78 y CV de 147.2% / Guanajuato 3: $879.78 sale and 147.2% CV |
| Rentabilidad / Profitability | Juguetes ~27% de la utilidad; Electrónica lidera en Airport y Commercial / Toys ~27% of profit; Electronics leads in Airport and Commercial |
| Tendencia / Trend | Pico en marzo, meseta en Q2, caída en ago–sep; YoY de 37.72% a 12.35% / March peak, Q2 plateau, Aug–Sep drop; YoY from 37.72% to 12.35% |
| Inventario ⚠️ / Inventory ⚠️ | 77 quiebres (~$1,123.15/día), 209 en riesgo, 30 en sobre-stock / 77 stockouts (~$1,123.15/day), 209 at risk, 30 overstocked |

---

## 9. Conclusiones / Conclusions

**ES:** La cadena tiene buen volumen total, pero con variabilidad significativa entre tiendas, sesgos estadísticos en las métricas de venta y desequilibrios estructurales de inventario. El promedio engaña cuando hay atípicos (usar mediana y CV), el surtido debe adaptarse al tipo de ubicación, la desaceleración del crecimiento YoY exige monitoreo en Q4, y el inventario debe vigilarse en sus dos extremos: quiebre y sobre-stock.

**EN:** The chain has strong total volume, but significant variability across stores, statistical distortions in sales metrics, and structural inventory imbalances. The mean misleads when outliers exist (use the median and CV), assortment should adapt to location type, the slowdown in YoY growth calls for Q4 monitoring, and inventory must be watched at both extremes: stockout and overstock.

---

## 10. Limitaciones y próximos pasos / Limitations and next steps

**ES**
- Dataset educativo con periodo acotado: no se puede confirmar estacionalidad.
- La demanda diaria asume un promedio constante en todo el periodo; no considera estacionalidad ni promociones.
- `inventory` es una foto de un momento: no hay historial para medir la duración de los quiebres.
- Próximos pasos: auditar transacciones atípicas, cruzar inventario con margen por producto y construir un dashboard en Power BI o Tableau sobre estas consultas.

**EN**
- Practice dataset with a limited period: seasonality cannot be confirmed.
- Daily demand assumes a constant average across the period; it ignores seasonality and promotions.
- `inventory` is a single-moment snapshot: there is no history to measure stockout duration.
- Next steps: audit outlier transactions, cross inventory with per-product margin, and build a Power BI or Tableau dashboard on top of these queries.

---

## English summary

This project analyzes sales, profitability and inventory for **Maven Toys**, a 50-store toy chain in Mexico, using **PostgreSQL** (CTEs, window functions such as `LAG`, `DENSE_RANK` and `SUM() OVER`, `PERCENTILE_CONT`, and conditional logic). Every query above includes a Spanish and English explanation, the SQL code and a chart. Data source: [Maven Analytics — Mexico Toy Sales](https://mavenanalytics.io/data-playground/mexico-toy-sales).
