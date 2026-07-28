#!/usr/bin/env bash
# Отключаем "exit on error" для диагностики
# set -euo pipefail

cd "$(dirname "$0")"

echo "==> Проверяю git-репозиторий..."
if [ ! -d .git ]; then
  echo "    .git не найден — инициализирую (нужен Antora для локального источника)"
  git init -q
fi

# Antora требует HEAD, даже если контент читается с диска
if ! git rev-parse HEAD >/dev/null 2>&1; then
  echo "==> Создаю пустой технический коммит..."
  git -c user.email="local@build" -c user.name="local-build" \
    commit --allow-empty -q -m "chore: init empty repo (required by Antora)"
fi

echo "==> Проверяю зависимости..."
if [ ! -d node_modules/@antora ] || [ ! -d node_modules/live-server ] || [ ! -d node_modules/onchange ]; then
  echo "    Устанавливаю @antora/cli, @antora/site-generator, live-server, onchange..."
  npm install @antora/cli@3 @antora/site-generator@3 live-server onchange --no-audit --no-fund
fi

echo "==> Первичная сборка сайта..."
npx antora --stacktrace --fetch antora-playbook.yml
if [ $? -ne 0 ]; then
  echo "Ошибка при первичной сборке!"
  read -r -p "Нажмите Enter для выхода..."
  exit 1
fi

# Запускаем live-server в фоне (без открытия браузера)
echo "==> Запускаю live-server на http://localhost:8080 (не открывает браузер)"
npx live-server build/site --port=8080 --no-browser --quiet &
LIVE_SERVER_PID=$!

# Очистка при выходе (Ctrl+C)
cleanup() {
  echo ""
  echo "==> Останавливаю live-server (PID $LIVE_SERVER_PID)"
  kill $LIVE_SERVER_PID 2>/dev/null || true
  exit 0
}
trap cleanup SIGINT SIGTERM

echo "==> Включаю режим слежения за изменениями в docs/..."
echo "    Сборка будет перезапускаться при изменении файлов."
echo "    Страница в браузере обновится автоматически (live-reload)."
echo "    Нажмите Ctrl+C для остановки."

npx onchange "docs/**/*.adoc" "docs/**/*.yml" "antora-playbook.yml" "supplemental-ui/**/*" -- npx antora --stacktrace --fetch antora-playbook.yml

echo "onchange завершился."
read -r -p "Нажмите Enter для выхода..."