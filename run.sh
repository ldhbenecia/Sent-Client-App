#!/bin/bash
# .env 파일을 읽어서 flutter run --dart-define 으로 전달
# 사용법: ./run.sh

set -a
source .env
set +a

flutter run \
  --dart-define=API_BASE_URL="$API_BASE_URL"
