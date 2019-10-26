#Loading required packages

library(shiny)
library(plotly)
library(readxl)
library(dplyr)
library(tidyr)
library(leaflet)

#Inputing the data - note data files are saved in subfile within the App directory.
hp <- read_excel("data/Houses-by-suburb-2008-2018.xlsx", 
                 sheet = "Sheet1", skip = 1)[-1,1:13]
colnames(hp) <- c("locality", "2008", "2009", "2010", "2011", "2012", "2013","2014", "2015", "2016", "2017","2018",
                  "2019")
dis <- read_excel("data/Melbourne Suburbs by Distance & Direction from CBD.xlsx")

#Joining the distance to city file and median price file together and cleaning up missing values
dis$locality <- toupper(dis$Suburb)
house <- inner_join(hp, dis, by = "locality") %>% 
    gather(key = "Year", value = "MedianPrice", '2008':'2019')
house1 <- house %>% mutate(Year = as.numeric(house$Year),
                           MedianPrice = as.numeric(house$MedianPrice),
                           Suburb = factor(house$Suburb, ordered = T))
house2 <- house1[-which(is.na(house1$MedianPrice)),]

#creating the year on year change dataset.
hp0 <- as.data.frame(sapply(hp, as.numeric))[-1]
hd <- cbind(hp[1], (hp0[-1] - hp0[-length(hp0)])/hp0[-length(hp0)])
shift <- inner_join(hd, dis, by = "locality") %>% 
    gather(key = "Year", value = "change", '2009':'2019')
shift$change <- 100*shift$change %>% round(3)

#Shiny server
shinyServer(function(input, output) {

#Plotting the top 10 suburbs within the criteria set from the UI
    output$p1 <- renderPlotly({
        x <- house2 %>% filter(Year == input$inputYear, 
                               `Distance (km)`>= input$inputDist[1],
                               `Distance (km)`<= input$inputDist[2],
                               Direction %in% input$direction) %>% 
            arrange(desc(MedianPrice)) %>% 
            top_n(n=10)
        
        plot_ly(data = x, 
                y = ~reorder(Suburb, MedianPrice), 
                x = ~MedianPrice, 
                alpha = 0.8 , 
                marker = list(
                    color=seq(1, 11),
                colorscale='YlGnBu',
                reversescale =F),
                type = "bar", orientation = "h") %>% 
            layout( title = paste0("Highest Median Price in ",input$inputYear),
                    xaxis = list(zeroline = FALSE, title = "Median House Price"),
                    yaxis = list(zeroline = FALSE, title = "Suburb"))
        
    })
 #Plotting top 10 growth suburbs within the criteria set from the UI 
    output$p2 <- renderPlotly({
        x1 <- shift %>% filter(Year == input$inputYear, 
                               `Distance (km)`>= input$inputDist[1],
                               `Distance (km)`<= input$inputDist[2],
                               Direction %in% input$direction) %>% 
            arrange(desc(change)) %>% 
            top_n(n=10)
        
        plot_ly(data = x1, 
                y = ~reorder(Suburb, change), 
                x = ~change, 
                marker = list(
                    color=seq(1, 11),
                    colorscale='YlGnBu',
                    reversescale =F),
                alpha = 0.8 , 
                type = "bar", orientation = "h") %>% 
            layout( title = paste0("Highest Growth in ", input$inputYear),
                    xaxis = list(zeroline = FALSE, title = "% Growth/Decrease of Median Price"),
                    yaxis = list(zeroline = FALSE, title = "Suburb"))
    })

#Plotting the cheapest 10 suburbs within the criteria set from the UI    
    output$p3 <- renderPlotly({
        x3 <- house2 %>% filter(Year == input$inputYear, 
                               `Distance (km)`>= input$inputDist[1],
                               `Distance (km)`<= input$inputDist[2],
                               Direction %in% input$direction) %>% 
            arrange(MedianPrice) %>% 
            top_n(n=-10)
        plot_ly(data = x3, 
                y = ~reorder(Suburb, -MedianPrice), 
                x = ~MedianPrice, 
                marker = list(
                    color=seq(1, 11),
                    colorscale='YlOrRd',
                    reversescale =F),
                alpha = 0.5 , 
                type = "bar", orientation = "h") %>% 
            layout( title = paste0("Lowest Median Price in ", input$inputYear),
                    xaxis = list(zeroline = FALSE, title = "Median House Price"),
                    yaxis = list(zeroline = FALSE, title = "Suburb"))
    })

#Plotting the 10 suburbs with least growth/most decrease within the criteria set from the UI    
    output$p4 <- renderPlotly({
        x4 <- shift %>% filter(Year == input$inputYear, 
                               `Distance (km)`>= input$inputDist[1],
                               `Distance (km)`<= input$inputDist[2],
                               Direction %in% input$direction) %>% 
            arrange(change) %>% 
            top_n(n=-10)
        
        plot_ly(data = x4, 
                y = ~reorder(Suburb, -change), 
                x = ~change, 
                marker = list(
                    color=seq(1, 11),
                    colorscale='YlOrRd',
                    reversescale =F),
                alpha = 0.8 , 
                type = "bar", orientation = "h") %>% 
            layout( title = paste0("Lowest Growth in ", input$inputYear),
                    xaxis = list(zeroline = FALSE, title = "% Growth/Decrease of Median Price"),
                    yaxis = list(zeroline = FALSE, title = "Suburb"))
    })
    
#Creating a map of the areas
    output$mymap <- renderLeaflet({
        leaflet() %>% 
            addTiles() %>% 
            setView( lng = 144.96, lat = -37.814, zoom = 10 ) %>% 
            addCircles(lng = 144.96, lat = -37.814, weight = 5,
                       radius = input$inputDist*1000, fillColor = "transparent",
                       label = htmltools::HTML(paste("Suburbs between",input$inputDist[1],"and",input$inputDist[2],"km of CBD are selected")),
                       labelOptions = labelOptions(direction = "auto", textsize = "15px"))
    })

})
