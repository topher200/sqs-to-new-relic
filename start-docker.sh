#!/bin/bash

docker build . -t topher200/sns-to-new-relic
docker run --env-file .env topher200/sns-to-new-relic
