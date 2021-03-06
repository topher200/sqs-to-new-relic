#!/bin/bash

docker stop nr-plugin
docker rm nr-plugin
docker build -t topher200/sqs-to-new-relic .
docker run --env-file .env --name nr-plugin $* topher200/sqs-to-new-relic
docker logs -f nr-plugin
