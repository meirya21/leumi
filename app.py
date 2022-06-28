from crypt import methods
from flask import Flask, render_template, request
from flask_pymongo import PyMongo
from pymongo import MongoClient
import pymongo

app = Flask(__name__)

mongodb = pymongo.MongoClient('mongo', 27017, username='admin', password='admin')
# mongodb = pymongo.MongoClient('mongodb://admin:admin1234@mongo-mongodb-0.mongo-mongodb-headless.default.svc.cluster.local:27017/')
db = mongodb["feed"]
mycol = db["feedback"]
# app.config["MONGO_URI"] = 'mongodb://admin:admin1234@mongo-mongodb-0.mongo-mongodb-headless.default.svc.cluster.local, mongo-mongodb-1.mongo-mongodb-headless.default.svc.cluster.local, mongo-mongodb-2.mongo-mongodb-headless.default.svc.cluster.local:27017/mongodb'

@app.route("/")
def feedback():
   return render_template('feedback.html')

@app.route("/read")
def read_data():
    customer = mycol.find({})
    return render_template('index.html', customer=customer)

@app.route("/data", methods=['GET'])
def show_data():
    if request.method == 'GET':
        rating = request.args.get("rating")
        rating1= request.args.get("rating1")
        rating2 = request.args.get("rating2")
        commentText = request.args.get("commentText")
    if rating1 != True and rating2 != True and rating != True:
        var = {"cleanliness": rating1, "courtesy": rating2, "overall": rating, "commentText": commentText}
        mycol.insert_one(var)
        return render_template('retind.html')


@app.route("/delete")
def delete():
    mycol.delete_many({})
    return "All data deleted"


if __name__ == "__main__":
    app.debug = True
    app.run(host="0.0.0.0", port=8000)