#! /bin/bash

docker ps | tail -n +2  | cut -d   -f 1 | tee echo | xargs docker kill
