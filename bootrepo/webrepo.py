import os

from flask import Flask

import bootrepo

app = Flask(__name__)


@app.route('/')
def hello_world():
    print "CleanUp before use."
    for file_name in os.listdir(bootrepo.STATIC_FILES_DIR):
        os.unlink(os.path.join(bootrepo.STATIC_FILES_DIR, file_name))

    return 'Inline PXE server.'


if __name__ == '__main__':
    app.run()
