DEPS = ./deps
LFE_DIR = $(DEPS)/lfe
LFE_EBIN = $(LFE_DIR)/ebin
LFE = $(LFE_DIR)/bin/lfe
LFEC = $(LFE_DIR)/bin/lfec
LFE_UTILS_DIR = $(DEPS)/lfe-utils
LFEUNIT_DIR = $(DEPS)/lfeunit
REBAR_DIR = $(DEPS)/rebar
ERL_LIBS = $(LFE_DIR):$(LFE_UTILS_DIR):$(LFEUNIT_DIR):$(REBAR_DIR):./
SOURCE_DIR = ./src
OUT_DIR = ./ebin
TEST_DIR = ./test
TEST_OUT_DIR = ./.eunit

get-deps:
	rebar get-deps
	for DIR in $(wildcard $(DEPS)/*); do 	cd $$DIR; git pull; cd - ; done

clean-ebin:
	rm -f $(OUT_DIR)/*.beam

clean-eunit:
	rm -rf $(TEST_OUT_DIR)

compile: get-deps clean-ebin
	rebar compile

compile-no-deps: clean-ebin
	rebar compile skip_deps=true

compile-tests: clean-eunit
	mkdir -p $(TEST_OUT_DIR)
	ERL_LIBS=$(ERL_LIBS) $(LFEC) -o $(TEST_OUT_DIR) $(TEST_DIR)/*_tests.lfe

shell: compile
	clear
	ERL_LIBS=$(ERL_LIBS) $(LFE) -pa $(TEST_OUT_DIR)

shell-no-deps: compile-no-deps
	@clear
	ERL_LIBS=$(ERL_LIBS) $(LFE) -pa $(TEST_EBIN_DIR)

clean: clean-ebin clean-eunit
	rebar clean

check: compile compile-tests
	@clear;
	@rebar eunit verbose=1 skip_deps=true

push-all:
	git push --all
	git push upstream --all
	git push --tags
	git push upstream --tags
