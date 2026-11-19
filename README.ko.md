# Threadraft

[English](README.md) · 한국어

Windows의 새 프로젝트에 Codex용 Spec Kit과 EGM, 이슈 스킬 2개를 준비합니다. 대상 프로젝트를 Codex에서 신뢰할 수 있는 프로젝트로 열고 이 README 전체를 채팅에 붙여넣으세요. 빈 폴더나 미리 작성한 파일이 있는 신규 프로젝트에서 시작할 수 있습니다.

## 열린 프로젝트 초기화

이 README를 Codex에 붙여넣었다면 현재 열린 프로젝트에서 아래 초기화를 진행하고 결과를 채팅으로 보고합니다.

1. **대상 확인** — 프로젝트의 절대 경로를 확인하고, Git 저장소가 있으면 루트를 확인합니다. 대상이 모호하면 사용할 프로젝트를 묻습니다. Threadraft 원본 저장소, 드라이브 루트, 다른 Git 루트의 하위 폴더에는 쓰지 않습니다. Git 조회 오류는 일반적인 저장소 부재와 구분합니다. 대상과 상위 경로의 Windows junction 등 경로 우회, `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE`, `SPECIFY_INIT_DIR` 같은 경로 지정 설정을 확인합니다. 안전하게 쓸 수 없는 경로나 설정을 발견하면 대상에 쓰지 않고 사유를 보고합니다.
2. **도구 확인** — `git --version`과 `specify version`을 실행하고, 현재 Codex 환경에 EGM이 설치됐는지 확인합니다. 사용 가능한 설치는 재사용합니다. 누락된 Spec Kit과 EGM은 공식 경로로 준비합니다. Codex 데스크톱은 게시된 EGM 플러그인을 사용하고, CLI는 EGM 가이드의 마켓플레이스·플러그인 설치 절차를 따릅니다. Git을 사용할 수 없으면 공식 설치 안내를 따릅니다. 필수 설치나 새 세션에 사용자 조치가 필요하면 프로젝트에 쓰기 전에 남은 조치와 재개 방법을 보고합니다. 도구가 이미 준비됐다면 안내 웹페이지를 열 필요가 없습니다. [Git 설치](https://git-scm.com/install/) · [Spec Kit 설치](https://github.github.io/spec-kit/installation.html) · [Spec Kit의 Codex 연동](https://github.github.io/spec-kit/integrations/codex.html) · [EGM 설치](https://github.com/google/elephant-goldfish-model#install)
3. **대상 밖에서 파일 준비** — 빈 임시 폴더에서 `specify init --here --integration codex --non-interactive`를 실행합니다. 대상 환경에서 실행 가능한 Spec Kit 스크립트 유형을 사용합니다. 기본 유형이 적합하면 그대로 두고 다르면 Specify의 `--script` 옵션을 사용합니다. 현재 Codex 세션을 쓸 수 있고 Specify가 실행 파일을 찾지 못한 것만 문제라면, 새 임시 폴더에서 `--ignore-agent-tools`를 추가해 다시 생성합니다. 생성된 `.specify/`와 `.agents/skills/speckit-*/` 아래의 일반 파일만 후보로 사용합니다. 별도의 임시 Git 저장소에 `https://github.com/dof128/threadraft.git`의 `refs/heads/main`을 가져오고, `FETCH_HEAD`를 한 커밋으로 해석해 아래 파일 2개를 가져옵니다. 경로와 내용을 보존합니다.

   ```text
   .agents/skills/issue-create/SKILL.md
   .agents/skills/issue-close/SKILL.md
   ```

4. **쓰기 전 비교** — 도구와 원본 파일이 준비됐는지, 생성 구성에 누락이 없는지, 실제 쓰기 경로가 프로젝트 안에 있는지 확인합니다. 모든 후보 경로를 기존 파일과 비교합니다. 동일한 파일과 개행만 다른 스킬은 재사용합니다. `AGENTS.md`와 사용자 파일을 보존합니다. 파일·디렉터리 충돌이 있으면 경로를 보고하고 Git 초기화를 포함한 대상 쓰기를 시작하지 않습니다.
5. **누락 항목 적용** — 대상에 Git이 없을 때만 초기화합니다. 매번 쓰기 직전에 경로를 재확인하고 새 파일은 덮어쓰기를 허용하지 않는 방식으로 추가합니다. `.specify/integration.json`은 필요한 구성 파일 뒤에 작성합니다. `/.worktrees/` 또는 `/.env` 규칙이 빠졌으면 `.gitignore`를 다시 확인한 뒤 누락 규칙만 추가하고 기존 내용과 형식을 보존합니다. 비교 이후 변경을 발견하면 추가 쓰기를 중단하고 이미 적용한 항목을 보고합니다. 커밋은 프로젝트 사용자가 결정합니다.
6. **검증과 결과 보고** — Git 루트, `.specify/integration.json`의 Codex 연동 및 선택한 스크립트 유형, 생성된 템플릿 해석기와 선행 조건 검사 파일, `speckit-specify`·`speckit-plan`·`speckit-tasks` 스킬과 Threadraft 스킬 파일 2개를 확인합니다. 대상 경로, 원본 커밋, 구성·재사용 항목, 충돌이나 차단 사유, 검증 근거를 보고합니다. EGM 설치 상태와 새 신뢰 세션에서 실제로 확인한 스킬은 파일 확인과 구분해 기록합니다. 플러그인 설치나 새 세션이 남았다면 필요한 조치를 안내합니다. EGM 리뷰는 사용자가 요청할 때 실행합니다. 첫 이슈 절차는 [원격 `main`의 스킬 사용 예시](https://github.com/dof128/threadraft/blob/main/docs/skill-usage.ko.md)를 연결합니다.

## 프로젝트 사용

작업 유형에 맞는 절차, 산출물 연결, 검증 결과 기록은 [Spec Kit 사용 절차](docs/spec-kit-workflow.ko.md)를 참고합니다. [스킬 사용 예시](docs/skill-usage.ko.md)에서 첫 이슈 시작, EGM 설계 검토, 이슈 종료 방법을 확인할 수 있습니다.

작업 범위, 검증 명령, 통합 정책은 대상 프로젝트의 `AGENTS.md`에 기록합니다. [OpenAI AGENTS.md 안내](https://developers.openai.com/codex/guides/agents-md)

[도구 목록](requires.json)에서 필수 CLI와 선택 CLI·MCP 도구를 확인할 수 있습니다.

## 라이선스

Threadraft는 [MIT 라이선스](LICENSE)에 따라 배포됩니다.
