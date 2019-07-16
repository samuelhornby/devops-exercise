from flask import Flask, request
from flask_restful import Resource, Api
import redis

app = Flask(__name__)
api = Api(app)


class GetData(Resource):
    def get(self, key):
        try:
            r = redis.Redis(host='localhost', port=7001, db=0)
            value = r.get(key)
            return value
        except Exception as e:
            return "500"


class PutData(Resource):
    def put(self):
        try:
            content = request.get_json()
            key = content['key']
            value = content['value']
            r = redis.Redis(host='localhost', port=7001, db=0)
            r.set(key, value)
            return content
        except Exception as e:
            return "500"


api.add_resource(GetData, '/key/<string:key>')
api.add_resource(PutData, '/key')

if __name__ == '__main__':
    app.run(debug=True)
