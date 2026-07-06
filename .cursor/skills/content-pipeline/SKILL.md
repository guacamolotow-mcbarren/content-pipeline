---
name: content-pipeline
description: >-
  Конвейер контента «Инфосистемы Джет» (RU). Команды: /start, /fast, /approve,
  /reject, /status, /export. Субагенты через Task. Статьи, интервью, кейсы.
---

# Content Pipeline — «Инфосистемы Джет»

**Язык:** русский. **Путь skill:** `.cursor/skills/content-pipeline/`

## Команды

| Команда | Действие |
|---------|----------|
| `/start` | Полный пайплайн (9 этапов) |
| `/fast` | Ускоренный: brief → plan → draft → 1 ревью → final |
| `/approve` | Одобрить материал / правки style guide |
| `/reject [текст]` | Отклонить — **только точечные** правки по списку |
| `/status` | Этап и файлы (читай `state.md`) |
| `/export [draft\|final]` | Экспорт в `.docx` → `content-project/export/` |

## Режимы

### `/start` — полный

```
START → BRIEF → INTERVIEW → PLAN → PLAN_REVIEW → DRAFT → EDIT_LOOP → LEAD_REVIEW → USER_REVIEW → FINETUNE → DONE
```

**HITL:** brief, final, finetune. После каждого `/reject` — показ обновлённого материала.

### `/fast` — срочный

```
START → BRIEF → PLAN → DRAFT → EDIT_LOOP (max 1) → LEAD_REVIEW → USER_REVIEW → DONE
```

**Пропуск:** интервью (2), ревью плана (4), finetune (9), цикл редактора >1.

**HITL:** brief, final.

**Когда предлагать:** дедлайн <2 ч, источники в `inputs/`, бриф почти полный.

При старте создай `state.md` (`mode: full` или `mode: fast`) по [шаблону](templates/state.md). Обновляй `stage` и счётчики раундов при каждом переходе.

## Структура проекта

```
content-project/
├── inputs/
├── inputs/extracted/
├── export/              # .docx из /export
├── state.md             # этап, режим, раунды
├── brief.md
├── plan.md
├── draft.md
├── feedback.md
└── final.md
```

## Оркестрация — только Task

Оркестратор **не пишет** plan/draft и **не ревьюит** сам. На каждую роль — **Task tool** с `subagent_type` из таблицы:

| Роль | subagent_type | Когда |
|------|---------------|-------|
| Тимлид | `content-teamlead` | /start, /fast, ревью плана, финал, finetune, /export |
| Интервьюер | `content-interviewer` | после brief (**только `/start`**) |
| Копирайтер | `content-copywriter` | plan, draft, правки |
| Редактор | `content-editor` | ревью draft |

Промпт Task: режим (`state.md`), текущий этап, пути к файлам, что сделать. После Task — обнови `state.md`.

**Модели:** этапы 1–4, 8–9 — Composer; **5, 6, 7** — GPT-5.5+ (напомни пользователю перед драфтом).

## Категории

| Ключ | Style guide |
|------|-------------|
| `interview` | [interview.md](style-guides/interview.md) |
| `article` | [article.md](style-guides/article.md) |
| `article-tech` | [article-tech.md](style-guides/article-tech.md) |
| `press-release` | [press-release.md](style-guides/press-release.md) |
| `case` | [case.md](style-guides/case.md) |
| `research` | [research.md](style-guides/research.md) |

---

## Этапы (полный `/start`)

| # | Этап | Агент | HITL |
|---|------|-------|------|
| 1 | Бриф | teamlead | да |
| 2 | Уточнения | interviewer | нет |
| 3 | План | copywriter | нет |
| 4 | Ревью плана | teamlead | нет (max 2 раунда) |
| 5 | Драфт | copywriter | нет |
| 6 | Редактура | editor → copywriter | нет (max 3 раунда) |
| 7 | Финал | teamlead → `final.md` | да |
| 8 | Согласование | пользователь | `/approve` / `/reject` |
| 9 | Finetune | teamlead → style guide | да |

## Этапы (`/fast`)

| # | Этап | Агент | Примечание |
|---|------|-------|------------|
| 1 | Бриф | teamlead | HITL |
| 2 | План (краткий) | copywriter | без отдельного ревью тимлида |
| 3 | Драфт | copywriter | GPT-5.5+ |
| 4 | 1 ревью | editor → copywriter | **max 1 раунд** |
| 5 | Финал | teamlead → `final.md` | HITL |
| 6 | Согласование | пользователь | `/approve` / `/reject` |

---

## `/reject` — точечные правки

1. Запиши комментарий пользователя в `feedback.md` **дословно**
2. Task → **copywriter**: правит **только** указанные абзацы/разделы
3. **Запрещено:** переписывать весь `draft.md` / `final.md` с нуля
4. Если правок >5 блоков — один проход **по разделам**, сохраняя остальной текст
5. Обнови версию в шапке драфта (`draft-vN`), инкремент `round_user_reject` в `state.md`
6. Max **2 раунда** `/reject` (full и fast)

## `/export` — docx

1. Источник: `draft.md` (по умолчанию) или `final.md` (`/export final`)
2. Убери служебные блоки: шапку версии, «Заметки для редактора», «Метаданные» (если не для публикации)
3. Создай `content-project/export/` при необходимости
4. Конвертация:
   ```bash
   pandoc content-project/final.md -o content-project/export/final.docx
   ```
5. Если pandoc недоступен — сообщи пользователю; fallback: установить pandoc или экспорт вручную

## Источники

| Формат | Метод |
|--------|-------|
| .md | Read |
| .docx | PowerShell + Zip / pandoc → `inputs/extracted/` |
| .pdf | pdfplumber / Read |
| .pptx | python-pptx / извлечение текста |

Эталоны кейсов/исследований: `habr case/*.docx`, `resaerch etalon/*.docx`.

## Критичная vs некритичная правка

**Критичная** (блокирует публикацию): факт, NDA, несоответствие брифу, формат категории.

**Некритичная:** стиль, формулировки, порядок разделов.

## Правила

1. Читай `state.md` в начале хода и после каждого Task
2. HITL — по таблице режима; не перескакивай этапы
3. Факты только из brief и источников
4. Версионируй драфты (`draft-v2`…)
5. Шаблоны: [brief](templates/brief.md), [plan](templates/plan.md), [draft](templates/draft.md), [feedback](templates/feedback.md), [state](templates/state.md)

## Чеклист (краткий)

```
- [ ] state.md актуален
- [ ] brief согласован
- [ ] plan / draft / final на месте
- [ ] редактор одобрил (раунд N)
- [ ] пользователь /approve
- [ ] finetune (только /start)
```
