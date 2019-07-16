# DevOps exercise for n3

## Description

This project is a RETful web app using Flask and Redis.

## Compose project

To run the services use the following command:
```
docker-compose up
```

## Example usage

Upload data using the following example:
```
curl http://127.0.0.1:5000/key -d '{"key":"key1", "value":"value1"}' -X PUT -H 'content-type: application/json'

```
If data being uploaded is in a valid JSON format, it will be successfully uploaded, otherwise you will see a 500 error message.

Retrieve stored Data using the following example:
```
curl http://127.0.0.1:5000/key/key1 -X GET

```

If the key:value pair being requested exists, it will be output in JSON format, otherwise you will see a 404 error message.