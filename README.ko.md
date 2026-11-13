# Agent Bootstrap

[English](README.md) · 한국어

PowerShell 7을 사용해 Windows 프로젝트에서 Spec Kit, Beads, Codex를 사용할 수 있도록 준비합니다. 이 패키지는 Task 스킬 3개와 프로젝트 범위의 Codex 에이전트 5개를 제공합니다.

## 실행

Git, [Specify CLI](https://github.github.io/spec-kit/installation.html), [Beads](https://github.com/gastownhall/beads)를 설치하고 PowerShell 7을 엽니다. 패키지 저장소를 복제하거나 ZIP을 풉니다. 어느 방식이든 패키지 디렉터리에서 별도의 대상 디렉터리를 지정해 같은 명령을 실행합니다.

```powershell
pwsh -NoProfile -File .\bootstrap.ps1 -ProjectPath 'C:\Projects\my-project' -Json
```

대상 디렉터리는 아직 없거나 기존 프로젝트 파일을 포함할 수 있습니다. 실행 파일이 PATH에 없으면 `-GitPath`, `-SpecifyPath`, `-BeadsPath`로 경로를 지정합니다. 필수 CLI와 선택 CLI·MCP 도구 목록은 [requires.json](requires.json)에서 확인할 수 있습니다.

Bootstrap은 완료한 단계, 충돌, 다음 조치를 보고합니다. 종료 코드 0은 대상 준비 완료, 2는 사전 검사에서 실행이 차단된 상태, 1은 준비 또는 적용 단계의 실패를 뜻합니다. 보고된 원인을 해결한 뒤 같은 명령을 다시 실행합니다. 충돌이 발생한 기존 파일은 보존합니다. Beads 데이터 이전에 실패하면 확인할 수 있도록 옮겨 온 사본의 경로를 보고합니다.

## 프로젝트 사용

작업 유형에 맞는 절차 선택, 산출물과 Task 연결, 검증 결과 기록은 [Spec Kit과 Beads 사용 절차](docs/spec-kit-beads-workflow.ko.md)를 참고합니다.

Codex에서 대상 프로젝트를 신뢰할 수 있는 프로젝트로 열어 프로젝트별 설정을 불러옵니다. 첫 Task worktree를 만들기 전에 Git 기준 커밋을 준비합니다. 프로젝트의 작업 범위, 경로, 검증 명령, 통합 정책을 해당 프로젝트의 `AGENTS.md`에 기록합니다. Bootstrap은 기존 파일의 내용을 보존하며, 파일이 없으면 그대로 둡니다. [OpenAI 가이드와 최소 예시](https://developers.openai.com/codex/guides/agents-md)

1. 요청에 따라 명세나 평가 문서를 준비합니다.
2. `task-open`으로 Beads Task와 worktree를 준비합니다. 기능 문서가 있으면 Task에 연결합니다.
3. `task-integrate`로 검토, 인계, 재개, 승인된 통합을 진행합니다.
4. Task의 인수 기준과 프로젝트 종료 조건을 충족하면 `task-close`를 사용합니다.

`.codex/agents/`의 프로젝트별 TOML 파일에는 조사, 코드 탐색, 구현, 리뷰, 검증 역할이 정의되어 있습니다. 필요한 경우 역할마다 `model`과 `model_reasoning_effort`를 설정합니다. 이 키를 생략하면 Codex가 기본값을 적용합니다. Bootstrap을 다시 실행해도 이 설정은 보존됩니다. 다른 로컬 수정이나 이름 충돌이 있으면 충돌을 검토하고 사용할 파일을 결정한 뒤 다시 실행합니다. [OpenAI 사용자 정의 에이전트](https://developers.openai.com/codex/subagents)

Windows용 Codex CLI 0.167.0-alpha.3.2에서 역할 자동 검색 오류를 재현했습니다. 새 세션에서 유효한 프로젝트 역할이 자동 등록 과정에서 알 수 없는 에이전트 유형으로 처리됐습니다. 비교 실행에서는 CLI에서 `description`과 `config_file`을 직접 지정해 같은 리뷰어 TOML을 등록했고, 세션 기록에서 하위 에이전트의 역할, 모델, 추론 강도를 확인했습니다. 해당 버전에는 역할 자동 검색 제약이 있습니다. [관련 Codex 이슈](https://github.com/openai/codex/issues/14579)

패키지는 새 임베디드 Beads 데이터를 격리된 환경에서 준비합니다. 대상의 Beads 데이터베이스는 해당 프로젝트와 함께 관리하고, 장기 보존용 사본은 Beads의 백업 절차에 따라 만듭니다.
