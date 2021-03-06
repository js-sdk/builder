BABEL=./node_modules/babel-cli/bin/babel.js
BROWSERIFY=./node_modules/browserify/bin/cmd.js
MOCHA_RUNNER=./node_modules/mocha/bin/_mocha
NYC=./node_modules/.bin/nyc

CFLAGS=--plugins transform-es2015-modules-umd
TEST_CFLAGS= --compilers js:babel-register --require should
TEST_REPORT= --check-coverage --lines 100 --functions 100 --branches 100 --statements 100

ifdef DEV
ifeq ("$(DEV)", "1")
TEST_CFLAGS+= -w
endif
endif

ifndef DEV
ifneq ("$(REPORT)", "")
TEST_REPORT+= --reporter=$(REPORT)
endif

ifeq ("$(REPORT)", "")
TEST_REPORT+= --reporter=text
endif
endif

# Rules for compiling source

compile: all

# Rules for testing

test:
	$(NYC) $(TEST_REPORT) $(MOCHA_RUNNER) $(TEST_CFLAGS) tests/*.js

# Rules for build and publish

check-working-tree:
	@sh ./builder/repo_status.sh

update-version:
	@echo "[Updating version]"
	@sh ./builder/update_version.sh --update

changelog:
	@echo "[Updating changelog.md]"
	(cat ./builder/.version | xargs python3 ./builder/changelog.py)  > ./builder/.changelog_update
	@cat ./builder/.changelog_update
	@cat ./builder/.changelog_update changelog.md > ./builder/.changelog_joined && mv ./builder/.changelog_joined changelog.md

empty-commit:
	@echo "[Empty commit]"
	git commit --allow-empty -m "Release `awk '{ print $$2 }' ./builder/.version`."

ammend-commit:
	@echo "[Ammend commit]"
	sh ./builder/update_version.sh --commit
	git add .
	git commit --amend -m "`git log -1 --format=%s`"

release-tag:
	@echo "[Tagging]"
	git tag -a -s "`awk '{ print $$2 }' ./builder/.version`"

pre-publish: check-working-tree update-version empty-commit

check-list: test compile changelog

post-check-list: ammend-commit release-tag

run-publish: check-list post-check-list
	@echo "[Publishing]"
	git push js-sdk master `awk '{ print $$2 }' ./builder/.version`
	npm publish

post-publish:
	@sh ./builder/update_version.sh --clean

publish: pre-publish run-publish post-publish
