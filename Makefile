.PHONY: test

all: build run

build:
	@mix do deps.get, compile

run:
	@mix run --no-halt

test:
	@mix test

update:
	@mix do deps.get, deps.update --all, compile

install:
	@mix deps.get

clean:
	@mix deps.clean --all
	@rm -rf deps
	@rm -rf mix.lock
	@rm -rf _build
