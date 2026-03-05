PYTHON ?= $(shell if [ -x .venv/bin/python ]; then echo .venv/bin/python; else echo python3; fi)
MODELS ?= qwen2.5-coder:7b
PROJECT ?= .
TASKS ?= eval/tasks.sample.jsonl
COMPILE_CMD ?=
OLLAMA_HOST ?= http://100.116.25.114:11434
OLLAMA_MODE ?= auto
OLLAMA_THINK ?= auto
LLM_BACKEND ?= ollama
OPENWEBUI_URL ?= http://localhost:3000
OPENWEBUI_API_KEY_ENV ?= OPENWEBUI_API_KEY
OPENWEBUI_COLLECTION_IDS ?=
OPENWEBUI_FILE_IDS ?=
SAVED_PROFILES ?= eval/profiles/openwebui_jade_agent_profiles.json
SAVED_MAX_TASKS ?=
SAVED_WALL_TIMEOUT_SEC ?= 7200
COMPILE_MODE ?= local
PARALLELS_VM ?= Windows 11
PARALLELS_PROJECT ?=
PARALLELS_SHELL ?= cmd
PARALLELS_USER ?=
PARALLELS_PASSWORD_ENV ?=
APPLY ?= 0
KEEP ?= 0
ONE_METHOD_COMPILE ?= 0

PARALLELS_ARGS = $(if $(filter parallels,$(COMPILE_MODE)),--compile-mode parallels --parallels-vm "$(PARALLELS_VM)" --parallels-shell "$(PARALLELS_SHELL)" $(if $(PARALLELS_PROJECT),--parallels-project-path "$(PARALLELS_PROJECT)",) $(if $(PARALLELS_USER),--parallels-user "$(PARALLELS_USER)",) $(if $(PARALLELS_PASSWORD_ENV),--parallels-password-env "$(PARALLELS_PASSWORD_ENV)",),)
OPENWEBUI_ARGS = --llm-backend "$(LLM_BACKEND)" $(if $(filter openwebui,$(LLM_BACKEND)),--openwebui-url "$(OPENWEBUI_URL)" --openwebui-api-key-env "$(OPENWEBUI_API_KEY_ENV)" $(foreach id,$(OPENWEBUI_COLLECTION_IDS),--openwebui-collection-id "$(id)") $(foreach id,$(OPENWEBUI_FILE_IDS),--openwebui-file-id "$(id)"),)

.PHONY: eval-compile eval-full eval-jade eval-jade-parallels
.PHONY: eval-one-method-generate eval-one-method-evaluate eval-one-method-all eval-one-method-plot
.PHONY: eval-saved-profiles eval-saved-profiles-bounded

eval-compile:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		$(OPENWEBUI_ARGS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--ollama-think "$(OLLAMA_THINK)" \
		--skip-ollama \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-full:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		$(OPENWEBUI_ARGS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--ollama-think "$(OLLAMA_THINK)" \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-jade:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		$(OPENWEBUI_ARGS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--ollama-think "$(OLLAMA_THINK)" \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",) \
		$(if $(filter 1,$(APPLY)),--apply-generated,) \
		$(if $(filter 1,$(KEEP)),--keep-generated,)

eval-jade-parallels:
	$(MAKE) eval-jade COMPILE_MODE=parallels

eval-one-method-generate:
	$(PYTHON) eval/run_one_method_csv_eval.py \
		--mode generate \
		--models $(MODELS) \
		--tasks-csv jade_one_method_eval_tasks_140.csv \
		--run-dir logs/one_method_csv_eval \
		$(OPENWEBUI_ARGS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--ollama-think "$(OLLAMA_THINK)"

eval-one-method-evaluate:
	$(PYTHON) eval/run_one_method_csv_eval.py \
		--mode evaluate \
		--models $(MODELS) \
		--tasks-csv jade_one_method_eval_tasks_140.csv \
		--run-dir logs/one_method_csv_eval \
		$(if $(filter 1,$(ONE_METHOD_COMPILE)),--compile,) \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-one-method-all:
	$(PYTHON) eval/run_one_method_csv_eval.py \
		--mode all \
		--models $(MODELS) \
		--tasks-csv jade_one_method_eval_tasks_140.csv \
		--run-dir logs/one_method_csv_eval \
		$(OPENWEBUI_ARGS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--ollama-think "$(OLLAMA_THINK)" \
		$(if $(filter 1,$(ONE_METHOD_COMPILE)),--compile,) \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-one-method-plot:
	$(PYTHON) eval/plot_one_method_results.py \
		--results logs/one_method_csv_eval/results.jsonl

eval-saved-profiles:
	$(PYTHON) scripts/run_openwebui_saved_profiles_eval.py \
		--profiles "$(SAVED_PROFILES)" \
		--wall-timeout-sec "$(SAVED_WALL_TIMEOUT_SEC)" \
		$(if $(SAVED_MAX_TASKS),--max-tasks "$(SAVED_MAX_TASKS)",)

eval-saved-profiles-bounded:
	$(MAKE) eval-saved-profiles SAVED_MAX_TASKS=20 SAVED_WALL_TIMEOUT_SEC=3600
