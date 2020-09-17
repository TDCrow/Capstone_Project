library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme = shinythemes::shinytheme("flatly"),

    # Application title
    titlePanel("Predicting the next word in text"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput("text","text", value = "Input text here"),
            sliderInput("resultnumber", label = "Number of Results", min = 1, max = 10, value = 3)
            ),

        # Show a plot of the generated distribution
        mainPanel(
            tableOutput("words")
        )
    )
))
