#!/usr/bin/env make

.PHONY: docker-console console start setup docker-build deploy deploy-fn logs invoke login local read-local-enviroment

export NODE_ENV=development

# ---------------------------------------------------------------------------------------------------------------------
# CONFIG
# ---------------------------------------------------------------------------------------------------------------------
DOCKER_IMAGE_VERSION=dev-enviroment
DOCKER_IMAGE_TAG=serverless-aws-node:$(DOCKER_IMAGE_VERSION)

# ---------------------------------------------------------------------------------------------------------------------
# SETUP
# ---------------------------------------------------------------------------------------------------------------------

setup:
	./bin/setup.sh

read-local-enviroment:
	. ./dev.env && echo "$$SECRET_FUNCTION_TOKEN"

# ---------------------------------------------------------------------------------------------------------------------
# DOCKER
# ---------------------------------------------------------------------------------------------------------------------

docker-build:
	@docker build -t $(DOCKER_IMAGE_TAG) .

docker-console:
	docker-compose run --rm --publish=8080:8080 dev-enviroment /bin/bash

console: docker-console

# ---------------------------------------------------------------------------------------------------------------------
# SERVERLESS
# ---------------------------------------------------------------------------------------------------------------------

# Redeploy entire stack throught cloud function
deploy: 
	serverless deploy

login: 
	serverless login

# Redeploy only the code + dependencies to update the AWS lambda function
# Faster then full deploy
deploy-fn:
	sls deploy function -f hello

# View logs of hello function and tail via -t flag
logs:
	serverless logs -f hello -t

# Invoke the Lambda directly and print log statements via
invoke:
	serverless invoke --function=hello --log

# Invoke functioon localy
# Unforrtunately  we cannot push  all enviroment variables to function only by key=value pairs after '-e' paramet
local:
	serverless invoke local --function=hello --log -e SECRET_FUNCTION_TOKEN=$(SECRET_FUNCTION_TOKEN)

# Unforrtunately  we cannot push  all enviroment variables to function only by key=value pairs after '-e' paramet
local-env:
	. ./dev.env && serverless invoke local --function=hello --log -e SECRET_FUNCTION_TOKEN="$$SECRET_FUNCTION_TOKEN"
