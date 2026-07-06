# content-pipeline

Мультиагентный конвейер создания контента на русском языке: бриф → план → драфт → ревью → согласование → дообучение style guide.

Работает в [Cursor](https://cursor.com): четыре субагента (тимлид, интервьюер, копирайтер, редактор) ведут материал от идеи до финального текста.

**Репозиторий:** [github.com/jet-marketing-pr-ai-utilities/content-pipeline](https://github.com/jet-marketing-pr-ai-utilities/content-pipeline)

---

## Категории материалов

| Категория | Ключ | Формат |
|-----------|------|--------|
| Интервью | `interview` | Q&A для любого СМИ |
| Статья для СМИ | `article` | Экспертный how-to с практическими сценариями |
| Техническая статья | `article-tech` | IT-площадка, корпблог |
| Пресс-релиз | `press-release` | Новостной материал |
| Технический кейс | `case` | Storytelling + техническая глубина |
| Исследование | `research` | Аналитический отчёт / white paper |

Требования конкретной площадки (рубрика, SEO, теги) фиксируются в брифе, а не в style guide.

---

## Быстрый старт

### Шаг 1. Установите в проект

Склонируйте репозиторий или скачайте ZIP и скопируйте папку `.cursor/` в корень вашего workspace в Cursor:

```bash
git clone https://github.com/jet-marketing-pr-ai-utilities/content-pipeline.git
```

```text
ваш-проект/
└── .cursor/
    ├── skills/content-pipeline/   ← skill, style guides, шаблоны
    └── agents/                  ← content-teamlead, content-copywriter, …
```

> Если в проекте уже есть `.cursor/` — скопируйте содержимое, не перезаписывая чужие skills и agents.

### Шаг 2. Создайте папку материала

В workspace создайте рабочую директорию (можно в любом месте):

```text
content-project/
├── inputs/          # исходники: .md, .docx, .pdf, .pptx
├── brief.md
├── plan.md
├── draft.md
├── feedback.md
└── final.md
```

### Шаг 3. Запустите пайплайн

Откройте чат Cursor (`Ctrl+L`) и напишите:

```text
@content-pipeline /start
Категория: article
Тема: [ваша тема]
```

Или явно попросите субагента:

```text
Используй content-teamlead для сбора брифа на интервью про [тема]
```

### Команды пайплайна

| Команда | Действие |
|---------|----------|
| `/start` | Начать новый материал, собрать бриф |
| `/approve` | Одобрить материал или правки style guide |
| `/reject [комментарий]` | Отклонить с правками |
| `/status` | Текущий этап и файлы |

---

## Этапы пайплайна

```text
START → BRIEF → INTERVIEW → PLAN → PLAN_REVIEW → DRAFT → EDIT_LOOP → LEAD_REVIEW → USER_REVIEW → FINETUNE → DONE
```

1. **Тимлид** собирает бриф через Q&A
2. **Интервьюер** задаёт уточняющие вопросы
3. **Копирайтер** пишет план и драфт
4. **Редактор** ревьюит (до 3 раундов)
5. **Тимлид** финальное ревью → `final.md`
6. **Пользователь** согласует (`/approve` / `/reject`)
7. **Тимлид** предлагает дообучение style guide

---

## Субагенты

| Агент | Когда вызывать |
|-------|----------------|
| `content-teamlead` | /start, ревью плана и финала, дообучение |
| `content-interviewer` | После brief.md — уточнения |
| `content-copywriter` | plan.md, draft.md, правки |
| `content-editor` | Ревью draft.md |

---

## Структура репозитория

```text
content-pipeline/
├── README.md
├── LICENSE
├── push-to-github.ps1
└── .cursor/
    ├── skills/content-pipeline/
    │   ├── SKILL.md
    │   ├── style-guides/      # interview, article, article-tech, …
    │   ├── templates/         # brief, plan, draft, feedback
    │   └── references/        # эталонные фрагменты
    └── agents/
        ├── content-teamlead.md
        ├── content-interviewer.md
        ├── content-copywriter.md
        └── content-editor.md
```

---

## Кастомизация

- **Style guides** — правьте файлы в `style-guides/` под свой бренд и форматы
- **Дообучение** — после каждого материала тимлид предлагает правки в style guide (этап FINETUNE)
- **Эталоны** — добавляйте свои референсы в `references/` или указывайте локальные файлы в брифе

### Разработка и публикация

Если правите skill в `.cursor/` workspace, перед коммитом синхронизируйте:

```powershell
cd content-pipeline
.\sync-from-dev.ps1
.\push-to-github.ps1   # нужен $env:GITHUB_TOKEN
```

---

## Лицензия

MIT. Разработано для «Инфосистемы Джет».
