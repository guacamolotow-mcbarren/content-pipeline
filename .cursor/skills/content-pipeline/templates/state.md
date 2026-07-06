# State — content-pipeline

> Обновляй при каждой смене этапа. Оркестратор читает этот файл в начале хода и при `/status`.

```yaml
mode: full          # full | fast
stage: START        # START | BRIEF | INTERVIEW | PLAN | PLAN_REVIEW | DRAFT | EDIT_LOOP | LEAD_REVIEW | USER_REVIEW | FINETUNE | DONE
category:           # interview | article | article-tech | press-release | case | research
round_editor: 0     # раунд редактор ↔ копирайтер
round_user_reject: 0
round_plan_review: 0
updated:            # YYYY-MM-DD HH:MM
```

## Этапы по режимам

**full:** START → BRIEF → INTERVIEW → PLAN → PLAN_REVIEW → DRAFT → EDIT_LOOP → LEAD_REVIEW → USER_REVIEW → FINETUNE → DONE

**fast:** START → BRIEF → PLAN → DRAFT → EDIT_LOOP (max 1) → LEAD_REVIEW → USER_REVIEW → DONE
