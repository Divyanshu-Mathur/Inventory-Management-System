library("plumber")
library("RMySQL")
con <- dbConnect(MySQL(),user="root",password="Div2004#17",dbname="shop")


#* fetch all inventory items
#* @get /inventory
function(){
  data <- dbGetQuery(con,"select * from inventory")
  return(data)
}

#* fetch particular item using item id
#* @get /inventory/<id>
function(id){
  query <- paste("select * from inventory where id=",id)
  data <- dbGetQuery(con,query)
  return(data)
}


#* add a new item
#* @post /add_inventory
function(name,category,qty,price,min_stock){
  query <- sprintf("insert into inventory(name,category,qty,price,min_stock) values('%s','%s',%d,%.2f,%d)",name, category, as.numeric(qty), as.numeric(price), as.numeric(min_stock))
  data <- dbExecute(con,query)
  return(list(message = "Item added!!"))
}

#* Update an inventory item
#* @put /inventory/<id>
function(id, name = NULL, category = NULL, qty = NULL, price = NULL, min_stock = NULL) {
  updates <- c()
  if (!is.null(name)) updates <- c(updates, sprintf("name = '%s'", name))
  if (!is.null(category)) updates <- c(updates, sprintf("category = '%s'", category))
  if (!is.null(qty)) updates <- c(updates, sprintf("qty = %d", as.numeric(qty)))
  if (!is.null(price)) updates <- c(updates, sprintf("price = %.2f", as.numeric(price)))
  if (!is.null(min_stock)) updates <- c(updates, sprintf("min_stock = %d", as.numeric(min_stock)))
  
  query <- sprintf("UPDATE inventory SET %s WHERE id = %s;", paste(updates, collapse = ", "), id)
  dbExecute(con, query)
  return(list(message = "Item updated successfully"))
}



#* Delete an inventory item
#* @delete /inventory/<id>
function(id) {
  query <- sprintf("DELETE FROM inventory WHERE id = %s;", id)
  dbExecute(con, query)
  return(list(message = "Item deleted successfully"))
}


#* Log a stock transaction
#* @post /transactions
function(item_id, type, quantity) {
  query <- sprintf(
    "INSERT INTO transactions (item_id, type, quantity) VALUES (%d, '%s', %d);",
    as.numeric(item_id), type, as.numeric(quantity)
  )
  dbExecute(con, query)
  return(list(message = "Transaction logged successfully"))
}

#* Fetch transaction history
#* @get /transactions
function() {
  query <- "SELECT * FROM transactions;"
  result <- dbGetQuery(con, query)
  return(result)
}

#* Create a purchase order
#* @post /purchase-orders
function(item_id, quantity,status) {
  query <- sprintf(
    "INSERT INTO purchase_orders (item_id, quantity, status) VALUES (%d, %d, '%s');",
    as.numeric(item_id), as.numeric(quantity),status
  )
  dbExecute(con, query)
  return(list(message = "Purchase order created successfully"))
}

#* Fetch all purchase orders
#* @get /purchase-orders
function() {
  query <- "SELECT * FROM purchase_orders;"
  result <- dbGetQuery(con, query)
  return(result)
}


#* Alert for low stock
#*  @get /low_stock
function(){
  query <- "SELECT * FROM inventory WHERE qty < min_stock;"
  result <- dbGetQuery(con,query)
  return(result)
}



