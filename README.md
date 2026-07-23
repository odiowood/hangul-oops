# 한글 Oops (hangul-oops)

> 만든 사람 · **odiowood**

**한/영 전환키를 안 누르고 잘못 친 텍스트를, 지우고 다시 칠 필요 없이 단축키 하나로 제자리에서 고쳐주는 macOS 도구입니다.**

`dkssud` 라고 쳐버렸나요? 드래그해서 선택하고 단축키만 누르면 → **안녕**
`ㅗ디ㅣㅐ` 가 나왔나요? 똑같이 → **hello**

방향(한→영 / 영→한)은 자동으로 감지합니다. 파이썬 같은 별도 설치도 필요 없습니다.

<p align="center">
  <a href="https://github.com/odiowood/hangul-oops/releases/latest/download/hangul-oops.zip">
    <img src="https://img.shields.io/badge/⬇_바로_다운로드-hangul--oops.zip-3b6cff?style=for-the-badge&logo=apple&logoColor=white" alt="바로 다운로드">
  </a>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey" alt="platform">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="license">
  <img src="https://img.shields.io/badge/의존성-없음_(순수_Lua)-success" alt="no dependencies">
</p>
<p align="center"><sub>버튼을 누르면 릴리스 페이지를 거치지 않고 최신 버전이 바로 내려받아집니다.</sub></p>

---

## ✨ 이런 걸 고쳐줍니다

| 잘못 친 것 (선택) | 단축키 누르면 |
|---|---|
| `dkssud` | 안녕 |
| `dkssudgktpdy` | 안녕하세요 |
| `rkqt` | 값 |
| `ㅗ디ㅣㅐ` | hello |
| `WkaQhd` | 짬뽕 |
| `wKAqHD` (Caps Lock 켠 채로 친 경우) | 짬뽕 |
| `dkssud ㅗ디ㅣㅐ` (한·영 섞임) | 안녕 hello |

- **완성형으로 조립**됩니다. `ㅇㅏㄴㄴㅕㅇ` 같은 낱자가 아니라 제대로 된 `안녕`으로요.
- **Caps Lock 보정**: 한글엔 Caps Lock이 없죠. 켜진 줄 모르고 친 경우까지 알아서 잡아줍니다.
- **클립보드 보존**: 변환은 복사·붙여넣기를 이용하지만, 끝나면 원래 복사해뒀던 내용을 그대로 되돌려 놓습니다.
- **한·영이 섞여도 OK**: 한글은 영문으로, 영문은 한글로 **구간별로 알아서** 서로 바꿔줍니다.
- **어디서나 동작**: 카톡, 크롬, 메모, 슬랙 등 텍스트를 입력하는 대부분의 앱에서 됩니다.

---

## 📦 설치 (약 3분)

이 도구는 [Hammerspoon](https://www.hammerspoon.org)이라는 무료 자동화 앱 위에서 돌아갑니다. Hammerspoon만 한 번 설치하면 나머지는 아주 간단합니다.

### 1. Hammerspoon 설치

[hammerspoon.org](https://www.hammerspoon.org)에서 내려받아 `Hammerspoon.app`을 **응용 프로그램** 폴더로 옮기고 실행하세요.
(Homebrew를 쓰신다면 `brew install --cask hammerspoon`)

### 2. 한글 Oops 설치 (자동)

**[👉 `hangul-oops.zip` 바로 내려받기](https://github.com/odiowood/hangul-oops/releases/latest/download/hangul-oops.zip)** (클릭 즉시 다운로드)

압축을 풀고 나온 폴더에서 **`install.command` 을 우클릭 → 열기**를 누르세요.
스푼 복사와 설정을 **자동으로** 해줍니다. (init.lua를 직접 편집할 필요가 없습니다.)

> 💡 macOS가 *"확인되지 않은 개발자"* 라며 막을 수 있어요. 그럴 땐 그냥 더블클릭 말고 **우클릭 → 열기 → (다시) 열기** 를 눌러주세요. 열어보고 안심하고 싶으면 `install.command`는 텍스트 파일이라 미리 열어 내용을 확인할 수 있습니다.

### 3. 권한 허용 (한 번만)

키 입력을 대신 눌러주려면 **손쉬운 사용** 권한이 필요합니다.
**시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용**에서 **Hammerspoon**을 켜주세요.
(권한을 켠 뒤에는 Hammerspoon을 한 번 재시작하면 확실히 인식됩니다.)

끝났습니다! 🎉

---

## ⌨️ 사용법

아무 앱에서나 잘못 친 텍스트를 **드래그로 선택**한 뒤 → **`Cmd + Shift + ;`**

### 단축키 바꾸기 (코드 편집 없이)

화면 **오른쪽 위 메뉴막대**에 생긴 **`가A`** 아이콘을 클릭하세요.

- **단축키 바꾸기** → 미리 준비된 조합 중에서 선택
- **직접 지정 (다음에 누르는 키로)…** → 클릭한 뒤 원하는 키 조합을 그대로 누르면 즉시 지정 (예: `⌘⇧H`)

바꾼 단축키는 **저장되어** 컴퓨터를 껐다 켜도 유지됩니다.

> 참고: 수식 키(`⌘ ⇧ ⌃ ⌥`) 하나 이상과 함께 눌러야 합니다.

---

## 🔧 작동 원리

두벌식 자판 배열을 기준으로,

- **영타 → 한글**: 각 키를 자모로 바꾼 뒤, 입력기(IME)와 똑같은 조합 규칙으로 초성·중성·종성을 합쳐 완성형 글자로 만듭니다. 겹받침(ㄳ, ㄺ…), 이중모음(ㅘ, ㅝ, ㅢ…), 쌍자음(ㅃ, ㅆ…)까지 처리합니다.
- **한글 → 영타**: 완성형 글자를 초성·중성·종성으로 분해해 자판 키로 되돌립니다.
- **방향 자동 감지**: 텍스트를 한글 구간·영문 구간으로 나눠, 한글은 영타로 / 영문은 한글로 각각 변환합니다. 그래서 한·영이 섞여 있어도 한 번에 처리됩니다. (숫자·공백·문장부호는 구간 경계가 되어 그대로 통과)

모든 변환은 **순수 Lua**로 구현되어 있어 별도 런타임(파이썬 등)이 필요 없습니다.

---

## ❓ 문제 해결

- **단축키를 눌러도 반응이 없어요** → 3단계 손쉬운 사용 권한을 켰는지, 켠 뒤 Hammerspoon을 재시작했는지 확인하세요.
- **일부 앱에서 붙여넣기가 안 돼요** → 그 앱이 `Cmd+C` / `Cmd+V`를 지원하는지 확인하세요. (텍스트 선택·복사가 되는 앱이면 대부분 동작합니다.)
- **단축키가 다른 앱 기능과 겹쳐요** → 위 "단축키 바꾸기"로 다른 조합을 지정하세요.

---

## 🛠 수동 설치 (고급)

자동 설치 스크립트를 쓰지 않고 직접 설정하고 싶다면:

1. `HanEng.spoon` 폴더를 더블클릭하거나 `~/.hammerspoon/Spoons/` 에 복사합니다.
2. `~/.hammerspoon/init.lua` 에 아래 2줄을 추가하고 Hammerspoon을 **Reload Config** 합니다.

```lua
hs.loadSpoon("HanEng")
spoon.HanEng:bindHotkeys({ convert = { { "cmd", "shift" }, ";" } })
```

---

## 🔔 업데이트 알림

새 버전이 나오면 **자동으로 알려드립니다.** 설치해두면 하루에 한 번 조용히 GitHub 최신 릴리스를 확인하고, 업데이트가 있을 때만 알림을 띄웁니다(클릭하면 다운로드 페이지로 이동). 지금 바로 확인하려면 메뉴바 `가A` → **업데이트 확인…** 을 누르세요.

> GitHub 계정이 있다면 이 저장소 오른쪽 위 **Watch → Custom → Releases**를 켜두면 새 릴리스 때 이메일 알림도 받을 수 있습니다.

---

## 🗑 제거

설치할 때 받은 폴더의 **`uninstall.command`** 를 **우클릭 → 열기** 하세요. 단축키·메뉴바 아이콘이 사라지고 관련 설정이 제거됩니다(기존의 다른 Hammerspoon 설정은 그대로 유지, 수정 전 백업 생성).

수동으로 지우려면: `~/.hammerspoon/Spoons/HanEng.spoon` 폴더를 삭제하고, `~/.hammerspoon/init.lua`에서 `HanEng` 관련 두 줄을 지운 뒤 Hammerspoon을 **Reload Config** 하세요. Hammerspoon 앱까지 지우려면 응용 프로그램에서 휴지통으로 옮기면 됩니다.

---

## 📄 라이선스

MIT License · © 2026 odiowood

자유롭게 쓰고 고치고 배포하셔도 됩니다. 다만 저작권 표시는 남겨주세요.
