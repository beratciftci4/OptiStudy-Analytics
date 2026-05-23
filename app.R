# ==============================================================================
# Project: OptiStudy Analytics - YKS Performance Tracking System
# Author: Berat
# Stack: R, Shiny, Shinydashboard, Tidyverse (ggplot2, dplyr)
# Version: 1.1.0 (Production Layout Optimized)
# ==============================================================================

library(shiny)
library(shinydashboard)
library(tidyverse)
library(scales)
library(openxlsx)

# --- USER INTERFACE (UI) ---
ui <- dashboardPage(
  skin = "purple",
  
  # Title and sidebar layout structural synchronization (Width expanded to 290px)
  dashboardHeader(title = "OptiStudy Analytics", titleWidth = 290),
  
  dashboardSidebar(
    width = 290,
    sidebarMenu(
      menuItem("Performans Merkezi", tabName = "dashboard", icon = icon("chart-line")),
      
      div(style = "padding: 20px; color: white;",
          h4(style = "font-weight: bold; border-bottom: 1px solid #5d5370; padding-bottom: 5px;", "📁 Veri Tabanı"),
          fileInput("excel_file", "Excel Dosyasını Yükleyin:", accept = c(".xlsx")),
          
          br(),
          h4(style = "font-weight: bold; border-bottom: 1px solid #5d5370; padding-bottom: 5px;", "➕ Yeni Deneme"),
          textInput("yayin_adi", "Yayın Adı:", placeholder = "Örn: 3D, Bilgi Sarmal"),
          selectInput("zorluk_seviyesi", "Sınav Zorluk Seviyesi:", 
                      choices = c("Kolay", "Orta", "Zor", "Çok Zor"), selected = "Orta"),
          
          h5(style="font-weight:bold; color:#a29bfe;", "📚 Türkçe"),
          fluidRow(
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("tr_d", "D:", 30, min=0, max=40)),
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("tr_y", "Y:", 5, min=0, max=40))
          ),
          
          h5(style="font-weight:bold; color:#55efc4;", "📐 Matematik"),
          fluidRow(
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("mat_d", "D:", 20, min=0, max=40)),
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("mat_y", "Y:", 3, min=0, max=40))
          ),
          
          h5(style="font-weight:bold; color:#ffeaa7;", "🌍 Sosyal"),
          fluidRow(
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("sos_d", "D:", 12, min=0, max=20)),
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("sos_y", "Y:", 4, min=0, max=20))
          ),
          
          h5(style="font-weight:bold; color:#ff7675;", "🧪 Fen Bilimleri"),
          fluidRow(
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("fen_d", "D:", 10, min=0, max=20)),
            column(6, style="padding-right: 5px; padding-left: 5px;", numericInput("fen_y", "Y:", 4, min=0, max=20))
          ),
          
          br(),
          actionButton("save_btn", "Hafızaya İşle", class = "btn-success", style="width: 100%; font-weight:bold;"),
          br(), br(),
          div(style="border-top: 1px solid #5d5370; padding-top: 15px;",
              downloadButton("download_excel", "Güncel Excel'i İndir", class = "btn-info", style="width: 100%; font-weight:bold;")
          )
      )
    )
  ),
  
  dashboardBody(
    # Custom CSS configuration for enterprise-level layout polish
    tags$head(tags$style(HTML("
      .content-wrapper { background-color: #f4f6f9 !important; }
      .box { border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      .nav-tabs-custom > .nav-tabs > li.active { border-top-color: #605ca8 !important; }
      .info-box-text { font-weight: bold !important; }
      /* Fixing standard shiny numeric input margins inside nested sidebars */
      .form-group { margin-bottom: 10px !important; }
    "))),
    
    tabItems(
      tabItem(tabName = "dashboard",
              
              uiOutput("welcome_ui"),
              
              conditionalPanel(
                condition = "output.file_uploaded == true",
                
                fluidRow(
                  valueBoxOutput("box_son_net", width = 4),
                  valueBoxOutput("box_kalibre_net", width = 4),
                  valueBoxOutput("box_ort_net", width = 4)
                ),
                
                fluidRow(
                  box(title = "🤔 Grafik Okuma Kılavuzu: Ham Net vs. Gerçek Trend", status = "warning", solidHeader = TRUE, width = 12,
                      p(HTML("YKS hazırlık sürecinde sınavların zorluk dereceleri her hafta değişkenlik gösterir. Sadece ham net sayısına odaklanmak, gelişim eğrisini görmeyi engeller. <b>OptiStudy</b> veri motoru bu gürültüyü filtreler:")),
                      tags$ul(
                        tags$li(HTML("<b style='color:#E63946;'>🔴 Kırmızı Kesikli Çizgi (Ham Net):</b> Sınavda elde edilen yalın net sayısıdır. Sınavın zorluğundan doğrudan etkilenir.")),
                        tags$li(HTML("<b style='color:#2A9D8F;'>🟢 Yeşil Düz Çizgi (Zorluk Kalibreli Net):</b> Sınavın zorluk dalgalanmaları elenmiş, <b>saf akademik potansiyeli (True Ability)</b> gösteren ana trenddir."))
                      ),
                      br(),
                      p(HTML("💡 <b>Grafikteki Kesişimlerin Anlamı:</b>")),
                      fluidRow(
                        column(6, div(style="background-color:#F7FFF7; padding:15px; border-left:5px solid #2A9D8F; border-radius:6px; margin-bottom:10px;",
                                      HTML("<b style='color:#2A9D8F;'>🟢 Yeşil Çizgi Üstteyse (Zor Sınav):</b><br>Giriş yapılan sınav Türkiye ölçeğinde yüksek zorluktadır. Ham net düşük görünse dahi motivasyon kaybı yaşanmamalıdır; çünkü zorluk filtresi kalktığında gerçek potansiyel yeşil çizginin işaret ettiği seviyedomir."))),
                        column(6, div(style="background-color:#FFF7F7; padding:15px; border-left:5px solid #E63946; border-radius:6px; margin-bottom:10px;",
                                      HTML("<b style='color:#E63946;'>🔴 Kırmızı Çizgi Üstteyse (Kolay Sınav):</b><br>İlgili sınav standartların altında bir kolaylığa sahiptir. Netlerin yüksek çıkması rehavete yol açmamalıdır; rasyonel durum yeşil çizgi hizasındadır.")))
                      )
                  )
                ),
                
                fluidRow(
                  box(title = "YKS Performans Eğrisi (Zorluk Filtreli Sürekli Analiz)", 
                      status = "primary", solidHeader = TRUE, width = 12,
                      plotOutput("trend_plot", height = "350px"))
                ),
                
                fluidRow(
                  box(title = "📊 Son Performansın Genel Ortalamalarla Karşılaştırılması", 
                      status = "info", solidHeader = TRUE, width = 12,
                      uiOutput("comparison_ui"))
                ),
                
                fluidRow(
                  box(title = "🔮 2027 YKS Projeksiyon Simülatörü", status = "success", solidHeader = TRUE, width = 6,
                      uiOutput("simulator_ui")),
                  box(title = "🧠 Gelişmiş Taktiksel Sınav Personası Modellemesi", status = "danger", solidHeader = TRUE, width = 6,
                      uiOutput("character_ui"))
                ),
                
                fluidRow(
                  box(title = "📚 Türkçe Analitik Strateji Raporu", status = "info", solidHeader = TRUE, width = 6, uiOutput("report_tr")),
                  box(title = "📐 Matematik Analitik Strateji Raporu", status = "success", solidHeader = TRUE, width = 6, uiOutput("report_mat"))
                ),
                fluidRow(
                  box(title = "🌍 Sosyal Bilimler Analitik Strateji Raporu", status = "warning", solidHeader = TRUE, width = 6, uiOutput("report_sos")),
                  box(title = "🧪 Fen Bilimleri Analitik Strateji Raporu", status = "danger", solidHeader = TRUE, width = 6, uiOutput("report_fen"))
                ),
                
                fluidRow(
                  box(title = "📋 Tüm Deneme Verileri (OptiStudy Analitik Veri Matrisi)", status = "info", 
                      solidHeader = TRUE, width = 12, tableOutput("raw_table"))
                )
              )
      )
    )
  )
)

# --- SERVER ENGINE ---
server <- function(input, output, session) {
  
  # Reactive core data store
  vals <- reactiveValues(df = NULL)
  
  # Flag for conditional panel routing
  output$file_uploaded <- reactive({
    return(!is.null(vals$df) && nrow(vals$df) > 0)
  })
  outputOptions(output, "file_uploaded", suspendWhenHidden = FALSE)
  
  # Initial placeholder screen configuration
  output$welcome_ui <- renderUI({
    if (is.null(vals$df) || nrow(vals$df) == 0) {
      box(title = "👋 OptiStudy Analitik Platformuna Hoş Geldiniz!", status = "info", solidHeader = TRUE, width = 12,
          p("Sistemin çalışabilmesi için deneme sonuçlarınızın olduğu Excel dosyasını sol panelden yüklemeniz gerekmektedir."),
          p("Uygulama tamamen tarayıcı tabanlı (RAM üzerinde) çalışır, verileriniz hiçbir sunucuya kaydedilmez."))
    }
  })
  
  # Pipeline: File ingestion and transformation schema
  observeEvent(input$excel_file, {
    req(input$excel_file)
    tryCatch({
      data <- read.xlsx(input$excel_file$datapath, sheet = 1, na.strings = c("", "NA", "*"))
      colnames(data)[1] <- "deneme_id"
      if(!"zorluk_seviyesi" %in% colnames(data)) data$zorluk_seviyesi <- "Orta"
      
      # Enforce explicit data types across data frames
      data <- data %>% mutate(
        deneme_id = as.numeric(deneme_id), yayin_adi = as.character(yayin_adi),
        zorluk_seviyesi = as.character(zorluk_seviyesi),
        turkce_d = as.numeric(turkce_d), turkce_y = as.numeric(turkce_y), turkce_b = as.numeric(turkce_b), turkce_net = as.numeric(turkce_net),
        mat_d = as.numeric(mat_d), mat_y = as.numeric(mat_y), mat_b = as.numeric(mat_b), mat_net = as.numeric(mat_net),
        sosyal_d = as.numeric(sosyal_d), sosyal_y = as.numeric(sosyal_y), sosyal_b = as.numeric(sosyal_b), sosyal_net = as.numeric(sosyal_net),
        fen_d = as.numeric(fen_d), fen_y = as.numeric(fen_y), fen_b = as.numeric(fen_b), fen_net = as.numeric(fen_net),
        toplam_net = as.numeric(toplam_net)
      ) %>% filter(!is.na(yayin_adi) & !is.na(toplam_net))
      
      # Scale weights for scientific difficulty normalization
      data <- data %>% mutate(
        zorluk_katsayisi = case_when(
          zorluk_seviyesi == "Kolay"   ~ 0.92,
          zorluk_seviyesi == "Orta"    ~ 1.00,
          zorluk_seviyesi == "Zor"     ~ 1.08,
          zorluk_seviyesi == "Çok Zor" ~ 1.16,
          TRUE ~ 1.00
        ),
        kalibre_net = toplam_net * zorluk_katsayisi
      )
      vals$df <- data
      showNotification("Excel veri matrisi başarıyla entegre edildi!", type = "message")
    }, error = function(e) {
      showNotification("HATA: Yüklenen dosya şablona uygun değil!", type = "error")
    })
  })
  
  # Transaction Pipeline: Input validation & raw calculations
  observeEvent(input$save_btn, {
    if(is.null(vals$df)) { showNotification("HATA: Önce bir Excel dosyası yüklemelisiniz!", type = "error"); return() }
    if ((input$tr_d + input$tr_y) > 40) { showNotification("HATA: Türkçe Doğru/Yanlış toplamı 40'ı geçemez!", type = "error"); return() }
    if ((input$mat_d + input$mat_y) > 40) { showNotification("HATA: Matematik Doğru/Yanlış toplamı 40'ı geçemez!", type = "error"); return() }
    if ((input$sos_d + input$sos_y) > 20) { showNotification("HATA: Sosyal Doğru/Yanlış toplamı 20'yi geçemez!", type = "error"); return() }
    if ((input$fen_d + input$fen_y) > 20) { showNotification("HATA: Fen Doğru/Yanlış toplamı 20'yi geçemez!", type = "error"); return() }
    
    t_b <- 40 - input$tr_d - input$tr_y
    m_b <- 40 - input$mat_d - input$mat_y
    s_b <- 20 - input$sos_d - input$sos_y
    f_b <- 20 - input$fen_d - input$fen_y
    
    t_net <- input$tr_d - (input$tr_y * 0.25)
    m_net <- input$mat_d - (input$mat_y * 0.25)
    s_net <- input$sos_d - (input$sos_y * 0.25)
    f_net <- input$fen_d - (input$fen_y * 0.25)
    top_net <- t_net + m_net + s_net + f_net
    
    new_id <- max(vals$df$deneme_id, na.rm=TRUE) + 1
    
    new_row <- data.frame(
      deneme_id = as.numeric(new_id), yayin_adi = as.character(input$yayin_adi),
      turkce_d = as.numeric(input$tr_d), turkce_y = as.numeric(input$tr_y), turkce_b = as.numeric(t_b), turkce_net = as.numeric(t_net),
      sosyal_d = as.numeric(input$sos_d), sosyal_y = as.numeric(input$sos_y), sosyal_b = as.numeric(s_b), sosyal_net = as.numeric(s_net),
      mat_d = as.numeric(input$mat_d), mat_y = as.numeric(input$mat_y), mat_b = as.numeric(m_b), mat_net = as.numeric(m_net),
      fen_d = as.numeric(input$fen_d), fen_y = as.numeric(input$fen_y), fen_b = as.numeric(f_b), fen_net = as.numeric(f_net),
      toplam_net = as.numeric(top_net), zorluk_seviyesi = as.character(input$zorluk_seviyesi),
      zorluk_katsayisi = case_when(
        input$zorluk_seviyesi == "Kolay"   ~ 0.92,
        input$zorluk_seviyesi == "Orta"    ~ 1.00,
        input$zorluk_seviyesi == "Zor"     ~ 1.08,
        input$zorluk_seviyesi == "Çok Zor" ~ 1.16,
        TRUE ~ 1.00
      ),
      stringsAsFactors = FALSE
    )
    new_row$kalibre_net <- new_row$toplam_net * new_row$zorluk_katsayisi
    
    vals$df <- bind_rows(vals$df, new_row)
    showNotification("Yeni deneme hafızaya eklendi!", type = "warning")
  })
  
  # Data Export Handler
  output$download_excel <- downloadHandler(
    filename = function() { paste("optistudy_data_", Sys.Date(), ".xlsx", sep="") },
    content = function(file) {
      req(vals$df)
      export_df <- vals$df %>% select(-zorluk_katsayisi, -kalibre_net)
      write.xlsx(export_df, file, rowNames = FALSE)
    }
  )
  
  # Rendering Metrics
  output$box_son_net <- renderValueBox({
    req(vals$df); valueBox(round(tail(vals$df$toplam_net, 1), 2), "Son Dönem Neti", icon = icon("pen"), color = "red")
  })
  output$box_kalibre_net <- renderValueBox({
    req(vals$df); valueBox(round(tail(vals$df$kalibre_net, 1), 2), "Zorluk Kalibreli Net", icon = icon("bullseye"), color = "green")
  })
  output$box_ort_net <- renderValueBox({
    req(vals$df); valueBox(round(mean(vals$df$toplam_net, na.rm=TRUE), 2), "Mevcut Net Ortalaması", icon = icon("calculator"), color = "purple")
  })
  
  # Time-Series Visualization Logic
  output$trend_plot <- renderPlot({
    req(vals$df)
    ggplot(vals$df, aes(x = factor(deneme_id))) +
      geom_line(aes(y = toplam_net, group = 1, color = "Ham Net"), linetype = "dashed", size = 1) +
      geom_point(aes(y = toplam_net, color = "Ham Net"), size = 3) +
      geom_line(aes(y = kalibre_net, group = 1, color = "Zorluk Kalibreli Net"), size = 1.2) +
      geom_point(aes(y = kalibre_net, color = "Zorluk Kalibreli Net"), size = 4, shape = 15) +
      scale_color_manual(values = c("Ham Net" = "#E63946", "Zorluk Kalibreli Net" = "#2A9D8F")) +
      labs(x = "Deneme Serisi", y = "Net Skoru", color = "Trend Tipi") +
      theme_minimal(base_size = 14) + theme(legend.position = "bottom")
  })
  
  # Linear Regression Forecasting Engine (OLS Method)
  output$simulator_ui <- renderUI({
    req(vals$df); if(nrow(vals$df) < 3) return(p("Tahmin motoru için en az 3 veri noktası gereklidir."))
    model <- lm(kalibre_net ~ deneme_id, data = vals$df)
    slope <- coef(model)["deneme_id"]; intercept <- coef(model)["(Intercept)"]
    yks_tahmin <- intercept + (slope * 50); se <- sigma(model)
    alt_sinir <- yks_tahmin - (1.96 * se); ust_sinir <- yks_tahmin + (1.96 * se)
    if(ust_sinir > 120) ust_sinir <- 120; if(alt_sinir < 0) alt_sinir <- 0; if(yks_tahmin > 120) yks_tahmin <- 118
    trend_yonu <- if(slope >= 0) "<b style='color:#2A9D8F;'>POZİTİF (Yükseliş)</b>" else "<b style='color:#E63946;'>NEGATİF (Düşüş)</b>"
    
    HTML(paste0(
      "📉 <b>Öğrenme Hızı Eğilimi:</b> Mevcut momentum ", trend_yonu, " yönündedir.<br>",
      "🎯 <b>YKS Nihai Net Projeksiyonu:</b> Çalışma temposu korunduğu takdirde süreç sonundaki tahmini net potansiyeli: <b>", round(yks_tahmin,1), "</b> net olarak hesaplanmıştır.<br><br>",
      "⚖️ <b>%95 İstatistiki Güven Aralığı:</b> Sınav anı performansı eklendiğinde netin realize olabileceği bilimsel aralık: <br>",
      "<h3 style='color:#9B5DE5; font-weight:bold; text-align:center;'>", round(alt_sinir,1), " - ", round(ust_sinir,1), " Net Aralığı</h3>"
    ))
  })
  
  # Psychometric Persona Evaluation Engine
  output$character_ui <- renderUI({
    req(vals$df)
    total_w <- sum(vals$df$turkce_y, na.rm=T) + sum(vals$df$mat_y, na.rm=T) + sum(vals$df$sosyal_y, na.rm=T) + sum(vals$df$fen_y, na.rm=T)
    total_d <- sum(vals$df$turkce_d, na.rm=T) + sum(vals$df$mat_d, na.rm=T) + sum(vals$df$sosyal_d, na.rm=T) + sum(vals$df$fen_d, na.rm=T)
    total_b <- sum(vals$df$turkce_b, na.rm=T) + sum(vals$df$mat_b, na.rm=T) + sum(vals$df$sosyal_b, na.rm=T) + sum(vals$df$fen_b, na.rm=T)
    risk_index <- if(total_d > 0) total_w / total_d else 0
    blank_ratio <- if((total_d + total_w + total_b) > 0) total_b / (total_d + total_w + total_b) else 0
    
    if (risk_index >= 0.20 & blank_ratio >= 0.15) {
      HTML("<h3 style='color:#9B5DE5; font-weight:bold;'>🎲 Stratejik Risk Mağduru</h3><p><b>Profil Analizi:</b> Zorlanılan branşlarda yüksek oranda boş bırakılarak süre kaybedilmekte; ancak işaretleme yapılan sorularda da yüksek çeldirici elenmesine maruz kalınmaktadır. Sınav anında odaklanma dağılması saptanmıştır.</p>")
    } else if (blank_ratio >= 0.18) {
      HTML("<h3 style='color:#E63946; font-weight:bold;'>🛡️ Aşırı Temkinli Analist</h3><p><b>Profil Analizi:</b> Emin olunmayan soruyu işaretlemek yerine pas geçme eğilimi yüksektir. Ancak bu durum zor sorularla inatlaşmaya, dolayısıyla süre bariyerine yol açmaktadır. Sınavda ortalama %15-20 oranında soruya süre yetmediği için dokunulamamaktadır.</p>")
    } else if (risk_index >= 0.22) {
      HTML("<h3 style='color:#F4A261; font-weight:bold;'>⚔️ Gözü Kara Taarruz Oyuncusu</h3><p><b>Profil Analizi:</b> Boş bırakma refleksi zayıftır. İki şık arasında kalındığında rasyonel eleme yapmak yerine hissiyatla işaretleme yapar. Bu durum sözel çeldiricilerin yüksek olduğu branşlarda net kaybına yol açar.</p>")
    } else {
      HTML("<h3 style='color:#2A9D8F; font-weight:bold;'>🎯 Rasyonel Sınav Yöneticisi</h3><p><b>Profil Analizi:</b> Risk yönetimi, süre kontrolü ve rasyonel analiz dengesi üst düzeydedir. Ne gereksiz risk alıp sallama yapar ne de süre kısıtına girip turlayı kaçırır. Mevcut sınav yönetimi karakteri korunmalıdır.</p>")
    }
  })
  
  # Descriptive Historical Comparison
  output$comparison_ui <- renderUI({
    req(vals$df); if(nrow(vals$df) < 2) return(p("Kıyaslama verisi aranıyor..."))
    son_deneme <- tail(vals$df, 1)
    
    compare_metric <- function(son, ort, label) {
      diff <- son - ort
      if(diff >= 0) return(paste0("<div style='padding:5px; color:#2A9D8F;'><b>▲ ", label, ": +", round(diff,2), " net daha iyi</b> (Son: ", round(son,2), " | Ort: ", round(ort,2), ")</div>"))
      else return(paste0("<div style='padding:5px; color:#E63946;'><b>▼ ", label, ": ", round(diff,2), " net daha düşük</b> (Son: ", round(son,2), " | Ort: ", round(ort,2), ")</div>"))
    }
    
    HTML(paste0(
      "<div style='background-color:#fafafa; padding:15px; border-radius:6px; border:1px solid #e0e0e0;'>",
      "<b>📋 Son Süreç Performans Analitiği (Yayın: ", son_deneme$yayin_adi, " | Zorluk: ", son_deneme$zorluk_seviyesi, ")</b><hr style='margin-top:5px; margin-bottom:10px;'>",
      "<div class='row'>",
      "<div class='col-md-3'>", compare_metric(son_deneme$turkce_net, mean(vals$df$turkce_net, na.rm=T), "Türkçe"), "</div>",
      "<div class='col-md-3'>", compare_metric(son_deneme$mat_net, mean(vals$df$mat_net, na.rm=T), "Matematik"), "</div>",
      "<div class='col-md-3'>", compare_metric(son_deneme$sosyal_net, mean(vals$df$sosyal_net, na.rm=T), "Sosyal"), "</div>",
      "<div class='col-md-3'>", compare_metric(son_deneme$fen_net, mean(vals$df$fen_net, na.rm=T), "Fen Bilimleri"), "</div>",
      "</div>",
      "<hr style='margin-top:10px; margin-bottom:10px;'>",
      "<b>🎯 GENEL TABLO:</b> ", compare_metric(son_deneme$toplam_net, mean(vals$df$toplam_net, na.rm=T), "Toplam Net"),
      "</div>"
    ))
  })
  
  # Rule-based Feedback Analytics (SaaS Ingestion Style)
  output$report_tr <- renderUI({
    req(vals$df); avg_w <- mean(vals$df$turkce_y, na.rm=TRUE); avg_b <- mean(vals$df$turkce_b, na.rm=TRUE); avg_n <- mean(vals$df$turkce_net, na.rm=TRUE)
    msg <- paste0("📊 <b>Mevcut Ortalaması:</b> ", round(avg_n, 2), " Net<br><br>")
    if(!is.na(avg_w) && avg_w > 5) msg <- paste0(msg, "🔴 <b>Risk Analizi:</b> Türkçe yanlış ortalaması kritik eşiğin üzerinde. Çeldiricilere elenme eğilimi saptanmıştır.<br><br>🎯 <b>Aksiyon Planı:</b> Günlük 20 paragraf rutini sürdürülmeli, şıklar metindeki nesnel kanıtlarla elenmelidir.")
    else if(!is.na(avg_b) && avg_b > 3) msg <- paste0(msg, "🟡 <b>Süre Bariyeri:</b> Türkçe metinlerinde harcanan süre fazladır; bu durum boş sayısını artırmaktadır.<br><br>🎯 <b>Aksiyon Planı:</b> 40 dakikalık limitli branş deneme kampları planlanmalıdır.")
    else msg <- paste0(msg, "🟢 <b>Durum:</b> Türkçe performansı kararlı ve başarılıdır.")
    HTML(msg)
  })
  output$report_mat <- renderUI({
    req(vals$df); avg_w <- mean(vals$df$mat_y, na.rm=TRUE); avg_b <- mean(vals$df$mat_b, na.rm=TRUE); avg_n <- mean(vals$df$mat_net, na.rm=TRUE)
    msg <- paste0("📊 <b>Mevcut Ortalaması:</b> ", round(avg_n, 2), " Net<br><br>")
    if(!is.na(avg_b) && avg_b > 10) msg <- paste0(msg, "🔴 <b>Süre Dağılım Hatası:</b> Doğruluk oranı yüksek ancak süre kısıtından dolayı ortalama ", round(avg_b,1), " soru boş bırakılıyor.<br><br>🎯 <b>Aksiyon Planı:</b> Sınav anında inatlaşma süresi 45 saniyeyle sınırlandırılmalı ve turlama taktiği katı bir şekilde uygulanmalıdır.")
    else if(!is.na(avg_w) && avg_w > 5) msg <- paste0(msg, "🟡 <b>Operasyonel Hata:</b> İşlem hataları net kaybına yol açmaktadır.<br><br>🎯 <b>Aksiyon Planı:</b> Karalama kağıdı dikey ve sıralı basamaklar halinde kullanılmalıdır.")
    else msg <- paste0(msg, "🟢 <b>Durum:</b> Matematik gelişimi analitik trende uygundur.")
    HTML(msg)
  })
  output$report_sos <- renderUI({
    req(vals$df); avg_n <- mean(vals$df$sosyal_net, na.rm=TRUE); sd_n <- sd(vals$df$sosyal_net, na.rm=TRUE)
    msg <- paste0("📊 <b>Mevcut Ortalaması:</b> ", round(avg_n, 2), " Net<br><br>")
    if(avg_n < 11) msg <- paste0(msg, "🔴 <b>Kavram Eksikliği:</b> Bilgi tabanlı sorularda elenme oranları yüksek saptanmıştır.<br><br>🎯 <b>Aksiyon Planı:</b> Felsefe/Din terim sözlükleri ve Coğrafya harita okuma kampları yapılmalıdır.")
    else if(!is.na(sd_n) && sd_n > 2.5) msg <- paste0(msg, "🟡 <b>Yüksek Varyans (Dalgalanma):</b> Sınav tipine göre net oynaklığı fazladır.<br><br>🎯 <b>Aksiyon Planı:</b> Sınav analizlerinde bilgi soruları saptanıp hata defteri oluşturulmalıdır.")
    else msg <- paste0(msg, "🟢 <b>Durum:</b> Sosyal bilimler performansı dengelidir.")
    HTML(msg)
  })
  output$report_fen <- renderUI({
    req(vals$df); avg_n <- mean(vals$df$fen_net, na.rm=TRUE); sd_n <- sd(vals$df$fen_net, na.rm=TRUE)
    msg <- paste0("📊 <b>Mevcut Ortalaması:</b> ", round(avg_n, 2), " Net<br><br>")
    if(!is.na(sd_n) && sd_n > 3) msg <- paste0(msg, "🔴 <b>Konu Seçme Sapması (Maksimum Kaldıraç):</b> Net varyansı çok yüksektir. Bilinen üniteler ile bilinmeyen üniteler arasında uçurum saptanmıştır.<br><br>🎯 <b>Aksiyon Planı:</b> Eksik büyük üniteler (Optik, Kalıtım vb.) acilen listelenip lokal ünite kamplarıyla kapatılmalıdır.")
    else if(avg_n < 10) msg <- paste0(msg, "🟡 <b>Temel Bilgi Boşluğu:</b> İlk ünitelerdeki teorik altyapı eksiktir.<br><br>🎯 <b>Aksiyon Planı:</b> Fizik/Kimya/Biyoloji derslerinin ilk 3 ünitesi tarama testleriyle kapatılmalıdır.")
    else msg <- paste0(msg, "🟢 <b>Durum:</b> Fen bilimleri tablosu ana hedefi desteklemektedir.")
    HTML(msg)
  })
  
  # Render Data Matrices
  output$raw_table <- renderTable({
    req(vals$df); if(nrow(vals$df) == 0) return(data.frame())
    vals$df %>% 
      select(deneme_id, yayin_adi, zorluk_seviyesi, turkce_net, sosyal_net, mat_net, fen_net, toplam_net) %>%
      rename(
        `Deneme ID` = deneme_id, `Yayın Adı` = yayin_adi, `Zorluk Seviyesi` = zorluk_seviyesi,
        `Türkçe Net` = turkce_net, `Sosyal Net` = sosyal_net, `Matematik Net` = mat_net, `Fen Net` = fen_net, `Toplam Net` = toplam_net
      )
  }, digits = 2)
}

shinyApp(ui = ui, server = server)