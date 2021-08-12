from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
<<<<<<< HEAD
    return 'Test string...234'
=======
    return 'Test string...2345'
>>>>>>> feature
