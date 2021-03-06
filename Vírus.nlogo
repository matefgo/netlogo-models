turtles-own
  [ infectado?        ;; se TRUE, o turtle está INFECTADO
    imune?      ;; se TRUE, o turtle está IMUNE
    semanas-doente   ;; quanto tempo o turtle está infectado
    idade ]        ;; quantas SEMANAS de idade o turtle possui

globals
[
  %infectado            ;; a porcentagem da população que está INFECTADA
  %imune              ;; a porcentagem da população que está IMUNE
  tempo-de-vida             ;; o tempo médio de vida de um turtle
  numero-filhos    ;; o número médio de filhos que um turtle pode gerar
  capacidade-total    ;; o número total de turtles que podem estar no modelo ao mesmo tempo
]

;; O setup (botão CONFIGURAR) está dividido em 3 subrotinas
to configurar
  clear-all ;; comando padrão para limpar tela
  configurar-constantes
  configurar-turtles
  atualizar-variaveis-globais
  reset-ticks ;; comando padrão para reiniciar o contador de ticks (tempo)
end

;; Nós criamos um número aleatório de turtles sendo 10 destas no estado INFECTADO
;; e eles são distribuidos aleatoriamente.
to configurar-turtles
  set-default-shape turtles "person"
  crt pessoa ;; anteriormente: "people"
    [ setxy random-xcor random-ycor
      set idade random tempo-de-vida
      set semanas-doente 0
      set imune? false
      set size 1.5  ;; define o tamanho de exibição das turtles. 1.5 é mais fácil de visualizar
      ficar-saudavel ]
  ask n-of 10 turtles
    [ ficar-doente ]
end

to ficar-doente ;; procedimento de TURTLE (para torna-se INFECTADO)
  set infectado? true
  set imune? false
  set color red
end

to ficar-saudavel ;; procedimento de TURTLE (para voltar a ser SAUDÁVEL)
  set infectado? false
  set imune? false
  set semanas-doente 0
  set color green
end

to ficar-imune ;; procedimento de TURTLE (para tornar-se IMUNE)
  set infectado? false
  set semanas-doente 0
  set imune? true
  set color gray
end

to configurar-constantes
  set tempo-de-vida 100
  set capacidade-total 750
  set numero-filhos 4
end

to começar
  envelhecer
  mover
  infectar
  recuperar
  reproduzir
  atualizar-variaveis-globais
  tick ;; adianta o tempo em +1
end

to atualizar-variaveis-globais
  if count turtles > 0
  [
    set %infectado (count turtles with [infectado?]) / (count turtles) * 100
    set %imune (count turtles with [imune?]) / (count turtles) * 100
  ]
end

;; Variáveis de contagem das turtles abaixo.
to envelhecer ;; Envelhecer as turtles
  ask turtles
  [
    set idade idade + 1
    if infectado?
      [ set semanas-doente (semanas-doente + 1) ]
    ;; Turtles morrem de velhice assim que suas idades se igualam ao
    ;; tempo médio de vida (fixado em 1500 semanas neste modelo).
    if idade > tempo-de-vida
      [ die ] ;; comando de eliminação de turtle.
  ]
end

;; Turtles se movem aleatoriamente.
to mover
  ask turtles
  [ rt random 100
    lt random 100
    fd 1 ]
end

;; Se uma turtle está doente, esta infecta outras turtles no mesmo espaço (PATCH)
;; Turtles no estado IMUNE não ficam infectadas.
to infectar
  ask turtles with [infectado?]
    [ ask other turtles-here with [ not imune? ] ;; se houverem turtles no mesmo espaço (PATCH), verifica se não estão imunes
        [ if (random-float 100) < Infecciosidade ;; anteriormente: "infectiousness"
            [ ficar-doente ] ] ]
end

;; Assim que uma turtle ficou doente por tempo suficiente,
;; ela ou irá se recuperar (tornando-se imune) ou morrerá.
to recuperar
   ask turtles with [infectado?]
     [ if (random semanas-doente) > (tempo-de-vida * (duração / 100))  ;; Se uma turtle sobreviveu para além da DURAÇÃO da infecção do vírus, então:
         [ ifelse ((random-float 100) < chance-de-recuperação) ;; anteriormente: "chance-recover"
             [ ficar-imune ] ;; irá se recuperar ou morrer.
             [ die ] ] ]
end

;; Se há menos turtles do que a CAPACIDADE TOTAL
;; então turtles estarão aptas a se reproduzirem.
;; A probabilidade de reprodução depende do número médio
;; de filhos que uma turtle pode gerar por vida. Neste modelo são 4 filhos por vida (por exemplo
;; 4 por 100 semanas). Portanto, a chance de uma turtle se reproduzir em qualquer turno é de 0.04,
;; isto se a população estiver abaixo do valor da CAPACIDADE TOTAL definida anteriormente.
to reproduzir
  ask turtles with [not infectado?]
    [ if (count turtles) < capacidade-total
         and (random tempo-de-vida) < numero-filhos
       [ hatch 1
           [ set idade 1
             lt 45 fd 1
             ficar-saudavel ] ] ]
end


; Copyright 1998 Uri Wilensky.
; Veja a aba de informações para copyrgith e licença de uso.
@#$#@#$#@
GRAPHICS-WINDOW
262
10
725
474
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-17
17
-17
17
1
1
1
ticks
30.0

SLIDER
31
172
225
205
Duração
Duração
0.0
99.0
20.0
1.0
1
semanas
HORIZONTAL

SLIDER
31
138
227
171
Chance-de-Recuperação
Chance-de-Recuperação
0.0
99.0
0.0
1.0
1
%
HORIZONTAL

SLIDER
31
104
225
137
Infecciosidade
Infecciosidade
0.0
99.0
99.0
1.0
1
%
HORIZONTAL

BUTTON
53
65
143
100
Configurar
configurar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
129
65
209
101
Começar
começar
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
6
255
258
419
População
Semanas
Pessoas
0.0
52.0
0.0
200.0
true
true
"" ""
PENS
"infectados" 1.0 0 -2674135 true "" "plot count turtles with [infectado?]"
"imunes" 1.0 0 -7500403 true "" "plot count turtles with [imune?]"
"saudáveis" 1.0 0 -10899396 true "" "plot count turtles with [not infectado? and not imune?]"
"total" 1.0 0 -13345367 true "" "plot count turtles"

SLIDER
31
27
225
60
Pessoa
Pessoa
10
300
150.0
1
1
NIL
HORIZONTAL

MONITOR
20
208
95
253
Infectados
%infectado
1
1
11

MONITOR
96
208
170
253
Imunes
%imune
1
1
11

MONITOR
171
208
245
253
Anos
ticks / 52
1
1
11

@#$#@#$#@
## O QUE É?

Esse modelo simula a transmissão e perpetuação de um vírus na população humana.

Biólogos ecológicos sugeriram diversos fatores que influenciam na sobrevivência de um vírus que é transmitido diretamente em uma população. (YORKE, et al. "Seasonality and the requirements for perpetuation and eradication of viruses in populations." Journal of Epidemiology, volume 109, páginas 103-123)

## COMO FUNCIONA?

O modelo é inicializado com 150 pessoas, sendo 10 dessas no estado de "infectado". As pessoas se movem de maneira aleatória pelo mundo em um desses três estados: saudável mas suscetível a infecção (cor verde), doente e capaz de infectar (cor vermelho), saudável e imune (cor cinza). As pessoas podem morrer por causa da infecção ou de idade. Quando a população está muito abaixo do valor "capacidade total" do ambiente (estabelecido em 700 neste modelo), pessoas saudáveis podem se reproduzir gerando descendentes saudáveis.

Algum dos fatores estão listados abaixo com uma explicação de como cada um deles são tratados neste modelo.

### Densidade populacional

A densidade populacional afeta o quão frequente os indivíduos infectados, imunes e vulneráveis entram em contato entre si. Você pode alterar o tamanho da população inicial através do slider PESSOAS.

### Rotatividade populacional

Conforme os indivíduos morrem, alguns que morrem serão infectados, outros serão vulneráveis e por fim alguns serão imunes. Todos os novos indivíduos que nascem, substituindo aqueles que morreram, serão vulneráveis. Pessoas podem morrem por causa do vírus, sendo as chances disso determinadas pelo slider CHANCE DE RECUPERAÇÃO, ou podem morrer por idade. Neste modelo, pessoas morrem por idade quando atingem, aproximadamente, a idade de 27 anos. E taxa de reprodução é constante neste modelo. A cada turno, todo indivíduo saudável tem uma chance de se reproduzir. Essa possibilidade é determinada para que cada pessoa reproduza, em média, 4 vezes se viverem 27 anos.


### Grau de imunidade

Se uma pessoa foi infectada e se recuperou, o quão imune ao vírus ela será? Frequentemente assumimos que a imunidade dura uma vida inteira e pode-se garantir isso, mas em alguns casos, a imunidade se desgasta depois de certo tempo e já não é mais garantida. Apesar disso, neste modelo, a imunidade dura para sempre e é garantida. 


### Infecciosidade (ou Transmissibilidade)

Quão facilmente o vírus se propaga? Alguns vírus os quais somos familiares se espalham facilmente. Alguns se propagam a partir do mínimo contato por vez. Outros (o vírus do HIV, que é resposável pela AIDS, por exemplo) precisam de um contato mais significante, talvez repetidas vezes, antes que o vírus seja transmitido de fato. Neste modelo, a INFECCIOSIDADE do vírus é determinada por um slide. 


### Duração da infecção

Quanto tempo uma pessoa fica infectada antes dela se recuperar ou morrer? Este período de tempo é essencialmente a janela de oportunidade de transmissão do vírus em novos hospedeiros. Neste modelo, a DURAÇÃO DA INFECÇÃO é determinada por um slider.


## COMO USAR

Cada "tick" representa uma semana na escala de tempo deste modelo.

O slider de INFECCIOSIDADE determina quão grande é a chance de ocorrer a transmissão do vírus quando uma pessoa infectada e uma pessoa vulnerável ocupam o mesmo espaço (chamado de PATCH). Por exemplo, quando o slider estiver no valor de 50, o vírus irá se propagar aproximadamente uma vez a cada dois possíveis encontros. 


O slider de DURAÇÃO determina a porcentagem do tempo médio de vida (determinada em 1500 semanas, ou aproximadamente 27 anos, neste modelo) que uma pessoa infectada passa antes da infecção terminar tanto em morte ou em recuperação. Note que embora o valor 0 seja uma possibilidade de valor no slider, esta irá produzir uma infecção de curta duração (aproximadamente 2 semanas), não uma infecção sem duração alguma. 

O slider CHANCE DE RECUPERAÇÃO controla a probabilidade da infecção terminar em recuperação/imunidade. Quando este slider é determinado em 0, por exemplo, a infecção é sempre mortal.

O botão CONFIGURAR reinicia os gráficos e plotagens e randomicamente distribui 140 pessoas vulneráveis (na cor verde) e 10 pessoas infectadas (na cor vermelho) com idades determinadas aleatoriamente. O botão COMEÇAR inicia a simulação e as funções de plotagem.

Existem 3 monitores de saída que mostram a porcentagem da população que está infectada, que está imune, e o número de anos que se passaram. A plotagem mostra (nas suas respectivas cores) o número de vulneráveis, infectados e pessoas imunes. Também mostra o número de indivíduos da população total na cor azul.


## PONTOS PARA OBSERVAÇÃO

Os fatores controlados pelos três sliders interagem para influenciar a probabilidade do vírus se desenvolver naquela população. Note que em todos os casos, esses fatores devem criar um equilíbrio no qual um número adequado de potenciais hospedeiros estejam disponíveis para o vírus e ele consiga acessá-los adequadamente. 

Frequentemente, haverá inicialmente uma explosão de infecções já que ninguém na população está imune e a densidade populacional estará no máximo. Isso se aproxima de um "surto" inicial de uma infecção viral numa população, que muitas vezes traz consequências desvastadoras para os humanos envolvidos. Entretanto, logo o vírus torna-se mais incomum a medida que a dinâmica populacional muda. O que acontece ao vírus é determinado pelos três fatores controlados pelos sliders. 

Note que os vírus que são bem-sucedidos inicialmente (infectando quase todos) podem não sobreviver a longo prazo. Já que todos os infectados geralmente morrem ou tornam-se imunes, o número de potenciais hospedeiros costuma ser limitado. A exceção é quando o slider de DURAÇÃO é definido tão alto que a rotatividade populacional (reprodução) pode acompanhar o ritmo fornecendo sempre novos hospedeiros. 


## COMO EXPLORAR O MODELO

Pense em como os diferentes valores dos sliders podem se aproximar da dinâmica dos vírus na vida real. O famoso vírus da Ebola na África Central tem uma duração curtíssima, um grande grau de infecciosidade, e uma taxa de recuperação extremamente baixa. Por todo medo que esse vírus gerou, quão bem-sucedido ele é? Defina os sliders adequadamente e observe o que acontece na simulação.

O vírus do HIV, que causa AIDS, possui uma duração extremamente longa, uma taxa de recuperação bastante baixa, mas um grau de infecciosidade muitíssimo baixo. Como um vírus com esses valores nos sliders se comporta neste modelo?

## EXPANDINDO O MODELO

Adicione sliders extras que controlem a CAPACIDADE TOTAL do mundo (a quantidade de pessoas que podem estar no modelo ao mesmo tempo) e o TEMPO DE VIDA MÉDIO das pessoas.

Construa um modelo similar que simule infecções virais em hospedeiros não-humanos com taxas de reprodução, tempo de vida e densidades populacionais bem diferentes.

Adicione um slider controlando quanto tempo a IMUNIDADE dura, para que assim a imunidade não seja perfeita ou eterna.


## MODELOS RELACIONADOS

* AIDS
* "Virus on a Network" (Vírus numa rede)


## CITAÇÃO

Se você mencionar este modelo numa publicação, solicitamos que você inclua essas citações para o prórpio modelo e o software Netlogo:

* Wilensky, U. (1998).  NetLogo Virus model.  http://ccl.northwestern.edu/netlogo/models/Virus.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

## COPYRIGHT E LICENÇA DE USO

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
