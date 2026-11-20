# Threadraft

[English](README.md) · 한국어

Windows에서 새 프로젝트를 시작할 때 Codex용 Spec Kit과 EGM, 이슈 관리 스킬 2개를 설정합니다. Codex에서 설정할 프로젝트를 열어 신뢰할 수 있는 프로젝트로 지정한 뒤 이 README 전체를 채팅에 붙여넣으세요. 빈 폴더에서도, 파일을 몇 개 만들어 둔 새 프로젝트에서도 시작할 수 있습니다.

## 열린 프로젝트 초기화

이 README가 Codex 채팅에 입력되면, 열린 프로젝트를 다음 순서로 설정하고 채팅에 결과를 알려 주세요.

1. **대상 확인** — 프로젝트의 절대 경로를 확인하고, Git 저장소가 있으면 루트를 확인합니다. 어느 프로젝트를 설정할지 알 수 없으면 사용자에게 확인합니다. Threadraft 원본 저장소, 드라이브 루트, 다른 Git 루트의 하위 폴더에는 쓰지 않습니다. Git 명령이 실패하면 저장소가 없는 경우인지, 다른 오류가 발생한 것인지 확인합니다. 프로젝트 경로와 상위 경로에 Windows junction처럼 다른 위치로 이어지는 항목이 있는지 확인합니다. 이어서 `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE`, `SPECIFY_INIT_DIR`처럼 Git이나 Spec Kit이 다른 경로를 사용하게 하는 환경 변수가 설정돼 있는지 확인합니다. 안전하게 쓸 수 없는 경로나 설정을 발견하면 프로젝트를 수정하기 전에 멈추고 이유를 알립니다.
2. **도구 확인** — `git --version`과 `specify version`을 실행하고, 현재 Codex 환경에 EGM이 설치됐는지 확인합니다. 이미 설치되어 정상 작동하는 도구는 그대로 사용합니다. Spec Kit이나 EGM이 없으면 공식 안내에 따라 설치합니다. Codex 데스크톱은 게시된 EGM 플러그인을 사용하고, CLI는 EGM 가이드의 마켓플레이스·플러그인 설치 절차를 따릅니다. Git을 사용할 수 없으면 공식 설치 안내를 따릅니다. 도구를 설치하거나 새 세션을 여는 데 사용자의 도움이 필요하면, 프로젝트 파일을 수정하기 전에 필요한 작업과 다시 시작하는 방법을 알립니다. 도구가 이미 준비됐다면 안내 웹페이지를 열 필요가 없습니다. [Git 설치](https://git-scm.com/install/) · [Spec Kit 설치](https://github.github.io/spec-kit/installation.html) · [Spec Kit의 Codex 연동](https://github.github.io/spec-kit/integrations/codex.html) · [EGM 설치](https://github.com/google/elephant-goldfish-model#install)
3. **프로젝트 밖에서 파일 준비** — 빈 임시 폴더에서 `specify init --here --integration codex --non-interactive`를 실행합니다. 프로젝트 환경에서 실행할 수 있는 스크립트 유형을 선택합니다. 기본값으로 실행하기 어려우면 Specify의 `--script` 옵션으로 지정합니다. Codex가 실행 중인데 Specify가 Codex 실행 파일을 찾지 못해서 실패했다면, 새 임시 폴더에서 `--ignore-agent-tools`를 추가해 다시 생성합니다. `.specify/`와 `.agents/skills/speckit-*/` 아래에 생성된 일반 파일만 가져올 목록에 넣습니다. 별도의 임시 Git 저장소에 `https://github.com/dof128/threadraft.git`의 `refs/heads/main`을 가져오고, `FETCH_HEAD`가 가리키는 커밋에서 아래 파일 2개를 가져옵니다. 파일 경로와 내용은 그대로 사용합니다.

   ```text
   .agents/skills/issue-create/SKILL.md
   .agents/skills/issue-close/SKILL.md
   ```

4. **쓰기 전 비교** — 도구와 원본 파일이 준비됐는지, 생성된 파일에 빠진 항목이 없는지, 각 파일을 실제로 쓸 위치가 프로젝트 안인지 확인합니다. 추가하려는 파일이 같은 경로에 이미 있는지도 확인합니다. 내용이 같은 파일과 줄바꿈 형식만 다른 스킬 파일은 그대로 사용합니다. `AGENTS.md`와 사용자 파일을 보존합니다. 파일이나 폴더가 충돌하면 해당 경로를 알리고 멈춥니다. 이 경우 Git 초기화도 보류합니다.
5. **빠진 파일과 설정 추가** — 대상에 Git이 없을 때만 초기화합니다. 파일을 쓰기 직전에 경로를 다시 확인하고, 새 파일은 기존 파일을 덮어쓸 수 없는 방식으로 생성합니다. `.specify/integration.json`은 필요한 구성 파일을 모두 준비한 뒤 작성합니다. `/.worktrees/` 또는 `/.env` 규칙이 빠졌으면 `.gitignore`를 다시 확인한 뒤 빠진 규칙만 추가하고 기존 내용과 형식을 보존합니다. 앞에서 확인한 상태와 달라진 점이 있으면 추가 작업을 멈추고 어디까지 마쳤는지 알립니다. 커밋할지는 사용자가 결정합니다.
6. **검증과 결과 보고** — Git 저장소 루트와 `.specify/integration.json`에 기록된 Codex 연동 및 스크립트 유형을 확인합니다. 템플릿 경로를 찾는 스크립트와 실행에 필요한 조건을 확인하는 스크립트, `speckit-specify`·`speckit-plan`·`speckit-tasks` 스킬과 Threadraft 스킬 파일 2개를 확인합니다. 프로젝트 경로와 원본 커밋, 새로 설정하거나 그대로 사용한 항목, 확인 결과를 정리합니다. 충돌이나 중단 사유가 있으면 함께 적습니다. EGM 설치 여부와 신뢰할 수 있는 프로젝트로 연 새 세션에서 실제로 사용할 수 있었던 스킬도 파일 확인 결과와 구분해 적습니다. 플러그인 설치나 새 세션이 남았다면 필요한 조치를 안내합니다. EGM 리뷰는 사용자가 요청할 때 실행합니다. 첫 이슈를 시작하는 방법으로 [원격 `main`의 스킬 사용 예시](https://github.com/dof128/threadraft/blob/main/docs/skill-usage.ko.md)를 연결합니다.

## 프로젝트 사용

[개발 업무 워크플로](docs/spec-kit-workflow.ko.md)에서 작업 유형별 시작점과 이슈에 문서를 연결하고 확인 결과를 남기는 방법을 살펴볼 수 있습니다. Codex 채팅에 입력할 문구는 [스킬 사용 예시](docs/skill-usage.ko.md)를 참고하세요.

작업 범위, 검증 명령, 변경을 반영하는 절차는 대상 프로젝트의 `AGENTS.md`에 기록합니다. [OpenAI AGENTS.md 안내](https://developers.openai.com/codex/guides/agents-md)

[도구 목록](requires.json)에서 필수 CLI와 필요에 따라 쓰는 CLI·MCP 도구를 확인할 수 있습니다.

## 라이선스

Threadraft는 [MIT 라이선스](LICENSE)에 따라 배포됩니다.
