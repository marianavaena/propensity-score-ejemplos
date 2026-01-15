*******************************************************
* Ejemplo didáctico de Propensity Score
* Autora: Mariana Vaena - marianavaena@gmail.com
* Descripción:
*   - Base ficticia con pacientes tratados / no tratados
*   - Outcome: mortalidad (0/1)
*   - Confusores: edad, sexo, charlson, sofa_total
*   - Se muestran tres usos del PS:
*       1) Ajuste por PS como covariable
*       2) Matching por PS
*       3) IPTW (Inverse Probability of Treatment Weighting)
*******************************************************
version 16
clear all
set more off

*------------------------------------------------------
* 0. Abrir la base de datos
* (ajustar el nombre/ubicación según tu repositorio)
*------------------------------------------------------

import delimited "ubicación del archivo csv", clear

*------------------------------------------------------
* 1. Tabla 1: comparación basal entre tratados y no tratados
*------------------------------------------------------
* El comando table1_mc es de usuario, significa que no viene incorporado con el software. 
* Instrucciones para instalarlo:
* ssc install table1_mc, replace
*
* vars():
*   - contn: continua aproximadamente normal -> media (DE), t-test
*   - conts: continua no normal -> mediana (RIC), rank-sum
*   - cat  : categórica -> n (%), chi2
*
table1_mc, by(tratamiento)                              ///
    vars(edad contn %4.0f \                             ///
         sexo cat \                                    ///
         charlson conts %4.0f \                         ///
         sofa_total conts %4.0f)                        ///
    nospace onecol varlabplus total(before)

* Interpretación (en esta base ficticia):
* - La edad media es ligeramente mayor en el grupo tratado.
* - El charlson y el SOFA muestran mayor carga en tratados.
* - El sexo no está perfectamente balanceado entre grupos.

* Esto implica desequilibrio basal → es necesario ajustar.
 
*------------------------------------------------------
* 2. Modelo crudo (sin ajuste)
*------------------------------------------------------

* Regresión logística simple: mortalidad ~ tratamiento
logistic mortalidad tratamiento

* Interpretación (en esta base ficticia):
* - Este modelo estima el efecto crudo del tratamiento sobre la mortalidad.
* - El OR del tratamiento sobre mortalidad no es significativo.
* - Puede deberse a confusión: si los más graves tienen mas chances de recibir el tratamiento, pero a la vez los mas graves tienen mas mortalidad, puede atenuarse el verdadero efecto del tratamiento sobre la mortalidad


*------------------------------------------------------
* 3. Estimación del Propensity Score
*------------------------------------------------------
* En Stata, el PS suele estimarse con un modelo de regresión logística:
* Pero la variable dependiente del modelo es el tratamiento

* logit tratamiento confundidor1 confundidor2 ...
* predict propensity_score, pr

* Cálculo de PS con nuestras variables confundidoras
logit tratamiento edad sexo charlson sofa_total
predict ps, pr

* Chequeo básico de los valores estimados del PS
summarize ps

* De modo opcional, podemos ver el solapamiento del PS por grupo

twoway (kdensity ps if tratamiento == 1)                 ///
      (kdensity ps if tratamiento == 0),                ///
      legend(order(1 "Tratados" 2 "No tratados"))       ///
	  title("Distribución del propensity score por grupo") 

* Interpretación (en esta base ficticia):
* - Se observa solapamiento aceptable entre grupos.
* - Sin embargo, los tratados tienden a tener valores más altos de PS, consistente con mayor carga de enfermedad.
* - Esto permite aplicar métodos basados en PS.

 
*------------------------------------------------------
* Uso 1: PS como covariable de ajuste
*------------------------------------------------------
* Ajuste del efecto del tratamiento usando el PS en lugar de todas las covariables individuales.
logistic mortalidad tratamiento ps

* Comentario:
* - El PS resume múltiples confusores en una sola variable, lo cual simplifica el modelo.
* - Este enfoque estima un efecto CONDICIONAL (ajustado), no un efecto marginal poblacional.

* Interpretación (en esta base ficticia):
* - Tras ajustar por el PS, el OR del tratamiento cambia notablemente: esto indica que el modelo crudo sufría confusión.
* - En esta base, el tratamiento parece asociado a menor mortalidad después del ajuste, lo cual es consistente con una minimización del sesgo de indicación.


*------------------------------------------------------
* Uso 2: PS matching (emparejamiento)
*------------------------------------------------------
* Para el matching vamos a usar psmatch2 (comando de usuario):
*   ssc install psmatch2, replace
*
* Matching 1:1, sin reemplazo, logit, caliper (0.2)
psmatch2 tratamiento edad sexo charlson sofa_total,      ///
    outcome(mortalidad) logit neighbor(1) caliper(0.2)

* psmatch2 genera una serie de variables auxiliares:
*   _weight: peso de cada observación para análisis posteriores
*   _id    : identificador de la pareja, etc.

gen matched = _weight > 0

* Chequeo rápido: cuántos casos quedaron emparejados
tab matched tratamiento

* Modelo en la muestra emparejada
* (para un ejemplo simple, ignoramos los pesos porque es matching 1:1 sin reemplazo)
logistic mortalidad tratamiento if matched == 1

* Comentario:
* - El matching crea una pseudo-población donde la distribución de confusores debería ser similar entre tratados y no tratados.
* - El estimando típico es el ATT (Average Treatment effect on the Treated).

* Interpretación (en esta base ficticia):
* - En esta base, el OR en la muestra emparejada muestra una reducción en la mortalidad del tratamiento
* - Sin embargo, pierde poder estadístico por reducción de muestra. Esto ocurre porque el matching 1:1 descarta observaciones sin pareja válida


*------------------------------------------------------
* Uso 3: IPTW (Inverse Probability of Treatment Weighting)
*------------------------------------------------------
* Los pesos IPTW clásicos:
*   - Tratados: 1/PS
*   - No tratados: 1/(1-PS)
* Se puede usar también la versión estabilizada; aquí mostramos la clásica.

gen iptw = .
replace iptw = 1/ps       if tratamiento == 1
replace iptw = 1/(1-ps)   if tratamiento == 0

* Chequeo rápido de magnitud de los pesos (para ver extremos)
summarize iptw, detail
* Opcional: podés truncar pesos extremos (por ejemplo al percentil 1 y 99) para evitar inestabilidad numérica en bases reales.

* Comprobar balance después de ponderar
* pbalchk es un comando de usuario:
*   ssc install pbalchk, replace
pbalchk tratamiento edad sexo charlson sofa_total, wt(iptw) graph

* Modelo ponderado por IPTW para estimar un efecto marginal (tipo ATE, Average Treatment Effect)
logistic mortalidad tratamiento [pw = iptw], vce(robust)

* Comentario:
* - Este modelo estima el efecto del tratamiento en una "población sintética" donde la distribución de confusores es similar entre grupos (ATE).
* - El ajuste robusto en la varianza es recomendable al usar pesos.

*Interpretación (en esta base ficticia):
* - Los pesos producen una "pseudo-población" donde la distribución de confusores es equilibrada.
* - Tras IPTW, el balance de las medias estandarizadas de las variables confusoras mejora notablemente.
* - En esta base, el efecto del tratamiento se hace más evidente y estadísticamente significativo.
* - IPTW tiende a conservar mayor n que el matching y estimar el ATE.


*******************************************************
* Fin del ejemplo de Propensity Score

*******************************************************
