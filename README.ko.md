# Threadraft

[English](README.md)

Threadraft는 개인 지식 저장소를 운영하기 위한 에이전트 프레임워크다. 운영 도구와 정책은 이 Git 저장소에서 관리하고, 개인 자료는 별도로 관리하는 Markdown Vault에 저장한다. llm-wiki-agent는 지식화 워크플로우와 Wiki 형식을 제공한다. QMD는 로컬 검색 후보를 찾고, Obsidian은 직접 기록하고 링크를 탐색하는 데 사용한다.

## 시작

Windows 네이티브 PowerShell 7과 Git을 사용한다. Health, Lint, Graph에는 Python 3.10 이상이 필요하다. 검색을 사용하려면 QMD를 설치한다. 다음 명령은 저장소 루트에서 실행한다.

```powershell
./scripts/Invoke-Vault.ps1 -Action Init
./scripts/Invoke-Vault.ps1 -Action Validate
./scripts/Invoke-Vault.ps1 -Action Health
```

기본 경로는 저장소의 `vault/`다. 각 명령에 `-VaultPath`를 지정해 저장소 밖의 로컬 Vault를 사용할 수 있다. Init은 빠진 디렉터리와 Wiki 시작 파일을 추가한다. 기존 파일을 보존한다. Obsidian에서 저장소 루트 대신 Vault 폴더를 연다. Web Clipper를 사용하는 경우 원본 자료를 `raw/articles/` 등 적절한 폴더에 저장한다.

## 운영

에이전트에는 대상 Vault와 작업 범위를 명시한다. [운영 정책](policies/vault.ko.md)에 따라 출처를 보존하고 원본과 정리된 Wiki를 구분한다. 폴더와 파일의 역할은 [아키텍처](docs/architecture.ko.md)를 참조한다.

```powershell
./scripts/Invoke-Vault.ps1 -Action Lint
./scripts/Invoke-Vault.ps1 -Action Graph
npm install --global @tobilu/qmd@2.9.0
./scripts/Invoke-Vault.ps1 -Action Index
./scripts/Invoke-Vault.ps1 -Action Search -Query '기록 찾기'
./scripts/Invoke-Vault.ps1 -Action Search -Collection Raw -Query '출처 확인'
```

Validate는 Vault 구조를 확인한다. Health는 빈 페이지, 인덱스 일치, 로그 포함 여부를 JSON으로 보고한다. Lint는 Wiki 링크 검사와 고립 문서 목록을 출력하며 깨진 링크가 있으면 실패한다. 링크는 Wiki에서 유일한 파일 이름을 사용하는 기본 `[[이름]]` 형식으로 작성한다. Graph는 추론 호출 없이 Wiki 링크를 추출해 `graph/graph.json`을 생성한다. 의미적 Lint는 에이전트 워크플로우에서 범위를 승인받아 진행한다.

Index는 Wiki와 Raw Markdown을 갱신하고, Search는 기본적으로 Wiki에서 키워드를 찾는다. QMD 설정과 인덱스는 Vault별로 `.cache/qmd/` 아래 생성된다. 벡터 또는 하이브리드 검색을 검토하는 경우 `Embed`와 `-SearchMode Vector` / `Hybrid`를 사용할 수 있다. 모델 다운로드가 필요할 수 있으며, 모델 선택과 검색 품질 검증은 열려 있다.

Vault와 캐시는 개인정보로 다룬다. 독립 버전 관리와 백업 대상은 사용자와 합의한다.

## 개발

```powershell
pwsh -NoProfile -File tests/Test-SyntheticVault.ps1
pwsh -NoProfile -File tests/Test-SyntheticVault.ps1 -WithQmd
```

테스트는 임시 합성 Vault를 만든다. 두 번째 명령에는 QMD가 필요하다. [구현 및 검증 기록](docs/implementation.ko.md)에서 확인한 환경과 남은 검증을 확인할 수 있다.

기존 Spec Kit·EGM 프로젝트 템플릿은 개편 직전 기준 커밋에 보존되어 있다. 장기 배포 방식은 미정이다. [기존 개발 템플릿](https://github.com/dof128/threadraft/tree/e28b0d558a46876c4a3f4af77e9344685d6fa51e)

[MIT 라이선스](LICENSE)
