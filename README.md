# Демо репозиторий для собеседования

Демо проект за ночь, собранный по принципу **Docs-as-Code**:
контент хранится в Git рядом с OpenAPI-спекой, собирается генератором **Antora**
и публикуется автоматически через GitHub Actions на GitHub Pages.

Проект создан как портфолио для позиции Технического писателя
в котором я буду описывать вымышленный API.

**Сайт на гите:** https://aks0t.github.io/doc-demo

## Требования

* Node.js 18+
* Docker + Docker Compose (нужны для локального рендера диаграмм через Kroki — см. ниже)

## Как собрать локально

Проще всего — через готовый скрипт, он поднимает всё сам:

```bash
./build.sh
```

Скрипт:
1. поднимает через `docker compose` три контейнера — `kroki`, `kroki-mermaid`, `kroki-bpmn` (см. `docker-compose.yml`) и дожидается готовности Kroki на `localhost:8000`;
2. ставит npm-зависимости, если их ещё нет;
3. собирает сайт (`build/site`);
4. запускает live-server на `http://localhost:8080` с live-reload при изменении `.adoc`.

Вручную (без live-server):

```bash
docker compose up -d
npm install
npx antora antora-playbook.yml
```

Собранный сайт появится в `build/site/index.html`.

## Диаграммы (Kroki)

Диаграммы (`stateDiagram`, `sequenceDiagram` и т.д.) рендерятся через
[Kroki](https://kroki.io) и расширение [`asciidoctor-kroki`](https://github.com/asciidoctor/asciidoctor-kroki).

**Версия расширения.** `asciidoctor-kroki` версии 1.x требует Asciidoctor.js 4.0,
а Antora 3.x пока использует более старую версию — поэтому в проекте закреплена
совместимая ветка `0.18.x` (`asciidoctor-kroki@latest-0`, см. `package.json`).
Использование 1.x ломает сборку с ошибкой вида `block.$!= is not a function`.

**Companion-контейнеры.** Основной образ `yuzutech/kroki` поддерживает из коробки
PlantUML, GraphViz и т.д., но **Mermaid и BPMN рендерятся отдельными
контейнерами-компаньонами** (`yuzutech/kroki-mermaid`, `yuzutech/kroki-bpmn`), к
которым Kroki обращается по сети. Без них Kroki отвечает `503 Service
Unavailable` на любой Mermaid/BPMN-блок — сборка при этом не падает, просто
диаграмма молча пропускается (в логе будет `WARN ... Skipping mermaid block`).
Поэтому в репозитории — `docker-compose.yml`, поднимающий все три контейнера
разом, а не одиночный `docker run`.

**Локальный сервер, а не публичный.** Сборка использует **локальный** Kroki
(`http://localhost:8000`), а не `kroki.io` — и локально (`build.sh` через
`docker compose`), и в CI (см. `services:` в
`.github/workflows/publish-docs.yml` — те же три контейнера как
сервис-контейнеры GitHub Actions, доступные раннеру как `localhost:8000`).
Сборка, завязанная на публичный `kroki.io`, время от времени падает или
рендерит не все диаграммы из-за сетевых таймаутов/rate-limit — с локальным
стеком сборка не зависит от внешней сети вообще.

Если диаграммы не рендерятся локально:
1. Проверьте, что Docker Desktop запущен: `docker info`.
2. Проверьте, что все три контейнера подняты: `docker compose ps`.
3. Проверьте, что Kroki отвечает: `curl http://localhost:8000`.
4. Смотрите логи: `docker compose logs kroki` / `docker compose logs mermaid` / `docker compose logs bpmn`.
5. Ищите в выводе `antora --stacktrace` строки `WARN (asciidoctor)` — там будет
   точная причина (`Skipping mermaid block` = companion-контейнер недоступен
   или вернул ошибку).

## Подход к документации

* Документация написана на основе сгенеренной аишкой OpenAPI-спецификации (`openapi/openapi.yaml`)
* Все примеры запросов (`curl`) синтаксически проверены; коллекция Postman прилагается.
* Единые стандарты оформления страниц эндпоинтов описаны в [`endpoint-standart.adoc`](docs/modules/ROOT/pages/standarts/endpoint-standart.adoc).
* Формат — AsciiDoc, генератор — Antora (выбран как основной инструмент в стеке компании).

## Публикация (CI/CD)

При пуше в `main` GitHub Actions:

1. устанавливает зависимости (`npm ci`);
2. поднимает Kroki + companion-контейнеры (mermaid, bpmn) как сервис-контейнеры и дожидается готовности;
3. собирает статический сайт (`npx antora antora-playbook.yml`);
4. публикует его на GitHub Pages.

См. [`.github/workflows/publish-docs.yml`](.github/workflows/publish-docs.yml).

## План развития документации

- [x] Инициализировать базовый проект (Antora + GitHub Pages)
- [x] Формализовать стандарт оформления эндпоинтов (`endpoint-standart.adoc`)
- [x] Настроить локальный рендер диаграмм (Kroki + companion-контейнеры) без зависимости от публичного сервиса
- [ ] Формализовать use-cases (сценарии использования API)
- [ ] Создать шаблоны для эндпоинтов и use-cases
- [ ] Выявить повторяющиеся блоки для выноса в partials
- [ ] Реализовать partials (общие таблицы, описания, примеры)
- [ ] Добавить документацию API v2
