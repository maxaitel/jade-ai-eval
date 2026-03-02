PYTHON ?= $(shell if [ -x .venv/bin/python ]; then echo .venv/bin/python; else echo python3; fi)
MODELS ?= qwen2.5-coder:7b
PROJECT ?= .
TASKS ?= eval/tasks.sample.jsonl
COMPILE_CMD ?=
OLLAMA_HOST ?= http://100.116.25.114:11434
OLLAMA_MODE ?= auto
COMPILE_MODE ?= local
PARALLELS_VM ?= Windows 11
PARALLELS_PROJECT ?=
PARALLELS_SHELL ?= cmd
PARALLELS_USER ?=
PARALLELS_PASSWORD_ENV ?=
APPLY ?= 0
KEEP ?= 0

PARALLELS_ARGS = $(if $(filter parallels,$(COMPILE_MODE)),--compile-mode parallels --parallels-vm "$(PARALLELS_VM)" --parallels-shell "$(PARALLELS_SHELL)" $(if $(PARALLELS_PROJECT),--parallels-project-path "$(PARALLELS_PROJECT)",) $(if $(PARALLELS_USER),--parallels-user "$(PARALLELS_USER)",) $(if $(PARALLELS_PASSWORD_ENV),--parallels-password-env "$(PARALLELS_PASSWORD_ENV)",),)

.PHONY: eval-compile eval-full eval-jade eval-jade-parallels

eval-compile:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		--skip-ollama \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-full:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-jade:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--ollama-mode "$(OLLAMA_MODE)" \
		$(PARALLELS_ARGS) \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",) \
		$(if $(filter 1,$(APPLY)),--apply-generated,) \
		$(if $(filter 1,$(KEEP)),--keep-generated,)

eval-jade-parallels:
	$(MAKE) eval-jade COMPILE_MODE=parallels
