# Easy 20 Compare: jade-qwen35-9b-jade vs qwen3.5:9b

- Date: 2026-03-06
- Tasks: `/Users/maxaitel/Documents/school-projects/jade-ai-training/jade-ai/eval/controls/easy_subset_20_20260306.csv`
- Metric: JADE compile success after sanitized extraction and one-method normalization.

## Summary

| Model | Compile ok | Compile rate | Structural pass | Structural rate |
| --- | ---: | ---: | ---: | ---: |
| jade-qwen35-9b-jade:latest | 3/20 | 15.00% | 19/20 | 95.00% |
| qwen3.5:9b | 3/20 | 15.00% | 20/20 | 100.00% |

## Compile Wins

- `jade-qwen35-9b-jade:latest` compiled: J001, J002, J003
- `qwen3.5:9b` compiled: J001, J002, J031

## Task Deltas

- `J003`: `jade-qwen35-9b-jade:latest`=ok, `qwen3.5:9b`=fail
- `J031`: `jade-qwen35-9b-jade:latest`=fail, `qwen3.5:9b`=ok

## Failure Patterns

### jade-qwen35-9b-jade:latest
- 7: 6400 Unexpected token
- 6: 6027 Unknown identifier
- 2: 6026 Unknown property or method
- 1: 6084 Cannot assign to constant
- 1: 7039 Expecting: )

### qwen3.5:9b
- 4: 6026 Unknown property or method
- 3: 6027 Unknown identifier
- 3: 6025 Unknown method
- 2: 7039 Expecting: )
- 2: 7881 Expecting: arithmetic expression
- 2: 6061 Non-numeric operand
- 1: 6004 Invalid token

