from flask import Flask, render_template,request,redirect,url_for,jsonify
import requests

app = Flask(__name__)
url = "http://127.0.0.1:8000"



#finding all inventory items
#low stock alert
@app.route('/', methods=['GET'])
def home():
    response = requests.get(f"{url}/inventory")
    low_stk = requests.get(f"{url}/low_stock").json()
    print(low_stk)
    if response.status_code == 200:
        data = response.json()
    else:
        data = []
    return render_template("home.html", data=data,low_stk=low_stk)


#finding details of a particular item
@app.route('/item/<int:id>')
def get_item(id):
    item = requests.get(f"{url}/inventory/{id}").json()
    return render_template("item.html",data=item)


#editing a particular item
@app.route('/item/<int:id>/edit',methods=['GET','POST'])
def edit_item(id):
    item = requests.get(f"{url}/inventory/{id}").json()
    if not item:
        return render_template("update_item.html",id=-1)
    elif request.method =='POST':
        print(item)
        item[0]["name"] = request.form["name"]
        item[0]["price"] = float(request.form["price"])
        item[0]["qty"] = int(request.form["qty"])
        item[0]["category"] = request.form["category"]
        item[0]["min_stock"] = int(request.form["min_stock"])
        print("Item updated")
        requests.put(f"{url}/inventory/{id}", data=item[0])
        return redirect(url_for("get_item", id=id))
    return render_template("update_item.html",id=id,data=item)


#delete a particular item
@app.route('/item/<int:id>/delete',methods=['POST'])
def delete_item(id):
    item = requests.get(f"{url}/inventory/{id}").json()
    msg="Deleted Succefully"
    if not item:
        msg="Item not found"
        return render_template("delete.html",message=msg)
    requests.delete(f"{url}/inventory/{id}")
    return redirect(url_for("home"))
    
    
#add a new item    
@app.route('/add_item', methods=['GET', 'POST'])
def add_item():
    if request.method == 'POST':
        # Get data from the form
        name = request.form['name']
        category = request.form['category']
        qty = int(request.form['qty'])
        price = float(request.form['price'])
        min_stock = int(request.form['min_stock'])

        # Prepare payload to send to R API
        payload = {
            'name': name,
            'category': category,
            'qty': qty,
            'price': price,
            'min_stock': min_stock
        }

        # Post data to R API
        try:
            response = requests.post(f"{url}/add_inventory", json=payload)
            if response.status_code == 200:
                return redirect(url_for("home"))
            else:
                return redirect(url_for("home"))
        except Exception as e:
            return render_template("error.html", error=str(e))

    return render_template('add_item.html')
        
    


#finding all transactions details 
@app.route('/transaction',methods=['GET','POST'])
def log():
    item = requests.get(f"{url}/transactions").json()
    return render_template("transactions.html",data=item)


#add a new transaction
@app.route('/transaction/new',methods=['GET','POST'])
def add_transaction():
    if request.method == 'POST':
        item_id = int(request.form['item_id'])
        type = request.form['type']
        quantity = int(request.form['quantity'])
        payload = {
            'item_id': item_id,
            'type': type,
            'quantity': quantity
        }
        try:
            requests.post(f"{url}/transactions", json=payload)
            return redirect(url_for("log"))
        except Exception as e:
            return render_template("error.html", error=str(e))

    return render_template('add_transaction.html')

    

#display purchase orders
@app.route('/purchase_order')
def purchase():
    data = requests.get(f"{url}/purchase-orders").json()
    return render_template("purchase_order.html",data=data)

@app.route('/purchase/new',methods=['GET','POST'])
def add_purchase():
    if request.method == 'POST':
        item_id=int(request.form['item_id'])
        quantity = int(request.form['quantity'])
        status=request.form['status']
        payload= {
            'item_id':item_id,
            'quantity':quantity,
            'status':status
        }   
        requests.post(f"{url}/purchase-orders",json=payload)   
        return redirect(url_for("purchase"))   
    return render_template("add_purchase.html")

if __name__ == "__main__":
    app.run(debug=True)
