-- ─────────────────────────────────────────────
-- DDL — Telco Customer Churn
-- Modelo: Star Schema + tabla puente N:M
-- Normalizacion: 3FN
-- ─────────────────────────────────────────────

-- Eliminar en orden inverso a las dependencias FK
DROP TABLE IF EXISTS bridge_cliente_servicio;
DROP TABLE IF EXISTS fact_cliente;
DROP TABLE IF EXISTS dim_cliente;
DROP TABLE IF EXISTS dim_genero;
DROP TABLE IF EXISTS dim_tipo_contrato;
DROP TABLE IF EXISTS dim_metodo_pago;
DROP TABLE IF EXISTS dim_tipo_internet;
DROP TABLE IF EXISTS dim_catalogo_servicios;

CREATE TABLE dim_genero (
    genero_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion TEXT    NOT NULL UNIQUE
);

CREATE TABLE dim_cliente (
    cliente_id    TEXT    PRIMARY KEY,
    genero_id     INTEGER NOT NULL,
    SeniorCitizen INTEGER NOT NULL CHECK (SeniorCitizen IN (0,1)),
    Partner       TEXT    NOT NULL CHECK (Partner IN ('Yes','No')),
    Dependents    TEXT    NOT NULL CHECK (Dependents IN ('Yes','No')),
    FOREIGN KEY (genero_id) REFERENCES dim_genero(genero_id)
);

CREATE TABLE dim_tipo_contrato (
    tipo_contrato_id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion      TEXT    NOT NULL UNIQUE
);

CREATE TABLE dim_metodo_pago (
    metodo_pago_id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion    TEXT    NOT NULL UNIQUE
);

CREATE TABLE dim_tipo_internet (
    tipo_internet_id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion      TEXT    NOT NULL UNIQUE
);

CREATE TABLE dim_catalogo_servicios (
    servicio_id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre      TEXT    NOT NULL UNIQUE,
    categoria   TEXT    NOT NULL CHECK (categoria IN ('Telefonia','Internet'))
);

CREATE TABLE bridge_cliente_servicio (
    cliente_id  TEXT    NOT NULL,
    servicio_id INTEGER NOT NULL,
    estado      TEXT    NOT NULL,
    PRIMARY KEY (cliente_id, servicio_id),
    FOREIGN KEY (cliente_id)  REFERENCES dim_cliente(cliente_id),
    FOREIGN KEY (servicio_id) REFERENCES dim_catalogo_servicios(servicio_id)
);

CREATE TABLE fact_cliente (
    cliente_id       TEXT    PRIMARY KEY,
    tipo_contrato_id INTEGER NOT NULL,
    metodo_pago_id   INTEGER NOT NULL,
    tipo_internet_id INTEGER NOT NULL,
    tenure           INTEGER NOT NULL,
    PaperlessBilling TEXT    NOT NULL,
    MonthlyCharges   REAL    NOT NULL,
    TotalCharges     REAL    NOT NULL,
    Churn            TEXT    NOT NULL,
    Churn_num        INTEGER NOT NULL,
    tenure_group     TEXT,
    perfil_familiar  TEXT,
    n_servicios      INTEGER,
    rango_cargo      TEXT,
    segmento_riesgo  INTEGER,
    FOREIGN KEY (cliente_id)       REFERENCES dim_cliente(cliente_id),
    FOREIGN KEY (tipo_contrato_id) REFERENCES dim_tipo_contrato(tipo_contrato_id),
    FOREIGN KEY (metodo_pago_id)   REFERENCES dim_metodo_pago(metodo_pago_id),
    FOREIGN KEY (tipo_internet_id) REFERENCES dim_tipo_internet(tipo_internet_id)
);