# 🎯 Ejemplo Didáctico de Propensity Score  
**Autora:** Mariana Vaena  
📧 *marianavaena@gmail.com*

Hola a todos!

Este repositorio acompaña un artículo de revisión sobre métodos basados en **Propensity Score (PS)** e incluye una base ficticia y scripts completos en **Stata** y **R** para mostrar de manera didáctica cómo funcionan las principales estrategias de ajuste en estudios observacionales.

El objetivo es ofrecer un recurso **claro, accesible y reproducible** para estudiantes e investigadores interesados en estos análisis.

---

## 📂 Contenido del repositorio

### 🧪 `prueba.csv`
Base de datos **ficticia** que se utiliza en todos los ejemplos.  
Incluye las siguientes variables:

-  `tratamiento` (0/1)  
-  `mortalidad` (0/1)  
-  `edad`  
-  `sexo`  
-  `charlson`  
-  `sofa_total`
---

### 📘 `propensity_score_ejemplo_DO.do`
Script de **Stata** completamente comentado, con:

- 📊 Tabla 1 (`table1_mc`)  
- 🧮 Modelo crudo  
- 🎯 Estimación del PS  
- 🔧 Ajuste por PS como covariable  
- 🤝 Matching 1:1 con `psmatch2`  
- ⚖️ IPTW clásico (1/PS y 1/(1−PS))  
- ✔️ Evaluación de balance con `pbalchk`  
- 🔎 Interpretación paso a paso

---

### 📗 `propensity_score_ejemplo_RMD.Rmd`
Documento **RMarkdown** reproducible con:

- Tabla 1 (`tableone`)  
- Estimación del PS (`glm`)  
- Matching (`MatchIt`)  
- Love plots y tablas de balance (`cobalt`)  
- IPTW (`survey`)  
- OR e intervalos de confianza (`broom`)  
- Interpretaciones claras en cada sección  
---

### 🌐 `propensity_score_ejemplo_HTML.html`
Versión **renderizada** del RMarkdown, lista para leer sin ejecutar código.  

---

## 🎓 Métodos ilustrados

Este repositorio cubre las tres estrategias principales basadas en Propensity Score:

### 1️⃣ PS como covariable  
- Simplifica el ajuste multivariable.  
- Proporciona un **efecto condicional**.

### 2️⃣ Matching por PS (1:1)  
- Crea pares comparables entre tratados y controles.  
- Estima **ATT** (Average Treatment effect on the Treated).  
- Mejora el balance pero reduce tamaño muestral.

### 3️⃣ IPTW  
- Genera una *pseudo-población* con covariables balanceadas.  
- Estima **ATE** (Average Treatment Effect).  
- Mantiene mayor tamaño muestral que el matching.

---

## 🌱 Propósito del repositorio

Este material busca:

- **enseñar** el uso correcto del Propensity Score,  
- **comparar** las distintas estrategias de ajuste,  
- **visibilizar** el impacto del balance en las estimaciones,  
- **promover** prácticas analíticas transparentes y reproducibles.

---

## 🤝 Licencia

Puede utilizarse libremente con fines docentes y de investigación.  
Se agradece citar a la autora.

---

## 📬 Contacto

**Mariana Vaena**  
📧 *marianavaena@gmail.com*

¡Gracias por visitar este repositorio! 🌟
