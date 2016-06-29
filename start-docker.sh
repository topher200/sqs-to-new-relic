#!/bin/bash

docker build . -t topher200/sns-to-new-relic
docker run --env-file .env --name nr-plugin $* topher200/sns-to-new-relic
