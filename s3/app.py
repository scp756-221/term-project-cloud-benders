# Standard library modules
import logging
import sys

# Installed packages
from flask import Blueprint
from flask import Flask
from flask import request
from flask import Response

from prometheus_flask_exporter import PrometheusMetrics

import requests

import simplejson as json

# The application

app = Flask(__name__)

metrics = PrometheusMetrics(app)
metrics.info('app_info', 'playlist process')

bp = Blueprint('app', __name__)

database = {}

@bp.route('/', methods=['GET'])
@metrics.do_not_track()
def hello_world():
    return ("Playlist API is running.")

@bp.route('/health')
@metrics.do_not_track()
def health():

    return Response("Server is up!!!", status=200, mimetype="application/json")


@bp.route('/readiness')
@metrics.do_not_track()
def readiness():
    pass


@bp.route('/', methods=['POST'])
def create_playlist():
    pass

@bp.route('/<playlist_id>', methods=['DELETE'])
def delete_playlist():
    pass

@bp.route('/<playlist_id>', methods=['GET'])
def get_playlist():
    pass

@bp.route('/<playlist_id>', methods=['PUT'])
def update_playlist():
    pass

# All database calls will have this prefix.  Prometheus metric
# calls will not---they will have route '/metrics'.  This is
# the conventional organization.
app.register_blueprint(bp, url_prefix='/api/playlist/')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        logging.error("missing port arg 1")
        sys.exit(-1)

    p = int(sys.argv[1])
    # Do not set debug=True---that will disable the Prometheus metrics
    app.run(host='0.0.0.0', port=p, threaded=True)
