#!/bin/bash
# 한글 Oops — 터미널 한 줄 설치 스크립트 (Gatekeeper 경고 없이 설치)
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/odiowood/hangul-oops/main/install.sh | bash
set -e

HS_DIR="$HOME/.hammerspoon"
SPOONS_DIR="$HS_DIR/Spoons"
INIT="$HS_DIR/init.lua"
SPOON_ZIP_URL="https://github.com/odiowood/hangul-oops/releases/latest/download/HanEng.spoon.zip"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "──────────────────────────────────────────"
echo "  한글 Oops 설치"
echo "──────────────────────────────────────────"

# 0) Hammerspoon 확인
if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo "⚠️  Hammerspoon 이 필요합니다."
    echo "    https://www.hammerspoon.org 에서 설치한 뒤 이 명령을 다시 실행해주세요."
    exit 1
fi

# 1) 최신 스푼 내려받아 설치 (curl 다운로드는 격리 플래그가 붙지 않음)
echo "⬇️  최신 버전 내려받는 중…"
curl -fsSL -o "$TMP/HanEng.spoon.zip" "$SPOON_ZIP_URL"
/usr/bin/ditto -x -k "$TMP/HanEng.spoon.zip" "$TMP/unz"
mkdir -p "$SPOONS_DIR"
rm -rf "$SPOONS_DIR/HanEng.spoon"
cp -R "$TMP/unz/HanEng.spoon" "$SPOONS_DIR/HanEng.spoon"
echo "✅ 스푼 설치: ~/.hammerspoon/Spoons/HanEng.spoon"

# 2) init.lua 설정 (이미 있으면 유지, 없으면 백업 후 추가)
touch "$INIT"
if grep -q 'loadSpoon("HanEng")' "$INIT" 2>/dev/null; then
    echo "ℹ️  설정이 이미 있어 init.lua 는 그대로 둡니다."
else
    cp "$INIT" "$INIT.hangul-oops-backup.$(date +%s)" 2>/dev/null || true
    {
        echo ""
        echo "-- 한글 Oops (https://github.com/odiowood/hangul-oops)"
        echo 'hs.loadSpoon("HanEng")'
        echo 'spoon.HanEng:bindHotkeys({ convert = { { "cmd", "shift" }, ";" } })'
    } >> "$INIT"
    echo "✅ 설정 추가 (단축키: Cmd + Shift + ;)"
fi

# 3) Hammerspoon 재시작
osascript -e 'tell application "Hammerspoon" to quit' >/dev/null 2>&1 || true
sleep 1
open -a Hammerspoon
sleep 2

# 4) 손쉬운 사용 설정 열기
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" 2>/dev/null || true

echo ""
echo "🎉 설치 완료! 마지막 한 단계:"
echo "   시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Hammerspoon 켜기"
echo ""
echo "   사용법: 잘못 친 텍스트를 드래그 선택 → Cmd + Shift + ;"
echo ""
