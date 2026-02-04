🔍 Risk Anomaly Detection with Isolation Forest (R)

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


