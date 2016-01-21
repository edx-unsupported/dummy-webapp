.DEFAULT_GOAL := test

.PHONY: clean compile_translations dummy_translations extract_translations fake_translations help html_coverage \
	migrate pull_translations push_translations quality requirements test update_translations validate

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  clean                      delete generated byte code and coverage reports"
	@echo "  compile_translations       compile translation files, outputting .po files for each supported language"
	@echo "  dummy_translations         generate dummy translation (.po) files"
	@echo "  extract_translations       extract strings to be translated, outputting .mo files"
	@echo "  fake_translations          generate and compile dummy translation files"
	@echo "  help                       display this help message"
	@echo "  html_coverage              generate and view HTML coverage report"
	@echo "  migrate                    apply database migrations"
	@echo "  pull_translations          pull translations from Transifex"
	@echo "  push_translations          push source translation files (.po) from Transifex"
	@echo "  quality                    run PEP8 and Pylint"
	@echo "  requirements               install requirements for local development"
	@echo "  test                       run tests and generate coverage report"
	@echo "  validate                   run tests and quality checks"
	@echo "  start-devstack             run a local development copy of the server"
	@echo "  open-devstack              open a shell on the server started by start-devstack"
	@echo "  pkg-devstack               build the dummy_webapp image from the latest configuration and code"
	@echo ""

clean:
	find . -name '*.pyc' -delete
	coverage erase
	rm -rf assets

local-requirements:
	pip install -qr requirements/local.txt --exists-action w

requirements:
	pip install -qr requirements.txt --exists-action w

test: clean
	coverage run ./manage.py test dummy_webapp --settings=dummy_webapp.settings.test
	coverage report

quality:
	pep8 --config=.pep8 dummy_webapp *.py
	pylint --rcfile=pylintrc dummy_webapp *.py

validate: test quality

migrate:
	python manage.py migrate

html_coverage:
	coverage html && open htmlcov/index.html

extract_translations:
	python manage.py makemessages -l en -v1 -d django
	python manage.py makemessages -l en -v1 -d djangojs

dummy_translations:
	cd dummy_webapp && i18n_tool dummy

compile_translations:
	python manage.py compilemessages

fake_translations: extract_translations dummy_translations compile_translations

pull_translations:
	tx pull -a

push_translations:
	tx push -s

start-devstack:
	docker-compose --x-networking up

open-devstack:
	docker exec -it dummy_webapp /edx/app/dummy_webapp/devstack.sh open

pkg-devstack:
	docker build -t dummy_webapp:latest -f docker/build/dummy_webapp/Dockerfile git://github.com/edx/configuration
