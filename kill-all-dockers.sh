#! /bin/bash

docker ps | tail -n +2  | cut -d ' ' -f 1 | xargs docker kill
