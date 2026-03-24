# TFP Platform - Comprehensive Manual Test Cases

## Document Information
- **Document Version:** 1.0
- **Created Date:** 2026-03-06
- **Platform:** TFP (The Fotographer's Platform)
- **Testing Type:** Manual Functional Testing

---

## Table of Contents
1. [Authentication](#1-authentication)
2. [Home Page](#2-home-page)
3. [Projects](#3-projects)
4. [Contests](#4-contests)
5. [Events](#5-events)
6. [Profile](#6-profile)
7. [Settings](#7-settings)
8. [Notifications](#8-notifications)
9. [Admin Panel](#9-admin-panel)
10. [Search Functionality](#10-search-functionality)
11. [Direct Messaging](#11-direct-messaging)
12. [Static Pages](#12-static-pages)

---

## Seeded Test Data

### Test Users
| User Type | Email | Password | Role | Subscription |
|-----------|-------|----------|------|--------------|
| Admin | admin@tfp.local | Admin123! | ADMIN | PRO_PLUS |
| Photographer | photo@tfp.local | Photo123! | PHOTOGRAPHER | PRO |
| Model | model@tfp.local | Model123! | MODEL | FREE |

### Additional Seeded Participants
- Email pattern: `seed.participant.{n}@tfp.local` (n = 1-400)
- Password: `Seed123!` (DEFAULT_SEED_PASSWORD)

---

## 1. Authentication

### 1.1 Login Page - Positive Test Cases

#### TC-AUTH-001: Successful Login with Photographer Credentials
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-001 |
| **Test Case Description** | Verify user can successfully log in with valid photographer credentials |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: photo@tfp.local, Password: Photo123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "photo@tfp.local" in email field<br>3. Enter password "Photo123!" in password field<br>4. Click "Sign In" button |
| **Expected Result** | User is redirected to their profile page (/profile/photo@tfp.local). Session is maintained upon page refresh. |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-002: Successful Login with Admin Credentials
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-002 |
| **Test Case Description** | Verify admin user can successfully log in and access admin features |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: admin@tfp.local, Password: Admin123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "admin@tfp.local" in email field<br>3. Enter password "Admin123!" in password field<br>4. Click "Sign In" button |
| **Expected Result** | User is redirected to profile page with admin access. Admin menu options visible in navigation. |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-003: Successful Login with Model Credentials
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-003 |
| **Test Case Description** | Verify model user can successfully log in |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: model@tfp.local, Password: Model123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "model@tfp.local" in email field<br>3. Enter password "Model123!" in password field<br>4. Click "Sign In" button |
| **Expected Result** | User is redirected to their profile page. |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-004: Session Persistence After Browser Refresh
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-004 |
| **Test Case Description** | Verify session is maintained after browser refresh |
| **Preconditions** | User is logged in as photo@tfp.local |
| **Test Data** | Logged in user session |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Note the current URL<br>3. Refresh the browser<br>4. Check if user remains logged in |
| **Expected Result** | User remains logged in after refresh. Profile page is displayed. |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-005: Login Redirect After Accessing Protected Route
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-005 |
| **Test Case Description** | Verify user is redirected to correct page after login when accessing protected route |
| **Preconditions** | User is not logged in |
| **Test Data** | Protected route: /projects/create |
| **Test Steps** | 1. Navigate to /projects/create directly<br>2. User should be redirected to login<br>3. Login with photo@tfp.local / Photo123!<br>4. Observe redirect destination |
| **Expected Result** | After login, user is redirected to /projects/create or their profile |
| **Actual Result** | [To be filled by tester] |

### 1.2 Login Page - Negative Test Cases

#### TC-AUTH-006: Login with Incorrect Username
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-006 |
| **Test Case Description** | Verify appropriate error message appears for non-existent username |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: nonexistent@tfp.local, Password: Photo123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "nonexistent@tfp.local"<br>3. Enter password "Photo123!"<br>4. Click "Sign In" button |
| **Expected Result** | Error message displayed: "Invalid email or password" or similar |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-007: Login with Incorrect Password
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-007 |
| **Test Case Description** | Verify error message appears when password is incorrect |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: photo@tfp.local, Password: WrongPassword123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "photo@tfp.local"<br>3. Enter password "WrongPassword123!"<br>4. Click "Sign In" button |
| **Expected Result** | Error message displayed: "Invalid email or password" |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-008: Login with Empty Credentials
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-008 |
| **Test Case Description** | Verify validation error when attempting to login with empty credentials |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: (empty), Password: (empty) |
| **Test Steps** | 1. Navigate to /login<br>2. Leave email field empty<br>3. Leave password field empty<br>4. Click "Sign In" button |
| **Expected Result** | Validation error messages appear for required fields (email and password) |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-009: Login with Empty Password Only
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-009 |
| **Test Case Description** | Verify validation error when password is empty |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: photo@tfp.local, Password: (empty) |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "photo@tfp.local"<br>3. Leave password field empty<br>4. Click "Sign In" button |
| **Expected Result** | Validation error message for password field |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-010: Login with Empty Email Only
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-010 |
| **Test Case Description** | Verify validation error when email is empty |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: (empty), Password: Photo123! |
| **Test Steps** | 1. Navigate to /login<br>2. Leave email field empty<br>3. Enter password "Photo123!"<br>4. Click "Sign In" button |
| **Expected Result** | Validation error message for email field |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-011: Login with Invalid Email Format
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-011 |
| **Test Case Description** | Verify validation error for invalid email format |
| **Preconditions** | User is on the login page (/login) |
| **Test Data** | Email: notanemail, Password: Photo123! |
| **Test Steps** | 1. Navigate to /login<br>2. Enter email "notanemail"<br>3. Enter password "Photo123!"<br>4. Click "Sign In" button |
| **Expected Result** | Email validation error (e.g., "Please enter a valid email") |
| **Actual Result** | [To be filled by tester] |

### 1.3 Registration

#### TC-AUTH-012: Successful User Registration
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-012 |
| **Test Case Description** | Verify new user can successfully register |
| **Preconditions** | User is on the registration page (/register) |
| **Test Data** | Email: newuser@test.com, Password: NewUser123!, Display Name: Test User |
| **Test Steps** | 1. Navigate to /register<br>2. Enter email "newuser@test.com"<br>3. Enter password "NewUser123!"<br>4. Confirm password<br>5. Enter display name<br>6. Click "Create Account" |
| **Expected Result** | User is registered and redirected to profile setup or home page |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-013: Registration with Existing Email
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-013 |
| **Test Case Description** | Verify error when registering with already registered email |
| **Preconditions** | User is on the registration page (/register) |
| **Test Data** | Email: photo@tfp.local (already registered), Password: NewUser123! |
| **Test Steps** | 1. Navigate to /register<br>2. Enter email "photo@tfp.local"<br>3. Enter password "NewUser123!"<br>4. Confirm password<br>5. Click "Create Account" |
| **Expected Result** | Error message indicating email is already registered |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-014: Registration with Weak Password
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-014 |
| **Test Case Description** | Verify validation for weak password |
| **Preconditions** | User is on the registration page (/register) |
| **Test Data** | Password: 12345678 (less than 8 characters or no special chars) |
| **Test Steps** | 1. Navigate to /register<br>2. Enter valid email<br>3. Enter weak password "123456"<br>4. Click "Create Account" |
| **Expected Result** | Password validation error (minimum 8 characters required) |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-015: Registration with Empty Fields
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-015 |
| **Test Case Description** | Verify validation errors for empty registration form |
| **Preconditions** | User is on the registration page (/register) |
| **Test Data** | All fields empty |
| **Test Steps** | 1. Navigate to /register<br>2. Leave all fields empty<br>3. Click "Create Account" |
| **Expected Result** | Validation errors for all required fields |
| **Actual Result** | [To be filled by tester] |

### 1.4 Forgot Password

#### TC-AUTH-016: Forgot Password - Request Reset Link
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-016 |
| **Test Case Description** | Verify user can request password reset email |
| **Preconditions** | User is on forgot password page (/forgot-password) |
| **Test Data** | Email: photo@tfp.local |
| **Test Steps** | 1. Navigate to /forgot-password<br>2. Enter email "photo@tfp.local"<br>3. Click "Send Reset Link" button |
| **Expected Result** | Success message "Check your email for reset instructions" or similar |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-017: Forgot Password - Non-existent Email
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-017 |
| **Test Case Description** | Verify appropriate response for non-existent email |
| **Preconditions** | User is on forgot password page (/forgot-password) |
| **Test Data** | Email: nonexistent@test.com |
| **Test Steps** | 1. Navigate to /forgot-password<br>2. Enter email "nonexistent@test.com"<br>3. Click "Send Reset Link" |
| **Expected Result** | Success message (to prevent email enumeration) or appropriate error |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-018: Forgot Password - Empty Email Field
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-018 |
| **Test Case Description** | Verify validation for empty email in forgot password |
| **Preconditions** | User is on forgot password page (/forgot-password) |
| **Test Data** | Email: (empty) |
| **Test Steps** | 1. Navigate to /forgot-password<br>2. Leave email field empty<br>3. Click "Send Reset Link" |
| **Expected Result** | Validation error for required email field |
| **Actual Result** | [To be filled by tester] |

### 1.5 Logout

#### TC-AUTH-019: Successful Logout
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-019 |
| **Test Case Description** | Verify user can successfully log out |
| **Preconditions** | User is logged in |
| **Test Data** | Logged in user: photo@tfp.local |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Click user menu/profile dropdown<br>3. Click "Logout" or "Sign Out"<br>4. Verify redirected to home page |
| **Expected Result** | User is logged out, session is cleared, redirected to home page |
| **Actual Result** | [To be filled by tester] |

#### TC-AUTH-020: Access Protected Page After Logout
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-020 |
| **Test Case Description** | Verify user cannot access protected pages after logout |
| **Preconditions** | User is logged in |
| **Test Data** | Logged in user session |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Logout<br>3. Try to navigate to /profile/photo@tfp.local |
| **Expected Result** | User is redirected to login page or shows unauthorized |
| **Actual Result** | [To be filled by tester] |

---

## 2. Home Page

### 2.1 Home Page - Positive Test Cases

#### TC-HOME-001: Home Page Loads Successfully
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-001 |
| **Test Case Description** | Verify home page loads without errors |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Wait for page to fully load<br>3. Check for any console errors |
| **Expected Result** | Home page loads with HTTP 200, all content is visible |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-002: Home Page Displays Trending Projects
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-002 |
| **Test Case Description** | Verify trending projects section displays on home page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Scroll to projects section<br>3. Verify project cards are displayed |
| **Expected Result** | Project cards with title, image, and creator info are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-003: Home Page Displays Active Contests
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-003 |
| **Test Case Description** | Verify active contests section displays on home page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Scroll to contests section<br>3. Verify contest cards are displayed |
| **Expected Result** | Contest cards with title, deadline, and prize info are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-004: Home Page Displays Upcoming Events
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-004 |
| **Test Case Description** | Verify upcoming events section displays on home page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Scroll to events section<br>3. Verify event cards are displayed |
| **Expected Result** | Event cards with title, date, and location are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-005: Navigate to Project from Home
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-005 |
| **Test Case Description** | Verify clicking project card navigates to project detail |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Click on any project card<br>3. Verify navigation to project detail page |
| **Expected Result** | User is redirected to /projects/[id] with project details |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-006: Navigate to Contest from Home
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-006 |
| **Test Case Description** | Verify clicking contest card navigates to contest detail |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Click on any contest card<br>3. Verify navigation to contest detail page |
| **Expected Result** | User is redirected to /contests/[id] with contest details |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-007: Navigate to Event from Home
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-007 |
| **Test Case Description** | Verify clicking event card navigates to event detail |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Click on any event card<br>3. Verify navigation to event detail page |
| **Expected Result** | User is redirected to /events/[id] with event details |
| **Actual Result** | [To be filled by tester] |

### 2.2 Home Page - UI Elements

#### TC-HOME-008: Navigation Menu is Visible
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-008 |
| **Test Case Description** | Verify navigation menu displays correctly |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Check for navigation menu elements |
| **Expected Result** | Menu items: Home, Projects, Contests, Events, Profile (when logged in) |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-009: Login/Join Button Functionality
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-009 |
| **Test Case Description** | Verify Join Now button opens auth modal |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Click "Join Now" button<br>3. Verify auth modal appears |
| **Expected Result** | Auth modal opens with login/register options |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-010: Footer Links Functionality
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-010 |
| **Test Case Description** | Verify footer links navigate to correct pages |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /<br>2. Scroll to footer<br>3. Click each footer link |
| **Expected Result** | Links navigate to Guidelines, Privacy, Terms pages |
| **Actual Result** | [To be filled by tester] |

### 2.3 Home Page - Responsive Design

#### TC-HOME-011: Home Page on Mobile Viewport
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-011 |
| **Test Case Description** | Verify home page renders correctly on mobile viewport |
| **Preconditions** | None |
| **Test Data** | Viewport: 375x667 (mobile) |
| **Test Steps** | 1. Set viewport to mobile (375x667)<br>2. Navigate to /<br>3. Verify layout adapts correctly |
| **Expected Result** | Mobile-friendly layout, all content accessible |
| **Actual Result** | [To be filled by tester] |

#### TC-HOME-012: Home Page on Tablet Viewport
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-HOME-012 |
| **Test Case Description** | Verify home page renders correctly on tablet viewport |
| **Preconditions** | None |
| **Test Data** | Viewport: 768x1024 (tablet) |
| **Test Steps** | 1. Set viewport to tablet (768x1024)<br>2. Navigate to /<br>3. Verify layout adapts correctly |
| **Expected Result** | Tablet-friendly layout with grid content |
| **Actual Result** | [To be filled by tester] |

---

## 3. Projects

### 3.1 Project Listing Page

#### TC-PROJ-001: Projects Page Loads Successfully
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-001 |
| **Test Case Description** | Verify projects listing page loads without errors |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects<br>2. Wait for page to fully load |
| **Expected Result** | Page loads with HTTP 200, project list is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-002: Display of Approved Projects
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-002 |
| **Test Case Description** | Verify only approved projects are displayed to public users |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects<br>2. Verify list of approved projects |
| **Expected Result** | Approved projects are visible, pending projects are hidden |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-003: Project Cards Display Correct Information
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-003 |
| **Test Case Description** | Verify project cards show all required information |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects<br>2. Examine project card details |
| **Expected Result** | Each card shows: title, image, location, type (TFP/Paid), creator |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-004: Filter Projects by Type
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-004 |
| **Test Case Description** | Verify projects can be filtered by type |
| **Preconditions** | None |
| **Test Data** | Filter: TFP, Paid, Collaboration |
| **Test Steps** | 1. Navigate to /projects<br>2. Apply TFP filter<br>3. Verify results |
| **Expected Result** | Only TFP projects are displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-005: Filter Projects by Location
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-005 |
| **Test Case Description** | Verify projects can be filtered by location |
| **Preconditions** | None |
| **Test Data** | Location: New York |
| **Test Steps** | 1. Navigate to /projects<br>2. Apply location filter<br>3. Verify results |
| **Expected Result** | Only projects in selected location are displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-006: Navigate to Project Detail
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-006 |
| **Test Case Description** | Verify clicking project card navigates to detail page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects<br>2. Click on first project card |
| **Expected Result** | User is redirected to project detail page |
| **Actual Result** | [To be filled by tester] |

### 3.2 Project Detail Page

#### TC-PROJ-007: Project Detail Page Loads
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-007 |
| **Test Case Description** | Verify project detail page loads with full information |
| **Preconditions** | None |
| **Test Data** | Project ID: 1 (or any approved project) |
| **Test Steps** | 1. Navigate to /projects/1<br>2. Wait for page to load |
| **Expected Result** | Project detail page displays with title, description, images, location, roles |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-008: Project Moodboard Images Display
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-008 |
| **Test Case Description** | Verify moodboard images are displayed on project detail |
| **Preconditions** | None |
| **Test Data** | Project with moodboard images |
| **Test Steps** | 1. Navigate to project detail with moodboard<br>2. Verify images are visible |
| **Expected Result** | Moodboard images displayed in gallery/grid format |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-009: Project Roles Display
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-009 |
| **Test Case Description** | Verify required roles are displayed on project detail |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects/1<br>2. Check roles section |
| **Expected Result** | Required roles (Photographer, Model, MUA, etc.) with status (Open/Filled) |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-010: Apply to Project (Logged In User)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-010 |
| **Test Case Description** | Verify logged-in user can apply to a project |
| **Preconditions** | User is logged in as photo@tfp.local |
| **Test Data** | Project ID with open role |
| **Test Steps** | 1. Navigate to project detail<br>2. Click "Apply" button<br>3. Fill application form<br>4. Submit application |
| **Expected Result** | Application submitted successfully, confirmation message shown |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-011: Apply to Project (Logged Out User)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-011 |
| **Test Case Description** | Verify logged-out user is prompted to login when applying |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to project detail<br>2. Click "Apply" button |
| **Expected Result** | Auth modal appears asking user to login |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-012: Cannot Apply to Own Project
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-012 |
| **Test Case Description** | Verify project owner cannot apply to their own project |
| **Preconditions** | User is logged in as project creator |
| **Test Data** | Owner's created project |
| **Test Steps** | 1. Login as project creator<br>2. Navigate to own project<br>3. Try to click Apply |
| **Expected Result** | Apply button is disabled or error message shown |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-013: View Project Creator Profile
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-013 |
| **Test Case Description** | Verify clicking creator name navigates to profile |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to project detail<br>2. Click on creator name/avatar |
| **Expected Result** | User is redirected to creator's profile page |
| **Actual Result** | [To be filled by tester] |

### 3.3 Create Project Page

#### TC-PROJ-014: Create Project Page Access (Authenticated)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-014 |
| **Test Case Description** | Verify authenticated user can access create project page |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to /projects/create |
| **Expected Result** | Create project form is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-015: Create Project Page Access (Unauthenticated)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-015 |
| **Test Case Description** | Verify unauthenticated user cannot access create project page |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects/create directly |
| **Expected Result** | User is redirected to login page |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-016: Create Project with All Fields
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-016 |
| **Test Case Description** | Verify user can create a project with all fields filled |
| **Preconditions** | User is logged in |
| **Test Data** | Title: Test Project, Description: Test description, Location: New York, Type: TFP |
| **Test Steps** | 1. Navigate to /projects/create<br>2. Fill in all required fields<br>3. Add moodboard images<br>4. Add roles<br>5. Submit form |
| **Expected Result** | Project created successfully, redirected to project detail |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-017: Create Project - Required Fields Validation
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-017 |
| **Test Case Description** | Verify validation errors for empty required fields |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /projects/create<br>2. Leave required fields empty<br>3. Click Submit |
| **Expected Result** | Validation errors for all required fields |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-018: Create Project - Location Autocomplete
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-018 |
| **Test Case Description** | Verify location autocomplete functionality works |
| **Preconditions** | User is logged in |
| **Test Data** | Location query: "New" |
| **Test Steps** | 1. Navigate to /projects/create<br>2. Start typing location<br>3. Verify autocomplete suggestions appear |
| **Expected Result** | Dropdown with matching locations appears |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-019: Create Project - Image Upload
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-019 |
| **Test Case Description** | Verify moodboard image upload functionality |
| **Preconditions** | User is logged in |
| **Test Data** | Image files: jpg, png |
| **Test Steps** | 1. Navigate to /projects/create<br>2. Upload moodboard images<br>3. Verify previews appear |
| **Expected Result** | Image previews are displayed after upload |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-020: Project Created as Pending Status
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-020 |
| **Test Case Description** | Verify newly created project has PENDING status |
| **Preconditions** | User creates a project |
| **Test Data** | Newly created project |
| **Test Steps** | 1. Create a new project<br>2. Note the project ID<br>3. Try to view as public user |
| **Expected Result** | Project has PENDING status, not visible to public |
| **Actual Result** | [To be filled by tester] |

### 3.4 Project Application

#### TC-PROJ-021: View Application Status
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-021 |
| **Test Case Description** | Verify user can view their application status |
| **Preconditions** | User has applied to a project |
| **Test Data** | User with pending application |
| **Test Steps** | 1. Login as applicant<br>2. Navigate to profile or applications |
| **Expected Result** | Application status (Applied, Shortlisted, Selected) is visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROJ-022: Withdraw Application
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-022 |
| **Test Case Description** | Verify user can withdraw their application |
| **Preconditions** | User has applied to a project |
| **Test Data** | User with active application |
| **Test Steps** | 1. Navigate to applied project<br>2. Find withdraw option<br>3. Confirm withdrawal |
| **Expected Result** | Application is withdrawn, status updated |
| **Actual Result** | [To be filled by tester] |

---

## 4. Contests

### 4.1 Contest Listing Page

#### TC-CONT-001: Contests Page Loads Successfully
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-001 |
| **Test Case Description** | Verify contests listing page loads without errors |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /contests<br>2. Wait for page to fully load |
| **Expected Result** | Page loads with HTTP 200, contest list is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-002: Display Active Contests
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-002 |
| **Test Case Description** | Verify active contests are displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /contests<br>2. Check for active contests |
| **Expected Result** | Active contests with deadline in future are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-003: Filter Contests by Status
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-003 |
| **Test Case Description** | Verify contests can be filtered by status |
| **Preconditions** | None |
| **Test Data** | Filters: Active, Upcoming, Judging, Completed |
| **Test Steps** | 1. Navigate to /contests<br>2. Apply status filter<br>3. Verify results |
| **Expected Result** | Only contests with selected status are displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-004: Contest Cards Display Correct Information
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-004 |
| **Test Case Description** | Verify contest cards show all required information |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /contests<br>2. Examine contest card details |
| **Expected Result** | Each card shows: title, image, deadline, prize, participant count |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-005: Navigate to Contest Detail
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-005 |
| **Test Case Description** | Verify clicking contest card navigates to detail page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /contests<br>2. Click on first contest card |
| **Expected Result** | User is redirected to contest detail page |
| **Actual Result** | [To be filled by tester] |

### 4.2 Contest Detail Page

#### TC-CONT-006: Contest Detail Page Loads
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-006 |
| **Test Case Description** | Verify contest detail page loads with full information |
| **Preconditions** | None |
| **Test Data** | Contest ID: 1 (active contest) |
| **Test Steps** | 1. Navigate to /contests/1<br>2. Wait for page to load |
| **Expected Result** | Contest detail page displays with title, description, deadline, prizes |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-007: Contest Banner Image Displays
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-007 |
| **Test Case Description** | Verify contest banner image is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest detail<br>2. Check for banner image |
| **Expected Result** | Banner image is visible at top of page |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-008: Display Contest Prizes
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-008 |
| **Test Case Description** | Verify prize information is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest detail<br>2. Check prizes section |
| **Expected Result** | Prize positions and amounts are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-009: View Contest Submissions
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-009 |
| **Test Case Description** | Verify contest submissions are displayed |
| **Preconditions** | Contest has submissions |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest detail<br>2. Scroll to submissions section |
| **Expected Result** | Submission thumbnails are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-010: Submit to Contest (Logged In)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-010 |
| **Test Case Description** | Verify logged-in user can submit to contest |
| **Preconditions** | User is logged in as photo@tfp.local, contest is active |
| **Test Data** | Image file for submission |
| **Test Steps** | 1. Navigate to active contest<br>2. Click "Submit" button<br>3. Upload image<br>4. Add description<br>5. Submit |
| **Expected Result** | Submission successful, confirmation shown |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-011: Submit to Contest (Logged Out)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-011 |
| **Test Case Description** | Verify logged-out user is prompted to login when submitting |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to active contest<br>2. Click "Submit" button |
| **Expected Result** | Auth modal appears asking user to login |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-012: Cannot Submit After Deadline
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-012 |
| **Test Case Description** | Verify user cannot submit after contest deadline |
| **Preconditions** | Contest deadline has passed |
| **Test Data** | Completed contest |
| **Test Steps** | 1. Navigate to completed contest<br>2. Try to find submit option |
| **Expected Result** | Submit button is disabled or not visible |
| **Actual Result** | [To be filled by tester] |

### 4.3 Contest Voting

#### TC-CONT-013: Like a Submission
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-013 |
| **Test Case Description** | Verify user can like a contest submission |
| **Preconditions** | User is logged in |
| **Test Data** | Contest with submissions |
| **Test Steps** | 1. Navigate to contest detail<br>2. Find submission thumbnail<br>3. Click like button |
| **Expected Result** | Like count increases, button shows liked state |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-014: Vote for Submission
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-014 |
| **Test Case Description** | Verify user can vote for a submission |
| **Preconditions** | User is logged in, contest is in voting phase |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest in voting phase<br>2. Click vote button on submission |
| **Expected Result** | Vote is recorded, count increases |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-015: Share Submission
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-015 |
| **Test Case Description** | Verify share functionality works |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest submission<br>2. Click share button |
| **Expected Result** | Share options appear or link is copied |
| **Actual Result** | [To be filled by tester] |

### 4.4 Contest Gallery

#### TC-CONT-016: Full Contest Gallery View
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-016 |
| **Test Case Description** | Verify full gallery page displays all submissions |
| **Preconditions** | Contest has submissions |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to contest detail<br>2. Click "View All" or gallery link<br>3. Verify full gallery loads |
| **Expected Result** | All submissions displayed in grid |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-017: Gallery Infinite Scroll/Pagination
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-017 |
| **Test Case Description** | Verify gallery loads more items on scroll |
| **Preconditions** | Contest has many submissions |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to gallery<br>2. Scroll down<br>3. Verify more items load |
| **Expected Result** | Pagination or infinite scroll works |
| **Actual Result** | [To be filled by tester] |

### 4.5 Create Contest

#### TC-CONT-018: Create Contest Page Access
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-018 |
| **Test Case Description** | Verify admin can access create contest page |
| **Preconditions** | User is logged in as admin |
| **Test Data** | None |
| **Test Steps** | 1. Login as admin@tfp.local<br>2. Navigate to create contest page |
| **Expected Result** | Create contest form is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-019: Create Contest with Prizes
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-019 |
| **Test Case Description** | Verify admin can create contest with multiple prizes |
| **Preconditions** | User is logged in as admin |
| **Test Data** | Title: Test Contest, Deadline: +7 days, Prizes: 1st, 2nd, 3rd |
| **Test Steps** | 1. Navigate to create contest<br>2. Fill all fields including prizes<br>3. Submit form |
| **Expected Result** | Contest created with all prize positions |
| **Actual Result** | [To be filled by tester] |

#### TC-CONT-020: Contest Created as Pending
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-020 |
| **Test Case Description** | Verify newly created contest has PENDING status |
| **Preconditions** | Admin creates contest |
| **Test Data** | Newly created contest |
| **Test Steps** | 1. Create a new contest<br>2. Try to view as public user |
| **Expected Result** | Contest has PENDING status, not visible to public |
| **Actual Result** | [To be filled by tester] |

---

## 5. Events

### 5.1 Event Listing Page

#### TC-EVEN-001: Events Page Loads Successfully
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-001 |
| **Test Case Description** | Verify events listing page loads without errors |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /events<br>2. Wait for page to fully load |
| **Expected Result** | Page loads with HTTP 200, event list is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-002: Display Upcoming Events
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-002 |
| **Test Case Description** | Verify upcoming events are displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /events<br>2. Check event list |
| **Expected Result** | Upcoming events with date in future are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-003: Event Cards Display Correct Information
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-003 |
| **Test Case Description** | Verify event cards show all required information |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /events<br>2. Examine event card details |
| **Expected Result** | Each card shows: title, date, time, location, category, price |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-004: Filter Events by Category
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-004 |
| **Test Case Description** | Verify events can be filtered by category |
| **Preconditions** | None |
| **Test Data** | Categories: Workshop, Masterclass, Meetup, Expo, Trip |
| **Test Steps** | 1. Navigate to /events<br>2. Apply category filter<br>3. Verify results |
| **Expected Result** | Only events with selected category are displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-005: Navigate to Event Detail
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-005 |
| **Test Case Description** | Verify clicking event card navigates to detail page |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /events<br>2. Click on first event card |
| **Expected Result** | User is redirected to event detail page |
| **Actual Result** | [To be filled by tester] |

### 5.2 Event Detail Page

#### TC-EVEN-006: Event Detail Page Loads
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-006 |
| **Test Case Description** | Verify event detail page loads with full information |
| **Preconditions** | None |
| **Test Data** | Event ID: 1 |
| **Test Steps** | 1. Navigate to /events/1<br>2. Wait for page to load |
| **Expected Result** | Event detail page displays with all information |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-007: Event Banner Image Displays
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-007 |
| **Test Case Description** | Verify event banner image is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to event detail<br>2. Check for banner image |
| **Expected Result** | Banner image is visible |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-008: Display Event Location
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-008 |
| **Test Case Description** | Verify event location details are displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to event detail<br>2. Check location section |
| **Expected Result** | Venue, city, country are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-009: Display Event Organizer
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-009 |
| **Test Case Description** | Verify event organizer information is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to event detail<br>2. Check organizer section |
| **Expected Result** | Organizer name and profile link are visible |
| **Actual Result** | [To be filled by tester] |

### 5.3 Event RSVP

#### TC-EVEN-010: RSVP to Event (Logged In)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-010 |
| **Test Case Description** | Verify logged-in user can RSVP to event |
| **Preconditions** | User is logged in as photo@tfp.local |
| **Test Data** | Upcoming event |
| **Test Steps** | 1. Navigate to event detail<br>2. Click RSVP/Going button<br>3. Confirm RSVP |
| **Expected Result** | RSVP confirmed, status shows "Going" |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-011: RSVP to Event (Logged Out)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-011 |
| **Test Case Description** | Verify logged-out user is prompted to login when RSVPing |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to event detail<br>2. Click RSVP button |
| **Expected Result** | Auth modal appears |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-012: Cancel RSVP
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-012 |
| **Test Case Description** | Verify user can cancel RSVP |
| **Preconditions** | User has RSVPed to event |
| **Test Data** | Event with RSVP |
| **Test Steps** | 1. Navigate to event where user has RSVPed<br>2. Click "Not Going" or cancel button |
| **Expected Result** | RSVP is cancelled, status updated |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-013: View Event Attendees
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-013 |
| **Test Case Description** | Verify list of attendees is displayed |
| **Preconditions** | Event has RSVPs |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to event detail<br>2. Scroll to attendees section |
| **Expected Result** | List of attendees with avatars is visible |
| **Actual Result** | [To be filled by tester] |

### 5.4 Create Event

#### TC-EVEN-014: Create Event Page Access
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-014 |
| **Test Case Description** | Verify user can access create event page |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to /events/create |
| **Expected Result** | Create event form is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-015: Create Event with All Fields
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-015 |
| **Test Case Description** | Verify user can create event with all fields |
| **Preconditions** | User is logged in |
| **Test Data** | Title: Test Event, Date: +7 days, Location: Los Angeles, Price: 100 |
| **Test Steps** | 1. Navigate to /events/create<br>2. Fill all required fields<br>3. Submit form |
| **Expected Result** | Event created successfully |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-016: Create Event - Required Fields Validation
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-016 |
| **Test Case Description** | Verify validation for empty required fields |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /events/create<br>2. Leave required fields empty<br>3. Click Submit |
| **Expected Result** | Validation errors for required fields |
| **Actual Result** | [To be filled by tester] |

#### TC-EVEN-017: Event Created as Pending Status
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVEN-017 |
| **Test Case Description** | Verify newly created event has PENDING status |
| **Preconditions** | User creates event |
| **Test Data** | Newly created event |
| **Test Steps** | 1. Create a new event<br>2. Try to view as public user |
| **Expected Result** | Event has PENDING status, not visible to public |
| **Actual Result** | [To be filled by tester] |

---

## 6. Profile

### 6.1 View Profile

#### TC-PROF-001: Public Profile Page Loads
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-001 |
| **Test Case Description** | Verify public profile page loads correctly |
| **Preconditions** | None |
| **Test Data** | Profile: photo@tfp.local |
| **Test Steps** | 1. Navigate to /profile/photo@tfp.local<br>2. Wait for page to load |
| **Expected Result** | Profile page displays with user information |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-002: Display User Information
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-002 |
| **Test Case Description** | Verify user information is displayed on profile |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Check user info section |
| **Expected Result** | Display name, bio, location, role, badges are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-003: Display Profile Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-003 |
| **Test Case Description** | Verify profile image is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Check for profile image |
| **Expected Result** | Profile avatar is visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-004: Display Cover Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-004 |
| **Test Case Description** | Verify cover image is displayed |
| **Preconditions** | None |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Check for cover image |
| **Expected Result** | Cover image is visible at top of profile |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-005: Display Subscription Tier
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-005 |
| **Test Case Description** | Verify subscription tier badge is displayed |
| **Preconditions** | None |
| **Test Data** | User with PRO subscription |
| **Test Steps** | 1. Navigate to profile with PRO tier<br>2. Check for tier badge |
| **Expected Result** | PRO/PRO_PLUS badge is visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-006: Display Portfolio Images
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-006 |
| **Test Case Description** | Verify portfolio images are displayed |
| **Preconditions** | User has portfolio images |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Scroll to portfolio section |
| **Expected Result** | Portfolio grid is displayed with images |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-007: View Own Profile
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-007 |
| **Test Case Description** | Verify user can view their own profile |
| **Preconditions** | User is logged in |
| **Test Data** | Logged in user |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to /profile/photo@tfp.local |
| **Expected Result** | Profile displays with edit options available |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-008: View Other User Profile
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-008 |
| **Test Case Description** | Verify user can view other user profiles |
| **Preconditions** | None |
| **Test Data** | Other user: model@tfp.local |
| **Test Steps** | 1. Navigate to /profile/model@tfp.local |
| **Expected Result** | Other user's profile is displayed |
| **Actual Result** | [To be filled by tester] |

### 6.2 Profile Interactions

#### TC-PROF-009: Follow User
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-009 |
| **Test Case Description** | Verify user can follow another user |
| **Preconditions** | User is logged in |
| **Test Data** | Target: model@tfp.local |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to model profile<br>3. Click Follow button |
| **Expected Result** | User is followed, button changes to Following |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-010: Unfollow User
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-010 |
| **Test Case Description** | Verify user can unfollow another user |
| **Preconditions** | User is following another user |
| **Test Data** | Already following user |
| **Test Steps** | 1. Navigate to following user's profile<br>2. Click Unfollow/Following button |
| **Expected Result** | User is unfollowed, button changes to Follow |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-011: View User's Projects
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-011 |
| **Test Case Description** | Verify user's created projects are displayed |
| **Preconditions** | User has created projects |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Look for projects section or tab |
| **Expected Result** | User's projects are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-012: View User's Contest Entries
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-012 |
| **Test Case Description** | Verify user's contest submissions are displayed |
| **Preconditions** | User has entered contests |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Look for contest entries section |
| **Expected Result** | User's contest submissions are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-013: View User's Events
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-013 |
| **Test Case Description** | Verify user's events are displayed |
| **Preconditions** | User has created events |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to profile<br>2. Look for events section |
| **Expected Result** | User's created events are visible |
| **Actual Result** | [To be filled by tester] |

### 6.3 Profile - Edge Cases

#### TC-PROF-014: View Non-existent Profile
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-014 |
| **Test Case Description** | Verify appropriate error for non-existent profile |
| **Preconditions** | None |
| **Test Data** | Profile: nonexistent@tfp.local |
| **Test Steps** | 1. Navigate to /profile/nonexistent@tfp.local |
| **Expected Result** | 404 page or "User not found" message |
| **Actual Result** | [To be filled by tester] |

#### TC-PROF-015: Deleted Profile View
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-015 |
| **Test Case Description** | Verify appropriate handling for deleted profile |
| **Preconditions** | User account has been deleted |
| **Test Data** | Deleted user profile |
| **Test Steps** | 1. Navigate to deleted profile URL |
| **Expected Result** | Profile not found or account deactivated message |
| **Actual Result** | [To be filled by tester] |

---

## 7. Settings

### 7.1 Profile Settings

#### TC-SET-001: Access Profile Settings
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-001 |
| **Test Case Description** | Verify user can access profile settings |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to /settings/profile |
| **Expected Result** | Profile settings form is displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-002: Update Display Name
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-002 |
| **Test Case Description** | Verify user can update display name |
| **Preconditions** | User is logged in |
| **Test Data** | New display name: Updated Name |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Update display name<br>3. Save changes |
| **Expected Result** | Display name is updated, success message shown |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-003: Update Bio
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-003 |
| **Test Case Description** | Verify user can update bio |
| **Preconditions** | User is logged in |
| **Test Data** | New bio: "This is my updated bio" |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Update bio field<br>3. Save changes |
| **Expected Result** | Bio is updated on profile |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-004: Update Location
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-004 |
| **Test Case Description** | Verify user can update location |
| **Preconditions** | User is logged in |
| **Test Data** | New location: Los Angeles, USA |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Update location<br>3. Save changes |
| **Expected Result** | Location is updated on profile |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-005: Update Profile Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-005 |
| **Test Case Description** | Verify user can update profile image |
| **Preconditions** | User is logged in |
| **Test Data** | New profile image file |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Upload new profile image<br>3. Save changes |
| **Expected Result** | Profile image is updated |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-006: Update Cover Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-006 |
| **Test Case Description** | Verify user can update cover image |
| **Preconditions** | User is logged in |
| **Test Data** | New cover image file |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Upload new cover image<br>3. Save changes |
| **Expected Result** | Cover image is updated |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-007: Add Portfolio Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-007 |
| **Test Case Description** | Verify user can add portfolio images |
| **Preconditions** | User is logged in |
| **Test Data** | Portfolio image files |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Add portfolio images<br>3. Save changes |
| **Expected Result** | Portfolio images added and visible on profile |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-008: Remove Portfolio Image
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-008 |
| **Test Case Description** | Verify user can remove portfolio images |
| **Preconditions** | User has portfolio images |
| **Test Data** | Existing portfolio image |
| **Test Steps** | 1. Navigate to /settings/profile<br>2. Find portfolio image<br>3. Click remove/delete |
| **Expected Result** | Portfolio image is removed |
| **Actual Result** | [To be filled by tester] |

### 7.2 Account Settings

#### TC-SET-009: Change Password
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-009 |
| **Test Case Description** | Verify user can change password |
| **Preconditions** | User is logged in |
| **Test Data** | Current: Photo123!, New: NewPassword123! |
| **Test Steps** | 1. Navigate to settings<br>2. Find change password option<br>3. Enter current and new password<br>4. Save |
| **Expected Result** | Password changed successfully |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-010: Change Password - Incorrect Current Password
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-010 |
| **Test Case Description** | Verify error when current password is incorrect |
| **Preconditions** | User is logged in |
| **Test Data** | Current: WrongPassword, New: NewPassword123! |
| **Test Steps** | 1. Navigate to change password<br>2. Enter wrong current password<br>3. Try to save |
| **Expected Result** | Error message for incorrect current password |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-011: Update Email Preferences
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-011 |
| **Test Case Description** | Verify user can update email preferences |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to settings<br>2. Find email preferences<br>3. Toggle notification settings |
| **Expected Result** | Email preferences are saved |
| **Actual Result** | [To be filled by tester] |

#### TC-SET-012: Delete Account
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-012 |
| **Test Case Description** | Verify user can delete their account |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to settings<br>2. Find delete account option<br>3. Confirm deletion |
| **Expected Result** | Account is deleted, user logged out |
| **Actual Result** | [To be filled by tester] |

### 7.3 Settings - Access Control

#### TC-SET-013: Access Settings (Logged Out)
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-SET-013 |
| **Test Case Description** | Verify unauthenticated user cannot access settings |
| **Preconditions** | User is not logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /settings/profile directly |
| **Expected Result** | Redirected to login page |
| **Actual Result** | [To be filled by tester] |

---

## 8. Notifications

### 8.1 Notification Page

#### TC-NOTI-001: Notifications Page Loads
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-001 |
| **Test Case Description** | Verify notifications page loads for logged-in user |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Login as photo@tfp.local<br>2. Navigate to /notifications |
| **Expected Result** | Notifications page loads |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-002: Display Application Notifications
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-002 |
| **Test Case Description** | Verify application status notifications are displayed |
| **Preconditions** | User has applied to projects |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Look for application notifications |
| **Expected Result** | Application status changes are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-003: Display RSVP Notifications
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-003 |
| **Test Case Description** | Verify RSVP notifications are displayed |
| **Preconditions** | User has RSVPed to events |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Look for RSVP notifications |
| **Expected Result** | Event RSVP related notifications are visible |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-004: Display Contest Notifications
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-004 |
| **Test Case Description** | Verify contest notifications are displayed |
| **Preconditions** | User has entered contests |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Look for contest notifications |
| **Expected Result** | Contest updates are visible |
| **Actual Result** | [To be filled by tester] |

### 8.2 Notification Interactions

#### TC-NOTI-005: Mark Notification as Read
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-005 |
| **Test Case Description** | Verify user can mark notification as read |
| **Preconditions** | User has unread notifications |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Click on unread notification |
| **Expected Result** | Notification is marked as read |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-006: Mark All Notifications as Read
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-006 |
| **Test Case Description** | Verify user can mark all notifications as read |
| **Preconditions** | User has multiple unread notifications |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Find "Mark all as read" option<br>3. Click it |
| **Expected Result** | All notifications are marked as read |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-007: Navigate from Notification
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-007 |
| **Test Case Description** | Verify clicking notification navigates to relevant page |
| **Preconditions** | User has notifications |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to /notifications<br>2. Click on any notification |
| **Expected Result** | User is navigated to relevant page (project, contest, event) |
| **Actual Result** | [To be filled by tester] |

### 8.3 Notification Settings

#### TC-NOTI-008: Notification Settings Access
| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTI-008 |
| **Test Case Description** | Verify user can access notification settings |
| **Preconditions** | User is logged in |
| **Test Data** | None |
| **Test Steps** | 1. Navigate to settings<br>2. Find notification settings |
| **Expected Result** | Notification preferences are displayed |
| **Actual Result** | [To be filled by tester] |

#### TC-NOTI-009: Toggle Email
