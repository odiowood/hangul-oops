#!/bin/bash
# 한글 Oops 제거 스크립트 — 더블클릭(또는 우클릭 → 열기)하면 제거됩니다.
# https://github.com/odiowood/hangul-oops

HS_DIR="$HOME/.hammerspoon"
SPOONS_DIR="$HS_DIR/Spoons"
INIT="$HS_DIR/init.lua"

echo "──────────────────────────────────────────"
echo "  한글 Oops 제거"
echo "──────────────────────────────────────────"
echo ""

# 1) 스푼 삭제
if [ -d "$SPOONS_DIR/HanEng.spoon" ]; then
    rm -rf "$SPOONS_DIR/HanEng.spoon"
    echo "✅ 스푼 삭제: ~/.hammerspoon/Spoons/HanEng.spoon"
else
    echo "ℹ️  스푼이 이미 없습니다."
fi

# 2) init.lua 에서 설정 줄 제거 (수정 전 백업)
if [ -f "$INIT" ] && grep -q 'loadSpoon("HanEng")' "$INIT" 2>/dev/null; then
    cp "$INIT" "$INIT.hangul-oops-uninstall-backup.$(date +%s)"
    grep -v -e 'loadSpoon("HanEng")' -e 'spoon.HanEng' \
            -e '한글 Oops (https://github.com/odiowood/hangul-oops)' \
            "$INIT" > "$INIT.tmp" && mv "$INIT.tmp" "$INIT"
    echo "✅ init.lua 에서 설정 제거 (백업 생성)"
else
    echo "ℹ️  init.lua 에 관련 설정이 없습니다."
fi

# 3) Hammerspoon 재시작으로 단축키/메뉴바 내리기
echo "🔄 Hammerspoon 을 다시 시작합니다..."
osascript -e 'tell application "Hammerspoon" to quit' >/dev/null 2>&1
sleep 1
open -a Hammerspoon >/dev/null 2>&1
sleep 1

echo ""
echo "🎉 제거 완료. 단축키와 메뉴바 아이콘(가A)이 사라집니다."
echo ""
echo "· Hammerspoon 앱까지 지우려면: 응용 프로그램에서 Hammerspoon 을 휴지통으로 옮기세요."
echo "· 다시 쓰고 싶으면 install.command 를 실행하면 됩니다."
echo ""
read -n 1 -s -r -p "이 창은 닫으셔도 됩니다. 아무 키나 누르세요..."
echo ""
