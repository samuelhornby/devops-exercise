# Simple DevOps example

## Description

This project is a simple RETful web app using Flask and Redis. The main point of this project is to display devops skills. The project can be composed locally using docker-compose or deployed to AWS EC2 or AWS ECS using Terraform. 

## Compose project locally

To run the services use the following command:
```
docker-compose up --detach --no-recreate
```
## Deploy to AWS
This project can be deployed to either EC2 or ECS

```
cd terraform
cd ecX  # where X = 2 or S
terraform init
terraform apply
```
You will need to provide your AWS access and private key along with your public ssh key.

### Example usage

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
