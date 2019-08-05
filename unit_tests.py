import unittest
import requests
import json


class TestAPI(unittest.TestCase):

    def test_put(self):
        # test put
        print("test put")
        data = {'key': 'mykey1', "value": "my value"}
        headers = {"Content-Type": "application/json"}
        r = requests.put("http://localhost:5000/key", data=json.dumps(data), headers=headers)
        self.assertEqual(r.status_code, 200)

    def test_get(self):
        # test get
        print("test get")
        data = {'key': 'mykey', "value": "my value"}
        headers = {"Content-Type": "application/json"}
        requests.put("http://localhost:5000/key", data=json.dumps(data), headers=headers)

        r = requests.get("http://localhost:5000/key/mykey")
        self.assertEqual(r.status_code, 200)


if __name__ == '__main__':
    unittest.main()

