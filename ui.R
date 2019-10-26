
library(shiny)
library(plotly)
library(leaflet)
library(shinydashboard)

# Define UI for application that draws a histogram
shinyUI(dashboardPage(

    # Application title
    dashboardHeader(title = "Melbourne's Cheapest and Most Expensive Suburbs Analysed Year and Distance from CBD",
                    titleWidth = 1050
                    ),
    
    # Sidebar with a slider input for Distance from Melbourne CBD
    dashboardSidebar(disable = T
    ),

        # Show a plot of the generated distribution
    dashboardBody(
        fluidRow(
            box(sliderInput("inputDist",
                                        h4("Select the Range of distance Melbourne CBD:"),
                                        min = 0,
                                        max = 50,
                                        value = c(7, 15)),
                p("Use the slider to select a range of distance.  eg.  
                  Default is looking at suburbs between 7-15km direct distance from Melbourne's CBD"),
                            
                sliderInput("inputYear",
                                        h4("Select the Year:"),
                                        min = 2009,
                                        max = 2019,
                                        sep = "",
                                        value = 2019,
                                        animate = animationOptions(interval = 2000, loop = FALSE)),
                            width = 3,
                p("Press play to have a look at the top suburbs over the last 10 years.")
                ),
            box(checkboxGroupInput("direction", label = h4("Select Direction from CBD"), 
                                    choices = list("North" = "North", 
                                                   "North-East" = "North-east", 
                                                   "East" = "East",
                                                   "South-East" = "South-east",
                                                   "South" = "South",
                                                   "South-West"= "South-west",
                                                   "West" = "West",
                                                   "North-West" = "North-west"),
                                    selected = c('East','South-east','South')),
                width = 2,
                p("**Default is set at Melbourne's Eastern, South East and Southern Suburbs."), p("  
                  **Select the checkbox for additional directions to be included in the rankings")),
            
            box(leafletOutput("mymap"), width = 7)),
        fluidRow(
            box(plotlyOutput("p1"), width = 3),
            box(plotlyOutput("p3"), width = 3),
            box(plotlyOutput("p2"), width = 3),
            box(plotlyOutput("p4"), width = 3)
        ),
        
        fluidRow(
            box(
                title = "Reference", width = 12, 
                p(a(href = "https://goo.gl/VbLsLg","List of Melbourne Suburbs by Distance & Direction from CBD"),
                "was obtained from",
                  a(href = "https://www.digitaladvocates.com.au", "www.digitaladvocates.com.au")),
                p("Median Houses prices by suburbs was obtained from",
                a(href = "
                https://discover.data.vic.gov.au/dataset/victorian-property-sales-report-median-house-by-suburb-time-series
                ","discover.data.vic.gov.au/")),
                p("Created by", a(href="https://www.linkedin.com/in/ychriszhang/", "Chris Zhang"),
                "in Oct 2008")
            )
        )
)))
