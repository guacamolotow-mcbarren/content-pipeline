---
name: content-pipeline
description: >-
  Мультиагентный конвейер создания контента «Инфосистемы Джет» на русском языке.
  Категории: интервью, статьи для СМИ, технические статьи, пресс-релизы, кейсы,
  исследования. Запуск: /start. Согласование: /approve, /reject. Используй при
  написании статей, интервью, пресс-релизов, кейсов и исследований для Jet.
---

# Content Pipeline — «Инфосистемы Джет»

Мультиагентный конвейер: бриф → план → драфт → ревью → согласование → дообучение.

**Язык всех материалов: русский.**

**Базовый путь:** `.cursor/skills/content-pipeline/` (skill, style guides, шаблоны, референсы).

## Быстрый старт

```
/start                    — начать новый материал
/approve                  — одобрить материал / изменения style guide
/reject [комментарий]     — отклонить с правками
/status                   — текущий этап и файлы
```

## Структура проекта

Создай в рабочей директории:

```
content-project/
├── inputs/          # исходники пользователя
├── brief.md
├── plan.md
├── draft.md
├── feedback.md
└── final.md
```

## Субагенты

| Агент | Файл | Когда вызывать |
|-------|------|----------------|
| Тимлид | `content-teamlead` | /start, ревью, финал, дообучение |
| Интервьюер | `content-interviewer` | после brief.md |
| Копирайтер | `content-copywriter` | plan.md, draft.md, правки |
| Редактор | `content-editor` | ревью draft.md |

Вызывай через Task tool или явно: «используй субагента content-copywriter».

## Категории и style guides

| Категория | Ключ | Style guide | Эталон |
|-----------|------|-------------|--------|
| Интервью | `interview` | [interview.md](style-guides/interview.md) | Интервью Янкина (см. references/) |
| Статья для СМИ | `article` | [article.md](style-guides/article.md) | ИИ-агенты для управленца |
| Техническая статья | `article-tech` | [article-tech.md](style-guides/article-tech.md) | jetinfosystems на Habr |
| Пресс-релиз | `press-release` | [press-release.md](style-guides/press-release.md) | cnews.ru/news/line/… |
| Технический кейс | `case` | [case.md](style-guides/case.md) | habr case/*.docx |
| Исследование | `research` | [research.md](style-guides/research.md) | resaerch etalon/*.docx |

## State Machine

```
START → BRIEF → INTERVIEW → PLAN → PLAN_REVIEW → DRAFT → EDIT_LOOP → LEAD_REVIEW → USER_REVIEW → FINETUNE → DONE
```

Отслеживай этап. При `/status` показывай текущий и следующий шаг.

---

## Этап 1: Старт (/start)

**Агент:** content-teamlead

1. Поприветствуй, спроси категорию (если не указана)
2. Проведи Q&A: тема, спикер, аудитория, источники, ограничения
3. Прочитай файлы из `inputs/` (.md напрямую; .docx/.pdf/.pptx — извлеки текст)
4. Создай `brief.md` по [шаблону](templates/brief.md)

**HITL:** покажи бриф → жди подтверждения → `BRIEF`

---

## Этап 2: Уточнения

**Агент:** content-interviewer

1. Изучи brief + источники
2. Задай 3–7 уточняющих вопросов (или «бриф полный»)
3. Обнови brief.md ответами

→ `INTERVIEW` → `PLAN`

---

## Этап 3: План

**Агент:** content-copywriter

1. Прочитай brief + style guide категории + эталоны
2. Создай `plan.md` по [шаблону](templates/plan.md)

→ `PLAN_REVIEW`

---

## Этап 4: Ревью плана

**Агент:** content-teamlead

- Критичные правки → `feedback.md` → копирайтер → повтор (max 2 раунда)
- OK → `DRAFT`

---

## Этап 5: Драфт

**Агент:** content-copywriter

1. Напиши полный текст в `draft.md` по [шаблону](templates/draft.md)
2. Строго по plan + style guide

→ `EDIT_LOOP`

---

## Этап 6: Редактура (цикл)

**Агент:** content-editor → content-copywriter

```
редактор → feedback.md → копирайтер → draft-vN → редактор
```

- Max **3 раунда** редактор ↔ копирайтер
- Редактор одобрил → `LEAD_REVIEW`
- 3 раунда без согласия → эскалация тимлиду

---

## Этап 7: Финальное ревью тимлида

**Агент:** content-teamlead

- Критичные правки → feedback → копирайтер + редактор
- OK → `final.md` → `USER_REVIEW`

**HITL:** покажи final.md пользователю.

---

## Этап 8: Согласование пользователя

| Команда | Действие |
|---------|----------|
| `/approve` | → `FINETUNE` |
| `/reject [текст]` | feedback.md (дословно) → копирайтер. Max **2 раунда** |

---

## Этап 9: Дообучение фреймворка

**Агент:** content-teamlead

1. Сравни final.md с style guide
2. Предложи правки в `.cursor/skills/content-pipeline/style-guides/[category].md`
3. Покажи diff

**HITL:** `/approve` → применить. `/reject` → пропустить.

→ `DONE`

---

## Чеклист прогресса

Копируй и обновляй:

```
- [ ] Этап 1: brief.md создан и согласован
- [ ] Этап 2: уточнения собраны
- [ ] Этап 3: plan.md написан
- [ ] Этап 4: план одобрен тимлидом
- [ ] Этап 5: draft.md написан
- [ ] Этап 6: редактор одобрил (раунд N/3)
- [ ] Этап 7: тимлид одобрил → final.md
- [ ] Этап 8: пользователь одобрил
- [ ] Этап 9: style guide обновлён
```

## Работа с файлами

### Чтение источников

| Формат | Метод |
|--------|-------|
| .md | Read |
| .docx | PowerShell + Zip + word/document.xml или pandoc |
| .pdf | pdfplumber / Read если текстовый |
| .pptx | python-pptx или извлечение текста |

Сохраняй извлечённый текст в `inputs/extracted/`.

### Локальные эталоны (в корне workspace)

- Кейсы: `habr case/*.docx`
- Исследования: `resaerch etalon/*.docx`

При написании кейсов/исследований — прочитай соответствующий эталон.

## Критерии «критичной правки»

Блокирует публикацию:
- Фактическая ошибка или неподтверждённое утверждение
- Нарушение NDA (реальные IP, имена, домены)
- Несоответствие брифу (другая тема, пропущен ключевой месседж)
- Грубое нарушение style guide (формат категории)

Не блокирует:
- Стилистика, формулировки, длина абзацев
- Порядок некритичных разделов

## Общие правила

1. **Один этап за раз** — не перескакивай без завершения текущего
2. **HITL** — пауза на этапах 1, 8, 9
3. **Файлы** — каждый артефакт в .md, версионируй драфты (draft-v2…)
4. **Не выдумывай** — факты только из brief и источников
5. **Язык** — русский, термины по style guide

## Шаблоны

- [brief.md](templates/brief.md)
- [plan.md](templates/plan.md)
- [draft.md](templates/draft.md)
- [feedback.md](templates/feedback.md)
