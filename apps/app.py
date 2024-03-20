from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    secret_value = os.getenv('HELLO_WORLD_SECRET')
    return f'Hello, World! {secret_value}'

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
