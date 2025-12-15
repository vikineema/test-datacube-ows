#!make
SHELL := /usr/bin/env bash

include  .env

ENV_FILE =  $(abspath .env)
export ENV_FILE

setup: build up init

build:
	docker compose build

up: ## Bring up your Docker environment
	docker compose up -d db
	docker compose up -d jupyter

down:
	docker compose down --remove-orphans

init: ## Prepare the database, initialise the database schema.
	docker compose  exec -T jupyter datacube -v system init

add-products: ## Add products to the datacube database:
	# Add products to be added to the csv file products/products.csv
	docker compose exec -T jupyter dc-sync-products products/products.csv --update-if-exists

index-datasets: ## Index datasets from a given path
	docker compose  exec jupyter s3-to-dc \
		s3://<bucket_name>/<prefix>/**/*.json \
		--no-sign-request --allow-unsafe --stac --log=info <product_name>

jupyter-shell: ## Open shell in jupyter service
	docker compose  exec jupyter /bin/bash

## Explorer
setup-explorer: ## Setup the datacube explorer
	# Initialise and create product summaries
	docker compose up -d explorer
	docker compose exec -T explorer cubedash-gen --init --all
	# Service available on http://localhost:${EXPLORER_PORT}/products

explorer-refresh-products:
	docker compose exec -T explorer cubedash-gen --init --all

explorer-shell: ## Open shell in explorer service
	docker compose exec explorer /bin/bash