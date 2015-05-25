library(randomForest)
library(pROC)
library(sampling)
library(dplyr)
library(ggmap)
train <- read.csv('../shiny_project/data/train_ext.csv', header = TRUE)
train <- transform(train, AddressAccuracy = as.factor(AddressAccuracy), Virus = as.factor(Virus), Month = as.factor(Month))
map <- readRDS('../shiny_project/data/mapdata_copyright_openstreetmap_contributors.rds')
strata_sample <- strata(train, stratanames = 'Virus', size = c(3000,500), method = 'srswor')
train <- train[strata_sample$ID_unit,]

test <- read.csv('../shiny_project/data/test_ext.csv', header = TRUE)
test <- transform(train, AddressAccuracy = as.factor(AddressAccuracy), Month = as.factor(Month))

shinyServer(function(input, output, session) {
    
  observe({
    sel_max <- length(input$predictors)
    max_ratio <- (min(0.9, 3000/input$sampling))
    min_ratio <- (max(0.1, 500/input$sampling))
    ratio_label <- (paste('Ratio of Majority to Minority( Range from', 1-min_ratio,'to',max_ratio,') :',sep = ' '))
    updateNumericInput(session,'mtry', min = 1, max = sel_max, value = ceiling((sel_max+1)/2),step = 1)
    updateNumericInput(session,'ratio', label = ratio_label, min = 1 - min_ratio, max = max_ratio, value = (max_ratio+1-min_ratio)/2)
    
  })
  
  compute <- eventReactive(input$goButton, {
    print('Running randomForest')
    rf <- randomforest()
    print('Done')
    rf
  })
  
  randomforest <- reactive({
    temp <- paste(input$predictors, collapse = ' + ')
    formula.string <- paste('Virus', temp, sep = ' ~ ')
    formula <- as.formula(formula.string)
    majority_size <- round((input$sampling * input$ratio),0)
    minority_size <- input$sampling - majority_size
    rf <- randomForest(formula, data = train, mtry = input$mtry, strata = train$Virus, replace = TRUE, sampsize = c(majority_size, minority_size), ntree = input$ntree, proximity = TRUE)
  })
  
  output$data <- renderTable({
    
    head(train)
  })
    
  output$confusion <- renderTable({
    
    rf <- compute()
    rf$confusion
  })
    
  #output$proximity <- renderPlot({
   
  #  rf <- compute()
  #  print('MDSplot')
  #  MDSplot(rf, train$Virus, palette = 1:2, k = length(input$predictors))
    
  #})
       
  output$importance <- renderPlot({
    
    rf <- compute()
    varImpPlot(rf)
  })
  
  output$distribution <- renderPlot({
    
    ggmap(map) + geom_point(data = train, aes(x = Longitude, y = Latitude, colour = Virus)) + facet_grid(Virus ~ Year)
  })
  
  output$roc <- renderPlot({
    
    rf <- compute()
    roc_curve <- roc(as.numeric(as.character(rf$y)),as.numeric(as.character(rf$predicted)))
    plot(roc_curve)
  })
  
  output$err_plot <- renderPlot({
    
    rf <- compute()
    plot(rf)
    legend("topright", colnames(rf$err.rate),col=1:4,cex=0.8,fill=1:4)
  })
    
  output$summary_rf <- renderPrint({
    rf <- compute()
    print(rf)
  })
  
  output$attr_df <- renderPrint({
    print(str(train))
  })
  
  output$dims_descrip <- renderUI({
    rf <- compute()
    temp <- attr(rf$terms,'factors') %>% attr('dimnames')
    predictor_names <- temp[[2]]
    text <- c()
    for(i in seq_along(predictor_names)){
      text[i] <- paste('Dim ',i,': ',predictor_names[i],'\n',sep = ' ')
    }
    HTML(paste(text, collpase = '<br/>'))
  })
  
  
})
