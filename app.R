# https://stackoverflow.com/questions/37347463/generate-report-with-shiny-app-and-rmarkdown
library(shiny)
library(rmarkdown)
server <- function(input, output) {
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },
    content = function(file) {
      src <- normalizePath('report.Rmd')
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)
      
      out <- rmarkdown::render('report.Rmd',
                               params = list(text = input$text),
                               switch(input$format,
                                      PDF = pdf_document(), 
                                      HTML = html_document(), 
                                      Word = word_document()
                               ))
      file.rename(out, file)
    }
  )
}

ui <- fluidPage(
  tags$textarea(id="text", rows=20, cols=155, 
                placeholder="Some placeholder text"),
  
  flowLayout(radioButtons('format', 'Document format', c('HTML', 'Word'),
                          inline = TRUE),
             downloadButton('downloadReport'))
  
)

shinyApp(ui = ui, server = server)