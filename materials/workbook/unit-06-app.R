library(dplyr)
library(dbplyr)
library(DBI)
library(shiny)
library(ggplot2)
library(ggiraph)

con <- dbConnect(
  odbc::databricks(),
  HTTPPath = "/sql/1.0/warehouses/300bd24ba12adf8e"
)

orders <- tbl(con, I("samples.tpch.orders"))
customers <- tbl(con, I("samples.tpch.customer"))
nation <- tbl(con, I("samples.tpch.nation"))

prep_orders <- orders %>% 
  left_join(customers, by = c("o_custkey" = "c_custkey")) %>% 
  left_join(nation, by = c("c_nationkey" = "n_nationkey")) %>% 
  mutate(
    order_year = year(o_orderdate), 
    order_month = month(o_orderdate)
  ) %>% 
  rename(customer = o_custkey) %>% 
  select(-ends_with("comment"),  -ends_with("key"))

countries <- nation %>% 
  pull(n_name)

ui <- fluidPage(
  selectInput("country", "Country:", choices = countries, selected = "FRANCE"),
  girafeOutput("sales_plot")
)

server <-  function(input, output) {
  output$sales_plot <- renderGirafe({
    sales_by_year <- prep_orders %>%
      filter(n_name == !!input$country) %>%
      group_by(order_year) %>%
      summarise(
        total_price = sum(o_totalprice, na.rm = TRUE)
      ) %>%
      collect()
    
    breaks <- as.double(quantile(c(0, max(sales_by_year$total_price))))
    breaks_labels <- paste(round(breaks / 1000000000, 1), "B")
    
    g <- sales_by_year %>%
      ggplot() +
      geom_col_interactive(aes(order_year, total_price, data_id = order_year, tooltip = total_price)) +
      scale_x_continuous(breaks = unique(sales_by_year$order_year)) +
      scale_y_continuous(breaks = breaks, labels = breaks_labels) +
      xlab("Year") +
      ylab("Total Sales") +
      labs(title = "Sales by year", subtitle = input$country) +
      theme_light()
    
    girafe(ggobj = g, options = list(opts_selection(type = "single")))
  })
  
  output$monthly_sales <- renderPlot({
    sales_by_month <- prep_orders %>%
      filter(
        n_name == !!input$country, 
        order_year == !!input$sales_plot_selected
      ) %>%
      group_by(order_month) %>%
      summarise(
        total_price = sum(o_totalprice, na.rm = TRUE)
      ) %>%
      collect()
    
    breaks <- as.double(quantile(c(0, max(sales_by_month$total_price))))
    breaks_labels <- paste(round(breaks / 1000000000, 1), "B")
    
    sales_by_month %>%
      ggplot() +
      geom_col(aes(order_month, total_price)) +
      scale_x_continuous(breaks = unique(sales_by_month$order_month)) +
      scale_y_continuous(breaks = breaks, labels = breaks_labels) +
      xlab("Year") +
      ylab("Total Sales") +
      labs(
        title = "Sales by month", 
        subtitle = paste0(input$country, " - ", input$sales_plot_selected)
      ) +
      theme_light()
  })
  
  observeEvent(input$sales_plot_selected, {
    showModal(
      modalDialog(
        title = paste0(input$country, " - ", input$sales_plot_selected),
        plotOutput("monthly_sales")
      )
    )
  })
}

shinyApp(ui, server)