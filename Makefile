DOCKER_COMPOSE  = docker-compose

EXEC_PHP        = $(DOCKER_COMPOSE) exec php
EXEC_DB         = $(DOCKER_COMPOSE) exec db

SYMFONY         = $(EXEC_PHP) bin/console
COMPOSER        = $(EXEC_PHP) composer

				#####################################
				###                               ###
				###    Docker-compose utilities   ###
				###                               ###
				#####################################

################ <help> #####################
.DEFAULT_GOAL := help
help: ## Show this help message
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
################ </build> #####################

################ <help> #####################
build: ## Build the Docker images
	@echo 'build Dockerfiles into container'
	$(DOCKER_COMPOSE) build --pull --force-rm
.PHONY: build
################ </build> #####################

################ <start> #####################
start: ## Start all containers
	@echo 'Starting containers in dev mode'
	$(DOCKER_COMPOSE) up -d --remove-orphans
.PHONY: start
################ </start> #####################

################ <stop> #####################
stop: ## Stop running containers
	@echo 'Stop all docker containers'
	$(DOCKER_COMPOSE) down
.PHONY: stop
################ </stop> #####################

################ <kill> #####################
kill:
	docker-compose kill
	docker-compose down --volumes --remove-orphans
	sudo rm -rf logs/*
################ </kill> #####################

################ <ps> #####################
ps:
	@echo 'List all containers managed by the environment'
	$(DOCKER_COMPOSE) ps
################ <ps> #####################

################ <logs> #####################
logs:
	@echo 'Follow logs generated by all containers from the containers creation'
	docker-compose logs -f
.PHONY: logs
################ </logs> #####################

				#####################################
				###                               ###
				###   Symfony commands utilities  ###
				###                               ###
				#####################################

################ <cache> #####################
cc: ## Clear and warmup PHP cache
	$(SYMFONY) cache:clear --no-warmup
	$(SYMFONY) cache:warmup
.PHONY: cc
################ </cache> #####################

################ <composer install> #####################
vendor: ## Install PHP vendors
	$(COMPOSER) install
.PHONY: vendor
################ </composer install> #####################

################ <database> #####################
db: ## Reset the database
	@echo "Waiting for database..."
	@while ! $(EXEC_DB) mysql -uroot -proot -e "SELECT 1;" > /dev/null 2>&1; do sleep 0.5 ; done
	-$(SYMFONY) doctrine:database:drop --if-exists --force
	-$(SYMFONY) doctrine:database:create --if-not-exists
	-$(SYMFONY) doctrine:schema:create
.PHONY: db
################ <logs> #####################

################ <phpcs-checker> #####################

checker:
	@echo "Run the phpcs checker"
	$(COMPOSER) cscheck
.PHONY: checker
################ <phpcs-checker> #####################


################ <phpcs-fixer> #####################
fixer: 
	@echo "Run the phpcs-fixer"
	$(COMPOSER) csfix
.PHONY: fixer
################ </phpcs-fixer> #####################

################ <controller> #####################
controller:
	@echo "Creating à new controller :"
	$(SYMFONY) make:controller
################ </controller> #####################