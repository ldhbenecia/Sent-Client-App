#!/bin/bash
# .env 파일을 읽어서 flutter run --dart-define 으로 전달
# 사용법: ./run.sh

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

flutter run \
  --dart-define=API_BASE_URL="$API_BASE_URL"
