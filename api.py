from flask import Flask, request
from flask_restful import Resource, Api
import redis

app = Flask(__name__)
api = Api(app)


class RedisConnection:
    def __init__(self):
        self.redis_host = 'redis_database_1'
        self.port = 6379
        self.db = 0

    def connect(self):
        try:
            r = redis.Redis(host=self.redis_host, port=self.port, db=self.db)
        except ConnectionError as e:
            print(e)
        return r


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
            return output
        else:
            return 404


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
            return 202
        else:
            return 500


api.add_resource(GetData, '/key/<string:key>')
api.add_resource(PutData, '/key')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
