# Gemini Code Review: TFP Workspace

**Date:** March 7, 2026

This document provides a comprehensive review of the `tfp-workspace` project, covering backend, frontend, database, and overall architecture. The purpose is to identify areas for improvement, potential issues, and missing implementations to guide future development.

## 1. Functional Review

### 1.1. Missing Implementations & Incomplete Features

*   **Event Bus Functionality:** The backend has an event bus (`shared/eventBus`) that currently only logs events (e.g., `contest.approved`). This is a significant missed opportunity. It should be expanded to handle asynchronous tasks like sending email notifications (using the existing `email` package) when a contest winner is selected, a project is approved, or a user receives a new message.
*   **User Notifications:** There is no apparent system for in-app user notifications. While an event bus exists, there is no corresponding frontend implementation or database model to store and display notifications to users for events like new messages, project application status changes, or contest results.
*   **Feature Flags:** The application lacks a feature flag system. For a project in development, this is crucial for testing new features in production with a subset of users and for enabling or disabling functionality without a full deployment.
*   **API Versioning:** The API does not appear to have a versioning strategy (e.g., `/api/v1/...`). While not critical pre-launch, implementing this early will make future breaking changes much more manageable.

### 1.2. Missed User Flows & Edge Cases

*   **Soft-Deleted Data:** The manual `deletedAt` implementation for soft deletes is error-prone. It's highly likely there are places in the code that query for data but forget to filter out soft-deleted records, leading to "ghost" data appearing in the UI.
*   **Race Conditions on Counters:** The denormalized `likeCount`, `voteCount`, etc., on `ContestSubmission` are subject to race conditions and drift. If two users like a submission simultaneously, the final count could be incorrect. This requires transactional updates.
*   **Inconsistent Location Data:** With `location` being a `Json?` field, there's no guarantee of what shape the data is in. This will inevitably lead to errors in both the backend (processing the data) and frontend (displaying it) when an unexpected format is encountered.

## 2. Technical Review

### 2.1. Code Architecture Assessment

*   **Backend (Good):** The backend (`apps/api`) has a good modular structure, leveraging Fastify plugins and separating concerns by domain (contest, project, user). The use of dependency injection via `decorate` for `prisma`, `storage`, and `eventBus` is clean.
*   **Backend (Needs Improvement):** While modular, the business logic is somewhat coupled to the Fastify framework within the route handlers. A move towards a more hexagonal architecture would involve extracting business logic into pure, framework-agnostic "service" or "use case" classes, making them more testable and reusable.
*   **Frontend (Needs Improvement):** The frontend's CSS architecture is a concern. Styles for a reusable component (`ListingCard.astro`) are located in a page-specific file (`pages/listings.scss`). This breaks component encapsulation and hinders reusability. Styles should be co-located with their components or placed in a shared `styles/components` directory.

### 2.2. Patterns and Principles

*   **Dependency Injection:** Used well on the backend with Fastify's decorators.
*   **Adapter Pattern:** The `storage` package uses an adapter pattern (`getStorageService`) to switch between storage providers (e.g., local vs. cloud). This is excellent.
*   **DRY Compliance:**
    *   **Backend:** There are opportunities to centralize duplicated logic, such as "not found" error handling, into shared utilities.
    *   **Frontend:** The `ListingCard.astro` component is a prime example of violating DRY. It contains large, nearly identical blocks of HTML for its different variants. This should be refactored into smaller, specialized components that compose a base `Card` component.

### 2.3. Security, Validation, and Middleware

*   **CRITICAL - Missing Security Headers:** The backend API does not use a library like `fastify-helmet`. This leaves the application vulnerable to common attacks like clickjacking, XSS, and MIME-type sniffing. **This is a high-priority fix.**
*   **CRITICAL - Insecure File Serving:** The API uses `@fastify/static` to serve user-uploaded content directly from the server's filesystem. This is not scalable, is a single point of failure, and is a security risk. The application should use the existing `storage` service to serve files from a dedicated object storage provider (like the configured Backblaze B2 or ImageKit).
*   **Good - Input Validation:** The use of Zod for input validation on the backend is a best practice and is implemented well in the central error handler.
*   **Good - Middleware Pipeline:** The backend has a clear middleware pipeline for CORS, JWT, cookies, and rate limiting.

## 3. Database Review

*   **CRITICAL - Unstructured `Json?` Fields:** The use of `Json?` for `location`, `budget`, and `entryFees` is a major data integrity risk. It prevents any form of schema enforcement at the database level.
    *   **Recommendation:** Create new structured models (e.g., a `Location` model with `street`, `city`, `country`, `lat`, `lon` fields) and establish proper relations. This will improve data consistency and unlock powerful querying capabilities.
*   **Inefficient Soft Deletes:** The manual `deletedAt` fields complicate every single database query.
    *   **Recommendation:** Implement Prisma's soft delete middleware to handle this automatically and transparently, reducing the chance of bugs.
*   **Denormalized Counters:** The `likeCount`, `voteCount`, etc., fields are prone to inconsistency.
    *   **Recommendation:** Use database triggers or, at a minimum, wrap the counter updates in a Prisma transaction (`prisma.$transaction`) along with the creation of the `ContestSubmissionReaction` to ensure atomicity.
*   **Stringly-Typed Enum:** The `ProjectRole.role` field is a `String`. This should be a Prisma `enum` to ensure data consistency, just like `UserRole`.

## 4. Frontend Review

### 4.1. Architecture and Performance

*   **Component-Based Architecture:** The frontend is not sufficiently component-based. As seen with `ListingCard.astro`, components are monolithic and contain too much conditional logic.
    *   **Recommendation:** Aggressively break down large components into smaller, single-purpose, composable components.
*   **Minimal JS Bundle:** The choice of Astro is excellent for achieving a minimal JavaScript footprint by default, which is great for performance.
*   **SSR Compatibility:** The application is configured for SSR with a Node.js adapter, which is good.

### 4.2. Styling and Theming

*   **Excellent - Design Tokens:** The `styles/tokens.scss` file is a fantastic single source of truth for design tokens (colors, spacing, typography). It's well-structured and uses CSS Custom Properties correctly.
*   **Inconsistent - Hardcoded Values:** Despite the excellent token file, developers are creating one-off color variations using `rgba()` in component stylesheets (e.g., `rgba($color-border, 0.24)`).
    *   **Recommendation:** Enforce a strict policy that all colors, including translucent ones, must be defined as variables in `tokens.scss`. Create new token variables for these alpha variations (e.g., `$border-translucent-24`).
*   **Inconsistent - Spacing:** The prompt mentions a "margin-top only" approach. While spacing variables exist, a `grep` for `margin-left`, `margin-right`, or `padding-left` would be needed to confirm if this is being enforced consistently.

## 5. Internationalization (i18n) and Accessibility (a11y)

*   **Good - i18n Implementation:** The project uses a shared `i18n` package, and components correctly use a `t()` function for translations. The `en_US.json` file is comprehensive, though its completeness should be continually audited as features are added.
*   **Accessibility (a11y):** The codebase shows some consideration for accessibility (e.g., `aria-label` attributes). However, without a formal audit using tools like `axe`, it's impossible to determine the level of compliance. A formal a11y audit should be added to the development lifecycle.

## 6. Cleanup Requirements

*   **Refactor Monolithic Components:** The highest priority for cleanup is refactoring components like `ListingCard.astro`.
*   **Untangle CSS:** Move component-specific styles out of page-specific stylesheets and co-locate them with their respective components.
*   **Query Cleanup:** If the soft-delete middleware is implemented, all manual `where: { deletedAt: null }` clauses can be removed from application code, simplifying queries.

## 7. Prioritized Action Items

1.  **[CRITICAL/High] Implement Security Headers:** Add `fastify-helmet` to the backend API immediately.
2.  **[CRITICAL/High] Fix Insecure File Serving:** Refactor the file upload and serving logic to use the `storage` package and a dedicated object store instead of the local filesystem.
3.  **[High] Refactor Database Schema:**
    *   Replace `Json?` fields (`location`, `budget`) with structured models.
    *   Implement Prisma's soft-delete middleware.
    *   Use transactions for updating denormalized counters.
4.  **[High] Refactor `ListingCard.astro`:** Break the monolithic component into smaller, reusable components.
5.  **[Medium] Centralize Component Styles:** Move styles from `pages/listings.scss` to a component-specific location.
6.  **[Medium] Expand Event Bus Functionality:** Integrate the `email` package to send notifications on key domain events.
7.  **[Low] Introduce a Feature Flag System:** Implement a feature flag solution to de-risk future deployments.
8.  **[Low] Conduct a Full Accessibility Audit:** Integrate a tool like `axe-core` into the E2E tests or development process.
