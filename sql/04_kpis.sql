-- sql/04_kpis.sql
-- KPIs Globales y Análisis de Pareto — Telco Customer Churn
-- ─────────────────────────────────────────────────────────────────

-- KPI 1: Métricas globales de volumen y rentabilidad

SELECT
  COUNT(*)                                                              AS total_clientes,
  SUM(Churn_num)                                                        AS total_cancelados,
  COUNT(*) - SUM(Churn_num)                                             AS total_activos,
  ROUND(AVG(Churn_num) * 100, 2)                                        AS tasa_cancelacion_pct,
  ROUND(SUM(MonthlyCharges), 2)                                         AS revenue_mensual_total,
  ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END), 2)   AS revenue_en_riesgo,
  ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END)
        / SUM(MonthlyCharges) * 100, 2)                                 AS pct_revenue_en_riesgo,
  ROUND(AVG(MonthlyCharges), 2)                                         AS cargo_mensual_promedio,
  ROUND(AVG(CASE WHEN Churn='Yes' THEN MonthlyCharges END), 2)          AS cargo_promedio_cancelados,
  ROUND(AVG(CASE WHEN Churn='No'  THEN MonthlyCharges END), 2)          AS cargo_promedio_activos,
  ROUND(AVG(tenure), 1)                                                 AS tenure_promedio_global,
  ROUND(AVG(CASE WHEN Churn='Yes' THEN tenure END), 1)                  AS tenure_promedio_cancelados,
  ROUND(AVG(CASE WHEN Churn='No'  THEN tenure END), 1)                  AS tenure_promedio_activos
FROM fact_cliente;

-- KPI 2: Distribución por tipo de contrato

SELECT
  tc.descripcion                                   AS tipo_contrato,
  COUNT(*)                                         AS clientes,
  SUM(f.Churn_num)                                 AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)                 AS tasa_cancelacion_pct,
  ROUND(SUM(f.MonthlyCharges), 2)                  AS revenue_mensual,
  ROUND(AVG(f.MonthlyCharges), 2)                  AS cargo_promedio,
  ROUND(AVG(f.tenure), 1)                          AS tenure_promedio
FROM fact_cliente f
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
GROUP BY tc.descripcion
ORDER BY tasa_cancelacion_pct DESC;

-- KPI 3: Pareto por tipo de contrato

WITH riesgo_por_contrato AS (
  SELECT
    tc.descripcion                                  AS tipo_contrato,
    COUNT(*)                                        AS clientes_cancelados,
    ROUND(SUM(f.MonthlyCharges), 2)                 AS revenue_en_riesgo
  FROM fact_cliente f
  JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
  WHERE f.Churn = 'Yes'
  GROUP BY tc.descripcion
),
total AS (SELECT SUM(revenue_en_riesgo) AS total_riesgo FROM riesgo_por_contrato)
SELECT
  r.tipo_contrato,
  r.clientes_cancelados,
  r.revenue_en_riesgo,
  ROUND(r.revenue_en_riesgo / t.total_riesgo * 100, 1)                    AS pct_del_total,
  ROUND(SUM(r.revenue_en_riesgo) OVER (
        ORDER BY r.revenue_en_riesgo DESC
  ) / t.total_riesgo * 100, 1)                                             AS pct_acumulado
FROM riesgo_por_contrato r, total t
ORDER BY r.revenue_en_riesgo DESC;

-- KPI 4: Pareto por método de pago

WITH riesgo_por_pago AS (
  SELECT
    mp.descripcion                                  AS metodo_pago,
    COUNT(*)                                        AS clientes_cancelados,
    ROUND(SUM(f.MonthlyCharges), 2)                 AS revenue_en_riesgo
  FROM fact_cliente f
  JOIN dim_metodo_pago mp ON f.metodo_pago_id = mp.metodo_pago_id
  WHERE f.Churn = 'Yes'
  GROUP BY mp.descripcion
),
total AS (SELECT SUM(revenue_en_riesgo) AS total_riesgo FROM riesgo_por_pago)
SELECT
  r.metodo_pago,
  r.clientes_cancelados,
  r.revenue_en_riesgo,
  ROUND(r.revenue_en_riesgo / t.total_riesgo * 100, 1)                    AS pct_del_total,
  ROUND(SUM(r.revenue_en_riesgo) OVER (
        ORDER BY r.revenue_en_riesgo DESC
  ) / t.total_riesgo * 100, 1)                                             AS pct_acumulado
FROM riesgo_por_pago r, total t
ORDER BY r.revenue_en_riesgo DESC;
