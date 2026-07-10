-- sql/05_hipotesis.sql
-- Queries de Análisis de Hipótesis H1-H10
-- Telco Customer Churn
-- ─────────────────────────────────────────────────────────────────

-- H1: Tipo de contrato vs tasa de cancelación

WITH metricas_contrato AS (
  SELECT
    tc.descripcion                                                        AS tipo_contrato,
    COUNT(*)                                                              AS total_clientes,
    SUM(f.Churn_num)                                                      AS cancelados,
    ROUND(AVG(f.Churn_num) * 100, 2)                                      AS tasa_cancelacion_pct,
    ROUND(SUM(f.MonthlyCharges), 2)                                       AS revenue_mensual,
    ROUND(SUM(CASE WHEN f.Churn='Yes' THEN f.MonthlyCharges ELSE 0 END),2) AS revenue_en_riesgo,
    ROUND(AVG(f.MonthlyCharges), 2)                                       AS cargo_promedio,
    ROUND(AVG(f.tenure), 1)                                               AS tenure_promedio
  FROM fact_cliente f
  JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
  GROUP BY tc.descripcion
)
SELECT *,
  ROUND(revenue_en_riesgo / revenue_mensual * 100, 2)                    AS pct_revenue_en_riesgo,
  ROUND(tasa_cancelacion_pct / MIN(tasa_cancelacion_pct) OVER (), 1)     AS ratio_vs_menor_churn
FROM metricas_contrato
ORDER BY tasa_cancelacion_pct DESC;


SELECT
  tc.descripcion                                        AS tipo_contrato,
  mp.descripcion                                        AS metodo_pago,
  COUNT(*)                                              AS clientes,
  SUM(f.Churn_num)                                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)                      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)                       AS cargo_promedio
FROM fact_cliente f
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
JOIN dim_metodo_pago   mp ON f.metodo_pago_id   = mp.metodo_pago_id
GROUP BY tc.descripcion, mp.descripcion
ORDER BY tc.descripcion, tasa_cancelacion_pct DESC;

-- H2: Antigüedad dentro del contrato

SELECT
  tenure_group,
  COUNT(*)                              AS clientes,
  SUM(Churn_num)                        AS cancelados,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct,
  ROUND(AVG(MonthlyCharges), 2)         AS cargo_promedio,
  ROUND(AVG(tenure), 1)                 AS tenure_promedio
FROM fact_cliente
GROUP BY tenure_group
ORDER BY tenure_group;


WITH base AS (
  SELECT
    f.tenure_group,
    tc.descripcion                                        AS tipo_contrato,
    COUNT(*)                                              AS clientes,
    SUM(f.Churn_num)                                      AS cancelados,
    ROUND(AVG(f.Churn_num) * 100, 2)                      AS tasa_cancelacion_pct
  FROM fact_cliente f
  JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
  GROUP BY f.tenure_group, tc.descripcion
)
SELECT *,
  RANK() OVER (
    PARTITION BY tipo_contrato
    ORDER BY tasa_cancelacion_pct DESC
  ) AS ranking_churn_dentro_contrato
FROM base
ORDER BY tipo_contrato, tenure_group;

-- H3: Clientes senior

SELECT
  d.SeniorCitizen,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio,
  ROUND(AVG(f.tenure), 1)               AS tenure_promedio
FROM fact_cliente f
JOIN dim_cliente d ON f.cliente_id = d.cliente_id
GROUP BY d.SeniorCitizen
ORDER BY d.SeniorCitizen DESC;


SELECT
  d.SeniorCitizen,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio
FROM fact_cliente f
JOIN dim_cliente d       ON f.cliente_id       = d.cliente_id
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
GROUP BY d.SeniorCitizen, tc.descripcion
ORDER BY d.SeniorCitizen DESC, tasa_cancelacion_pct DESC;

-- H4: Perfil familiar

SELECT
  perfil_familiar,
  COUNT(*)                              AS clientes,
  SUM(Churn_num)                        AS cancelados,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct,
  ROUND(AVG(MonthlyCharges), 2)         AS cargo_promedio,
  ROUND(AVG(tenure), 1)                 AS tenure_promedio
FROM fact_cliente
GROUP BY perfil_familiar
ORDER BY tasa_cancelacion_pct DESC;


SELECT
  perfil_familiar,
  tenure_group,
  COUNT(*)                              AS clientes,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct
FROM fact_cliente
GROUP BY perfil_familiar, tenure_group
ORDER BY perfil_familiar, tenure_group;

-- H5: Tipo de internet

SELECT
  ti.descripcion                        AS tipo_internet,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio,
  ROUND(AVG(f.tenure), 1)               AS tenure_promedio,
  ROUND(SUM(CASE WHEN f.Churn='Yes' THEN f.MonthlyCharges ELSE 0 END), 2) AS revenue_en_riesgo
FROM fact_cliente f
JOIN dim_tipo_internet ti ON f.tipo_internet_id = ti.tipo_internet_id
GROUP BY ti.descripcion
ORDER BY tasa_cancelacion_pct DESC;


SELECT
  ti.descripcion                        AS tipo_internet,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio
FROM fact_cliente f
JOIN dim_tipo_internet ti ON f.tipo_internet_id  = ti.tipo_internet_id
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id  = tc.tipo_contrato_id
GROUP BY ti.descripcion, tc.descripcion
ORDER BY ti.descripcion, tasa_cancelacion_pct DESC;

-- H6: Servicios de proteccion

WITH seguridad AS (
  SELECT
    b.cliente_id,
    MAX(CASE WHEN s.nombre = 'OnlineSecurity' AND b.estado = 'Yes' THEN 1 ELSE 0 END) AS tiene_seguridad,
    MAX(CASE WHEN s.nombre = 'TechSupport'    AND b.estado = 'Yes' THEN 1 ELSE 0 END) AS tiene_soporte
  FROM bridge_cliente_servicio b
  JOIN dim_catalogo_servicios s ON b.servicio_id = s.servicio_id
  WHERE s.nombre IN ('OnlineSecurity', 'TechSupport')
  GROUP BY b.cliente_id
),
clasificacion AS (
  SELECT
    seg.cliente_id,
    CASE
      WHEN seg.tiene_seguridad = 1 AND seg.tiene_soporte = 1 THEN 'Ambos servicios'
      WHEN seg.tiene_seguridad = 0 AND seg.tiene_soporte = 0 THEN 'Ningun servicio'
      ELSE 'Solo uno de los dos'
    END AS perfil_proteccion
  FROM seguridad seg
)
SELECT
  c.perfil_proteccion,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio,
  ROUND(AVG(f.tenure), 1)               AS tenure_promedio
FROM clasificacion c
JOIN fact_cliente f ON c.cliente_id = f.cliente_id
GROUP BY c.perfil_proteccion
ORDER BY tasa_cancelacion_pct DESC;

-- H7: Numero de servicios adicionales

SELECT
  n_servicios,
  COUNT(*)                              AS clientes,
  SUM(Churn_num)                        AS cancelados,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct,
  ROUND(AVG(MonthlyCharges), 2)         AS cargo_promedio,
  ROUND(AVG(tenure), 1)                 AS tenure_promedio
FROM fact_cliente
GROUP BY n_servicios
ORDER BY n_servicios;


WITH un_servicio AS (
  SELECT cliente_id FROM fact_cliente WHERE n_servicios = 1
)
SELECT
  s.nombre                              AS servicio,
  s.categoria,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio
FROM bridge_cliente_servicio b
JOIN dim_catalogo_servicios s ON b.servicio_id = s.servicio_id
JOIN fact_cliente f            ON b.cliente_id  = f.cliente_id
WHERE b.cliente_id IN (SELECT cliente_id FROM un_servicio)
  AND b.estado = 'Yes'
GROUP BY s.nombre, s.categoria
ORDER BY tasa_cancelacion_pct DESC;

-- H8: Metodo de pago

SELECT
  mp.descripcion                        AS metodo_pago,
  CASE WHEN mp.descripcion LIKE '%(automatic)%'
       THEN 'Automatico' ELSE 'Manual' END  AS tipo_pago,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio,
  ROUND(AVG(f.tenure), 1)               AS tenure_promedio
FROM fact_cliente f
JOIN dim_metodo_pago mp ON f.metodo_pago_id = mp.metodo_pago_id
GROUP BY mp.descripcion
ORDER BY tasa_cancelacion_pct DESC;


SELECT
  mp.descripcion                        AS metodo_pago,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct
FROM fact_cliente f
JOIN dim_metodo_pago   mp ON f.metodo_pago_id   = mp.metodo_pago_id
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
GROUP BY mp.descripcion, tc.descripcion
ORDER BY mp.descripcion, tasa_cancelacion_pct DESC;

-- H9: Segmento de riesgo financiero

WITH revenue_total_riesgo AS (
  SELECT SUM(MonthlyCharges) AS total_riesgo
  FROM fact_cliente WHERE Churn = 'Yes'
)
SELECT
  f.segmento_riesgo,
  f.rango_cargo,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  SUM(f.Churn_num)                      AS cancelados,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(SUM(CASE WHEN f.Churn='Yes' THEN f.MonthlyCharges ELSE 0 END), 2) AS revenue_en_riesgo,
  ROUND(SUM(CASE WHEN f.Churn='Yes' THEN f.MonthlyCharges ELSE 0 END)
        / r.total_riesgo * 100, 2)      AS pct_del_revenue_en_riesgo
FROM fact_cliente f
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id,
     revenue_total_riesgo r
GROUP BY f.segmento_riesgo, f.rango_cargo, tc.descripcion
ORDER BY revenue_en_riesgo DESC;


SELECT
  rango_cargo,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  SUM(Churn_num)                        AS cancelados,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct,
  ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END), 2) AS revenue_en_riesgo
FROM fact_cliente f
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
GROUP BY rango_cargo, tc.descripcion
ORDER BY rango_cargo, tipo_contrato;

-- H10: Facturacion electronica

SELECT
  PaperlessBilling,
  COUNT(*)                              AS clientes,
  SUM(Churn_num)                        AS cancelados,
  ROUND(AVG(Churn_num) * 100, 2)        AS tasa_cancelacion_pct,
  ROUND(AVG(MonthlyCharges), 2)         AS cargo_promedio,
  ROUND(AVG(tenure), 1)                 AS tenure_promedio
FROM fact_cliente
GROUP BY PaperlessBilling
ORDER BY tasa_cancelacion_pct DESC;


SELECT
  f.PaperlessBilling,
  tc.descripcion                        AS tipo_contrato,
  COUNT(*)                              AS clientes,
  ROUND(AVG(f.Churn_num) * 100, 2)      AS tasa_cancelacion_pct,
  ROUND(AVG(f.MonthlyCharges), 2)       AS cargo_promedio
FROM fact_cliente f
JOIN dim_tipo_contrato tc ON f.tipo_contrato_id = tc.tipo_contrato_id
GROUP BY f.PaperlessBilling, tc.descripcion
ORDER BY tc.descripcion, tasa_cancelacion_pct DESC;
