#!/bin/bash
# 개발 환경 실행 — .env 기반 (DEV_MODE=true → DEV 버튼 표시)
# 사용법: ./run.dev.sh

set -a
source .env
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

echo "▶ [DEV] API: $API_BASE_URL | DEV_MODE: $DEV_MODE"
flutter run \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=DEV_MODE="$DEV_MODE"
