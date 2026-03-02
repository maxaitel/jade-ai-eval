PYTHON ?= $(if $(wildcard .venv/bin/python),.venv/bin/python,python3)
MODELS ?= qwen2.5-coder:7b
PROJECT ?= .
TASKS ?= eval/tasks.sample.jsonl
COMPILE_CMD ?=
OLLAMA_HOST ?= http://100.116.25.114:11434
APPLY ?= 0
KEEP ?= 0

.PHONY: eval-compile eval-full eval-jade

eval-compile:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		--skip-ollama \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-full:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",)

eval-jade:
	$(PYTHON) eval/run_jade_eval.py \
		--models $(MODELS) \
		--project-path $(PROJECT) \
		--tasks-file $(TASKS) \
		--ollama-host "$(OLLAMA_HOST)" \
		$(if $(COMPILE_CMD),--compile-cmd "$(COMPILE_CMD)",) \
		$(if $(filter 1,$(APPLY)),--apply-generated,) \
		$(if $(filter 1,$(KEEP)),--keep-generated,)
