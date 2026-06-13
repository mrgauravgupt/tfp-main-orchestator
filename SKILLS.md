# Antigravity MCP, Skills, & System Access Directory

This document provides a comprehensive inventory of the Model Context Protocol (MCP) servers, advanced developer skills, operating system access utilities, and end-to-end testing workflows available to the Antigravity agent in this workspace.

---

## 1. Model Context Protocol (MCP) Servers
The agent is equipped with several MCP servers loaded dynamically. These servers expose targeted APIs for filesystem, repository management, database operations, and browser execution.

| MCP Server | Description | Key Capabilities / Tools |
| :--- | :--- | :--- |
| **`filesystem`** | Local filesystem access within allowed boundaries. | `read_file`, `write_file`, `edit_file`, `list_directory`, `create_directory`, `directory_tree` |
| **`github`** | Direct integration with GitHub repositories. | `get_file_contents`, `create_branch`, `create_pull_request`, `push_files`, `list_commits`, `create_issue` |
| **`prisma-mcp-server`**| Prisma database schema and migration utility. | `migrate-status`, `migrate-dev`, `migrate-reset`, `Prisma-Studio` |
| **`puppeteer`** | Headless/headed Chrome browser automation. | `puppeteer_navigate`, `puppeteer_screenshot`, `puppeteer_click`, `puppeteer_fill`, `puppeteer_hover` |

---

## 2. Active Developer Skills
Advanced agent skills are loaded from the plugin configurations to guide execution, debugging, and framework integration.

### Browser & UI Automation
* **`chrome-devtools`**: Provides deep browser debugging, target navigation, page inspections, and Chrome DevTools Protocol (CDP) interactions.
* **`a11y-debugging`**: Accessibility auditing based on web.dev guidelines, verifying ARIA attributes, semantic landmarks, keyboard focus, and contrast.
* **`debug-optimize-lcp`**: Diagnostic workflows for improving Largest Contentful Paint (LCP), Cumulative Layout Shift (CLS), and other Core Web Vitals.
* **`troubleshooting`**: Automated resolution workflows when browser targets fail to connect or initialize.

### Core Frameworks & APIs
* **`firebase-*`**: Deep skills covering Firebase Authentication, Cloud Firestore schema design and rules auditing, App Hosting, Remote Config, and Crashlytics.
* **`modern-web-guidance`**: Reference guidelines for modern web standards, CSS layouts (`:has()`, container queries, grid), and native browser APIs.
* **`xcode-project-setup` & `android-cli`**: Device-specific build and deployment automation wrappers.

### Utility & Specializations
* **`workflow-skill-creator`**: Distills completed user interaction sequences into reusable agent skills.
* **`uv`**: Manages Python dependency synchronization and virtual environment baselines.
* **`science-*`**: Domain-specific query layers for scientific databases (UniProt, RCSB PDB, PubChem, PubMed, ChEMBL, etc.).

---

## 3. Computer & OS Access Methods
The agent interacts with the macOS host system through approved shell commands and automation protocols.

### Terminal & Execution (`run_command`)
* The agent executes shell commands directly on the host (e.g., `pnpm`, `git`, `python`, `docker`, service control scripts).
* Background tasks can be monitored and controlled using the `manage_task` tool.

### GUI & Screen Capture (`screencapture`)
* Since the agent operates in a headless/terminal mode, it cannot "see" the physical screen directly.
* To inspect the macOS GUI or active applications, the agent utilizes the macOS native screenshot utility:
  ```bash
  screencapture -x /Users/hexa/.gemini/antigravity/scratch/current_desktop.png
  ```
  *(The `-x` flag suppresses the screenshot shutter sound for a silent capture).*
* Captured screenshots are saved inside the `/Users/hexa/.gemini/antigravity/scratch/` directory and read using `view_file` to perform visual audits.

### File & Application Opening (`open`)
* To launch applications, open URLs in the default user browser, or open local files, the agent uses the macOS `open` command:
  ```bash
  open http://localhost:3000
  open /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/docs/agent-index.json
  ```

### Automated Web Browsing (`puppeteer` / `chrome-devtools`)
* Browser-bound actions are driven via `puppeteer` or `chrome-devtools` protocol wrappers, allowing the agent to launch isolated Chromium instances, navigate pages, click buttons, fill forms, and run page assertions.
* Visual verification is conducted by capturing page states:
  ```json
  // Inside a tool call:
  {
    "tool": "puppeteer_screenshot",
    "arguments": {
      "path": "/Users/hexa/.gemini/antigravity/scratch/page_state.png"
    }
  }
  ```

---

## 4. End-to-End Testing (E2E) Workflows
For **TFP Photographers**, end-to-end testing is structured around Playwright and local seed automation.

### Preparation & Baseline Restores
1. **Stop stale services**:
   ```bash
   bash ./scripts/stop-app.sh
   ```
2. **Reset the database and baseline**:
   ```bash
   bash ./scripts/start-app.sh reset local
   ```
3. **Execute browser-driven data seeding**:
   ```bash
   pnpm qa:create-data:seed:real:quick
   ```
4. **Confirm stack health**:
   * API: `http://localhost:4000/health`
   * Web: `http://localhost:3000/`

### Running Test Suites
* **Full Smoke/CI suite**:
  ```bash
  pnpm test:e2e:smoke:ci
  ```
* **Accessibility checks**:
  ```bash
  pnpm test:e2e:a11y:ci
  ```
* **Visual UI capture and regression review**:
  ```bash
  pnpm qa:ui:inventory
  pnpm qa:ui:capture:smoke
  pnpm qa:ui:analyze:strict
  ```
* **Open policy/moderation investigator**:
  Use `scripts/qa/test-folder-moderation/policy_leaf_investigator.html` to review image moderation outcomes.
