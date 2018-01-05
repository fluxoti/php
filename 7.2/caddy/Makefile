BUILD_NAME := 'local/php-7.2-caddy'

# bins
DOCKER := $(shell which docker)

all: build

build:
	${DOCKER} build -t ${BUILD_NAME}:latest   .

build-no-cache:
	${DOCKER} build --rm --no-cache -t ${BUILD_NAME}:latest   .	