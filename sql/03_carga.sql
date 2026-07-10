-- Carga completa --- Telco Customer Churn
-- Pipeline: catalogos, dimensiones y hechos
-- Orden de carga respeta dependencias FK


-- 1. dim_genero: valores unicos de gender
INSERT INTO dim_genero (descripcion)
SELECT DISTINCT gender FROM telco_clean ORDER BY gender;

-- 2. dim_tipo_contrato: valores unicos de Contract
INSERT INTO dim_tipo_contrato (descripcion)
SELECT DISTINCT Contract FROM telco_clean ORDER BY Contract;

-- 3. dim_metodo_pago: valores unicos de PaymentMethod
INSERT INTO dim_metodo_pago (descripcion)
SELECT DISTINCT PaymentMethod FROM telco_clean ORDER BY PaymentMethod;

-- 4. dim_tipo_internet: valores unicos de InternetService
INSERT INTO dim_tipo_internet (descripcion)
SELECT DISTINCT InternetService FROM telco_clean ORDER BY InternetService;

-- 5. dim_catalogo_servicios: catalogo manual de 8 servicios
INSERT INTO dim_catalogo_servicios (nombre, categoria) VALUES
  ('PhoneService',    'Telefonia'),
  ('MultipleLines',   'Telefonia'),
  ('OnlineSecurity',  'Internet'),
  ('OnlineBackup',    'Internet'),
  ('DeviceProtection','Internet'),
  ('TechSupport',     'Internet'),
  ('StreamingTV',     'Internet'),
  ('StreamingMovies', 'Internet');

-- 6. dim_cliente: datos demograficos de cada cliente
INSERT INTO dim_cliente (cliente_id, genero_id, SeniorCitizen, Partner, Dependents)
SELECT
  t.customerID,
  g.genero_id,
  CASE WHEN t.SeniorCitizen = 'Senior' THEN 1 ELSE 0 END AS SeniorCitizen,
  t.Partner,
  t.Dependents
FROM telco_clean t
JOIN dim_genero g ON t.gender = g.descripcion;

-- 7. fact_cliente: metricas de facturacion y churn
INSERT INTO fact_cliente (
  cliente_id, tipo_contrato_id, metodo_pago_id, tipo_internet_id,
  tenure, PaperlessBilling, MonthlyCharges, TotalCharges,
  Churn, Churn_num, tenure_group, perfil_familiar,
  n_servicios, rango_cargo, segmento_riesgo
)
SELECT
  t.customerID,
  c.tipo_contrato_id,
  m.metodo_pago_id,
  i.tipo_internet_id,
  t.tenure,
  t.PaperlessBilling,
  t.MonthlyCharges,
  t.TotalCharges,
  t.Churn,
  t.Churn_num,
  t.tenure_group,
  t.perfil_familiar,
  t.n_servicios,
  t.rango_cargo,
  t.segmento_riesgo
FROM telco_clean t
JOIN dim_tipo_contrato c ON t.Contract        = c.descripcion
JOIN dim_metodo_pago   m ON t.PaymentMethod   = m.descripcion
JOIN dim_tipo_internet i ON t.InternetService = i.descripcion;

-- 8. bridge_cliente_servicio: 7043 clientes x 8 servicios = 56344 filas
INSERT INTO bridge_cliente_servicio (cliente_id, servicio_id, estado)
SELECT t.customerID, s.servicio_id, t.PhoneService
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'PhoneService'
UNION ALL
SELECT t.customerID, s.servicio_id, t.MultipleLines
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'MultipleLines'
UNION ALL
SELECT t.customerID, s.servicio_id, t.OnlineSecurity
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'OnlineSecurity'
UNION ALL
SELECT t.customerID, s.servicio_id, t.OnlineBackup
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'OnlineBackup'
UNION ALL
SELECT t.customerID, s.servicio_id, t.DeviceProtection
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'DeviceProtection'
UNION ALL
SELECT t.customerID, s.servicio_id, t.TechSupport
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'TechSupport'
UNION ALL
SELECT t.customerID, s.servicio_id, t.StreamingTV
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'StreamingTV'
UNION ALL
SELECT t.customerID, s.servicio_id, t.StreamingMovies
  FROM telco_clean t JOIN dim_catalogo_servicios s ON s.nombre = 'StreamingMovies';
