# Antigravity MCP, Skills, & System Access Directory

This document provides a comprehensive inventory of the Model Context Protocol (MCP) servers, advanced developer skills, operating system access utilities, manual QA guidelines, and troubleshooting workflows available to the Antigravity agent in this workspace.

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

---

## 5. Manual QA & Manual Validation Workflows

Manual validation relies on headed browser interactions, verification matrices, and local data resets. Follow these steps when asked to manually test or audit the platform.

### 5.1 Guided Manual Simulation Runner
A node-based simulation script is available to mimic human-like browser navigation, logins, forms, uploads, and admin controls:
```bash
# Run the full guided manual-browser simulation flow in headed mode:
node scripts/qa/manual-browser-flow.js --headed --flow-mode=full
```
* **Seeding Bypass Option**: To skip the admin baseline database reset and speed up verification, run:
  ```bash
  node scripts/qa/manual-browser-flow.js --headed --flow-mode=full --use-seeded-users=1
  ```
* **Quick Simulation Output**: Visual verification logs and screenshot files are outputted to `tmp/manual-browser-sim-result.json` and `tmp/manual-browser-sim-failure.png` on error.

### 5.2 Deterministic Seed Personas & Credentials
For manual logging and testing, use the following local account matrix:

| Role Persona | Email Credentials | Password | Key Testing Areas |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@tfp.local` | `Admin123!` | Moderation queues, reports triage, user suspension, contest creation. |
| **Photographer** | `photo@tfp.local` | `Photo123!` | Portfolio uploads, opportunities creation, applications review, DMs. |
| **Model** | `model@tfp.local` | `Model123!` | Event RSVPs, contest submissions, opportunity applying, messaging. |

### 5.3 Core Manual Checkpoints & UI Validation
When validating features manually, you MUST systematically check:
1. **Interactive Focus Traps**: Ensure that when a modal (Auth Modal, Report Modal, Country Modal) opens:
   * Focus is trapped inside the dialog and does not leak back to the main document body.
   * `Esc` closes the modal, returning focus back to the triggering control.
2. **Keyboard-Only CTAs**: Verify that top header search input, navigation links, and primary action buttons can be navigated and triggered using only the `Tab` and `Enter`/`Space` keys.
3. **Viewport Breakpoint Compliance**: Resize the viewport or emulate device widths using DevTools:
   * **1440px** (Desktop Wide)
   * **1280px** (Laptop)
   * **768px** (Tablet)
   * **375px** (Mobile)
   * Check for horizontal layout overflows, element clipping, and sticky button visual spacing.
4. **Theme Contrast Auditing**: Ensure text readability and form control inputs remain visible across all supported themes. Avoid hardcoded light/dark colors.
5. **No-JavaScript Progressive Enhancement**: Disable JavaScript in the browser settings and verify that:
   * Standard route navigations and listing directory pages function using SSR links.
   * Native `<noscript>` fallback indicators are visible on JS-enhanced fields (such as map widgets and image dropzones).
6. **Policy Leaf Verification**: Open `scripts/qa/test-folder-moderation/policy_leaf_investigator.html` in a web browser to inspect policy trees and moderation outcomes of uploaded assets.

---

## 6. Troubleshooting & Diagnostics

Use these diagnostic recipes when experiencing connection, build, or verification failures.

### 6.1 Common Connection & Launch Failures
* **Error: `Could not find DevToolsActivePort`**:
  * This is specific to `--autoConnect` mode in the DevTools client. It means the browser debugging port is inaccessible.
  * *Fix*: Verify that the target Chrome browser is running, navigate to `chrome://inspect/#remote-debugging`, and make sure **Enable remote debugging** is checked.
* **Limited Tools Available (Only 9 tools visible)**:
  * This occurs when the MCP client enforces read-only safety restrictions.
  * *Fix*: Disable "Plan Mode" or adjust tool permission locks in your Gemini agent settings.
* **Server Address Binding Errors**:
  * Ensure sibling services are running on their assigned ports:
    * Astro Frontend: `http://localhost:3000`
    * Fastify API Backend: `http://localhost:4000` (Health check: `http://localhost:4000/health`)
    * Collage Service: `http://localhost:4001` (Health check: `http://localhost:4001/health/live`)
    * Image Moderation: `http://localhost:7001` (Health check: `http://localhost:7001/health/live`)

### 6.2 Workspace Diagnostic Checklist
Before troubleshooting code, always check the state of the workspace:
```bash
# Check status of local git repository
git status

# Inspect running node process PIDs
ps aux | grep node

# Force stop all running TFP services
pnpm app:stop
```
