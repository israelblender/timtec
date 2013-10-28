all: setup_py setup_coveralls setup_js setup_django

ci: setup_ci all settings_ci

create-staging:
	virtualenv ~/env
	~/env/bin/pip install -r requirements.txt
	mkdir -p ~/webfiles/static
	mkdir -p ~/webfiles/media

update-staging:
	cp timtec/settings_local_staging.py timtec/settings_local.py
	~/env/bin/pip install -r requirements.txt
	~/env/bin/python manage.py syncdb --noinput
	~/env/bin/python manage.py collectstatic --noinput
	~/env/bin/python manage.py compilemessages
	touch timtec/wsgi.py

staging: create-staging update-staging

python_tests:
	py.test --pep8 --flakes --cov . . $*

karma_tests:
	karma start tests/confkarma.js $*

all_tests: python_tests karma_tests

setup_ci:
	psql -c 'create database timtec_ci;' -U postgres

setup_py:
	pip install -q -r requirements.txt --use-mirrors
	pip install -q -r dev-requirements.txt --use-mirrors
	python setup.py -q develop

setup_coveralls:
	pip install -q coveralls --use-mirrors

setup_js:
	npm install less yuglify karma --loglevel silent

setup_django:
	python manage.py syncdb --noinput
	python manage.py compilemessages

settings_ci:
	cp timtec/settings_local_ci.py timtec/settings_local.py
