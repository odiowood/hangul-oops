#!/bin/bash
# 한글 Oops 설치 스크립트 — 더블클릭(또는 우클릭 → 열기)하면 자동으로 설치됩니다.
# https://github.com/odiowood/hangul-oops

cd "$(dirname "$0")" || exit 1

HS_DIR="$HOME/.hammerspoon"
SPOONS_DIR="$HS_DIR/Spoons"
INIT="$HS_DIR/init.lua"
SPOON_SRC="./HanEng.spoon"

echo "──────────────────────────────────────────"
echo "  한글 Oops 설치"
echo "──────────────────────────────────────────"
echo ""

# 0) Hammerspoon 설치 확인
if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo "⚠️  Hammerspoon이 설치되어 있지 않습니다."
    echo "    https://www.hammerspoon.org 에서 먼저 설치한 뒤 이 스크립트를 다시 실행해주세요."
    echo ""
    read -n 1 -s -r -p "아무 키나 누르면 종료합니다..."
    exit 1
fi

# 1) 스푼이 스크립트와 같은 폴더에 있는지 확인
if [ ! -d "$SPOON_SRC" ]; then
    echo "❌ HanEng.spoon 폴더를 찾을 수 없습니다."
    echo "    압축을 풀고 나온 폴더 안에서 install.command 를 실행해주세요"
    echo "    (install.command 와 HanEng.spoon 이 같은 폴더에 있어야 합니다)."
    echo ""
    read -n 1 -s -r -p "아무 키나 누르면 종료합니다..."
    exit 1
fi

# 2) 스푼 복사
mkdir -p "$SPOONS_DIR"
rm -rf "$SPOONS_DIR/HanEng.spoon"
cp -R "$SPOON_SRC" "$SPOONS_DIR/HanEng.spoon"
echo "✅ 스푼 설치 완료: ~/.hammerspoon/Spoons/HanEng.spoon"

# 3) init.lua 에 설정 추가 (이미 있으면 건드리지 않음)
touch "$INIT"
if grep -q 'loadSpoon("HanEng")' "$INIT" 2>/dev/null; then
    echo "ℹ️  설정이 이미 있어 init.lua 는 그대로 둡니다."
else
    cp "$INIT" "$INIT.hangul-oops-backup.$(date +%s)" 2>/dev/null
    {
        echo ""
        echo "-- 한글 Oops (https://github.com/odiowood/hangul-oops)"
        echo 'hs.loadSpoon("HanEng")'
        echo 'spoon.HanEng:bindHotkeys({ convert = { { "cmd", "shift" }, ";" } })'
    } >> "$INIT"
    echo "✅ 설정 추가 완료 (단축키: Cmd + Shift + ;)"
fi

# 4) Hammerspoon 재시작으로 설정 반영
echo "🔄 Hammerspoon 을 다시 시작합니다..."
osascript -e 'tell application "Hammerspoon" to quit' >/dev/null 2>&1
sleep 1
open -a Hammerspoon
sleep 2

echo ""
echo "──────────────────────────────────────────"
echo "🎉 거의 끝났습니다! 마지막 한 단계만 남았어요."
echo "──────────────────────────────────────────"
echo ""
echo "손쉬운 사용 권한을 켜주세요 (키 입력을 대신 눌러주기 위해 필요):"
echo "  시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Hammerspoon 체크"
echo "  (권한을 켠 뒤에는 Hammerspoon 을 한 번 재시작하면 확실히 인식됩니다)"
echo ""
echo "사용법: 잘못 친 텍스트를 드래그로 선택한 뒤  →  Cmd + Shift + ;"
echo ""

# 손쉬운 사용 설정 화면 열어주기
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" 2>/dev/null

read -n 1 -s -r -p "이 창은 닫으셔도 됩니다. 아무 키나 누르세요..."
echo ""
