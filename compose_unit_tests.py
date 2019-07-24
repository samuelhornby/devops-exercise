import unittest
import requests


class TestAPI(unittest.TestCase):

    def test_compose(self):
        print("composing")

    def test_put(self):
        r = requests.put("put something")
        self.assertEqual(r.status_code, 200)

    def test_get(self):
        r = requests.get("get something")
        self.asserEqual(r.status_code, 200)
