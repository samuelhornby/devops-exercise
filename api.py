from flask import Flask, request
from flask_restful import Resource, Api
import redis

app = Flask(__name__)
api = Api(app)


class GetData(Resource):
    def get(self, _id):
        r = redis.Redis(host='localhost', port=7001, db=0)
        value = r.hgetall(_id)
        return value


class PutData(Resource):
    def put(self):
        content = request.get_json()
        r = redis.Redis(host='localhost', port=7001, db=0)
        r.hmset("test", content)

        return content


api.add_resource(GetData, '/key/<string:_id>')
api.add_resource(PutData, '/key')

if __name__ == '__main__':
    app.run(debug=True)
