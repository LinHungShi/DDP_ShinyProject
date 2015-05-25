

shinyUI(fluidPage(
  
  titlePanel("R package:randomForest for West Nile Virus Prediction"),
  sidebarLayout(
   
    sidebarPanel(
       
      helpText(h3('This shiny app allow user to use random forest to train the data. Tuning Parameters is allowed so that the user can see the influence of parameters. Since the data is imbalanced, user can use stratafied sampling to resample.')),
      checkboxGroupInput("predictors", 
                         label = ("Select the predictors you want to use:"), 
                         choices = list(Longitude ='Longitude', Latitude = 'Latitude'
                                        , AddressAccuracy = 'AddressAccuracy'
                                        , Year = 'Year', Month = 'Month'
                                        , Species = 'Species'),
                      
                         selected = c('Longitude','Latitude')),
      numericInput('sampling',label = ('Number of Data Used( Range from 500 to 3500 ) :'), min = 500, max = 3500, value = 3500),
      numericInput('ratio', label = ('Ratio of Majority to Minority( Range from 0.857142857142857 to 0.857142857142857 ) :'), min = 6/7, max = 6/7, value = 6/7),
      sliderInput('mtry', label = ('Variable Selection:'), min = 1, max = 2, value = 2,step = 1),
      numericInput('ntree', label = ('Number of Tree:'), min = 1, max = 10, value = 500,step = 1),
      br(),
      actionButton('goButton',label = 'GO!')
    ),
   
    mainPanel(
      
      tabsetPanel(
        tabPanel("Data Visualization",
                 helpText('Head of Data:'),
                 tableOutput("data"),
                 br(),
                 helpText('Detail of Data:'),
                 verbatimTextOutput('attr_df'),
                 br(),
                 helpText('Distribution of Virus by Years:'),
                 plotOutput('distribution')
                 ), 
        tabPanel("Importance", plotOutput("importance")), 
        tabPanel("ROC Curve", plotOutput('roc')),
        tabPanel("Summary of RF", verbatimTextOutput("summary_rf")), 
        tabPanel("Confusion Matrix", tableOutput("confusion")),
        #tabPanel('Proximity Plot', 
        #         plotOutput('proximity'),
        #         htmlOutput('dims_descrip')),
        tabPanel('Error Rate Plot', plotOutput('err_plot')),
        selected = 'Importance'  
      )
    )
  )
))
