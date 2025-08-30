#!/bin/bash

echo "🧪 Тестирование API эндпоинтов сброса пароля"
echo "=============================================="

BASE_URL="https://type-backend.linka.su/api"
TEST_EMAIL="test@example.com"

echo ""
echo "1️⃣ Тестирование запроса сброса пароля..."
curl -s -X POST "$BASE_URL/auth/reset-password" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\"}" \
  | jq '.' 2>/dev/null || echo "jq не установлен, показываю raw ответ"

echo ""
echo "2️⃣ Тестирование верификации OTP (ожидаем 400)..."
curl -s -X POST "$BASE_URL/auth/reset-password/verify" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"code\":\"123456\"}" \
  | jq '.' 2>/dev/null || echo "jq не установлен, показываю raw ответ"

echo ""
echo "3️⃣ Тестирование подтверждения сброса пароля (ожидаем 400)..."
curl -s -X POST "$BASE_URL/auth/reset-password/confirm" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"code\":\"123456\",\"password\":\"NewPass123!\"}" \
  | jq '.' 2>/dev/null || echo "jq не установлен, показываю raw ответ"

echo ""
echo "✅ Тестирование завершено!"
echo ""
echo "📝 Результаты:"
echo "- Эндпоинт 1 должен вернуть 200 OK"
echo "- Эндпоинты 2 и 3 должны вернуть 400 Bad Request (ожидаемо)"
echo "- Все эндпоинты должны возвращать JSON ответы"
