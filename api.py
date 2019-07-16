from flask import Flask, request
from flask_restful import Resource, Api
import redis

app = Flask(__name__)
api = Api(app)


class GetData(Resource):
    """
    Handles get requests
    """
    def get(self, key):
        try:
            r = redis.Redis(host='devops-exercise_database_1', port=6379, db=0)
            value = r.get(key).decode("utf-8")
            output = {"key": key, "value": value}
            if key is not None and value is not None:  # Confirm data exists on Redis
                return output, "202"
            else:
                return "404"
        except Exception as e:
            return "404"


class PutData(Resource):
    """
    Handles put requests
    """
    def put(self):
        try:
            content = request.get_json()  # read data from http request
            key = content['key']
            value = content['value']
            if key is not None and value is not None:  # Confirm data is valid
                r = redis.Redis(host='devops-exercise_database_1', port=6379, db=0)
                r.set(key, value)  # Store data on Redis
                return "OK 202"
        except Exception as e:
            return "500"


api.add_resource(GetData, '/key/<string:key>')
api.add_resource(PutData, '/key')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
