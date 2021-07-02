import psutil
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello_world():
    freq = psutil.cpu_freq()
    return dict(
        cpu=dict(frequency=dict(current=freq.current, max=freq.max, min=freq.min))
    )
