from flask import Flask, request
from flask_restful import Resource, Api
import redis
import socket

app = Flask(__name__)
api = Api(app)


class RedisConnection:
    def __init__(self):
        self.redis_host = 'localhost'
        self.port = 6379
        self.db = 0

    def connect(self):
        try:
            r = redis.Redis(host=self.redis_host, port=self.port, db=self.db)
            return r
        except Exception as e:
            return e


class GetData(Resource):
    """
    Handles get requests
    """
    def get(self, key):
        r = RedisConnection()
        rc = r.connect()
        value = rc.get(key).decode("utf-8")
        output = {"key": key, "value": value}
        if key is not None and value is not None:  # Confirm data exists on Redis
            return output, "202"
        else:
            return "404"


class PutData(Resource):
    """
    Handles put requests
    """
    def put(self):
        content = request.get_json()  # read data from http request
        key = content['key']
        value = content['value']
        if key is not None and value is not None:  # Confirm data is valid
            r = RedisConnection()
            rc = r.connect()
            rc.set(key, value)  # Store data on Redis
            return "OK 202"


api.add_resource(GetData, '/key/<string:key>')
api.add_resource(PutData, '/key')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
