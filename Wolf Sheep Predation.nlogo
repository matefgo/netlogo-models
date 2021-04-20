globals [ max-ovelhas ]  ; Não permite que a população de ovelhas cresça demais.

; Ovelhas e Lobos são espécies de turtles
breed [ ovelhas ovelha ]  ; não confundir o nome da RAÇA (no plural) com o nome do turtle (no singular)
breed [ lobos lobo ]

turtles-own [ energia ]       ; tanto ovelhas como lobos possuem energia

patches-own [ contagem-regressiva ]    ; this is for the sheep-wolves-grass model version

to configurar
  clear-all ; limpa a tela
  ifelse netlogo-web? [ set max-ovelhas 10000 ] [ set max-ovelhas 30000 ]

  ; Checar a versão do modelo selecionada
  ; se não houver modelagem de grama, então as ovelhas não precisam comer para sobreviver
  ; caso contrário, o estado e a lógica de crescimento de cada grama precisa ser configurada
  ifelse model-version = "ovelhas-lobos-grama" [
    ask patches [
      set pcolor one-of [ green brown ]
      ifelse pcolor = green
        [ set contagem-regressiva tempo-crescimento-grama ]
      [ set contagem-regressiva random tempo-crescimento-grama ] ; inicializa os tempos de recrescimento da grama, de maneira aleatória, para os espaços marrons
    ]
  ]
  [
    ask patches [ set pcolor green ]
  ]

  criar-ovelhas numero-inicial-ovelhas ; cria e então inicializa as suas variáveis
  [
    set shape  "sheep"
    set color white
    set size 1.5  ; o tamanho 1.5 facilita a visualização
    set label-color blue - 2
    set energia random (2 * ganho-energia-ovelha)
    setxy random-xcor random-ycor
  ]

  criar-lobos numero-inicial-lobos ; cria lobos e então inicializa as suas variáveis
  [
    set shape "wolf"
    set color black
    set size 2  ; o tamanho 2 facilita a visualização
    set energia random (2 * ganho-energia-lobo)
    setxy random-xcor random-ycor
  ]
  mostrar-indicadores
  reset-ticks
end

to começar
  ; para a simulação caso não hajam lobos ou ovelhas no modelo
  if not any? turtles [ stop ]
  ; para a simulação caso não hajam lobos e o número de ovelhas seja muito grande
  if not any? lobos and count ovelhas > max-ovelhas [ user-message "As ovelhas dominaram a terra." stop ]
  ask ovelhas [
    mover

    ; nesta versão, as ovelhas comem grama, grama cresce e as ovelhas gastam energia para se moverem
    if model-version = "ovelhas-lobos-grama" [
      set energia energia - 1  ; diminui a energia de ovelhas apenas na versão do modelo com grama
      comer-grama  ; ovelhas comem grama apenas na versão do modelo com grama 
      morrer ; ovelhas morrem de fome apenas na versão do modelo com grama 
    ]

    reproduzir-ovelhas  ; ovelhas se reproduzem numa taxa aleatória definida pelo slider
  ]
  ask lobos [
    mover
    set energia energia - 1  ; lobos perdem energia quando se movem 
    comer-ovelha ; lobos comem uma ovelhas que estejam no mesmo PATCH 
    morrer ; lobos morrem se ficarem sem energia
    reproduzir-lobos ; lobos se reproduzem numa taxa aleatória definida pelo slider
  ]

  if model-version = "ovelhas-lobos-grama" [ ask patches [ crescer-grama ] ]

  tick
  display-labels
end

to mover  ; procedimento de TURTLE 
  rt random 50
  lt random 50
  fd 1
end

to comer-grama  ; procedimento de OVELHA
  ; ovelhas comem grama e mudam a cor do PATCH para marrom
  if pcolor = green [
    set pcolor brown
    set energia energia + ganho-energia-ovelha  ; ovelhas ganham energia se alimentando de grama
  ]
end

to reproduzir-ovelhas  ; procedimento de OVELHA
  if random-float 100 < reprodução-ovelhas [  ; realiza um sorteio para verificar se haverá reprodução
    set energia (energia / 2)                 ; divide a energia entre o pai e o filho gerado
    hatch 1 [ rt random-float 360 fd 1 ]      ; gera um filho e o move 1 passo para frente
  ]
end

to reproduzir-lobos  ; procedimento de LOBO
  if random-float 100 < reprodução-lobos [  ; realiza um sorteio para verificar se haverá reprodução
    set energia (energia / 2)               ; divide a energia entre o pai e o filho gerado
    hatch 1 [ rt random-float 360 fd 1 ]    ; gera um filho e o move 1 passo para frente
  ]
end

to comer-ovelha  ; procedimento de LOBO
  let prey one-of ovelhas-here                  ; seleciona uma ovelha aleatória
  if prey != nobody  [                          ; verifica se houve uma captura. caso sim,
    ask prey [ die ]                            ; elimina a ovelha e...
    set energia energia + ganho-energia-lobo    ; recebe energia se alimentando
  ]
end

to morrer  ; procedimento de TURTLE (ou seja, procedimento tanto de LOBO quanto de OVELHA)
  ; quando a energia fica abaixo de zero, a turtle é eliminada.
  if energia < 0 [ die ]
end

to crescer-grama  ; procedimento de PATCH
  ; contagem regressiva para PATCHES marrons: quando chegar a 0, a grama cresce
  if pcolor = brown [
    ifelse contagem-regressiva <= 0
      [ set pcolor green
        set contagem-regressiva tempo-crescimento-grama ]
      [ set contagem-regressiva contagem-regressiva - 1 ]
  ]
end

to-report grama
  ifelse model-version = "ovelhas-lobos-grama" [
    report patches with [pcolor = green]
  ]
  [ report 0 ]
end


to mostrar-indicadores
  ask turtles [ set label "" ]
  if mostrar-energia? [
    ask lobos [ set label round energia ]
    if model-version = "ovelhas-lobos-grama" [ ask ovelhas [ set label round energia ] ]
  ]
end


; Copyright 1997 Uri Wilensky.
; Veja a aba de Informação para informações de copyright e licença.
@#$#@#$#@
GRAPHICS-WINDOW
355
10
865
520
-1
-1
10
1
14
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30

SLIDER
5
60
179
93
numero-inicial-ovelhas
numero-inicial-ovelhas
0
250
100
1
1
NIL
HORIZONTAL

SLIDER
5
196
179
229
ganho-energia-ovelhas
ganho-energia-ovelhas
0.0
50.0
4
1.0
1
NIL
HORIZONTAL

SLIDER
5
231
179
264
reprodução-ovelhas
reprodução-ovelhas
1.0
20.0
4
1.0
1
%
HORIZONTAL

SLIDER
185
60
350
93
numero-inicial-lobos
numero-inicial-lobos
0
250
50
1
1
NIL
HORIZONTAL

SLIDER
183
195
348
228
ganho-energia-lobos
ganho-energia-lobos
0.0
100.0
20
1.0
1
NIL
HORIZONTAL

SLIDER
183
231
348
264
reprodução-lobos
reprodução-lobos
0.0
20.0
5
1.0
1
%
HORIZONTAL

SLIDER
40
100
252
133
tempo-crescimento-grama
tempo-crescimento-grama
0
100
30
1
1
NIL
HORIZONTAL

BUTTON
40
140
109
173
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
115
140
190
173
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
0

PLOT
10
360
350
530
Populações
Tempo
Pop.
0
100
0
100
true
true
"" ""
PENS
"ovelhas" 1 0 -612749 true "" "plot count ovelhas"
"lobos" 1 0 -16449023 true "" "plot count lobos"
"grama / 4" 1 0 -10899396 true "" "if model-version = \"ovelhas-lobos-grama\" [ plot count grama / 4 ]"

MONITOR
41
308
111
353
ovelhas
count ovelhas
3
1
11

MONITOR
115
308
185
353
lobos
count lobos
3
1
11

MONITOR
191
308
256
353
grama
count grama / 4
0
1
11

TEXTBOX
20
178
160
196
Ovelhas settings
11
0
0

TEXTBOX
198
176
311
194
Lobos settings
11
0
0

SWITCH
105
270
241
303
mostrar-energia?
mostrar-energia?
1
1
-1000

CHOOSER
5
10
350
55
versão-modelo
versão-modelo
"ovelhas-lobos" "ovelhas-lobos-grama"
0
@#$#@#$#@
## O QUE É?

Este modelo explora a estabiladade de ecossistemas predador-presa. Esse sistema é chamado de instável se tende a resultar na extinção de uma ou mais espécies envolvidas. Do contrário, um sistema assim é chamado de estável se tende a se manter durante o tempo, apesar das flutuações no tamanho das populações envolvidas.

## COMO FUNCIONA?

Existem duas principais variações para este modelo.

Na primeira variação, a versão "ovelhas-lobos", lobos e ovelhas vagam de maneira aleatória pelo ambiente, enquanto os lobos caçam as ovelhas. Cada passo dado pelos lobos custa energia e eles precisam comer as ovelhas para repor o que gastaram - quando eles ficam sem energia, eles morrem.

Na segunda variação, a versão "ovelhas-lobos-grama" modela explicitamente a grama (cor verde) além dos lobos e ovelhas. O comportamento dos lobos é idêntico a primeira variação mostrada, contudo, desta vez as ovelhas precisam comer grama para manter suas energias - caso zerem sua energia, elas morrem. Quando a grama é comida, ela só irá crescer novamente após um tempo fixado. Esta variação é mais complexa do que a primeira, mas é geralmente estável. Também se assemelha bastante aos clássicos modelos de oscilação de população da Lotka Volterra. Os modelos clássicos LV, no entanto, assumem que as populações podem assumir valores reais, mas em populações pequenas esses modelos subestimam extinções. Modelos baseados em agentes, como esse, fornecem resultados mais realistas. (Veja Wilenky & Rand, 2015; capítulo 4)

A construção deste modelo é descrita em dois papers por Wilensky & Reisman (1998; 2006) refenciado abaixo.

## COMO USAR
                                                                            
1. Escolha a versão do modelo "ovelhas-lobos-grama" para incluir a alimentação e crescimento da grama, ou "ovelhas-lobos" para incluir apenas lobos (pretos) e ovelhas (brancos).                                                                            
2. Ajuste os parâmetros nos sliders (veja abaixo) ou use as configurações padrão.
3. Pressione o botão CONFIGURAR.                                                                          
4. Pressione o botão COMEÇAR para começar a simulação.                                                                          
5. Verifique os monitores para ver os tamanhos atuais das populações.                                                                           
6. Verifique o monitor POPULAÇÃO para ver as populações flutuarem com o tempo.                                                                           
                                                                            
Parâmetros:
VERSÃO-MODELO: se será modelado ovelhas, lobos e grama ou apenas ovelhas e lobos.                                                                            
NUMERO-INICIAL-OVELHAS: o tamanho inicial da população de OVELHAS. 
NUMERO-INICIAL-LOBOS: o tamanho inicial da população de LOBOS.
GANHO-ENERGIA-OVELHA: a quantidade de energia que as ovelhas conseguem para cada PATCH de grama comido (Note que este não é usado na versão do modelo "ovelhas-lobos") 
GANHO-ENERGIA-LOBO: a quantidade de energia que os lobos conseguem para cada ovelha comida.
REPRODUÇÃO-OVELHAS: a probabilidade de uma ovelha se reproduzir a cada passo de tempo.     
REPRODUÇÃO-LOBOS: a probabilidade de um lobo se reproduzir a cada passo de tempo.                                                                                 
TEMPO-CRESCIMENTO-GRAMA: quanto tempo leva para a grama crescer novamente depois que foi comida (Note que este não é usado na versão do modelo "ovelhas-lobos")
MOSTRAR-ENERGIA?: mostrar ou não a energia de cada animal como um número                                                                            
                                                                   
Notas:
- uma unidade de energia é deduzida para cada passo dado por um lobo                                                                            
- quando executando a versão do modelo ovelhas-lobos-grama, uma unidade de energia é deduzida para cada passo dado por uma ovelha                                                                            

Existem três monitores para mostrar as populações de lobos, ovelhas e grama e um gráfico de populações para mostrar os valores da população ao longo do tempo.

Se não restarem lobos e houver muitas ovelhas, a execução do modelo é interrompida.

## PONTOS PARA OBSERVAÇÃO

Ao executar a versão "ovelhas-lobos", observe como as populações de ovelhas e lobos flutuam. Observe que os aumentos e diminuições nos tamanhos de cada população estão relacionados. De que maneira eles estão relacionados? O que acontece eventualmente?

Na versão "ovelhas-lobos-grama" do modelo, perceba a linha verde adicionada ao gráfico de população representando as flutuações na quantidade de grama. Como os tamanhos das três populações parecem se relacionar agora? Qual é a explicação para isto?

Por que você supõe que algumas variações do modelo podem ser estáveis enquanto que outras não?

## EXPLORANDO O MODELO

Tente ajustar os parâmetros com várias configurações. Verifique o quão sensível é a estabilidade do modelo em relação a um determinado parâmetro.                                                                            

Você consegue encontrar algum parâmetro que gere um ecossistema estável na versão "ovelhas-lobos" do modelo?  

Tente executar a versão do modelo "ovelhas-lobos-grama", mas definindo o NUMERO-INICIAL-LOBOS como 0. Isto dá um ecossistema estável com apenas ovelhas e grama. Por que isso seria estável enquanto que a variação com apenas ovelhas e lobos não é?

Observe que sob configurações estáveis, as populações tendem a flutuar em um ritmo previsível. Você consegue identificar algum parâmetro que irá acelerar ou desacelerar esse ritmo?

## EXPANDINDO O MODELO

Existem várias maneiras de alterar o modelo para que ele fique estável apenas com lobos e ovelhas (sem grama). Alguns exigirão que novos elementos sejam codificados ou que comportamentos existentes sejam modificados. Você consegue desenvolver essa versão?                                                                             
 
Tente modificar as regras de reprodução -- por exemplo, o que aconteceria se a reprodução dependesse da energia ao invés de ser determinada por uma probabilidade fixa?

Você consegue modificar o modelo para que as ovelhas se agrupem?   
                                                                            
Você consegue modificar o modelo para que os lobos persigam as ovelhas de maneira ativa?                                                                            

## RECURSOS DO NETLOGO
                                                                            
Note o uso de RAÇAS para modelos dois tipos diferentes de "turtles": lobos e ovelhas. Note o uso de PATCHES para modelagem da grama.                                                                            
                                                                                                                                                       
Note o uso do ONE-OF agenteset reporter para selecionar uma ovelha aleatória para ser comida por um lobo.                                                                           

## MODELOS RELACIONADOS

Procure por "Rabbits Grass Weeds" (coelhos grama ervas-daninhas) para outro modelo com interação de populações com diferentes regras.

## CRÉDITOS E REFERÊNCIAS

Wilensky, U. & Reisman, K. (1998). Connected Science: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. International Journal of Complex Systems, M. 234, pp. 1 - 12. (The Wolf-Sheep-Predation model is a slightly extended version of the model described in the paper.)

Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209. http://ccl.northwestern.edu/papers/wolfsheep.pdf .

Wilensky, U., & Rand, W. (2015). An introduction to agent-based modeling: Modeling natural, social and engineered complex systems with NetLogo. Cambridge, MA: MIT Press.

Lotka, A. J. (1925). Elements of physical biology. New York: Dover.

Volterra, V. (1926, October 16). Fluctuations in the abundance of a species considered mathematically. Nature, 118, 558–560.

Gause, G. F. (1934). The struggle for existence. Baltimore: Williams & Wilkins.

## COMO CITAR

Se você mencionar este modelo ou o software NetLogo numa publicação, solicitamos que você inclua essas citações abaixo:                                                                            
                                                                            
Para o próprio modelo:

* Wilensky, U. (1997).  NetLogo Wolf Sheep Predation model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Por favor, cite o software Netlogo como:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT E LICENÇA DE USO 

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2000.

<!-- 1997 2000 -->
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

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
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
