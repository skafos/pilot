.PHONY: test

VERSION_FILE=VERSION
VERSION=`cat $(VERSION_FILE)`

all: build run

build:
	@mix do deps.get, compile

run:
	mix run --no-halt

test:
	@MIX_ENV=test mix do deps.get, test

update: 
	@mix do deps.get, deps.update --all, compile

install:
	@mix deps.get

release: 
	@echo "Creating release for version $(VERSION)..."
	@mix do deps.get, compile
	@git tag -a $(VERSION) -m "Creating release for version $(VERSION)"
	@git push --tags

clean:
	@mix deps.clean --all
	@rm -rf deps
	@rm -rf mix.lock
	@rm -rf _build
