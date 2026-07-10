-- sql/01_eda.sql
-- EDA — Telco Customer Churn
-- Queries de análisis exploratorio
-- Tabla fuente: telco_raw (database/telco.db)
-- ─────────────────────────────────────────────────────────────────

-- Sección 1 — Completitud
SELECT COUNT(*) AS total_filas,
       COUNT(DISTINCT customerID) AS clientes_unicos
FROM telco_raw;

-- Sección 2 — Perfilado de columnas
SELECT COUNT(*) AS total FROM telco_raw;

-- Sección 3 — Nulos y blancos
SELECT
  SUM(CASE WHEN TRIM(TotalCharges)='' THEN 1 ELSE 0 END) AS blancos_totalcharges,
  SUM(CASE WHEN tenure=0 THEN 1 ELSE 0 END) AS tenure_cero
FROM telco_raw;

-- Sección 4 — Duplicados
SELECT COUNT(*) - COUNT(DISTINCT customerID) AS duplicados
FROM telco_raw;

-- Sección 5 — Estadísticas numéricas
SELECT
  MIN(tenure) AS tenure_min, MAX(tenure) AS tenure_max,
  ROUND(AVG(tenure),2) AS tenure_avg,
  MIN(MonthlyCharges) AS monthly_min, MAX(MonthlyCharges) AS monthly_max,
  ROUND(AVG(MonthlyCharges),2) AS monthly_avg
FROM telco_raw;

-- Sección 8 — Frecuencias categóricas
SELECT Contract, COUNT(*) AS n,
  ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM telco_raw),2) AS pct
FROM telco_raw GROUP BY Contract ORDER BY n DESC;

SELECT PaymentMethod, COUNT(*) AS n,
  ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM telco_raw),2) AS pct
FROM telco_raw GROUP BY PaymentMethod ORDER BY n DESC;

SELECT InternetService, COUNT(*) AS n,
  ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM telco_raw),2) AS pct
FROM telco_raw GROUP BY InternetService ORDER BY n DESC;

SELECT gender, COUNT(*) AS n,
  ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM telco_raw),2) AS pct
FROM telco_raw GROUP BY gender;

SELECT Churn, COUNT(*) AS n,
  ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM telco_raw),2) AS pct
FROM telco_raw GROUP BY Churn;

-- Sección 10 — Validación de negocio
SELECT COUNT(*) AS inconsistencias
FROM telco_raw
WHERE InternetService='No'
  AND OnlineSecurity != 'No internet service';
