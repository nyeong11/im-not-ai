#!/bin/bash
# 클라우드 세션 시작 시 humanize 스킬·에이전트를 ~/.claude 에 연결해 /humanize 등을 쓸 수 있게 한다.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# 스킬 4종(humanize-korean·humanize·humanize-scan·humanize-redo) + 런타임 에이전트 심링크 (멱등)
./install.sh --claude-only

# 테스트 의존성 — 저장소는 stdlib 전용, pytest 만 필요 (.github/workflows/test.yml 과 동일)
python3 -m pip install --quiet pytest
