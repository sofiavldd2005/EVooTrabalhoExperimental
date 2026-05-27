### **Pessoa 1: GNSS e Requisitos de Navegação**
**Foco:** Avaliação da exatidão e desempenho do sistema EGNOS utilizando o ficheiro `EV_2026.C33`.

*   **Lista de Tarefas:**
    1.  **Implementação Matemática:** Aplicar a metodologia de conversão de coordenadas WGS84 para o referencial cartesiano e calcular os erros $d$ (HPE) e $h$ (VPE).
    2.  **Validação de Ferramenta:** Determinar os erros para as soluções de navegação A, B, C e D e comparar com os resultados obtidos pela ferramenta de processamento.
    3.  **Análise de Desempenho (SBAS):** Processar o ficheiro C33 para calcular parâmetros de exatidão, integridade, disponibilidade e continuidade.
    4.  **Identificação de Eventos:** Localizar instantes onde os níveis de proteção (HPL/VPL) são inferiores aos erros de navegação (eventos de integridade).
*   **Tópicos a Investigar:**
    *   Sistemas de coordenadas e elipsoide WGS84.
    *   Requisitos ICAO SARPs para modos de operação CAT-I, APV-I e APV-II.
    *   Conceitos de níveis de alerta (HAL/VAL) e limites de desempenho de navegação.

---

### **Pessoa 2: Processamento de Sinal e Instrumentação**
**Foco:** Análise espetral de dados de instrumentação de Classe I utilizando o ficheiro `EV_2026.A33`.

*   **Lista de Tarefas:**
    1.  **Visualização Temporal:** Criar gráficos da variação temporal das quatro acelerações ($a_1$ a $a_4$) medidas em laboratório.
    2.  **Análise Espetral:** Determinar e representar o espetro unilateral de amplitude (Fast Fourier Transform) para cada sinal.
    3.  **Caracterização de Picos:** Identificar as frequências e amplitudes onde ocorrem os picos significativos no espetro.
    4.  **Relatório Técnico:** Comentar os resultados obtidos face às características do sistema de instrumentação PCM.
*   **Tópicos a Investigar:**
    *   Normas de instrumentação PCM Classe I (RCC IRIG 106-24).
    *   Processamento digital de sinal (Transformadas de Fourier e análise de frequências).
    *   Ruído e vibração em sistemas de aquisição de dados.

---

### **Pessoa 3: Dados de Voo e Cargas Estruturais**
**Foco:** Análise de parâmetros de voo e contagem de ciclos de aceleração vertical utilizando o ficheiro `EV_2026.B33`.

*   **Lista de Tarefas:**
    1.  **Monitorização de Parâmetros:** Gerar gráficos temporais de todas as grandezas (EAS, QNE, aceleração vertical, parâmetros dos motores esquerdo e direito).
    2.  **Conversão de Unidades:** Converter a aceleração vertical medida para unidades de $g$ ($g_0 = 9.80665 m/s^2$).
    3.  **Algoritmo de Extremos:** Criar um ficheiro apenas com os picos e vales (extremos relativos) da aceleração.
    4.  **Contagem de Ciclos:** Desenvolver e aplicar o algoritmo de contagem de ciclos para os pares de valores $N_1$ e $N_2$ estipulados (ex: ciclos de 2.5g, 4g, etc.).
*   **Tópicos a Investigar:**
    *   Altitudes barométricas (diferenças entre QNE, QNH e QFE).
    *   Fatores de carga vertical em aeronaves (Alpha-Jet).
    *   Algoritmos de contagem para análise de fadiga e monitorização de integridade estrutural.

---

### **Tarefas Partilhadas (Colaboração Final)**
*   **Integração do Relatório:** Consolidar as listagens de programas (código) e as conclusões de cada parte num único documento estruturado.
*   **Revisão Cruzada:** Verificar se os resultados da Pessoa 1 e Pessoa 3 (que usam dados de voo reais) mantêm coerência mútua em termos de cronologia e eventos.
*   **Conclusões Gerais:** Elaborar a análise crítica final sobre o desempenho do sistema EGNOS e o comportamento da aeronave durante os ensaios.
