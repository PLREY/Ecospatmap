#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#    https://shiny.rstudio.com/gallery/covid19-tracker.html
#
#   https://shiny.rstudio.com/gallery/biodiversity-national-parks.html
#
#   https://leaflet-extras.github.io/leaflet-providers/preview/ 
#
#   https://stackoverflow.com/questions/71669825/leaflet-side-by-side-for-2-raster-images-in-r 
#
#   https://wbi-nwt.analythium.app/apps/nwt/ 
#
#   https://fontawesome.com/icons/layer-group?f=classic&s=duotone&sc=%231E3050 <-- choose icon
#   

#wd<-"/home/shiny/" # Working directory by default
setwd("C:/Users/prey3/Switchdrive/THESE_PL/40_Ecospat_maps/Example_app/")

#
### Import packages
#
library(shiny) #Web application framework for R

library(shinydashboard) #Create dashboard with shiny
library(shinycssloaders) #Add loading animations to a 'shiny' output while it's recalculating
library(shinymanager) #Simple and secure authentication mechanism for single ‘Shiny’ applications.
library(htmltools) #Tools for html
library (htmlwidgets) #HTML widgets for R -->useful for tags$...

library(stringr) #Simple, Consistent Wrappers for Common String Operations
library(terra) # Geographic data analysis and modeling; New library for raster pckg 
library(RColorBrewer) #ColorBrewer Palettes

library(leaflet) # to work with sidedbyside plug-in we need to work with the version 2.03.9000 of leaflet (forced when you install raster-options of leaflet (see below). 
                 # current consequences we need to use raster::raster to upload Spatrast file format.
                 # if you work with latest version of leaflet with Spatrast format, you can use directly the rast function from terra pckg
library(leaflet.extras)
library(leaflet.extras2) # for leaflet options we need to previously installed if we update leaflet version: remotes::install_github("rstudio/leaflet", ref="joe/feature/raster-options") #--> DONE
library(leaflet.opacity) # for opacity slider on raster image

library(bslib) #Custom 'Bootstrap' 'Sass' Themes for 'shiny' and 'rmarkdown'
library(showtext) #Using Fonts More Easily in R Graphs
library(thematic) #Unified and Automatic 'Theming' of 'ggplot2', 'lattice', and 'base' R Graphics

lf<-as.data.frame(data.table::fread("lf.csv"))
lf.sr<-as.data.frame(data.table::fread("lf-sr.csv"))

credentials <- data.frame(
  user = c("author", "reviewer"), # mandatory
  password = c("pass1", "pass2"), # mandatory
  start = c("2023-05-24"), # optinal (all others)
  expire = c(NA, "2024-12-31"),
  admin = c(TRUE, FALSE),
  comment = "Simple and secure authentification mechanism 
  for single ‘Shiny’ applications.",
  stringsAsFactors = FALSE
)


#
##
#### Define UI for Shiny web app structure
##
#

ui <- fluidPage(
  
  # load custom stylesheet
  includeCSS("www/style.css"),
  
  # load page layout
  dashboardPage(
    
    #skin = "green", # colors choice limited
    
    # Define the title of your dashboard
    dashboardHeader(title="Ecospatmap", titleWidth = 300),
    
    # Define the content and parameters of your sidebar
    dashboardSidebar(width = 300,
      
    #  includeHTML("www/header-nav-bar.html"),
    #  includeCSS("www/Style-header-nav-bar.css")
      
                      # Define Menu content
                      sidebarMenu(
                        HTML(paste0(
                          "<br>",
                          "<a href='https://www.unil.ch/ecospat/home.html'><img style = 'display: block; margin-left: auto; margin-right: auto;' src= 'www/images/ecospat_logo_400x400.jpg' title='Ecospat website'  width = '186' height= '186' /></a>",
                          "<br>")),
                        # Items creation
                        shinydashboard::menuItem("Home", tabName = "home", icon = icon("home")),
                        shinydashboard::menuItem("Species Richness map", tabName = "SRm", icon = icon("tree", "fa")),
                        shinydashboard::menuItem("NCPs Map", tabName = "NCPmap", icon = icon("mountain-sun", "fa"),
                                                 # Sub items creation
                                                 menuSubItem("Individual NCP map", tabName="indNCP", icon = icon("layer-group", "fa")),
                                                 menuSubItem("NCP maps comparisons", tabName="sbysNCP", icon=icon("layer-group", "fa")))
                      ) # END Sidebar Menu
    ), # END dashboard Sidebar
    
    # Define the content of the dashboard body for each item (and sub-items) defined above
    dashboardBody(
      
      #includeCSS("www/Style-background-home2.css"), # background image in the body part
      
      tabItems(
        # 'home' section
        tabItem(tabName = "home",
                # specific markdown document with text was created to avoid 'polluting' the script
                includeHTML("www/home2.html"),
                includeCSS("www/Style-home2.css"),
                tags$img(src = "www/images/tourism-aravis.jpg", style = 'position: end')
                
                #setBackgroundImage(src = "www/images/first-light.jpg"),
                
                #Markdown("www/home.md")
        ),
        
        # 'Species Richness map' section
        tabItem(tabName = "SRm",
                fluidRow(
                  leafletOutput("SRM")%>% withSpinner(color = "lightgreen", type=7),
                  
                  # We create 2 panels, one for each side to choose independant ratser file at each request 
                  
                  # Define a panel to select variables into the leaflet content
                  # Here, we define some parameters (e.g., size from the border, width, height, draggable or not)
                  # You cans also customize the content as you want
                  
                  #Left panel
                  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                draggable = TRUE, top = 75, left = "auto", right = "auto", bottom = "auto",
                                width = 330, wheight = "auto",
                                
                                em(h6("Species richness map"), align="left"),
                                radioButtons("TSsr", "Choose a Time-Scenario:", unique(lf.sr$Time.Scenario), inline= "TRUE", selected="Current (1980-2010)"))
                  # Define the size of the leaflet render and a spinner for the load time
                )
        ),
        
        # 'Individual NCP map' section
        tabItem(tabName = "indNCP",
                # Split the variables selection in an unique line. The dashboard contains 12 columns, split as you want with this info
                # here, we decided to split in 4 equal parts
                fluidRow(
                  column(4, uiOutput("NCP")),
                  column(4, uiOutput("TS")),
                  column(4, uiOutput("METHOD"), 
                         align="center"),
                  HTML("<br>"),
                  HTML("<br>"),
                # Back to line, and write the caption of what you show
                h4(textOutput("caption")),
                # Skip a line
                HTML("<br>"),
                # Add a button to download the raster selected
                downloadButton("downloadMap", "Download"), align="center",
                HTML("<br>"),
                HTML("<br>")
                ),
                # Define the size of the leaflet render and a spinner for the load time
                fluidRow(
                  leafletOutput("IndNCP", height = 700) %>% withSpinner(color = "lightgreen", type=7)
                )
        ),
        # 'Side-by-side NCP map' section
        tabItem(tabName = "sbysNCP",
                fluidRow(
                  leafletOutput("SbyS_NCP")%>% withSpinner(color = "lightgreen", type=7),
                  
                  # We create 2 panels, one for each side to choose independant ratser file at each request 
                  
                  # Define a panel to select variables into the leaflet content
                  # Here, we define some parameters (e.g., size from the border, width, height, draggable or not)
                  # You cans also customize the content as you want
                  
                  #Left panel
                  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                draggable = TRUE, top = 75, left = "auto", right = "auto", bottom = "auto",
                                width = 330, height = "auto",
                                
                                em(h6("Left panel"), align="left"),
                                selectInput("NcpLeft", "Choose a NCP:", unique(lf$NCP), selected = "Total NCPs"),
                                radioButtons("TSLeft", "Choose a Time-Scenario:", unique(lf$Time.Scenario), inline= "TRUE", selected="Current (1980-2010)"),
                                radioButtons("MethLeft", "Choose a Method to apply:", unique(lf$Method), inline="TRUE", selected="Method 'NCP-BIN'")),
                  #Right panel
                  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                draggable = TRUE, top = 75, left = "auto", right = 20, bottom = "auto",
                                width = 330, height = "auto",
                                
                                em(h6("Right panel"), align="right"),
                                
                                selectInput("NcpRight", "Choose a NCP:", unique(lf$NCP), selected = "Total NCPs"),
                                radioButtons("TSRight", "Choose a Scenario:", unique(lf$Time.Scenario), inline= "TRUE", selected="RCP 8.5 (2070-2099)"),
                                radioButtons("MethRight", "Choose a Method to apply:", unique(lf$Method), inline="TRUE", selected="Method 'NCP-BIN'"))
                ) # END FluidRow
        ) # END Tab Item 
      ) # END Tab Items 
    ) # END Dashboard Body
  ) # END Dashboard Page
) # END FLUID PAGE


# Wrap your UI with secure_app
ui <- secure_app(ui)

#
##
#### Define server logic required to draw a raster map
##
#

server <- function(input, output) {
  
  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(check_credentials = check_credentials(credentials))
  
  #
  ### For indNCP panel
  #
  
  # Compute the formula text, this is in a reactive expression to update the file request for the diverse map output (and captions output)
  

  formulaText <-reactive({ lf[which(lf$Time.Scenario==input$t.sce &
                           lf$NCP==input$ncp &
                           lf$Method==input$meth),"lf"]
  })
  
  
  
  output$NCP <- renderUI({
                  selectInput("ncp", "Select a NCP:", unique(lf$NCP))})
  
  output$TS <- renderUI({
                selectInput("t.sce", "Select a Time scenario:", unique(lf$Time.Scenario))})
  
  output$METHOD <- renderUI({
                    selectInput("meth", "Select a Method to apply:", unique(lf$Method))})
  
  # Return the formula text for printing as a caption
  output$caption <- renderText ({
                      paste0("Map for the ",input$ncp," NCP with the ",input$t.sce," time scenario (",input$meth,") was imported")})
  
  # Generate a Download button of the requested variable
  output$downloadMap <- downloadHandler(
                          filename = function() {paste0(input$ncp,"_",input$t.sce,"_",input$meth,"_Rey-et-al-2024.tif")},
                          content = function(file) {terra::writeRaster(terra::rast(formulaText()),file, overwrite=TRUE)}
                          )
  
  # Generate a leaflet map with the requested raster
  output$IndNCP <- renderLeaflet({
    
    file <- formulaText()
    
    # file<-reactive({
    #   validate(
    #    need(formulaText()!="", "Please select a correct request")
    #    )
    # })
    
    valR<-na.omit(values(terra::rast(file)))
    
    leaflet(options = leafletOptions(zoomControl = FALSE)) |>
      htmlwidgets::onRender("function(el, x) {L.control.zoom({ position: 'topright' }).addTo(this) }")%>%
      
      addTiles(group="OSM")|> 
      
      addProviderTiles(providers$SwissFederalGeoportal.NationalMapColor,group = "Swiss Map", providerTileOptions(noWrap = TRUE)) |> # the default web map layer is OSM, so we put into group name 'OSM'.
      addProviderTiles(providers$SwissFederalGeoportal.SWISSIMAGE, group = "Satellite", providerTileOptions(noWrap = TRUE)) |> # added an extra webmap layer and called group - Satellite
      
      addFullscreenControl() |>
      
      addRasterImage(terra::rast(file), colors = "YlOrRd", opacity = 0.6, group="NCP projection", layerId = "NCP.proj") |>
      
      addOpacitySlider(layerId = "NCP.proj") |>
      
      addLegend(pal = colorNumeric("YlOrRd", domain=values(rast(file))), values = valR, position = "bottomright",
                title = "NCP index value") |>
      
      addLayersControl(
        baseGroups = c("OSM","Swiss Map", "Satellite"),
        overlayGroups = "NCP projection",
        position = c("topleft"),
        options = layersControlOptions(collapsed = TRUE)) 
    
  })
  
  #
  ### For Species Richness map panel
  #
  
  # Select file for the SR panel
  formulaText_sr <-reactive({
    lf.sr[which(lf.sr$Time.Scenario==input$TSsr),"lf"]
  })
  
  
  # Generate a leaflet map with the 2 requested rasters
  output$SRM<- renderLeaflet({
    
    file_sr <- formulaText_sr()
    valR_sr<-na.omit(values(rast(file_sr)))
    
    leaflet(options = leafletOptions(zoomControl = FALSE)) |>
      htmlwidgets::onRender("function(el, x) {L.control.zoom({ position: 'topright' }).addTo(this) }")%>%
      
      addTiles(group="OSM")|> 
      
      addProviderTiles(providers$SwissFederalGeoportal.NationalMapColor,group = "Swiss Map", providerTileOptions(noWrap = TRUE)) |> # the default web map layer is OSM, so we put into group name 'OSM'.
      addProviderTiles(providers$SwissFederalGeoportal.SWISSIMAGE, group = "Satellite", providerTileOptions(noWrap = TRUE)) |> # added an extra webmap layer and called group - Satellite
      
      addFullscreenControl() |>
      
      addRasterImage(rast(file_sr), colors = "YlOrRd", opacity = 0.6, group="Species Richness map", layerId = "SR.proj") |>
      
      addOpacitySlider(layerId = "SR.proj") |>
      
      addLegend(pal = colorNumeric("YlOrRd", domain=values(rast(file_sr))), values = valR_sr, position = "bottomright",
                title = "Species richness value") |>
      
      addLayersControl(
        baseGroups = c("OSM","Swiss Map", "Satellite"),
        overlayGroups = "Species Richness map",
        position = c("topleft"),
        options = layersControlOptions(collapsed = TRUE)) 
    
  }) 
  
  
  #
  ### For Side by side panel Right and Left
  #
  
  # Select file for the right panel
  formulaText_R <-reactive({
                   lf[which(  lf$Time.Scenario==input$TSRight &
                   lf$NCP==input$NcpRight &
                   lf$Method==input$MethRight),"lf"]
                  })
  
  # Select file for the left panel
  formulaText_L <-reactive({
                   lf[which(  lf$Time.Scenario==input$TSLeft &
                   lf$NCP==input$NcpLeft &
                   lf$Method==input$MethLeft),"lf"]
                  })
  
  
  # Generate a leaflet map with the 2 requested rasters
  output$SbyS_NCP<- renderLeaflet({
    
    
    file_R <- formulaText_R()
    valR_R<-na.omit(values(rast(file_R)))
    
    file_L <- formulaText_L()
    valR_L<-na.omit(values(rast(file_L)))
    
    
    leaflet() |> 
      addMapPane("right", zIndex = 0) |> # creation of the right panel
      addMapPane("left",  zIndex = 0) |> # creation of the left panel
      
      
      # indexation of individual leaflet tile
       addTiles(group = "OSM", layerId = "baseid1", options = pathOptions(pane = "right")) |> 
       addTiles(group = "OSM", layerId = "baseid2", options = pathOptions(pane = "left")) |> 
       
       # addProviderTiles(providers$SwissFederalGeoportal.NationalMapColor, layerId= "baseid1", pathOptions(pane = "right")) |>  # the default web map layer is OSM, so we put into group name 'OSM'.
       # addProviderTiles(providers$SwissFederalGeoportal.NationalMapColor, layerId= "baseid2", pathOptions(pane = "left")) |>  # the default web map layer is OSM, so we put into group name 'OSM'.
      
      # Add raster images for the right and left panel
      addRasterImage(x = rast(file_R), colors = "YlOrRd", opacity=0.6, options = gridOptions(pane = "right")) |> 
      addRasterImage(x = rast(file_L), colors = "YlOrRd", opacity=0.6, options = gridOptions(pane = "left")) |> 
      
      # Add adapted legend for both panel with some customizations
      addLegend(title=  paste(em(h5(HTML("<li>"),"NCP predictions of:",strong(input$NcpRight),HTML("</li>")),align="left"), # text in italic, header 5, with bullet point presentation, and variable selected in strong
                              em(h5(HTML("<li>"),"Time-Scenario:",strong(input$TSRight),HTML("</li>")),align="left"),
                              em(h5(HTML("<li>"),"Method",strong(str_remove(input$MethRight,"Method ")),HTML("</li>")),align="left")), 
                pal = colorNumeric("YlOrRd", domain= values(rast(file_R))),  values = valR_R, position = "bottomright")|> # adapt colors and values legend
      
      addLegend(title = paste(em(h5(HTML("<li>"),"NCP predictions of:",strong(input$NcpLeft),HTML("</li>")),align="left"),
                              em(h5(HTML("<li>"),"Time-Scenario:",strong(input$TSLeft),HTML("</li>")),align="left"),
                              em(h5(HTML("<li>"),"Method ",strong(str_remove(input$MethLeft,"Method ")),HTML("</li>")),align="left")),
                pal = colorNumeric("YlOrRd", domain= values(rast(file_L))), values = valR_L, position = "bottomleft")|>
      
      #addOpacitySlider(layerId ="NCPs.proj") |>
      
      #addLayersControl(
       #  baseGroups = c("OSM","Swiss Map", "Satellite"),
       #  overlayGroups = c("NCPs projection"),
       #  position = "topleft",
       #  options = layersControlOptions(collapsed = TRUE)) |>
        
      # Add the side by side plug-in based on previous informations - leaflet.extra2 pkg
      addSidebyside(layerId = "sidecontrols", rightId = "baseid1", leftId  = "baseid2")})
} # END Server


shinyApp(ui = ui, server = server) # Run the application 
