import os

from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello_world():
    static_files = os.path.join(os.path.dirname(__file__), 'static')
    print "CleanUp before use."
    for file_name in os.listdir(static_files):
        os.unlink(os.path.join(static_files, file_name))

    return 'Inline PXE server.'


if __name__ == '__main__':
    app.run(host='0.0.0.0')
