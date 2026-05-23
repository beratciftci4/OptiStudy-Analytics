#  OptiStudy Analytics

OptiStudy Analytics is a comprehensive, production-ready SaaS-style web application developed in **R** using the **Shiny Dashboard** ecosystem. It transitions typical student exam tracking from static ledger scoring into an advanced psychometric and predictive data analytics engine designed for high-stakes exam preparation (YKS).

------------

##  Key Structural Innovations

### 1. Noise Filtering via Difficulty Calibration
Raw scores in standardized testing are highly volatile due to fluctuating weekly exam difficulties. OptiStudy implements a **Difficulty Normalization Algorithm** ($0.92 \times$ to $1.16 \times$) mapped dynamically from user-selected exam tiers. This eliminates metric noise, stabilizes variance, and isolates the student's **True Ability Score**.

### 2. Psychometric Persona Modeling (Persona Engine)
Leveraging test-behavior metrics, the application evaluates student exam behavior across three statistical vectors: **Risk Index** ($\frac{\text{Incorrect}}{\text{Correct}}$) and **Satiation Ratio** ($\frac{\text{Blanks}}{\text{Total}}$). The rule-based engine categorizes the student into 1 of 4 core exam personas (e.g., *🛡️ Over-Cautious Analyst*, *⚔️ Aggressive Risk-Taker*) providing actionable tactical intervention.

### 3. OLS Linear Regression Forecasting Simulator
Built-in predictive forecasting utilizes **Ordinary Least Squares (OLS) Linear Regression** to model learning momentum over time. Projecting out across a standard 50-exam macrocycle, the application displays a baseline future score backed by a **95% Statistical Confidence Interval Band** to account for situational variance.

------------

##  Tech Stack & Architecture

* **Language:** R (v4.4+)
* **Framework:** Shiny, Shinydashboard
* **Data Wrangling:** Tidyverse (dplyr, purrr, tidyr)
* **Visualization:** ggplot2 (Time-series smoothing, custom themes)
* **File Ingestion:** openxlsx (Seamless client-side RAM caching without permanent server logs)

------------

## 🔮 Future Roadmap

* **AYT Integration & Cross-Exam Corelation Matrix:** The current engine is optimized specifically for TYT macro-cycles. The next major release will integrate AYT (Advanced Proficiency Test) metrics. This will allow the engine to compute a cross-exam correlation matrix, analyzing how score variance in core TYT subjects (e.g., Core Math) predictive-models the student's AYT performance thresholds.

------------

##  Deployment & Local Execution

To run this platform locally, execute the following commands in your R environment:

```R
# Install required dependencies
install.packages(c("shiny", "shinydashboard", "tidyverse", "scales", "openxlsx"))

# Ingest and execute the application
shiny::runApp("path_to_your_project/app.R")
