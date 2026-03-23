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
		"s3://deafrica-water-quality/mapping/wq_annual/1-0-0/x200/y034/*/*.stac-item.json" \
		--no-sign-request --allow-unsafe --stac --log=info wq_annual

jupyter-shell: ## Open shell in jupyter service
	docker compose  exec jupyter /bin/bash

lint-src:
	docker compose  exec jupyter bash -c "ruff check --fix --unsafe-fixes services/"          
	docker compose  exec jupyter bash -c "ruff format --verbose services/"

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

## OWS
setup-ows: ## Setup the datacube OWS
	docker compose up -d ows
	# Create or update the OWS database schema, including the 
	# spatio-temporal materialised views
	docker compose exec ows datacube-ows-update --schema
	# Cleanup up any datacube-ows 1.8.x tables/views
	docker compose exec ows datacube-ows-update --cleanup --env default
	# Refresh the ODC spatio-temporal materialised views
	docker compose exec ows datacube-ows-update --views
	# Update ranges for all configured OWS layers
	docker compose exec ows datacube-ows-update

ows-shell: ## Open shell in ows service
	docker compose exec ows /bin/bash

reset: down up init add-products index-datasets setup-explorer setup-ows

test-ows-config:
	docker compose exec ows datacube-ows-cfg check -i /env/config/inventory/dev_af/inventory.json