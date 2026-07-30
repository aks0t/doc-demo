#!/usr/bin/env bash
set -uo pipefail

cd "$(dirname "$0")"

KROKI_URL="http://localhost:8000"
LIVE_SERVER_PID=""

fail() {
  echo ""
  echo "❌ $1"
  read -r -p "Нажмите Enter для выхода..."
  exit 1
}

# Определяем, какой CLI для compose доступен: современный "docker compose" (плагин)
# или устаревший отдельный бинарник "docker-compose"
COMPOSE_CMD=""
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
fi

cleanup() {
  echo ""
  echo "==> Останавливаю фоновые процессы..."
  [ -n "$LIVE_SERVER_PID" ] && kill "$LIVE_SERVER_PID" 2>/dev/null || true
  [ -n "$COMPOSE_CMD" ] && $COMPOSE_CMD down >/dev/null 2>&1 || true
  exit 0
}
trap cleanup EXIT SIGINT SIGTERM

echo "==> Проверяю git-репозиторий..."
if [ ! -d .git ]; then
  echo "    .git не найден — инициализирую (нужен Antora для локального источника)"
  git init -q
fi

if ! git rev-parse HEAD >/dev/null 2>&1; then
  echo "==> Создаю пустой технический коммит..."
  git -c user.email="local@build" -c user.name="local-build" \
    commit --allow-empty -q -m "chore: init empty repo (required by Antora)"
fi

echo "==> Проверяю Docker..."
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker не найден. Установите Docker Desktop и убедитесь, что демон запущен — без него не будут рендериться диаграммы (Kroki)."
fi
if ! docker info >/dev/null 2>&1; then
  fail "Docker установлен, но демон не запущен. Запустите Docker Desktop и повторите попытку."
fi
if [ -z "$COMPOSE_CMD" ]; then
  fail "Не найден ни 'docker compose' (плагин), ни 'docker-compose'. Обновите Docker Desktop — compose встроен начиная с недавних версий."
fi

echo "==> Поднимаю Kroki + companion-контейнеры (mermaid, bpmn) через ${COMPOSE_CMD}..."
$COMPOSE_CMD up -d || fail "Не удалось поднять контейнеры через docker-compose.yml."

echo "==> Жду готовности Kroki на ${KROKI_URL}..."
KROKI_READY=false
for i in $(seq 1 60); do
  if curl -sf -o /dev/null "${KROKI_URL}/health" 2>/dev/null || curl -s -o /dev/null -w '%{http_code}' "${KROKI_URL}" 2>/dev/null | grep -qE '^[0-9]{3}$'; then
    KROKI_READY=true
    break
  fi
  sleep 1
done
if [ "$KROKI_READY" != true ]; then
  fail "Kroki не ответил на ${KROKI_URL} за 60 секунд. Проверьте логи: ${COMPOSE_CMD} logs"
fi
echo "    Kroki готов."

echo "==> Проверяю npm-зависимости (Antora, live-server, onchange, asciidoctor-kroki)..."
if [ ! -d node_modules/@antora ] || [ ! -d node_modules/live-server ] || [ ! -d node_modules/onchange ] || [ ! -d node_modules/asciidoctor-kroki ]; then
  echo "    Устанавливаю зависимости из package.json..."
  npm install --no-audit --no-fund || fail "npm install завершился с ошибкой."
fi

echo "==> Первичная сборка сайта..."
npx antora --stacktrace --fetch antora-playbook.yml
if [ $? -ne 0 ]; then
  fail "Ошибка при первичной сборке! Смотрите стектрейс выше."
fi

echo "==> Запускаю live-server на http://localhost:8080 (не открывает браузер)"
npx live-server build/site --port=8080 --no-browser --quiet &
LIVE_SERVER_PID=$!

echo "==> Включаю режим слежения за изменениями в docs/..."
echo "    Сборка будет перезапускаться при изменении файлов."
echo "    Страница в браузере обновится автоматически (live-reload)."
echo "    Нажмите Ctrl+C для остановки (контейнеры и live-server остановятся автоматически)."

npx onchange "docs/**/*.adoc" "docs/**/*.yml" "antora-playbook.yml" "supplemental-ui/**/*" -- npx antora --stacktrace --fetch antora-playbook.yml

echo "onchange завершился."
read -r -p "Нажмите Enter для выхода..."
