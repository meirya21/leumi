from crypt import methods
from multiprocessing import connection
from flask import Flask, render_template, request
from flask_pymongo import PyMongo
from pymongo import MongoClient
import pymongo

app = Flask(__name__)

mongodb = MongoClient("mongodb://admin:admin@mongo-mongodb-0.mongo-mongodb-headless:27017/feed")

@app.route("/")
def feedback():
   return render_template('feedback.html')

@app.route('/read', methods=['GET'])
def read_data():
    db = mongodb.feed
    collection = db.feed
    records = (collection.find({}))
    return render_template("index.html", records=records)

@app.route("/data", methods=['GET'])
def show_data():
    if request.method == 'GET':
        rating = request.args.get("rating")
        rating1= request.args.get("rating1")
        rating2 = request.args.get("rating2")
        commentText = request.args.get("commentText")
    if rating1 != True and rating2 != True and rating != True:
        var = {"cleanliness": rating1, "courtesy": rating2, "overall": rating, "commentText": commentText}
        db = mongodb.feed
        collection = db.feed
        collection.insert_one(var)
        return render_template('retind.html')

@app.route("/delete")
def delete():
    db = mongodb.feed
    collection = db.feed
    collection.delete_many({})
    return "All data deleted"


if __name__ == "__main__":
    app.debug = True
    app.run(host="0.0.0.0", port=8000)