#' @import bnutil bnshiny
#' @export
shinyServerRun = function(input, output, session, context) {

  output$body = renderUI({
    tabsetPanel(
      tabPanel("Meta Data Table",
               tableOutput("mDataTable"),
               actionButton("done", "return to Bionavigator")),
      tabPanel("Data Table", tableOutput("dDataTable"))
    )
  })

  getFolderReactive = context$getRunFolder()
  getDataReactive = context$getData()

  observe({
    getData=getDataReactive$value
    if (is.null(getData)) return()
    data = getData()

    output$mDataTable = renderTable({
      df = data$metadata
    })

    output$dDataTable = renderTable({
      df = data$data
    })

    observeEvent(input$done, {
      df = data.frame(rowSeq = 1, colSeq = 1, dummy = NaN)
      mf = data.frame(groupingType = c("rowSeq", "colSeq", "QuantitationType"),
              labelDescription = c("rowSeq", "colSeq", "dummy"))
      result = AnnotatedData$new(data = df, metadata = mf)
      context$setResult(result)
      return()
    })
  })
}

#' @export
shinyServerShowResults = function(input, output, session, context) {
  getFolderReactive = context$getRunFolder()
  getDataReactive = context$getData()
  observe({
    getFolder = getFolderReactive$value
    if (is.null(getFolder)) return()
    folder = getFolder()

    getData=getDataReactive$value
    if (is.null(getData)) return()

    data = getData()
    save(file = file.path(folder, "aCubeDump.RData"), data)
    shell.exec(folder)
  })

}
