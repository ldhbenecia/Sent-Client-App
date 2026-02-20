#!/bin/bash
# 프로덕션 환경 실행 — .env.prod 기반 (DEV_MODE=false → DEV 버튼 숨김)
# 실제 기기 배포: flutter build ipa
# 사용법: ./run.prod.sh

if [ ! -f .env.prod ]; then
  echo "❌ .env.prod 파일이 없습니다."
  echo "   .env.prod.example 을 복사해서 만드세요:"
  echo "   cp .env.prod.example .env.prod"
  exit 1
fi

set -a
source .env.prod
set +a

# 시뮬레이터 부팅
DEVICE="iPhone 17 Pro"
STATUS=$(xcrun simctl list devices | grep "$DEVICE" | grep -o "(Booted)\|(Shutdown)" | head -1)

if [ "$STATUS" != "(Booted)" ]; then
  echo "▶ 시뮬레이터 부팅 중: $DEVICE"
  xcrun simctl boot "$DEVICE"
  open -a Simulator
  sleep 3
fi

echo "▶ [PROD] API: $API_BASE_URL | DEV_MODE: $DEV_MODE"
flutter run \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=DEV_MODE="$DEV_MODE"
