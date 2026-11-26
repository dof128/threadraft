# 구현 및 검증 기록

## 기존 저장소와 전환 범위

기준 커밋 `e28b0d558a46876c4a3f4af77e9344685d6fa51e`에는 Windows용 Spec Kit·EGM 초기화 안내, 이슈 스킬 두 개, 개발 워크플로우 문서가 있었다. Vault나 앱 런타임은 없었다. 개편 브랜치에서는 지식 관리 진입점을 적용했다. 기존 문서와 스킬은 [기준 커밋](https://github.com/dof128/threadraft/tree/e28b0d558a46876c4a3f4af77e9344685d6fa51e)에서 함께 확인할 수 있다. 별도 브랜치, 릴리스 또는 배포 방식은 미정이다.

| 설계 항목 | 적용 내용 |
| --- | --- |
| 운영과 데이터 분리 | 운영 지침, 정책, 템플릿, 도구와 테스트를 Git에서 관리한다. 루트 `vault/`와 `.cache/`는 제외한다. |
| 초기화와 경로 | PowerShell 7 래퍼로 빠진 디렉터리와 시드 파일을 생성한다. 기존 시드는 유지한다. 일반적인 링크·junction 경로를 거부하고, 같은 Vault를 사용하는 래퍼 실행끼리 파일 잠금으로 조율한다. |
| llm-wiki-agent | upstream 커밋과 MIT 라이선스를 기록했다. 에이전트가 upstream 스키마와 지식화 절차를 사용하며, 래퍼는 로컬 Health, 구조 Lint와 Wiki 링크 Graph를 실행한다. |
| QMD | Vault별 캐시에 Wiki·Raw Markdown 컬렉션을 구성한다. CLI로 갱신하고 기본 Wiki 검색 및 명시적 Raw 검색을 제공한다. |
| Obsidian | Vault 폴더만 열고 직접 입력과 링크 탐색에 사용한다. 에이전트와 동시 편집하는 경우는 별도 검증이 필요하다. |
| 발견·개인화 | 출처, 기록 이유, 관심사, 연결 후보와 판단 이력을 기록하는 정책과 템플릿을 제공한다. 자동 발견 또는 주기 실행은 도입하지 않았다. |

첨부된 [아키텍처 초안](architecture.ko.md)은 원문 그대로 보존했다. [upstream 적용 상세](../tools/llm-wiki-agent/README.md)에는 재사용한 도구와 변경 범위를 기록했다. 스크립트의 잠금은 Obsidian이나 직접 파일을 편집하는 에이전트에 적용되지 않는다. 경로 점검과 Git 제외는 접근 제어를 대체하지 않는다.

## 합성 데이터 검증

Linux에서 PowerShell 7.4.19, Python 3.12, Node.js 24 및 QMD 2.9.0으로 다음을 확인했다.

- 임시 Vault 생성과 구조 확인, 재초기화 시 기존 Wiki 인덱스와 원본 내용 보존.
- 저장소 내부 허용 범위 밖의 경로 및 Vault 내부·상위 경로의 심볼릭 링크 거부. 잠긴 Vault의 중복 초기화 거부.
- Health의 인덱스 정합성 확인, Lint의 깨진 링크 실패 처리, Graph의 Wikilink JSON 생성.
- Wiki와 Raw 검색 범위, 영어·한국어 키워드 적중과 문서 수정 후 인덱스 갱신. 임베딩 검색 품질은 평가하지 않았다.
- Git에서 루트 Vault 및 캐시 경로 제외와 현재 기준 이력의 추적 여부 확인.

Windows 네이티브 PowerShell 및 QMD 확인용 GitHub Actions 작업을 추가했다. 해당 작업은 로컬 Linux 검증에 포함되지 않았다. Obsidian GUI, Web Clipper, 에이전트의 전체 Ingest·Query 및 의미 Lint, 모델 다운로드·벡터/하이브리드 검색, 독립 백업 복구는 실행 검증하지 않았다.

## 열려 있는 결정

- 독립 Vault Git 또는 다른 백업 방식, 백업 대상과 복구 정책, 민감 자료의 에이전트 접근 범위.
- 다국어 임베딩 후보와 품질 기준. Qwen3-Embedding-0.6B는 설계의 검증 후보로 유지한다.
- Obsidian과 에이전트의 편집 충돌, 경로·앵커가 포함된 Wikilink, 이름 변경 처리. 현재 구조 Lint는 upstream의 파일 이름 기반 검사다.
- upstream 갱신 주기·절차 및 개발 템플릿의 장기 보존·배포 방식.
