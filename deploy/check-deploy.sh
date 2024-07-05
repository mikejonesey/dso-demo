#!/bin/bash

docker run -i kubesec/kubesec scan /dev/stdin < dso-demo-deploy.yaml

