.PHONY: clean all ebin mmake dialyzer plt mk_template mk_template2 code touch_mask

EBIN_DIR := "./ebin"
MAKE_OPTS := {d,kongqq}
ERL := erl
PROCESSES := 20
PLT := ".dialyzer_plt"

ifdef RELEASE
	MAKE_OPTS += ,{d,'RELEASE'}
endif

ifdef LIVE
	MAKE_OPTS += ,{d,'LIVE'}
endif

ifdef INLINE
	MAKE_OPTS+=,inline
endif

ifdef DEBUG
	 MAKE_OPTS += ,{d,'DEBUG'}
endif

ifdef BUILD_VERSION
	 MAKE_OPTS += ,{d,'BUILD_VERSION','$(BUILD_VERSION)'}
endif

all: ebin mmake mk_template
	(cp ./config/server.app $(EBIN_DIR))
	@$(ERL) -pa $(EBIN_DIR) -noinput -eval "case mmake:all($(PROCESSES),[$(MAKE_OPTS)]) of up_to_date -> halt(0); error -> halt(1) end."
	@$(ERL) -pa $(EBIN_DIR) -noinput -eval "begin vsn_code_change:make(), halt(0) end."
	@$(ERL) -pa $(EBIN_DIR) -noinput -eval "begin version_info:make(), halt(0) end."
	mv deps/data_cn/data_config_mysql.beam $(EBIN_DIR)
	touch deps/data_cn/beam_mask

ebin:
	(mkdir -p $(EBIN_DIR))
	(mkdir -p deps/data_cn)

mmake:
	@$(ERL) -pa $(EBIN_DIR) -noinput  -eval "case make:files([\"src/misc/mmake.erl\"], [{outdir, \"ebin\"},debug_info]) of error -> halt(1); _ -> halt(0) end"
	@$(ERL) -pa $(EBIN_DIR) -noinput  -eval "case make:files([\"src/misc/dynarec.erl\"], [{outdir, \"ebin\"},debug_info]) of error -> halt(1); _ -> halt(0) end"

clean:
	(rm -rf ./ebin/*)
	(rm -rf ./deps/data_cn/*)
	(rm -rf *.dump)

plt:
	(./scripts/gen_plt.sh -a erts -a kernel -a stdlib -a crypto -a mnesia -a sasl -a common_test -a eunit)

dialyzer:clean mmake mk_template2
	@$(ERL) -pa $(EBIN_DIR) -noinput -eval "case mmake:all($(PROCESSES),[debug_info]) of up_to_date -> halt(0); error -> halt(1) end."
	(dialyzer --plt $(PLT) -Werror_handling  -r $(EBIN_DIR)/)

mk_template:
	@$(ERL) -pa $(EBIN_DIR) -noinput  -eval "case make:files([\"src/mod/gen_server2.erl\"], [{outdir, \"ebin\"},{i,\"include\"}]) of error -> halt(1); _ -> halt(0) end"

mk_template2:
	@$(ERL) -pa $(EBIN_DIR) -noinput  \
		-eval "case make:files([\"src/mod/gen_server2.erl\"], [{outdir, \"ebin\"},{i,\"include\"},debug_info]) of error -> halt(1); _ -> halt(0) end"

code:
	chmod +x scripts/*.erl
	./scripts/gen_dic.erl
	./scripts/gen_ets.erl
	./scripts/gen_dets.erl
	./scripts/gen_db.erl
	./scripts/gen_preload.erl
	./scripts/gen_merger_load.erl
	./scripts/gen_merger_save.erl
	./scripts/gen_logtype.erl

touch_mask:
	touch deps/data_cn/beam_mask

vsn:
	@$(ERL) -pa $(EBIN_DIR) -noinput -detached -s vsn_code_change make -s init stop
