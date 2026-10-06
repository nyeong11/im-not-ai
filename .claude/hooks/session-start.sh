#!/bin/bash
# Claude Code 클라우드 세션 시작 시 스킬 자동 설치.
# - im-not-ai: 이 저장소를 ~/.claude 에 심링크 (./install.sh --claude-only)
# - jobstack : ~/jobstack 에 클론(없으면) 후 ./install.sh
# - pytest   : tests/ 실행용
# 로컬 실행에는 영향 없음(CLAUDE_CODE_REMOTE=true 일 때만 동작). 여러 번 실행해도 안전.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

REPO="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
JOBSTACK_DIR="${JOBSTACK_DIR:-$HOME/jobstack}"
JOBSTACK_URL="${JOBSTACK_URL:-https://github.com/nyeong11/jobstack.git}"

# 1. im-not-ai — 이미 우리 심링크면 install.sh 가 건너뛴다
"$REPO/install.sh" --claude-only >&2

# 2. jobstack — 실패해도 세션 시작은 막지 않는다
if [ ! -d "$JOBSTACK_DIR/.git" ]; then
  git clone -q --depth 1 "$JOBSTACK_URL" "$JOBSTACK_DIR" >&2 \
    || echo "jobstack 클론 실패 — 건너뜀" >&2
else
  git -C "$JOBSTACK_DIR" pull -q --ff-only >&2 || true
fi
if [ -x "$JOBSTACK_DIR/install.sh" ]; then
  (cd "$JOBSTACK_DIR" && ./install.sh >&2) || echo "jobstack 설치 실패 — 건너뜀" >&2
fi

# 3. 테스트 도구
python3 -c 'import pytest' 2>/dev/null \
  || pip install -q pytest >&2 \
  || pip install -q --break-system-packages pytest >&2 \
  || echo "pytest 설치 실패 — 건너뜀" >&2
