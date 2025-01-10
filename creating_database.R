library("RMySQL")
con <- dbConnect(MySQL(),user = "root",password ="Div2004#17",dbname="shop")
inventory_table <- "create table IF NOT Exists inventory (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
category VARCHAR(50),
qty INT NOT NULL DEFAULT 0,
price DECIMAL(10, 2) NOT NULL,
min_stock INT NOT NULL DEFAULT 0
)
"

dbExecute(con,inventory_table)

transactions_table <- "
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    type ENUM('incoming', 'outgoing') NOT NULL,
    quantity INT NOT NULL,
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory(id)
);
"

dbExecute(con,transactions_table)

purchase_orders_table <- "
CREATE TABLE IF NOT EXISTS purchase_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    status ENUM('pending', 'ordered', 'received') NOT NULL DEFAULT 'pending',
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory(id)
);
"

dbExecute(con,purchase_orders_table)


insert_inventory_data <- "
INSERT INTO inventory (name, category, qty, price, min_stock)
VALUES
    ('Apples', 'Fruits', 50, 1.50, 20),
    ('Bananas', 'Fruits', 30, 1.20, 15),
    ('Rice', 'Grains', 100, 0.80, 50),
    ('Milk', 'Dairy', 10, 0.99, 5),
    ('Bread', 'Bakery', 25, 1.25, 10);
"
dbExecute(con, insert_inventory_data)

insert_transactions_data <- "
INSERT INTO transactions (item_id, type, quantity)
VALUES
    (1, 'outgoing', 10),
    (2, 'incoming', 20),
    (3, 'outgoing', 15),
    (4, 'incoming', 5),
    (5, 'outgoing', 10);
"
dbExecute(con, insert_transactions_data)

insert_purchase_orders_data <- "
INSERT INTO purchase_orders (item_id, quantity, status)
VALUES
    (1, 20, 'pending'),
    (4, 10, 'ordered'),
    (5, 15, 'received');
"
dbExecute(con, insert_purchase_orders_data)
dbDisconnect(con)
