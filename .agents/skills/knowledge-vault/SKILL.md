---
name: knowledge-vault
description: Manage an explicitly approved Threadraft Vault using upstream Wiki workflows, local QMD retrieval, and Threadraft policies.
---

# Vault 워크플로우

AGENTS.md와 policies/vault.ko.md를 먼저 읽는다. 운영 모드와 Vault 경로를 확인하고 승인된 범위 안에서만 아래 단계를 실행한다. tools/llm-wiki-agent/AGENTS.md에서 Wiki 유형 및 Ingest, Query, Lint, Graph 절차를 참조한다. 실행 도구, 경로 및 개인정보에는 Threadraft 정책을 적용한다.

- **기록** — 승인된 자료를 `raw/`에 추가하고 Health를 실행한다. 출처 및 기존 Wiki를 확인하여 중복과 모순을 검토하고 upstream Ingest 절차에 맞춰 Markdown을 갱신한다. `wiki/index.md`를 동기화하고 `wiki/log.md`에 변경 이유를 남긴다. Health를 다시 실행한 뒤 QMD 갱신을 요청한다.
- **검색** — QMD Wiki 검색에서 후보를 선택하고 Wikilink를 따라간다. 필요한 경우 `raw/`에서 출처를 확인한다. 근거가 있는 답변과 후보 가설을 구분하고 사용자가 선택하면 synthesis로 저장한다.
- **정리·발견** — Health 결과와 upstream Lint 기준으로 깨진 링크, 중복, 오래된 주장, 모순을 점검한다. 관계 후보와 검토 질문은 `reports/`에 작성한다. 확인된 링크의 파생 그래프는 래퍼의 Graph 동작으로 재생성한다.
