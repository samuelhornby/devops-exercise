FROM python:3
MAINTAINER Samuel Hornby
WORKDIR /usr/src/app
RUN apt update
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "./api.py"]
