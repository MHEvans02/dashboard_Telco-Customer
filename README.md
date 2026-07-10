# 📉 Análisis de Cancelación de Clientes — Telco Customer Churn

Análisis end-to-end de la cancelación de clientes (churn) de una empresa de telecomunicaciones, con **SQL como motor central del pipeline** y un dashboard ejecutivo en **Tableau Public**. El objetivo: identificar por qué cancelan los clientes, qué segmentos concentran el mayor riesgo financiero, y traducir los hallazgos en recomendaciones accionables.

**Stack:** SQL / SQLite · Python (pandas · numpy · scipy) · matplotlib · seaborn · Tableau Public · dbdiagram.io · Miro

---

## 📑 Contenido

- [Descripción](#-descripción)
- [Dataset](#-dataset)
- [Estructura del repositorio](#-estructura-del-repositorio)
- [Pipeline del proyecto](#-pipeline-del-proyecto)
- [Modelo relacional](#-modelo-relacional)
- [KPIs principales](#-kpis-principales)
- [Resultados de las hipótesis](#-resultados-de-las-hipótesis)
- [Segmentos de mayor riesgo](#-segmentos-de-mayor-riesgo)
- [Dashboard](#-dashboard)
- [Cómo reproducir el proyecto](#-cómo-reproducir-el-proyecto)
- [Autor](#-autor)

---

## 🎯 Descripción

El proyecto recorre el ciclo completo de trabajo de un analista de datos —obtención, exploración, limpieza, modelado relacional, análisis y visualización— sobre un dataset real de churn.

A diferencia de otros proyectos multi-herramienta, este usa **SQL como eje de todo el pipeline** (EDA, ETL, modelado y análisis), con **Python** para validación estadística y **Tableau Public** para el reporte ejecutivo final. Cada KPI se valida de forma cruzada entre SQL y Python, coincidiendo al centavo.

**Qué demuestra técnicamente:**

- EDA profesional: perfilado, patrón de ausencia (MCAR), outliers (IQR + z-score), correlaciones (Pearson + Cramér's V)
- SQL avanzado: CTEs, Window Functions (RANK, PARTITION BY), subconsultas
- Modelado dimensional: Star Schema en 3FN con tabla puente para resolver una relación N:M
- Validación cruzada SQL ↔ Python
- Storytelling ejecutivo: historia de 6 dashboards con recomendaciones de negocio

---

## 📊 Dataset

**Telco Customer Churn** — 7.043 clientes · 21 columnas · publicado por IBM Sample Data Sets en Kaggle.

> ⚠️ **El dataset no está incluido en el repositorio** (la carpeta `data/` está excluida vía `.gitignore`). Descargalo desde Kaggle antes de correr los notebooks:

1. Descargá el CSV desde 👉 [Kaggle — Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
2. Colocá el archivo `WA_Fn-UseC_-Telco-Customer-Churn.csv` dentro de la carpeta `data/`
3. Corré los notebooks en orden (ver [Cómo reproducir](#-cómo-reproducir-el-proyecto)) — los archivos procesados y la base de datos se regeneran solos.

| Atributo | Detalle |
|---|---|
| Volumen | 7.043 filas × 21 columnas |
| Naturaleza | Snapshot (corte transversal), no serie temporal |
| Granularidad | Una fila por cliente único |
| Variable objetivo | `Churn` (Yes / No) |

---

## 📂 Estructura del repositorio

```
├── data/                     # (excluida del repo — descargar CSV de Kaggle)
├── database/
│   └── telco.db              # Base SQLite con el modelo relacional
├── notebooks/
│   ├── 01_eda.ipynb          # Análisis exploratorio
│   ├── 02_etl.ipynb          # Limpieza y transformación
│   ├── 03_modelado.ipynb     # Modelado relacional (DDL + carga)
│   ├── 03.1_exportar_modelo.ipynb  # Exporta el modelo a Excel para Tableau
│   └── 04_analisis.ipynb     # Análisis de KPIs e hipótesis
├── sql/
│   ├── 01_eda.sql            # Queries de exploración
│   ├── 02_ddl.sql            # Creación de tablas
│   ├── 03_carga.sql          # Carga de datos al modelo
│   ├── 04_kpis.sql           # KPIs globales y Pareto
│   └── 05_hipotesis.sql      # Queries de las 10 hipótesis
├── assets/                   # 18 visualizaciones del análisis
├── docs/
│   ├── documentacion_tecnica.pdf   # Documento técnico completo
│   ├── modelado.pdf                # Diagrama del modelo relacional
│   └── Diagrama de flujo.pdf       # Pipeline del proceso
├── Libro1.twb                # Dashboard de Tableau
├── requirements.txt
└── README.md
```

---

## 🔄 Pipeline del proyecto

| Etapa | Herramienta | Entregable |
|---|---|---|
| **1. Fuente de datos** | Kaggle CSV | Dataset original (7.043 × 21) |
| **2. EDA** | SQL + Python (scipy) | `01_eda.ipynb` · `01_eda.sql` · 18 gráficos |
| **3. ETL** | SQL / SQLite | `02_etl.ipynb` · `telco_clean.csv` |
| **4. Modelado** | SQL / SQLite | `03_modelado.ipynb` · `telco.db` |
| **5. Análisis** | SQL puro + Python | `04_analisis.ipynb` · `04_kpis.sql` · `05_hipotesis.sql` |
| **6. Dashboard** | Tableau Public | Historia con 6 dashboards |

---

## 🗄️ Modelo relacional

**Star Schema con tabla puente · 8 tablas · normalización 3FN.** La relación muchos-a-muchos entre clientes y servicios se resolvió mediante una tabla puente con clave primaria compuesta.

| Tabla | Registros | Rol |
|---|---|---|
| `dim_genero` | 2 | Catálogo de género |
| `dim_tipo_contrato` | 3 | Catálogo de contrato |
| `dim_metodo_pago` | 4 | Catálogo de método de pago |
| `dim_tipo_internet` | 3 | Catálogo de internet |
| `dim_catalogo_servicios` | 8 | Catálogo de servicios |
| `dim_cliente` | 7.043 | Dimensión de cliente |
| `fact_cliente` | 7.043 | Tabla de hechos |
| `bridge_cliente_servicio` | 56.344 | Tabla puente (N:M) |

Integridad referencial validada: **0 registros huérfanos** en todas las claves foráneas.

---

## 📈 KPIs principales

| Indicador | Valor |
|---|---|
| Tasa de cancelación global | **26,54%** (1.869 de 7.043) |
| Ingreso mensual total | **$456.116,60** |
| Ingreso mensual en riesgo | **$139.130,85** (30,5%) |
| Antigüedad promedio | **32,4 meses** |

---

## 🔬 Resultados de las hipótesis

Las 10 hipótesis fueron planteadas **antes** del análisis y concluidas con el dato concreto:

| # | Hipótesis | Resultado | Veredicto |
|---|---|---|---|
| H1 | Tipo de contrato | Mes a mes 42,71% vs dos años 2,83% (**15x**) | ✅ Confirmada |
| H2 | Antigüedad | 0-12m 47,44% vs 49-72m 9,51% | ✅ Confirmada |
| H3 | Clientes senior | Senior 41,68% vs no senior 23,61% (18pp) | ✅ Confirmada |
| H4 | Perfil familiar | Sin pareja/dep. 34,24% vs con ambos 14,24% | ✅ Confirmada |
| H5 | Tipo de internet | Fiber optic 41,89% vs DSL 18,96% (**2,2x**) | ✅ Confirmada |
| H6 | Servicios de protección | Sin ninguno 33,42% vs ambos 9,01% (**3,7x**) | ✅ Confirmada |
| H7 | Cantidad de servicios | Anomalía: 1 servicio = 45,76% (el más alto) | ⚠️ Parcial |
| H8 | Método de pago | Cheque electrónico 45,29% vs tarjeta 15,24% (**3x**) | ✅ Confirmada |
| H9 | Riesgo financiero | Relación no lineal; pico en cargo alto (35,94%) | ✅ Confirmada |
| H10 | Factura electrónica | Electrónica 33,57% vs física 16,33% (**2x**) | ✅ Confirmada |

**Hallazgo central:** el tipo de contrato es el factor individual de mayor impacto en la cancelación.

**Anomalía interesante (H7):** los clientes con un solo servicio adicional tienen la tasa de cancelación más alta (45,76%), por encima incluso de quienes no tienen ninguno. A partir de dos servicios la relación se vuelve inversa: a más servicios, menos cancelación (5,28% con seis servicios).

---

## 💰 Segmentos de mayor riesgo

| Segmento | Ingreso en riesgo | Clientes |
|---|---|---|
| Cargo alto + contrato mes a mes | **$102.177** | 1.186 |
| Fiber optic + cheque electrónico | $74.346 | 849 |
| Clientes nuevos sin servicios adicionales | $41.284 | 706 |

*Los segmentos se solapan (un cliente puede pertenecer a más de uno). El de cargo alto con contrato mes a mes es el más crítico.*

**Recomendaciones de negocio:**

1. Migrar clientes mes a mes a contratos anuales (la tasa cae de 42,71% a 11,27%)
2. Incentivar el pago automático (cheque electrónico 45,29% → tarjeta 15,24%)
3. Reforzar el onboarding en los primeros 12 meses (concentran 47,44% de la cancelación)
4. Promover el bundling de servicios de retención (a más servicios, menor cancelación)
5. Revisar la propuesta de valor de Fiber optic (41,89% de cancelación pese a ser premium)

---

## 📊 Dashboard

El dashboard ejecutivo está publicado en **Tableau Public** — una historia de 6 dashboards:

1. Resumen ejecutivo
2. Panorama general de cancelación
3. Contrato y antigüedad
4. Servicios e internet
5. Facturación y pagos
6. Segmentos de riesgo y conclusiones



---

## ⚙️ Cómo reproducir el proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/MHEvans02/<nombre-del-repo>.git
cd <nombre-del-repo>

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Descargar el dataset de Kaggle y colocarlo en data/
#    https://www.kaggle.com/datasets/blastchar/telco-customer-churn
#    → data/WA_Fn-UseC_-Telco-Customer-Churn.csv

# 4. Correr los notebooks en orden
jupyter notebook
```

Ejecutá los notebooks en este orden: `01_eda` → `02_etl` → `03_modelado` → `03.1_exportar_modelo` → `04_analisis`. Cada uno regenera sus salidas (dataset limpio, base de datos, modelo en Excel y visualizaciones).

---

## 👤 Autor

**Michael Hans Evans** — Data Analyst
📍 Córdoba, Argentina
💻 [GitHub: MHEvans02](https://github.com/MHEvans02)

---

> 📌 Dataset: [Telco Customer Churn — Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) · 7.043 filas · 21 columnas
