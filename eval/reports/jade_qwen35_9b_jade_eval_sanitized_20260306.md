# jade-qwen35-9b-jade sanitized eval (2026-03-06)

- Model: `jade-qwen35-9b-jade:latest`
- Harness changes: stripped `<think>` tags, trimmed non-code wrappers, normalized one-method outputs into JADE method-source blocks.
- Easy compile pass before -> after: 0/6 -> 2/6
- Hard compile pass before -> after: 0/4 -> 0/4

## Easy tasks

| Task | Before | After | After reason |
| --- | ---: | ---: | --- |
| J001 | fail | ok | ok |
| J027 | fail | fail | 6400 Unexpected token |
| J051 | fail | ok | ok |
| J079 | fail | fail | 6026 Unknown property or method |
| J118 | fail | fail | 7082 Expecting: endif |
| J121 | fail | fail | 6027 Unknown identifier |

## Hard tasks

| Task | Before | After | After reason |
| --- | ---: | ---: | --- |
| hard_batch_processing | fail | fail | 7841 Expecting: schema definition |
| hard_domain_model | fail | fail | 7841 Expecting: schema definition |
| hard_inheritance_and_collections | fail | fail | 7841 Expecting: schema definition |
| hard_validation_and_errors | fail | fail | 6229 Incompatible schema file format |

## Interpretation

- The easy-task improvement from 0/6 to 2/6 shows the original harness was unfairly penalizing body-only answers.
- The hard-task result stayed at 0/4 after sanitization, which points to genuine model-side schema-generation problems on those prompts.
