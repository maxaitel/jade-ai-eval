# jade-qwen35-9b-jade eval (2026-03-06)

- Model: `jade-qwen35-9b-jade:latest`
- Easy CSV: `/Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai/eval/controls/easy_subset_20260306.csv`
- Hard pack: `/Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai/eval/tasks.jade.hard.jsonl`
- Total tasks: 10
- Ollama responses received: 10/10
- Compile successes: 0/10
- Total compiler errors counted: 10

## By pack

| Pack | Tasks | Ollama ok | Structural pass | Compile ok | Compiler errors |
| --- | ---: | ---: | ---: | ---: | ---: |
| easy_csv | 6 | 6 | 2 | 0 | 6 |
| hard_jsonl | 4 | 4 | 0 | 0 | 4 |

## Task details

| Pack | Task | Category | Compile ok | Errors | First error | Notes |
| --- | --- | --- | ---: | ---: | --- | --- |
| easy_csv | J001 | integer_boolean | no | 1 | 7039 Expecting: ) (line 624) |  |
| easy_csv | J027 | integer_boolean | no | 1 | 6025 Unknown method (line 626) |  |
| easy_csv | J051 | numeric_conversion | no | 1 | 6025 Unknown method (line 633) |  |
| easy_csv | J079 | string_character | no | 1 | 7785 Expecting: jade method source (line 1) |  |
| easy_csv | J118 | date_time | no | 1 | 7039 Expecting: ) (line 635) |  |
| easy_csv | J121 | array_collection | no | 1 | 6025 Unknown method (line 631) |  |
| hard_jsonl | hard_domain_model | hard_schema | no | 1 | 7841 Expecting: schema definition (line 1) | response begins with <think> tag |
| hard_jsonl | hard_inheritance_and_collections | hard_schema | no | 1 | 7841 Expecting: schema definition (line 1) | response begins with <think> tag |
| hard_jsonl | hard_validation_and_errors | hard_schema | no | 1 | 7841 Expecting: schema definition (line 1) | response begins with <think> tag |
| hard_jsonl | hard_batch_processing | hard_schema | no | 1 | 7841 Expecting: schema definition (line 1) | response begins with <think> tag |

## Notes

- Easy-pack structural pass was 2/6, but compile pass was 0/6.
- All 4 hard-pack outputs began with `<think>` and failed immediately with `Compile Error 7841 - Expecting: schema definition` at line 1.
- Compiler error count is measured as the number of `Compile Error` or `Compile error` entries in JADE loader output for each task.
