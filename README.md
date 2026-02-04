**🔍 Risk Anomaly Detection with Isolation Forest (R)**

Pipeline completo de detecção de risco/anomalias usando Isolation Forest, com foco em análise exploratória, priorização de risco e visualização executiva.
Projeto não supervisionado, ideal para cenários onde não existe variável alvo real (fraude, inconsistência, outliers operacionais, risco comercial etc.).

🎯 Objetivo do Projeto

Identificar registros com comportamento estatisticamente anômalo, atribuir um score de risco normalizado (0–1) e classificá-los em:

- Baixo risco
- Médio risco
- Alto risco

* Além disso, o pipeline gera:

- ranking dos Top N registros mais arriscados
- arquivos prontos para Power BI
- gráficos analíticos
- relatório técnico em JSON

🧠 Modelo Utilizado

- Algoritmo: Isolation Forest
- Tipo: Não supervisionado
- Biblioteca: isotree

* Justificativa:
- O Isolation Forest é eficiente para:

- grandes volumes de dados
- múltiplas variáveis
- detecção de padrões raros sem rótulo

⚠️ Métricas supervisionadas como Accuracy, Recall,AUC não se aplicam e foram intencionalmente ignoradas.


⚙️ Fluxo do Pipeline

Carga de dados
CSV ou banco MySQL (configurável)

* Preprocessamento:
-Imputação de valores ausentes
-Normalização de variáveis numéricas
-One-hot encoding para categóricas
-Agrupamento de categorias raras

*Treinamento:

- Isolation Forest com 300 árvores
- Score de risco
- Normalização para escala 0–1
- Quanto maior, maior o risco

*Classificação:

Baixo / Médio / Alto risco

Outputs:

- CSV para BI
- Ranking dos maiores riscos
- Relatório técnico
- Gráficos analíticos

📊 Gráficos Gerados:

1️⃣ Distribuição do Risk Score
- Mostra concentração, dispersão e cauda de risco.

2️⃣ Boxplot por Classe de Risco
- Valida se a separação Baixo / Médio / Alto faz sentido estatístico.

3️⃣ Volume por Classe
- Visão executiva: quanto do dataset está em risco.
- Todos os gráficos são exportados em PNG (300 DPI), prontos para relatórios.

⚙️ Executa:
Rscript R/risk_pipeline_isolation_forest.R

🧩 Casos de Uso:

- Detecção de risco operacional
- Análise de outliers financeiros
- Priorização de auditoria
- Monitoramento de vendas anômalas
- Suporte a regras de negócio

⚠️ Observações Importantes

- O modelo não substitui regra de negócio
- O score indica anomalia estatística, não fraude confirmada
- A validação final deve ser feita por analista ou especialista do domínio

👤 Autor
Projeto desenvolvido com foco em Data Analytics, BI e Modelagem Estatística aplicada, priorizando clareza, reprodutibilidade e aplicabilidade real.

🏗️ Estrutura do Projeto

```
risk-anomaly-isolationforest/
│
├── data/
│   └── sales-2003.csv
│
├── R/
│   └── risk_pipeline_isolation_forest.R
│
├── outputs_graficos/
│   ├── distribuicao_risk_score.png
│   ├── boxplot_risco_por_classe.png
│   └── volume_por_classe_risco.png
│
├── dados_preditos_powerbi.csv
├── ranking_top_risco.csv
├── relatorio_modelo_risco.json
│
├── README.md
└── .gitignore


```
