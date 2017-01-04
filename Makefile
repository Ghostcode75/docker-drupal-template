# ----------------
# Make help script
# ----------------

# Usage:
# Add help text after target name starting with '\#\#'
# A category can be added with @category. Team defaults:
# 	dev-environment
# 	docker
# 	test

# Output colors
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Script
HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	print "see makefile for additional commands\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

help: ## Show help (same if no target is specified).
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

#
# Dev Environment
#
install:	##@dev-environment Build development environment from scratch.

fetch-db:	##@dev-environment Download `database.sql` from AWS.

fetch-files:	##dev-environment Download `/files` from AWS.

import-db:	##dev-environment Import locally cached copy of `database.sql` to proj dir.

import-files:	##dev-environment Import locally cached copy of `/files` to proj dir.

pull-db:	##dev-environment Download AND import `database.sql`.
	make fetch-db
	make import-db

pull-files:	##dev-environment Download AND import `/files`.
	make fetch-files
	make import-files

pull-all:	##dev-environment Download AND import `database.sql` + `/files`.
	make pull-db
	make pull-files

prep-site:	##@drush Run site-installation drush commands (updb, cc all, fra, etc).
#Example:
	#-docker-compose exec -T web drush @omega.docker sql-query "DELETE FROM cache WHERE cid LIKE 'ctools_plugin_files%';"
	#-docker-compose exec -T web drush @omega.docker rr -yv
	#-docker-compose exec -T web drush @omega.docker updb --cache-clear=0 -yv
	#-docker-compose exec -T web drush @omega.docker cc all -yv
	#-docker-compose exec -T web drush @omega.docker fr-all -yv
	#-docker-compose exec -T web drush @omega.docker en maillog -yv
	#-docker-compose exec -T web drush @omega.docker composer-json-rebuild -yv
	#-docker-compose exec -T web drush @omega.docker composer-manager install -yv
	#-docker-compose exec -T web drush @omega.docker omega-cenium-create-key -yv

uli:  	##@drush Outputs one-time admin login link for local dev.
#Example:
	#docker-compose exec -T web drush @hptn.docker uli

#
# Docker
#
up: 	##@docker Start containers and display status.
#Example:
	#make down
	#docker-compose -f docker-compose.yml -f docker-compose-sync.yml up -d
	#make status

down:	##@docker Stop and remove containers.
#Example:
	#docker-compose -f docker-compose.yml -f docker-compose-sync.yml down

clean:  ##@docker Unisntall and remove application services and data.
#Example:
	#-docker-compose -f docker-compose.yml -f docker-compose-sync.yml down
	#-docker volume rm hptn_mysql-data

status: ##@docker Print docker logs and container status.
#Example:
	#docker-compose -f docker-compose.yml -f docker-compose-sync.yml logs
	#docker-compose -f docker-compose.yml -f docker-compose-sync.yml ps

#
# Tests
#
tests:	##@test Run code standard and Behat tests
	make behat
	make phpcs
	make phpcbf

behat:  ##@test Run Behat test suite.
#Example:
	#docker-compose exec -T web behat -c www/tests/behat.yml --tags=~@failing --colors -f progress

phpcs:	##@test	Run code standards check.
#Example:
	#docker-compose exec -T web www/bin/phpcs --config-set installed_paths www/vendor/drupal/coder/coder_sniffer
	#docker-compose exec -T web www/bin/phpcs --standard=Drupal www/web/modules/custom/*/* www/web/themes/custom/*/* $(phpcs_config)
	#docker-compose exec -T web www/bin/phpcs --standard=Drupal jsonscripts/* $(phpcs_config)

phpcbf:	##@test Run code standards corrections.
#Example:
	#docker-compose exec -T web www/bin/phpcs --config-set installed_paths www/vendor/drupal/coder/coder_sniffer
	#docker-compose exec -T web www/bin/phpcbf --standard=Drupal www/web/modules/custom/*/* www/web/themes/custom/*/* $(phpcs_config)
	#docker-compose exec -T web www/bin/phpcbf --standard=Drupal jsonscripts/* $(phpcs_config)

#
# Other
#
