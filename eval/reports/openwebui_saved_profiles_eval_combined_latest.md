# OpenWebUI Saved Profiles Eval (Combined)

This report combines:
- `logs/openwebui_saved_profiles_eval/20260305T203721/results.json` (profile-pair run, interrupted after profile 1)
- `logs/openwebui_saved_profiles_eval/20260305T205640/results.json` (profile 2 recovery run)

| Profile | Think | Files | Max Tasks | Pass Rate | Non-Empty | Timeouts | Avg Gen Sec | Wall Sec |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| jade_fast_nothink_rag2_dense | false | 2 | 4 | 0.25 | 1 | 3 | 168.457 | 673.985 |
| jade_fallback_think_rag1_dense | true | 1 | 1 | 1.0 | 1 | 0 | 273.648 | 273.78 |


Restored retrieval config: `HYBRID=true, THRESH=1.0, TOP_K=8, TOP_K_RERANKER=8, BM25=0.5`
