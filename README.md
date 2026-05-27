# Notas sobre o trabalho experimental

# Topicos do trabalho

- Resultados obtidos
- Análises
- Conclusões

> [!NOTE]
> Tempos de listar os programas desenvolvidos e utilizados no processamento e análise dos dados
>(vi no relatorio do marafuz q literal punham os programas la, será que podemos só por link do repo do git, por codigo no relatorio fica feio)

### Antena

- Posicao:
  - Latref 38.80572066° N
  - Lonref − 9.19497089° W
  - Alt ref 1282.203° m



### antena?
- modelo : NOVATEL L1/L2 GPSANTENNA MODEL 512 REV
- taxa de amostragem: 1Hz


> [!NOTE]
> Ver o que são coordenadas **WGS84**

## TODO 
Ver **EV – Avaliação da exatidão
de um sistema GNSS – 2025-2026.pdf** contem a metodologia pra tratar os dados, considerando epsilon = 10. 

### A determinar

- erro de posição horizontal: **d**
- erro de posição vertical: **h**
- erros de um sistema GNSS

- comparar resultados de ambos os metodos




> [!NOTE]
> Apresentar coordenadas expressas em metros, m.


| Solução de Navegação | Latitude ($Lat$) | Longitude ($Lon$) | Altitude ($Alt$) |
| :--- | :--- | :--- | :--- |
| **A** | $38.80482050^\circ\text{ N}$ | $-9.19496103^\circ\text{ W}$ | $1284.221\text{ m}$ |
| **B** | $38.80562050^\circ\text{ N}$ | $-9.19497003^\circ\text{ W}$ | $1282.221\text{ m}$ |
| **C** | $38.80572550^\circ\text{ N}$ | $-9.19497203^\circ\text{ W}$ | $1281.321\text{ m}$ |
| **D** | $38.80581050^\circ\text{ N}$ | $-9.19497603^\circ\text{ W}$ | $1280.221\text{ m}$ |

 
### Voo de calibração

- trajetória de referencia: **Total Trimble Control**
> [!NOTE]
> Ver o que é o **Total Trimble Control**
> Ver o que é a solução de navegação **EGNOS**
> Ver o que é o **Pegasus** do **Eurocontrol**

- Avaliar o desempenho do sistema de calibração **EGNOS**, de acordo com os requesitos impostos pelo **ICAO** no documento [Standarts and Recommended Pratices (SARPs)](https://www.icao.int/safety-management/standards-and-recommended-practices-sarps).

- Modos de operação (par aum *Satellite Based Augmentation System* -SBAS)
  - precision approach CATegory I (CAT- I)
  - Approach Procedure with Vertical guidance II (APV-II)
  - Approach Procedure with Vertical guidance I (APV-I)

- Estes modos avaliam-se segundo as seguintes métricas ( ver enunciado):
  - Exatidão (*horizontal  Position Error* - HPE e *vertical Position Error* -  VPE )
  - Integridade (*horizontal protection level* - HPL e *vertical protection level*)
    - ver percentil 99 devem verificar os limites *horizontal Alert Level* - HAL e *vertical Alert Level* - VAL
  - Disponibilidade (ver enunciado)
  - Continuidade (ver enunciado)

#### TODO - com o voo de calibração?
  - Determinar erros HPE e VPE
  - Representar estes erros, limites de protecao e numero de satelites em funcao do tempo (RX_TOM)
  - Determinar paramentros de desempenho
  - Identificar eventos de integridade
  - Determinar o *single-sided magnitude spectrum*
    - Para cadasignal e frequências que há picos significations, determinar correspondentes frequências e amplitudes
    > [!NOTE]
    > Ver o que é o *single-sided magnitude spectrum*

#### TODO dos dados de voo do Alpha-Jet

- Plotar dados mencionados no enunciado
- Converter valores de aceleracao as stated no enunciado pra *g*
- Criar ficheiro de picos de *g*
- Elaboar algoritmo pra contagem de ocorrências de ciclos de aceleracao vertical e implementar para os valores do enunciado, e depois para o ficheiro criado no ponto acima
- Comentar resultados



