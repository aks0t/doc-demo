# Демо репозиторий для собеседования

Демо проект за ночь, собранный по принципу **Docs-as-Code**:
контент хранится в Git рядом с OpenAPI-спекой, собирается генератором **Antora**
и публикуется автоматически через GitHub Actions на GitHub Pages.

Проект создан как портфолио для позиции Технического писателя
в котором я буду описывать вымышленный API.

**Сайт на гите:** https://aks0t.github.io/doc-demo

## Как собрать локально

Требуется Node.js 18+.

```bash
npm install @antora/cli@3 @antora/site-generator@3
npx antora antora-playbook.yml
```

Собранный сайт появится в `build/site/index.html`.

Также для удобства сгенерил скрипт для локального запуска с лайв сервером `build.sh`

## Подход к документации

* Документация написана на основе сгенеренной аишкой OpenAPI-спецификации (`openapi/openapi.yaml`)
* Все примеры запросов (`curl`) синтаксически проверены; коллекция Postman прилагается.
* Единые стандарты оформления страниц эндпоинтов описаны в [`endpoint-standart.adoc`](docs/modules/ROOT/pages/standarts/endpoint-standart.adoc).
* Формат — AsciiDoc, генератор — Antora (выбран как основной инструмент в стеке компании).

## Публикация (CI/CD)

При пуше в `main` GitHub Actions:

1. устанавливает Antora;
2. собирает статический сайт (`npx antora antora-playbook.yml`);
3. публикует его на GitHub Pages.

См. [`.github/workflows/publish-docs.yml`](.github/workflows/publish-docs.yml).

## План развития документации

- [x] Инициализировать базовый проект (Antora + GitHub Pages)
- [x] Формализовать стандарт оформления эндпоинтов (`endpoint-standart.adoc`)
- [ ] Формализовать use-cases (сценарии использования API)
- [ ] Создать шаблоны для эндпоинтов и use-cases
- [ ] Выявить повторяющиеся блоки для выноса в partials
- [ ] Реализовать partials (общие таблицы, описания, примеры)
- [ ] Добавить документацию API v2