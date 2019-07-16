FROM python:3
MAINTAINER Samuel Hornby
WORKDIR /usr/src/app
RUN apt update -y
RUN pip install flask redis
RUN pip install -U flask_restful
COPY . .
CMD ["python", "./api.py"]
