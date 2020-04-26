COFFEE_OUT ?= bin/coffee
COFFEE_SRC ?= cli.cr
SYSTEM_BIN ?= /usr/local/bin

fast-install: fast-build
	cp $(COFFEE_OUT) $(SYSTEM_BIN) && rm -f $(COFFEE_OUT)*
install: build
	cp $(COFFEE_OUT) $(SYSTEM_BIN) && rm -f $(COFFEE_OUT)*
fast-build: shard
	crystal build -Dpreview_mt $(COFFEE_SRC) -o $(COFFEE_OUT)
build: shard
	crystal build -Dpreview_mt $(COFFEE_SRC) -o $(COFFEE_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(COFFEE_OUT)* && rm -rf lib && rm shard.lock