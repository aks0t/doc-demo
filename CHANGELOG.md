# Changelog

Все значимые изменения проекта и технической документации документируются в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/),
версии следуют [Semantic Versioning](https://semver.org/lang/ru/).

## [Unreleased]

### Исправлено

- `openapi.yaml`: ответ `403 Forbidden` снят с операций — он зарезервирован под
  будущее разделение прав и в текущей версии не возвращается. Текст
  `api/errors.adoc` и раздел «Права доступа» в `guides/authentication.adoc`
  приведены в соответствие.

### Добавлено

- Доступность (accessibility): добавлен a11y чек-лист и тест-кейсы
  `TC-AUTH-06`, `TC-LIST-09`, `TC-FORM-11` (тип `Accessibility`); счётчики
  в отчёте обновлены до 32 кейсов.

### Планируется

- Расширение набора use-case документации.
- Улучшение автоматической генерации документации из OpenAPI.

## [1.1.0] — 2026-08-06

### Добавлено

- Раздел «Тестирование»: обзор подхода (`testing/overview.adoc`), test plan,
  тест-кейсы (auth, список лидов, форма, смена статуса), примеры баг-репортов
  с объяснением Severity/Priority, чек-листы (smoke/regression/cross-browser)
  и итоговый отчёт по прогону.
- Стандарт оформления тест-кейсов (`standarts/test-case-standart.adoc`):
  схема ID `TC-<ОБЛАСТЬ>-<номер>`, обязательные колонки, правила для
  баг-репортов и чек-листов.
- Postman smoke-коллекция `qa/api-tests/crm-leads-smoke.postman_collection.json`
  с тестами на ключевые сценарии контракта (токен, создание лида,
  `409 duplicate_email`, `404 lead_not_found`, `409 invalid_status_transition`,
  фильтрация).
- Глоссарий дополнен QA-терминами: Test Case, Bug Report, Severity, Priority,
  Smoke- и Regression-тестирование.

### Изменено

- Задокументирован rate limiting: лимит 120 запросов в минуту на клиента,
  заголовки `X-RateLimit-*` и `Retry-After` (см. `api/overview.adoc`).
- В `guides/authentication.adoc` добавлен раздел «Права доступа»: уточнено,
  что в текущей версии API все токены имеют полный доступ, `403 Forbidden`
  зарезервирован под будущее разделение прав.
- README перепозиционирован: проект представлен как пример документирования
  и тестирования продукта по принципу Docs-as-Code.

### Исправлено

- `openapi.yaml` и `leads.adoc`: для `PATCH /leads/{id}` задокументирован
  ответ `409 Conflict` с кодом `invalid_status_transition`, который ранее был
  определён в enum, но не описан как ответ операции.
- `leads.adoc`: добавлен пример ошибки валидации для недопустимого значения
  `source` в `POST /leads`.
- `openapi.yaml`: поле `source` добавлено в схему `LeadUpdateRequest` — теперь
  обновление источника лида описано в спеке.
- `auth.adoc`: явно указан grant type `client_credentials`
  (OAuth 2.0 Client Credentials) — ранее точная формулировка была только в
  глоссарии.

## [1.0.0] — 2026-07-30

### Добавлено

- API аутентификации через `POST /auth/token`.
- CRUD API для ресурса `leads`.
- Единый формат ошибок API.
- OpenAPI-спецификация с примерами запросов и ответов.
- Документация бизнес-процессов с BPMN-диаграммами.
- Диаграммы архитектуры, последовательностей и состояний.
- CI/CD pipeline для автоматической сборки и публикации документации через Antora, GitHub Actions и GitHub Pages.
- Руководство по переходу от Confluence к подходу Documentation-as-Code.

### Изменено

- Унифицирован формат ошибок во всех примерах API.
- Обновлена структура документации эндпоинтов.
- README дополнен описанием архитектурных решений.

### Исправлено

- Устранены расхождения между OpenAPI-спекой и ручной документацией.
- Исправлены примеры ошибок API.

[Unreleased]: https://github.com/aks0t/doc-demo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/aks0t/doc-demo/releases/tag/v1.1.0
[1.0.0]: https://github.com/aks0t/doc-demo/releases/tag/v1.0.0
