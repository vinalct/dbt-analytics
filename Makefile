.PHONY: local-setup clean dbt-deps dbt-debug

local-setup:
	@bash local_setup.sh

dbt-deps:
	dbt deps

dbt-debug:
	dbt debug

clean:
	dbt clean
