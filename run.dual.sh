#!/bin/bash
# 시뮬레이터 2대로 동시 실행 — 멀티 유저 테스트용
# 사용법: ./run.dual.sh

set -a
source .env
set +a

DEVICE_A="iPhone 17 Pro"
DEVICE_B="iPhone 17 Pro Max"

# 시뮬레이터 부팅
boot_if_needed() {
  local device="$1"
  local status
  status=$(xcrun simctl list devices | grep "$device" | grep -o "(Booted)\|(Shutdown)" | head -1)
  if [ "$status" != "(Booted)" ]; then
    echo "▶ 시뮬레이터 부팅 중: $device"
    xcrun simctl boot "$device"
  fi
}

boot_if_needed "$DEVICE_A"
boot_if_needed "$DEVICE_B"
open -a Simulator
sleep 3

ID_A=$(xcrun simctl list devices | grep "$DEVICE_A" | grep "Booted" | head -1 | grep -oE '[0-9A-F-]{36}')
ID_B=$(xcrun simctl list devices | grep "$DEVICE_B" | grep "Booted" | head -1 | grep -oE '[0-9A-F-]{36}')

echo "▶ [DUAL] 디바이스 A: $DEVICE_A ($ID_A)"
echo "▶ [DUAL] 디바이스 B: $DEVICE_B ($ID_B)"
echo "▶ [DUAL] API: $API_BASE_URL"
echo ""
echo "각 터미널에서 아래 명령을 실행하세요:"
echo ""
echo "  # 터미널 1 (${DEVICE_A})"
echo "  flutter run -d $ID_A \\"
echo "    --dart-define=API_BASE_URL=\"$API_BASE_URL\" \\"
echo "    --dart-define=DEV_MODE=\"$DEV_MODE\" \\"
echo "    --dart-define=APP_VERSION=\"${APP_VERSION:-0.1.0}\""
echo ""
echo "  # 터미널 2 (${DEVICE_B})"
echo "  flutter run -d $ID_B \\"
echo "    --dart-define=API_BASE_URL=\"$API_BASE_URL\" \\"
echo "    --dart-define=DEV_MODE=\"$DEV_MODE\" \\"
echo "    --dart-define=APP_VERSION=\"${APP_VERSION:-0.1.0}\""
echo ""
echo "자동으로 두 개를 동시에 실행하려면 아무 키나 누르세요 (Ctrl+C로 취소)"
read -r

flutter run -d "$ID_A" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=DEV_MODE="$DEV_MODE" \
  --dart-define=APP_VERSION="${APP_VERSION:-0.1.0}" &
PID_A=$!

sleep 5

flutter run -d "$ID_B" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=DEV_MODE="$DEV_MODE" \
  --dart-define=APP_VERSION="${APP_VERSION:-0.1.0}" &
PID_B=$!

echo ""
echo "▶ 두 인스턴스 실행 중 (PID: $PID_A, $PID_B)"
echo "▶ 종료하려면 Ctrl+C"

trap "kill $PID_A $PID_B 2>/dev/null; exit" INT TERM
wait
