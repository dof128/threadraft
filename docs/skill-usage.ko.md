# 스킬 사용 예시

표에 나온 예시를 Codex 채팅에 입력하세요. 무엇을 바꾸고 어떤 상태면 작업을 마칠 수 있는지 정해졌다면 `issue-create`로 바로 시작할 수 있습니다. 기존 이슈의 작업을 이어갈 때는 이슈 키나 작업 문서 경로를 전달합니다. [Codex에서 Spec Kit 호출하기](https://github.github.io/spec-kit/integrations/codex.html)

## Spec Kit · 새 기능 만들기

기능의 동작과 구현 범위를 정리해야 할 때 사용합니다. CSV 내보내기 기능을 예로 들면 다음 순서로 진행합니다. [Spec Kit 기능 개발 가이드](https://github.github.io/spec-kit/reference/agentic-sdd.html)

| 스킬 | 언제, 왜 쓰나요? | 채팅 입력 예시 |
| --- | --- | --- |
| `specify` | 기능이 어떻게 동작해야 하는지, 요구사항을 충족했는지 어떻게 판단할지 `spec.md`에 적을 때 | `$speckit-specify 필터가 적용된 목록을 CSV로 내보내는 기능이 어떻게 동작해야 하는지 정리해 줘.` |
| `clarify` | 답에 따라 동작이나 작업 범위가 달라질 수 있는 부분을 확인할 때 | `$speckit-clarify 현재 페이지와 필터 결과 전체 중 어디까지 내보낼지 확인해 줘.` |
| `plan` | 요구사항을 바탕으로 수정할 모듈, 데이터 흐름, 확인 방법을 `plan.md`에 정리할 때 | `$speckit-plan 기존 필터 로직을 재사용하는 구현 계획을 작성해 줘.` |
| `tasks` | 구현 계획을 할 일로 나누고 작업 순서를 `tasks.md`에 적을 때 | `$speckit-tasks 내보내기와 테스트를 구현 순서에 맞춰 나눠 줘.` |
| `implement` | `tasks.md`의 항목을 구현하고 진행 상황을 기록할 때 | `$speckit-implement 이슈 worktree에서 tasks.md의 항목을 순서대로 구현해 줘.` |
| `converge` | 구현 후 명세, 계획, 작업 목록과 코드를 대조해 누락을 찾을 때 | `$speckit-converge CSV 내보내기 구현을 점검하고 빠진 항목을 tasks.md에 추가해 줘.` |

작업 문서를 검토한 뒤 `issue-create`로 작업 문서와 Git worktree를 연결합니다. `converge`가 작업을 추가하면 `implement`로 처리한 뒤 다시 확인합니다.

## Spec Kit 확장 · 기존 버그 수정하기

기존 동작의 문제를 조사하고 수정할 때 사용합니다. 아래 예시는 Spec Kit의 `bug` 확장이 설치된 프로젝트에서 실행합니다. [버그 수정 가이드](https://github.github.io/spec-kit/guides/bugfix.html)

| 스킬 | 언제, 왜 쓰나요? | 채팅 입력 예시 |
| --- | --- | --- |
| `bug.assess` | 재현 조건이나 원인을 아직 모를 때. 증상과 정상 동작, 원인으로 의심되는 부분과 그 근거, 수정안을 `assessment.md`에 남깁니다. | `$speckit-bug-assess 필터 결과가 0건일 때 CSV 내보내기를 누르면 오류가 납니다. 헤더만 들어 있는 CSV가 저장돼야 합니다. slug=csv-empty` |
| `bug.fix` | 평가를 검토하고 수정 범위를 확정했을 때. 같은 `slug`로 수정하고 변경 내역을 `fix.md`에 남깁니다. | `$speckit-bug-fix slug=csv-empty` |

수정 후에는 오류가 났던 상황을 다시 재현해 정상 동작하는지 확인합니다.

## EGM · 설계 검토하기

`egm-review`는 여러 에이전트가 설계를 따로 검토하므로 모델 사용량이 늘어날 수 있습니다. 실행 전에 남은 사용량과 필요한 검토 범위를 확인하세요.

| 스킬 | 언제, 왜 쓰나요? | 채팅 입력 예시 |
| --- | --- | --- |
| `egm-review` | 구현 전에 설계가 전제한 조건, 예외 상황, 아직 결정하지 않은 부분을 별도로 검토할 때. 검토할 문서 경로와 관련 자료를 전달합니다. | `$egm-review specs/csv-export/plan.md에서 대량 내보내기와 결과가 0건인 경우를 중점적으로 검토해 줘.` |
| `egm-resolve` | 리뷰에서 지적한 내용이 타당한지 살펴보고 무엇을 수정할지 정할 때. 설계 문서를 작성한 대화에서 문서 경로, 검토할 범위, 리뷰에서 나온 지적 사항을 전달합니다. | `$egm-resolve specs/csv-export/plan.md 전체를 다룬 위 리뷰의 지적을 검토하고 어떤 부분을 고치면 좋을지 제안해 줘.` |

## 커스텀 스킬 · 이슈 관리하기

첫 이슈의 Git worktree를 만들기 전에 사용할 기준 커밋을 정합니다. 새 저장소에 커밋이 없다면 사용자가 먼저 초기 커밋을 만들고, worktree에서 사용할 작업 문서와 그 밖에 필요한 파일이 기준 커밋에 포함됐는지 확인합니다.

| 스킬 | 언제, 왜 쓰나요? | 채팅 입력 예시 |
| --- | --- | --- |
| [`issue-create`](../.agents/skills/issue-create/SKILL.md) | 작업을 시작하거나 이어갈 때. 이슈 문서를 찾거나 만들고 Git worktree를 연결합니다. | `$issue-create specs/csv-export/ 문서를 연결해 이슈와 worktree를 준비해 줘.` |
| [`issue-close`](../.agents/skills/issue-close/SKILL.md) | 완료 기준을 충족했거나 작업을 중단하기로 했을 때. 승인된 결과와 근거를 남기고 이슈를 닫습니다. 변경을 보존했는지 확인한 뒤 승인 범위에서 worktree와 브랜치를 정리합니다. | `$issue-close csv-export 이슈를 완료 처리하고 연결된 worktree와 브랜치를 정리해 줘.` |

**`issue-archive` (준비 중)** · 이슈를 닫은 뒤 후속 작업에서 참고할 수 있도록 Spec Kit 문서에서 결정한 내용과 그 이유를 요약해 메모리에 기록합니다. 보존할 문서를 병합하고 기존 문서와 충돌하는 내용을 찾아 검토할 수 있게 할 예정입니다.
