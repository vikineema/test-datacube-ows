#!make
SHELL := /usr/bin/env bash

include  .env

ENV_FILE =  $(abspath .env)
export ENV_FILE

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

index-datasets-esa_worldcereal_activecropland: ## Index datasets from a given path
	docker compose  exec jupyter s3-to-dc \
		"s3://deafrica-input-datasets/esa_worldcereal/activecropland/tc-wintercereals/**/*.stac-item.json" \
		--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_activecropland

index-datasets-esa_worldcereal_maize_active: ## Index datasets from a given path
	docker compose  exec jupyter s3-to-dc \
		"s3://deafrica-input-datasets/esa_worldcereal/activecropland/tc-maize-main/**/*.stac-item.json" \
		--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_maize_active

index-datasets-esa_worldcereal_maize_irrigation: ## Index datasets from a given path
	docker compose  exec jupyter s3-to-dc \
		"s3://deafrica-input-datasets/esa_worldcereal/irrigation/tc-maize-main/**/*.stac-item.json" \
		--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_maize_irrigation

index-datasets-esa_worldcereal_maize_main: ## Index datasets from a given path
	docker compose  exec jupyter s3-to-dc \
		"s3://deafrica-input-datasets/esa_worldcereal/maize/tc-maize-main/**/*.stac-item.json" \
		--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_maize_main

index-datasets-esa_worldcereal_temporarycrops:
	docker compose  exec jupyter s3-to-dc \
			"s3://deafrica-input-datasets/esa_worldcereal/temporarycrops/tc-annual/**/*.stac-item.json" \
			--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_temporarycrops

index-datasets-esa_worldcereal_wintercereals:
	docker compose  exec jupyter s3-to-dc \
			"s3://deafrica-input-datasets/esa_worldcereal/wintercereals/tc-wintercereals/**/*.stac-item.json" \
			--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_wintercereals

index-datasets-esa_worldcereal_wintercereals_irrigation:
	docker compose  exec jupyter s3-to-dc \
			"s3://deafrica-input-datasets/esa_worldcereal/irrigation/tc-wintercereals/**/*.stac-item.json" \
			--no-sign-request --allow-unsafe --stac --log=info esa_worldcereal_wintercereals_irrigation

index-esa-worldcereal: index-datasets-esa_worldcereal_activecropland index-datasets-esa_worldcereal_maize_irrigation index-datasets-esa_worldcereal_maize_main index-datasets-esa_worldcereal_temporarycrops index-datasets-esa_worldcereal_wintercereals index-datasets-esa_worldcereal_wintercereals_irrigation

setup: init add-products index-esa-worldcereal setup-explorer

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
	make test-ows-config
	# Cleanup up any datacube-ows 1.8.x tables/views
	docker compose exec ows datacube-ows-update --cleanup --env default
	# Refresh the ODC spatio-temporal materialised views
	docker compose exec ows datacube-ows-update --views
	# Update ranges for all configured OWS layers
	docker compose exec ows datacube-ows-update

down-ows:
	docker compose down --remove-orphans ows

ows-shell: ## Open shell in ows service
	docker compose exec ows /bin/bash

reset-ows: down-ows setup-ows

full-reset: down up init add-products index-datasets setup-explorer setup-ows

test-ows-config:
	docker compose exec ows datacube-ows-cfg check -i /env/config/inventory/dev_af/inventory.json

copy-config:
	# cp ~/dev/digitalearthafrica/config/services/ows_refactored/water_quality/* services/ows_refactored/water_quality/
	cp ~/dev/digitalearthafrica/config/services/ows_refactored/wofs/* services/ows_refactored/wofs/