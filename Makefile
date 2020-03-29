# output name
NAME							=	$(shell basename $(CURDIR))
# source directory
SOURCE						=	$(CURDIR)/src

PYTHON_VERSION		=	3
PYTHON						=	"python$(PYTHON_VERSION)"
PIP								=	"pip$(PYTHON_VERSION)"

# default to test and build
all: test build

# install build dependencies
deps: check
	@$(PIP) install iterm2

# install development dependencies
deps-dev: check deps
	@$(PIP) install yapf futures isort flake8

# format code
format: check
	@isort --skip-glob=.tox --recursive .
	@yapf -ir *.py $(SOURCE)/*.py

# run golint on all source tree
lint: check
	@flake8 --exclude=.tox

# build
build:
	@$(PYTHON) setup.py sdist bdist_wheel

run: check build
	@$(PYTHON) "$(SOURCE)/$(NAME).py"

# run tests
test: check
	$(PYTHON) setup.py test

# clean build artefacts
clean: clean-build clean-pyc clean-test

clean-build:
	@rm -rf build/
	@rm -rf dist/
	@rm -rf .eggs/
	@find . -name '*.egg-info' -exec rm -rf {} +
	@find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -rf {} +

clean-test:
	@rm -rf .tox/
	@rm -f .coverage
	@rm -rf htmlcov/

# build dist & wheel
dist: clean
	@python setup.py sdist
	@python setup.py bdist_wheel
	@ls -l dist
	@du -h dist

# release & upload
release: clean
	@python setup.py sdist upload
	@python setup.py bdist_wheel upload

# install
install-develop:
	@$(PIP) install -e .

install: clean
	@$(PYTHON) setup.py install

# docs
docs:
	@cd docs && make html