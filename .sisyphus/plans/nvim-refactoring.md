# Neovim Configuration Refactoring

## TL;DR

> **Quick Summary**: Neovim 설정(~/.config/nvim)의 유지보수성과 가독성 개선을 위한 전체 리팩토링. 코드 중복 제거, 책임 분리, 설정값 중앙화를 수행하며 기존 키맵과 동작은 100% 유지.
> 
> **Deliverables**:
> - `lua/ashrock/config.lua` - 중앙화된 설정값
> - `lua/ashrock/utils.lua` - 공통 유틸리티 함수
> - 리팩토링된 `init.lua`, `set.lua`, `remap.lua`
> - 리팩토링된 `md_frontmatter.lua`
> - 플러그인별 키맵 이동된 `lazy/*.lua`
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 0 → Task 1 → Task 2 → Task 3-6 (parallel) → Task 7 → Task 8

---

## Context

### Original Request
Neovim 설정 레포지토리의 유지보수성과 가독성 측면에서 리팩토링할 것이 있는지 검토하고 제안해 달라는 요청. 전체 리팩토링 진행하며 기존 동작 100% 유지.

### Interview Summary
**Key Discussions**:
- 전체 리팩토링 진행 (중복 제거 + 책임 분리 + 코드 품질)
- 기존 키맵과 동작 완전히 동일하게 유지
- Neovim 버전 불확실 → 조건부 API 사용
- `/texts/` 경로는 `~/texts/` (홈 디렉토리)

**Research Findings**:
- 17개 Lua 파일, lazy.nvim 사용
- ESLint 가용성 체크가 3곳에 중복
- frontmatter 파싱 로직 50줄 이상 중복
- LSP 콜백 56줄이 init.lua에 있음
- 하드코딩된 값 7개 이상

### Metis Review
**Identified Gaps** (addressed):
- 동작 검증 전략 부재 → 키맵 스냅샷 생성/비교 추가
- 스코프 경계 불명확 → 명시적 파일 목록 정의
- API 호환성 → 버전 체크 로직으로 조건부 적용
- 롤백 전략 → 각 단계별 git commit

---

## Work Objectives

### Core Objective
중복 코드 제거, 책임 분리, 설정값 중앙화를 통해 Neovim 설정의 유지보수성과 가독성을 개선한다. 모든 기존 키맵과 동작은 100% 동일하게 유지한다.

### Concrete Deliverables
- `lua/ashrock/config.lua` - 하드코딩 값 중앙화
- `lua/ashrock/utils.lua` - ESLint 체크 등 공통 함수
- 리팩토링된 `lua/ashrock/init.lua` (~15줄로 축소)
- 리팩토링된 `lua/ashrock/set.lua` (MD 로직 분리)
- 리팩토링된 `lua/ashrock/remap.lua` (~50줄로 축소)
- 리팩토링된 `lua/ashrock/md_frontmatter.lua` (중복 제거)
- 키맵 이동된 `lua/ashrock/lazy/lsp.lua`
- 키맵 이동된 `lua/ashrock/lazy/telescope.lua`
- 키맵 이동된 `lua/ashrock/lazy/harpoon.lua` (신규)

### Definition of Done
- [x] `rg "vim.fn.executable.*eslint" ~/.config/nvim` → 1곳만 출력 (utils.lua)
- [x] `diff keymap_before.txt keymap_after.txt` → 차이 없음
- [x] `:LspInfo` (*.lua 파일에서) → lua_ls attached
- [x] `:lua print(vim.inspect(require('ashrock.md_frontmatter').get_all('topics')))` → 테이블 반환
- [x] `nvim --startuptime after.log` → before 대비 ±10% 이내

### Must Have
- 모든 기존 키맵 동일하게 동작
- LSP attach 동작 유지
- Markdown frontmatter 자동완성 유지
- 포매팅 (ESLint/Biome/Prettier) 동작 유지
- git sync 동작 유지 (비활성 상태 유지)

### Must NOT Have (Guardrails)
- 플러그인 내부 설정 변경 (키맵 이동만)
- 명시되지 않은 파일 수정
- 새로운 플러그인 추가
- 기능 추가 또는 제거
- 에러 메시지 변경
- 로드 순서 변경으로 인한 동작 차이

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.

### Test Decision
- **Infrastructure exists**: NO (personal Neovim config)
- **Automated tests**: None
- **Framework**: N/A

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| **Keymap** | Bash (nvim headless) | `nvim --headless -c "redir! > out.txt \| verbose nmap \| quit" && cat out.txt` |
| **Lua Module** | Bash (nvim headless) | `nvim --headless -c "lua print(vim.inspect(...))" -c "quit"` |
| **File Content** | Grep/Read | `rg "pattern" file` or Read tool |
| **Startup Time** | Bash | `nvim --startuptime log.txt -c quit && cat log.txt` |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Baseline - Sequential):
└── Task 0: Generate baseline snapshots

Wave 2 (Foundation - Sequential):
├── Task 1: Create config.lua
└── Task 2: Create utils.lua (depends: 1)

Wave 3 (Refactoring - Parallel):
├── Task 3: Refactor md_frontmatter.lua (depends: 1)
├── Task 4: Move LSP keymaps to lazy/lsp.lua (depends: 2)
├── Task 5: Move Telescope keymaps (depends: 2)
└── Task 6: Move Harpoon keymaps + create lazy/harpoon.lua (depends: 2)

Wave 4 (Integration - Sequential):
├── Task 7: Clean up init.lua, set.lua, remap.lua (depends: 3,4,5,6)
└── Task 8: Update deprecated APIs + final cleanup (depends: 7)

Wave 5 (Verification):
└── Task 9: Final verification and comparison
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 0 | None | 1,2,3,4,5,6,7,8,9 | None |
| 1 | 0 | 2,3,7 | None |
| 2 | 1 | 4,5,6 | None |
| 3 | 1 | 7 | 4,5,6 |
| 4 | 2 | 7 | 3,5,6 |
| 5 | 2 | 7 | 3,4,6 |
| 6 | 2 | 7 | 3,4,5 |
| 7 | 3,4,5,6 | 8 | None |
| 8 | 7 | 9 | None |
| 9 | 8 | None | None |

---

## TODOs

### - [x] 0. Generate Baseline Snapshots (CRITICAL - MUST BE FIRST)

**What to do**:
- 현재 모든 키맵 스냅샷 생성 (`:nmap`, `:vmap`, `:imap`)
- 현재 startup time 측정
- 현재 LSP 동작 확인
- 스냅샷 파일들을 `.sisyphus/evidence/` 에 저장

**Must NOT do**:
- 어떤 설정 파일도 수정하지 않음
- 검증만 수행

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 단순 명령 실행 및 파일 저장
- **Skills**: []
  - No special skills needed

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 1 (alone)
- **Blocks**: Tasks 1-9
- **Blocked By**: None

**References**:
- `lua/ashrock/remap.lua` - 현재 키맵 정의
- `lua/ashrock/init.lua:11-66` - LSP 키맵 정의

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: Generate keymap snapshot
  Tool: Bash (nvim headless)
  Preconditions: Neovim installed
  Steps:
    1. nvim --headless -c "redir! > /tmp/nmap_before.txt | silent verbose nmap | redir END | quit"
    2. nvim --headless -c "redir! > /tmp/vmap_before.txt | silent verbose vmap | redir END | quit"
    3. nvim --headless -c "redir! > /tmp/imap_before.txt | silent verbose imap | redir END | quit"
    4. mkdir -p ~/.config/nvim/.sisyphus/evidence
    5. cp /tmp/*map_before.txt ~/.config/nvim/.sisyphus/evidence/
  Expected Result: 3 keymap snapshot files created
  Evidence: .sisyphus/evidence/nmap_before.txt, vmap_before.txt, imap_before.txt

Scenario: Measure startup time
  Tool: Bash
  Steps:
    1. nvim --startuptime /tmp/startup_before.log -c quit
    2. cp /tmp/startup_before.log ~/.config/nvim/.sisyphus/evidence/
    3. grep "Total" /tmp/startup_before.log
  Expected Result: Startup time recorded
  Evidence: .sisyphus/evidence/startup_before.log

Scenario: Verify LSP attach baseline
  Tool: Bash (nvim headless)
  Steps:
    1. Create temp lua file: echo "print('test')" > /tmp/test.lua
    2. nvim --headless /tmp/test.lua -c "sleep 2" -c "redir! > /tmp/lsp_before.txt | LspInfo | redir END | quit"
    3. cp /tmp/lsp_before.txt ~/.config/nvim/.sisyphus/evidence/
    4. cat /tmp/lsp_before.txt
  Expected Result: Shows lua_ls or similar LSP client info
  Evidence: .sisyphus/evidence/lsp_before.txt
```

**Commit**: NO (baseline only)

---

### - [x] 1. Create config.lua - Centralized Configuration

**What to do**:
- `lua/ashrock/config.lua` 생성
- 하드코딩된 값들을 테이블로 정의:
  - `cache_timeout = 300`
  - `git_sync_interval = 60000`
  - `format_timeout = 500`
  - `lsp_defer_delay = 100`
  - `harpoon_slots = 8`
  - `texts_path = vim.fn.expand("~/texts")`
  - `colorscheme = "tokyonight-night"`
- 모듈 export

**Must NOT do**:
- 다른 파일 수정 (아직)
- 값 변경 (동일한 값 유지)

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 단일 파일 생성, 간단한 구조
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 2 (sequential)
- **Blocks**: Tasks 2, 3, 7
- **Blocked By**: Task 0

**References**:
- `lua/ashrock/md_frontmatter.lua:13,42` - cache timeout (300)
- `lua/ashrock/autosync.lua:49` - git sync interval (60000)
- `lua/ashrock/remap.lua:37` - format timeout (500)
- `lua/ashrock/init.lua:30` - defer delay (100)
- `lua/ashrock/remap.lua:98` - harpoon slots (8)
- `lua/ashrock/set.lua:29,56` - texts path pattern
- `lua/ashrock/init.lua:7` - colorscheme

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: config.lua exports all values
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "lua local c = require('ashrock.config'); print(c.cache_timeout, c.git_sync_interval, c.format_timeout, c.texts_path)" -c quit 2>&1
  Expected Result: Output shows "300  60000  500  /Users/[username]/texts"
  Evidence: Terminal output captured

Scenario: config.lua has no syntax errors
  Tool: Bash
  Steps:
    1. luacheck ~/.config/nvim/lua/ashrock/config.lua --no-unused 2>&1 || true
    2. nvim --headless -c "lua require('ashrock.config')" -c quit 2>&1
  Expected Result: No Lua errors
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor(config): create centralized config.lua with hardcoded values`
- Files: `lua/ashrock/config.lua`

---

### - [x] 2. Create utils.lua - Shared Utility Functions

**What to do**:
- `lua/ashrock/utils.lua` 생성
- ESLint 가용성 체크 함수 추출:
  ```lua
  local M = {}
  
  function M.is_eslint_available()
    local clients = vim.lsp.get_clients and vim.lsp.get_clients({ name = "eslint" })
                 or vim.lsp.get_active_clients({ name = "eslint" })
    return vim.fn.executable('eslint') == 1
        or #clients > 0
        or #(vim.lsp.get_clients and vim.lsp.get_clients({ name = "eslintls" })
             or vim.lsp.get_active_clients({ name = "eslintls" })) > 0
  end
  
  return M
  ```
- Neovim 버전 체크 포함 (get_clients vs get_active_clients)

**Must NOT do**:
- 기존 파일에서 아직 교체하지 않음
- 함수 동작 변경

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 단일 파일 생성
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 2 (after Task 1)
- **Blocks**: Tasks 4, 5, 6
- **Blocked By**: Task 1

**References**:
- `lua/ashrock/init.lua:44-46` - ESLint check pattern
- `lua/ashrock/remap.lua:25-27` - ESLint check pattern
- `lua/ashrock/lazy/conform.lua:32-34` - ESLint check pattern

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: utils.is_eslint_available() works
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "lua local u = require('ashrock.utils'); print(type(u.is_eslint_available()))" -c quit 2>&1
  Expected Result: Output shows "boolean"
  Evidence: Terminal output

Scenario: Version-compatible API usage
  Tool: Grep
  Steps:
    1. Read lua/ashrock/utils.lua
    2. Verify contains both "vim.lsp.get_clients" and "vim.lsp.get_active_clients" with conditional
  Expected Result: Both API patterns present with fallback
  Evidence: File content
```

**Commit**: YES
- Message: `refactor(utils): extract shared ESLint check with version-compatible API`
- Files: `lua/ashrock/utils.lua`

---

### - [x] 3. Refactor md_frontmatter.lua - Remove Duplication

**What to do**:
- `get_all_topics()`와 `get_all_objects()` 를 제네릭 함수로 통합:
  ```lua
  local function get_all(field_name)
    -- field_name: "topics" or "objects"
    -- 동일한 로직, 파라미터만 다름
  end
  ```
- config.lua에서 cache_timeout 가져오기
- 기존 함수들을 래퍼로 유지 (호환성):
  ```lua
  M.get_all_topics = function() return get_all("topics") end
  M.get_all_objects = function() return get_all("objects") end
  ```
- 새 함수 `M.get_all(field_name)` 도 export

**Must NOT do**:
- 반환값 형태 변경
- 에러 처리 방식 변경
- 캐시 동작 변경

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 단일 파일 리팩토링, 명확한 패턴
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3 (with Tasks 4, 5, 6)
- **Blocks**: Task 7
- **Blocked By**: Task 1

**References**:
- `lua/ashrock/md_frontmatter.lua:11-38` - get_all_topics() 현재 구현
- `lua/ashrock/md_frontmatter.lua:40-67` - get_all_objects() 현재 구현
- `lua/ashrock/config.lua` - cache_timeout 값

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: get_all_topics() returns same result as before
  Tool: Bash (nvim headless)
  Preconditions: ~/texts/ directory with .md files containing frontmatter
  Steps:
    1. nvim --headless -c "lua print(type(require('ashrock.md_frontmatter').get_all_topics()))" -c quit 2>&1
  Expected Result: "table"
  Evidence: Terminal output

Scenario: get_all_objects() returns same result as before
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "lua print(type(require('ashrock.md_frontmatter').get_all_objects()))" -c quit 2>&1
  Expected Result: "table"
  Evidence: Terminal output

Scenario: New generic get_all() function works
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "lua print(type(require('ashrock.md_frontmatter').get_all('topics')))" -c quit 2>&1
  Expected Result: "table"
  Evidence: Terminal output

Scenario: No duplicate code patterns
  Tool: Bash (grep)
  Steps:
    1. rg "for _, file in ipairs(files)" ~/.config/nvim/lua/ashrock/md_frontmatter.lua | wc -l
  Expected Result: Output is "1" (single loop, not duplicated)
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor(md_frontmatter): consolidate duplicate parsing logic into generic function`
- Files: `lua/ashrock/md_frontmatter.lua`

---

### - [x] 4. Move LSP Keymaps to lazy/lsp.lua

**What to do**:
- `init.lua`의 LspAttach autocmd (11-66줄)를 `lazy/lsp.lua`로 이동
- `nvim-lspconfig` 플러그인의 config 함수 안에 배치
- utils.lua의 `is_eslint_available()` 사용
- config.lua의 `lsp_defer_delay` 사용

**Must NOT do**:
- 키맵 변경 (gd, K, gh, leader+vws 등 모두 동일)
- 동작 변경 (gd가 definition → references 폴백 동작 유지)
- 로드 순서 변경

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 코드 이동, 명확한 목표
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3 (with Tasks 3, 5, 6)
- **Blocks**: Task 7
- **Blocked By**: Task 2

**References**:
- `lua/ashrock/init.lua:11-66` - 현재 LspAttach 콜백
- `lua/ashrock/lazy/lsp.lua` - nvim-lspconfig 설정
- `lua/ashrock/utils.lua` - is_eslint_available()
- `lua/ashrock/config.lua` - lsp_defer_delay

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: LSP keymaps work after move
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "redir! > /tmp/lsp_keys.txt | verbose nmap gd | redir END | quit"
    2. cat /tmp/lsp_keys.txt
  Expected Result: gd mapping shows "vim.lsp.buf.definition" or similar
  Evidence: /tmp/lsp_keys.txt

Scenario: LspAttach callback still triggers
  Tool: Bash (nvim headless)
  Steps:
    1. echo "print('test')" > /tmp/test.lua
    2. nvim --headless /tmp/test.lua -c "sleep 2" -c "redir! > /tmp/lsp_check.txt | LspInfo | redir END | quit"
    3. cat /tmp/lsp_check.txt
  Expected Result: Shows attached LSP client
  Evidence: /tmp/lsp_check.txt

Scenario: init.lua no longer contains LspAttach
  Tool: Bash (grep)
  Steps:
    1. rg "LspAttach" ~/.config/nvim/lua/ashrock/init.lua | wc -l
  Expected Result: "0"
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor(lsp): move LSP keymaps from init.lua to lazy/lsp.lua`
- Files: `lua/ashrock/lazy/lsp.lua`, `lua/ashrock/init.lua`

---

### - [x] 5. Move Telescope Keymaps to lazy/telescope.lua

**What to do**:
- `remap.lua`의 Telescope 키맵 (69-81줄)을 `lazy/telescope.lua`로 이동
- lazy.nvim의 `keys` 옵션 사용:
  ```lua
  return {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>pf', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
      { '<leader>ps', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
      { '<C-p>', function() require('telescope.builtin').git_files() end, desc = 'Git files' },
    },
    -- existing config...
  }
  ```

**Must NOT do**:
- 키맵 변경
- Telescope 설정 변경

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 키맵 이동만
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3 (with Tasks 3, 4, 6)
- **Blocks**: Task 7
- **Blocked By**: Task 2

**References**:
- `lua/ashrock/remap.lua:69-81` - 현재 Telescope 키맵
- `lua/ashrock/lazy/telescope.lua` - 현재 Telescope 설정

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: Telescope keymaps work after move
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "redir! > /tmp/telescope_keys.txt | verbose nmap <leader>pf | redir END | quit"
    2. cat /tmp/telescope_keys.txt
  Expected Result: Shows Telescope find_files mapping
  Evidence: /tmp/telescope_keys.txt

Scenario: remap.lua no longer contains Telescope keymaps
  Tool: Bash (grep)
  Steps:
    1. rg "telescope.builtin" ~/.config/nvim/lua/ashrock/remap.lua | wc -l
  Expected Result: "0"
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor(telescope): move keymaps to lazy/telescope.lua using keys option`
- Files: `lua/ashrock/lazy/telescope.lua`, `lua/ashrock/remap.lua`

---

### - [x] 6. Create lazy/harpoon.lua and Move Keymaps

**What to do**:
- `lazy/init.lua`에서 Harpoon 플러그인 정의를 새 `lazy/harpoon.lua`로 분리
- `remap.lua`의 Harpoon 키맵 (83-104줄)을 `lazy/harpoon.lua`로 이동
- config.lua의 `harpoon_slots` 사용
- lazy.nvim의 `keys` 옵션 사용

**Must NOT do**:
- 키맵 변경
- Harpoon 설정 변경 (toggle_opts 등)

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 파일 분리 및 키맵 이동
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: YES
- **Parallel Group**: Wave 3 (with Tasks 3, 4, 5)
- **Blocks**: Task 7
- **Blocked By**: Task 2

**References**:
- `lua/ashrock/lazy/init.lua:25-29` - 현재 Harpoon 플러그인 정의
- `lua/ashrock/remap.lua:83-104` - 현재 Harpoon 키맵
- `lua/ashrock/config.lua` - harpoon_slots

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: Harpoon keymaps work after move
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "redir! > /tmp/harpoon_keys.txt | verbose nmap <leader>a | redir END | quit"
    2. cat /tmp/harpoon_keys.txt
  Expected Result: Shows harpoon:list():add mapping
  Evidence: /tmp/harpoon_keys.txt

Scenario: lazy/harpoon.lua created and loaded
  Tool: Bash
  Steps:
    1. test -f ~/.config/nvim/lua/ashrock/lazy/harpoon.lua && echo "exists"
    2. nvim --headless -c "lua require('ashrock.lazy.harpoon')" -c quit 2>&1
  Expected Result: "exists" and no errors
  Evidence: Terminal output

Scenario: Harpoon removed from lazy/init.lua
  Tool: Bash (grep)
  Steps:
    1. rg "ThePrimeagen/harpoon" ~/.config/nvim/lua/ashrock/lazy/init.lua | wc -l
  Expected Result: "0"
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor(harpoon): extract to dedicated lazy/harpoon.lua with keymaps`
- Files: `lua/ashrock/lazy/harpoon.lua`, `lua/ashrock/lazy/init.lua`, `lua/ashrock/remap.lua`

---

### - [x] 7. Clean Up init.lua, set.lua, remap.lua

**What to do**:
- `init.lua`: LSP 콜백 제거 후 ~15줄로 축소
- `set.lua`: markdown 템플릿 로직(27-84줄)을 `md_frontmatter.lua`로 이동
  - config.lua의 `texts_path` 사용
- `remap.lua`: Telescope, Harpoon 키맵 제거 후 ~50줄로 축소
- `conform.lua`, `remap.lua`에서 ESLint 체크를 `utils.is_eslint_available()`로 교체
- 불필요한 주석 코드 제거:
  - `init.lua:4` - autosync 주석
  - `init.lua:59-64` - BufWritePre 주석
  - `treesitter.lua:6-8` - ensure_installed 주석
- 네이밍 통일: `OpenRandomFileInDir` → `open_random_file_in_dir`

**Must NOT do**:
- 동작 변경
- 추가 기능 구현

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 정리 작업, 명확한 범위
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 4 (sequential)
- **Blocks**: Task 8
- **Blocked By**: Tasks 3, 4, 5, 6

**References**:
- `lua/ashrock/init.lua` - 전체 파일
- `lua/ashrock/set.lua:27-84` - markdown 템플릿 로직
- `lua/ashrock/remap.lua` - 전체 파일
- `lua/ashrock/lazy/conform.lua:32-34` - ESLint 체크
- `lua/ashrock/utils.lua` - is_eslint_available()
- `lua/ashrock/config.lua` - texts_path

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: init.lua reduced in size
  Tool: Bash
  Steps:
    1. wc -l ~/.config/nvim/lua/ashrock/init.lua
  Expected Result: Less than 20 lines
  Evidence: Terminal output

Scenario: remap.lua reduced in size
  Tool: Bash
  Steps:
    1. wc -l ~/.config/nvim/lua/ashrock/remap.lua
  Expected Result: Less than 60 lines
  Evidence: Terminal output

Scenario: ESLint check unified to utils
  Tool: Bash (grep)
  Steps:
    1. rg "vim.fn.executable.*eslint" ~/.config/nvim/lua/ashrock --type lua | wc -l
  Expected Result: "1" (only in utils.lua)
  Evidence: Terminal output

Scenario: Markdown template still works
  Tool: Bash (nvim headless)
  Preconditions: ~/texts/ directory exists
  Steps:
    1. nvim --headless ~/texts/test_new.md -c "CreateMDTemplate" -c "wq"
    2. head -5 ~/texts/test_new.md
    3. rm ~/texts/test_new.md
  Expected Result: Shows frontmatter with created date
  Evidence: Terminal output

Scenario: Function renamed to snake_case
  Tool: Bash (grep)
  Steps:
    1. rg "OpenRandomFileInDir" ~/.config/nvim/lua/ashrock | wc -l
  Expected Result: "0"
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor: clean up init.lua, set.lua, remap.lua after keymap extraction`
- Files: `lua/ashrock/init.lua`, `lua/ashrock/set.lua`, `lua/ashrock/remap.lua`, `lua/ashrock/lazy/conform.lua`, `lua/ashrock/lazy/treesitter.lua`, `lua/ashrock/md_frontmatter.lua`

---

### - [x] 8. Update Deprecated APIs and Final Cleanup

**What to do**:
- 모든 파일에서 `vim.lsp.get_active_clients()` → 버전 호환 방식으로 교체
  ```lua
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  ```
- `vim.cmd('edit ' .. file)` → 안전한 방식으로 교체
  ```lua
  vim.cmd.edit(vim.fn.fnameescape(file))
  ```
- `vim.cmd('bdelete ' .. buf)` → `vim.cmd.bdelete(buf)`
- 최종 코드 스타일 검토

**Must NOT do**:
- 새로운 기능 추가
- 동작 변경

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: API 교체 작업
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 4 (after Task 7)
- **Blocks**: Task 9
- **Blocked By**: Task 7

**References**:
- `lua/ashrock/remap.lua:56,65` - vim.fn.system, vim.cmd 사용
- `lua/ashrock/bufonly.lua:5` - vim.cmd 사용
- Neovim API documentation

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: No deprecated API warnings
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "lua require('ashrock')" -c quit 2>&1 | grep -i deprecated || echo "no deprecation"
  Expected Result: "no deprecation"
  Evidence: Terminal output

Scenario: Safe file operations
  Tool: Bash (grep)
  Steps:
    1. rg "vim.cmd\('edit '\s*\.\." ~/.config/nvim/lua/ashrock | wc -l
  Expected Result: "0" (no unsafe concatenation)
  Evidence: Terminal output
```

**Commit**: YES
- Message: `refactor: update deprecated APIs and improve safety`
- Files: `lua/ashrock/remap.lua`, `lua/ashrock/bufonly.lua`

---

### - [x] 9. Final Verification and Comparison

**What to do**:
- 새 키맵 스냅샷 생성
- before/after 스냅샷 비교
- startup time 비교
- LSP 동작 확인
- 모든 주요 기능 테스트

**Must NOT do**:
- 파일 수정

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: 검증만 수행
- **Skills**: []

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Wave 5 (final)
- **Blocks**: None
- **Blocked By**: Task 8

**References**:
- `.sisyphus/evidence/nmap_before.txt` - 이전 키맵 스냅샷
- `.sisyphus/evidence/startup_before.log` - 이전 startup time

**Acceptance Criteria**:

**Agent-Executed QA Scenarios:**

```
Scenario: Keymap snapshot comparison
  Tool: Bash
  Steps:
    1. nvim --headless -c "redir! > /tmp/nmap_after.txt | silent verbose nmap | redir END | quit"
    2. diff ~/.config/nvim/.sisyphus/evidence/nmap_before.txt /tmp/nmap_after.txt || echo "DIFF FOUND"
  Expected Result: No significant differences (only file path changes acceptable)
  Evidence: diff output

Scenario: Startup time comparison
  Tool: Bash
  Steps:
    1. nvim --startuptime /tmp/startup_after.log -c quit
    2. before=$(grep "Total" ~/.config/nvim/.sisyphus/evidence/startup_before.log | awk '{print $2}')
    3. after=$(grep "Total" /tmp/startup_after.log | awk '{print $2}')
    4. echo "Before: $before, After: $after"
  Expected Result: After is within ±10% of Before
  Evidence: Terminal output

Scenario: All major keymaps work
  Tool: Bash (nvim headless)
  Steps:
    1. nvim --headless -c "verbose nmap <leader>pf" -c quit 2>&1 | grep -q telescope && echo "telescope OK"
    2. nvim --headless -c "verbose nmap gd" -c quit 2>&1 | grep -q lsp && echo "lsp OK"
    3. nvim --headless -c "verbose nmap <leader>a" -c quit 2>&1 | grep -q harpoon && echo "harpoon OK"
  Expected Result: All show "OK"
  Evidence: Terminal output

Scenario: ESLint check consolidated
  Tool: Bash
  Steps:
    1. count=$(rg "vim.fn.executable.*eslint" ~/.config/nvim/lua/ashrock --type lua | wc -l)
    2. echo "ESLint check occurrences: $count"
  Expected Result: count = 1
  Evidence: Terminal output
```

**Commit**: NO (verification only)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `refactor(config): create centralized config.lua` | config.lua | lua require test |
| 2 | `refactor(utils): extract shared ESLint check` | utils.lua | lua require test |
| 3 | `refactor(md_frontmatter): consolidate duplicate logic` | md_frontmatter.lua | function call test |
| 4 | `refactor(lsp): move keymaps to lazy/lsp.lua` | lazy/lsp.lua, init.lua | keymap test |
| 5 | `refactor(telescope): move keymaps to lazy file` | lazy/telescope.lua, remap.lua | keymap test |
| 6 | `refactor(harpoon): extract to dedicated file` | lazy/harpoon.lua, lazy/init.lua, remap.lua | keymap test |
| 7 | `refactor: clean up core files` | init.lua, set.lua, remap.lua, etc. | full test |
| 8 | `refactor: update deprecated APIs` | remap.lua, bufonly.lua | no warnings |

---

## Success Criteria

### Verification Commands
```bash
# ESLint 체크 중복 확인 (1곳만 있어야 함)
rg "vim.fn.executable.*eslint" ~/.config/nvim/lua/ashrock --type lua | wc -l
# Expected: 1

# 키맵 스냅샷 비교
diff ~/.config/nvim/.sisyphus/evidence/nmap_before.txt /tmp/nmap_after.txt
# Expected: No diff or minimal (file path only)

# Startup time
nvim --startuptime /tmp/startup.log -c quit && grep "Total" /tmp/startup.log
# Expected: Similar to before

# LSP 동작
nvim --headless /tmp/test.lua -c "sleep 2" -c LspInfo -c quit 2>&1
# Expected: Shows attached client
```

### Final Checklist
- [x] ESLint 체크 1곳으로 통합
- [x] frontmatter 중복 코드 제거
- [x] LSP 키맵 lazy/lsp.lua로 이동
- [x] Telescope/Harpoon 키맵 각 파일로 이동
- [x] init.lua 15줄 이하
- [x] remap.lua 60줄 이하
- [x] 모든 키맵 동일하게 동작
- [x] Startup time ±10% 이내
- [x] Deprecated API 경고 없음
