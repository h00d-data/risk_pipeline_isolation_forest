# ===============================
# CONFIGURAÇÕES GERAIS
# ===============================

USE_CSV <- TRUE
CSV_PATH <- "sales-2003.csv"

SQL_CONFIG <- list(
  host = "localhost",
  user = "user",
  password = "password",
  database = "db",
  table = "orders"
)

OUTPUT_POWERBI <- "dados_preditos_powerbi.csv"
OUTPUT_TOP_RISK <- "ranking_top_risco.csv"
OUTPUT_REPORT_JSON <- "relatorio_modelo_risco.json"

TOP_N_RISCO <- 50
OUTPUT_DIR_GRAFICOS <- "outputs_graficos"

# ===============================
# LIBRARIES
# ===============================

library(tidyverse)
library(recipes)
library(isotree)
library(jsonlite)
library(DBI)
library(RMySQL)
library(lubridate)

# ===============================
# CARGA DE DADOS
# ===============================

start_time <- Sys.time()

if (USE_CSV) {
  df <- read_csv(CSV_PATH, show_col_types = FALSE)
  message("✅ Base CSV carregada")
} else {
  con <- dbConnect(
    RMySQL::MySQL(),
    host = SQL_CONFIG$host,
    user = SQL_CONFIG$user,
    password = SQL_CONFIG$password,
    dbname = SQL_CONFIG$database
  )
  df <- dbReadTable(con, SQL_CONFIG$table)
  dbDisconnect(con)
  message("✅ Base SQL carregada")
}

print(head(df))
glimpse(df)

# ===============================
# PREPROCESSAMENTO (RECEITA)
# ===============================

rec <- recipe(~ ., data = df) |>
  step_impute_median(all_numeric_predictors()) |>
  step_impute_mode(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.01) |>
  step_dummy(all_nominal_predictors())

prep_rec <- prep(rec)
X <- bake(prep_rec, new_data = df)

# ===============================
# MODELO DE RISCO (ISOLATION FOREST)
# ===============================

iso_model <- isolation.forest(
  X,
  ntrees = 300,
  sample_size = nrow(X),
  ndim = 1,
  seed = 42
)

raw_score <- predict(iso_model, X, type = "score")

# Normalização 0–1 (quanto maior, maior o risco)
risk_score <- (max(raw_score) - raw_score) /
              (max(raw_score) - min(raw_score))

df <- df |>
  mutate(
    risk_score = risk_score,
    risk_label = cut(
      risk_score,
      breaks = c(-0.01, 0.33, 0.66, 1.0),
      labels = c("Baixo", "Médio", "Alto")
    )
  )

# ===============================
# RANKING TOP N DE MAIOR RISCO
# ===============================

df_risk_rank <- df |>
  arrange(desc(risk_score)) |>
  slice_head(n = TOP_N_RISCO) |>
  mutate(rank_risco = row_number())

write_csv(df_risk_rank, OUTPUT_TOP_RISK)

# ===============================
# OUTPUT PARA POWER BI
# ===============================

write_csv(df, OUTPUT_POWERBI)

# ===============================
# RELATÓRIO FINAL (JSON)
# ===============================

elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

relatorio <- list(
  modelo = "IsolationForest",
  tipo_modelo = "Nao supervisionado",
  total_registros = nrow(df),
  tempo_execucao_segundos = round(elapsed, 2),
  distribuicao_risco = list(
    alto = sum(df$risk_label == "Alto"),
    medio = sum(df$risk_label == "Médio"),
    baixo = sum(df$risk_label == "Baixo")
  ),
  estatisticas_score = summary(df$risk_score),
  observacoes = c(
    "Modelo não supervisionado, sem variável alvo real",
    "Métricas supervisionadas foram ignoradas propositalmente",
    "Score indica grau de anomalia estatística",
    "Validação final depende de regra de negócio"
  )
)

write_json(relatorio, OUTPUT_REPORT_JSON, pretty = TRUE, auto_unbox = TRUE)

# ===============================
# GERAÇÃO DE GRÁFICOS
# ===============================

dir.create(OUTPUT_DIR_GRAFICOS, showWarnings = FALSE)

# Gráfico 1 — Distribuição do Risk Score
ggplot(df, aes(risk_score)) +
  geom_histogram(bins = 30, fill = "#2c7fb8", alpha = 0.8) +
  geom_density(color = "black") +
  labs(
    title = "Distribuição do Score de Risco",
    x = "Risk Score (0 = baixo | 1 = alto)",
    y = "Quantidade de Registros"
  ) +
  theme_minimal()

ggsave(
  filename = paste0(OUTPUT_DIR_GRAFICOS, "/distribuicao_risk_score.png"),
  dpi = 300,
  width = 8,
  height = 5
)

# Gráfico 2 — Boxplot por Classe
ggplot(df, aes(risk_label, risk_score, fill = risk_label)) +
  geom_boxplot(show.legend = FALSE) +
  labs(
    title = "Distribuição do Risk Score por Classe de Risco",
    x = "Classe de Risco",
    y = "Risk Score"
  ) +
  theme_minimal()

ggsave(
  filename = paste0(OUTPUT_DIR_GRAFICOS, "/boxplot_risco_por_classe.png"),
  dpi = 300,
  width = 8,
  height = 5
)

# Gráfico 3 — Volume por Classe
ggplot(df, aes(risk_label)) +
  geom_bar(fill = "#41ab5d") +
  labs(
    title = "Quantidade de Registros por Classe de Risco",
    x = "Classe de Risco",
    y = "Número de Registros"
  ) +
  theme_minimal()

ggsave(
  filename = paste0(OUTPUT_DIR_GRAFICOS, "/volume_por_classe_risco.png"),
  dpi = 300,
  width = 7,
  height = 5
)

# ===============================
# LOG FINAL
# ===============================

message("📊 Relatório Final")
message(paste("⏱️ Tempo total:", round(elapsed, 1), "s"))
print(table(df$risk_label))

message("✅ Arquivo Power BI: ", OUTPUT_POWERBI)
message("✅ Ranking Top risco: ", OUTPUT_TOP_RISK)
message("✅ Relatório JSON: ", OUTPUT_REPORT_JSON)
message("📈 Gráficos salvos em: ", OUTPUT_DIR_GRAFICOS)
message("🚀 Pipeline de risco finalizado com sucesso.")
