# TFP Platform - Manual Test Cases

**Document Version:** 1.0  
**Created:** March 2026  
**Platform:** TFP (The Fotobook Platform)  
**Testing Team:** QA Department

---

## Table of Contents

1. [Test Credentials & Seed Data](#test-credentials--seed-data)
2. [Authentication Modules](#authentication-modules)
   - 2.1 Login Page
   - 2.2 Register Page
   - 2.3 Forgot Password Page
3. [Public Pages](#public-pages)
   - 3.1 Home Page
   - 3.2 Privacy Policy Page
   - 3.3 Terms of Service Page
4. [Projects Module](#projects-module)
   - 4.1 Projects Listing Page
   - 4.2 Project Detail Page
   - 4.3 Create Project Page
5. [Contests Module](#contests-module)
   - 5.1 Contests Listing Page
   - 5.2 Contest Detail Page
   - 5.3 Contest Gallery Page
6. [Events Module](#events-module)
   - 6.1 Events Listing Page
   - 6.2 Event Detail Page
7. [User Profile Module](#user-profile-module)
   - 7.1 Public Profile Page
   - 7.2 Edit Profile / Settings Page
8. [Notifications Module](#notifications-module)
   - 8.1 Notifications Page
9. [Admin Module](#admin-module)
   - 9.1 Admin Moderation Queue

---

## 1. Test Credentials & Seed Data

### Seeded Users for Testing

| User Type | Email | Password | Role | Subscription |
|-----------|-------|----------|------|--------------|
| Admin | `admin@tfp.local` | `Seed123!` | ADMIN | PRO_PLUS |
| Photographer | `photo@tfp.local` | `Seed123!` | PHOTOGRAPHER | PRO |
| Model | `model@tfp.local` | `Seed123!` | MODEL | FREE |
| Participant 1 | `seed.participant.1@tfp.local` | `Seed123!` | USER | FREE |
| Participant 2 | `seed.participant.2@tfp.local` | `Seed123!` | USER | FREE |
| Project Creator | `elena.rodriguez@tfp.local` | `Seed123!` | PHOTOGRAPHER | - |
| Contest Organizer | `photodaily@tfp.local` | `Seed123!` | USER | - |
| Event Organizer | `photoworkshops@tfp.local` | `Seed123!` | USER | - |

### Seeded Data Overview

- **Projects:** 6 seeded projects (Fashion Editorial, Urban Portrait, Creative Conceptual, Fitness Campaign, Bohemian Wedding, Editorial Makeup Brand)
- **Contests:** 6 seeded contests (Street Photography Challenge, Portrait Masterclass, Golden Hour Landscape, Creative Self-Portrait, Wildlife Photography Award, Black & White Mono)
- **Events:** 6 seeded events (Street Photography Workshop, Portrait Masterclass, Night Shoot Meetup, Fashion Expo, Lightroom Training, Nature Trip)
- **Users:** 400+ seeded participant users

---

## 2. Authentication Modules

### 2.1 Login Page

#### TC-AUTH-001: Successful Login with Valid Credentials

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-001 |
| **Test Case Description** | Verify that a user can successfully log in with valid email and password |
| **Preconditions** | 1. Application is running and accessible<br>2. User has valid credentials in the system |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Locate the email input field<br>3. Enter `photo@tfp.local` in the email field<br>4. Locate the password input field<br>5. Enter `Seed123!` in the password field<br>6. Click the "Login" or "Sign In" button |
| **Expected Results** | 1. User is successfully authenticated<br>2. Page redirects to the home page or dashboard<br>3. User's profile avatar/name appears in the navigation header<br>4. Session is maintained (user stays logged in upon page refresh) |
| **Actual Results** | _________________ |

---

#### TC-AUTH-002: Login with Incorrect Password

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-002 |
| **Test Case Description** | Verify that appropriate error message is displayed when incorrect password is entered |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `WrongPassword123` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Enter `photo@tfp.local` in the email field<br>3. Enter `WrongPassword123` in the password field<br>4. Click the "Login" button |
| **Expected Results** | 1. Error message is displayed (e.g., "Invalid email or password", "Authentication failed")<br>2. User remains on the login page<br>3. User is not logged in |
| **Actual Results** | _________________ |

---

#### TC-AUTH-003: Login with Non-existent Username/Email

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-003 |
| **Test Case Description** | Verify that appropriate error message is displayed when logging in with a non-existent email |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `nonexistent@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Enter `nonexistent@tfp.local` in the email field<br>3. Enter `Seed123!` in the password field<br>4. Click the "Login" button |
| **Expected Results** | 1. Error message is displayed (e.g., "No account found with this email", "User does not exist")<br>2. User remains on the login page |
| **Actual Results** | _________________ |

---

#### TC-AUTH-004: Login with Empty Credentials

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-004 |
| **Test Case Description** | Verify validation messages are displayed when attempting to login with empty fields |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Leave email field empty<br>3. Leave password field empty<br>4. Click the "Login" button |
| **Expected Results** | 1. Validation error message appears for email field (e.g., "Email is required", "Please enter your email")<br>2. Validation error message appears for password field (e.g., "Password is required", "Please enter your password")<br>3. User cannot submit the form without filling required fields |
| **Actual Results** | _________________ |

---

#### TC-AUTH-005: Login with Empty Email Only

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-005 |
| **Test Case Description** | Verify validation message is displayed when email field is empty but password is provided |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Leave email field empty<br>3. Enter `Seed123!` in the password field<br>4. Click the "Login" button |
| **Expected Results** | 1. Validation error message appears for email field<br>2. User remains on login page<br>3. Form is not submitted |
| **Actual Results** | _________________ |

---

#### TC-AUTH-006: Login with Empty Password Only

| Field | Details |
|-------|--------- |
| **Test Case ID** | TC-AUTH-006 |
| **Test Case Description** | Verify validation message is displayed when password field is empty but email is provided |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `photo@tfp.local` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Enter `photo@tfp.local` in the email field<br>3. Leave password field empty<br>4. Click the "Login" button |
| **Expected Results** | 1. Validation error message appears for password field<br>2. User remains on login page<br>3. Form is not submitted |
| **Actual Results** | _________________ |

---

#### TC-AUTH-007: Login Session Persistence

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-007 |
| **Test Case Description** | Verify that user session persists across page refreshes |
| **Preconditions** | 1. User is logged in successfully |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in with valid credentials<br>2. Navigate to any page (e.g., Projects)<br>3. Refresh the browser page<br>4. Check if user remains logged in |
| **Expected Results** | 1. User remains logged in after page refresh<br>2. User's profile information is displayed in the navigation |
| **Actual Results** | _________________ |

---

#### TC-AUTH-008: Login Redirect After Authentication

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-008 |
| **Test Case Description** | Verify that successful login redirects to the correct landing page |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Log in with valid credentials<br>3. Observe the redirect destination |
| **Expected Results** | 1. After successful login, user is redirected to the home page (`/`) or dashboard<br>2. The URL changes to the protected page |
| **Actual Results** | _________________ |

---

#### TC-AUTH-009: Login as Admin User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-009 |
| **Test Case Description** | Verify admin user can log in and access admin features |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `admin@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Log in with admin credentials<br>3. Verify admin-specific navigation elements appear<br>4. Navigate to admin moderation page |
| **Expected Results** | 1. Admin user logs in successfully<br>2. Admin dashboard/moderation link appears in navigation<br>3. Admin can access `/admin/moderation` route |
| **Actual Results** | _________________ |

---

#### TC-AUTH-010: Login as Model User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-010 |
| **Test Case Description** | Verify model user can log in with their credentials |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `model@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Navigate to the login page (`/login`)<br>2. Log in with model user credentials |
| **Expected Results** | 1. Model user logs in successfully<br>2. User's profile shows MODEL role<br>3. Standard user features are accessible |
| **Actual Results** | _________________ |

---

### 2.2 Register Page

#### TC-AUTH-011: Successful Registration with Valid Data

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-011 |
| **Test Case Description** | Verify that a new user can successfully register with valid information |
| **Preconditions** | 1. Application is running and accessible<br>2. Register page is accessible |
| **Test Data** | Email: `newuser@test.com`<br>Password: `TestPass123!`<br>Display Name: `Test User` |
| **Test Steps** | 1. Navigate to the register page (`/register`)<br>2. Enter a unique email address<br>3. Enter a display name<br>4. Enter a password<br>5. Confirm the password<br>6. Click "Register" or "Sign Up" button |
| **Expected Results** | 1. User account is created successfully<br>2. User is redirected to login or automatically logged in<br>3. Confirmation message is displayed |
| **Actual Results** | _________________ |

---

#### TC-AUTH-012: Registration with Invalid Email Format

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-012 |
| **Test Case Description** | Verify validation error for invalid email format |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `invalid-email`<br>Password: `TestPass123!` |
| **Test Steps** | 1. Navigate to register page<br>2. Enter invalid email format (e.g., `invalid-email`)<br>3. Fill other required fields<br>4. Click register button |
| **Expected Results** | 1. Validation error message appears for email field (e.g., "Please enter a valid email address")<br>2. Form is not submitted |
| **Actual Results** | _________________ |

---

#### TC-AUTH-013: Registration with Existing Email

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-013 |
| **Test Case Description** | Verify appropriate error when registering with already registered email |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `photo@tfp.local` (existing user)<br>Password: `TestPass123!` |
| **Test Steps** | 1. Navigate to register page<br>2. Enter email that already exists in system (`photo@tfp.local`)<br>3. Fill other required fields<br>4. Click register button |
| **Expected Results** | 1. Error message displayed (e.g., "An account with this email already exists", "Email already registered")<br>2. Registration is blocked |
| **Actual Results** | _________________ |

---

#### TC-AUTH-014: Registration with Weak Password

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-014 |
| **Test Case Description** | Verify validation for weak password requirements |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Password: `123` (weak password) |
| **Test Steps** | 1. Navigate to register page<br>2. Fill all required fields<br>3. Enter a weak password<br>4. Click register button |
| **Expected Results** | 1. Validation error message about password requirements<br>2. Password strength indicator shows weak<br>3. Form is not submitted |
| **Actual Results** | _________________ |

---

#### TC-AUTH-015: Registration with Mismatched Passwords

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-015 |
| **Test Case Description** | Verify error when password and confirm password do not match |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Password: `TestPass123!`<br>Confirm Password: `DifferentPass123!` |
| **Test Steps** | 1. Navigate to register page<br>2. Fill all required fields<br>3. Enter password<br>4. Enter different confirm password<br>5. Click register button |
| **Expected Results** | 1. Error message displayed (e.g., "Passwords do not match", "Confirm password must match password") |
| **Actual Results** | _________________ |

---

#### TC-AUTH-016: Registration with Empty Required Fields

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-016 |
| **Test Case Description** | Verify validation errors for empty required fields |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to register page<br>2. Leave all fields empty<br>3. Click register button |
| **Expected Results** | 1. Validation errors appear for all required fields<br>2. Form is not submitted |
| **Actual Results** | _________________ |

---

### 2.3 Forgot Password Page

#### TC-AUTH-017: Forgot Password - Request Reset Link

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-017 |
| **Test Case Description** | Verify user can request password reset for registered email |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `photo@tfp.local` |
| **Test Steps** | 1. Navigate to forgot password page (`/forgot-password`)<br>2. Enter registered email address<br>3. Click "Send Reset Link" or "Submit" button |
| **Expected Results** | 1. Success message displayed (e.g., "Password reset link sent to your email")<br>2. User is notified to check their email |
| **Actual Results** | _________________ |

---

#### TC-AUTH-018: Forgot Password - Non-existent Email

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-018 |
| **Test Case Description** | Verify appropriate message for non-existent email in forgot password |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | Email: `notfound@tfp.local` |
| **Test Steps** | 1. Navigate to forgot password page<br>2. Enter email that doesn't exist<br>3. Click submit button |
| **Expected Results** | 1. Either error message or generic success (for security)<br>2. No indication that email doesn't exist (prevents email enumeration) |
| **Actual Results** | _________________ |

---

#### TC-AUTH-019: Forgot Password - Empty Email Field

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-019 |
| **Test Case Description** | Verify validation for empty email field in forgot password |
| **Preconditions** | 1. Application is running and accessible |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to forgot password page<br>2. Leave email field empty<br>3. Click submit button |
| **Expected Results** | 1. Validation error message for required email field<br>2. Form is not submitted |
| **Actual Results** | _________________ |

---

### 2.4 Logout Functionality

#### TC-AUTH-020: Logout Functionality

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-020 |
| **Test Case Description** | Verify user can successfully log out of the application |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in with valid credentials<br>2. Click user avatar/menu in navigation<br>3. Click "Logout" or "Sign Out" option |
| **Expected Results** | 1. User is logged out<br>2. Navigation shows login/register options<br>3. User is redirected to home page<br>4. Session is cleared |
| **Actual Results** | _________________ |

---

#### TC-AUTH-021: Access Protected Page After Logout

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-AUTH-021 |
| **Test Case Description** | Verify user is redirected to login when accessing protected page after logout |
| **Preconditions** | 1. User is logged out |
| **Test Data** | N/A |
| **Test Steps** | 1. Try to access protected page directly (e.g., `/projects/create`, `/settings/profile`)<br>2. Observe the redirect behavior |
| **Expected Results** | 1. User is redirected to login page<br>2. After login, user can access the protected page |
| **Actual Results** | _________________ |

---

## 3. Public Pages

### 3.1 Home Page

#### TC-PUB-001: Home Page Load - Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-001 |
| **Test Case Description** | Verify home page loads correctly for unauthenticated users |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to home page (`/`)<br>2. Observe page layout and content |
| **Expected Results** | 1. Page loads without errors<br>2. Navigation shows Login/Register options<br>3. Featured projects, contests, and events are displayed<br>4. Call-to-action for signup is visible |
| **Actual Results** | _________________ |

---

#### TC-PUB-002: Home Page Load - Authenticated User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-002 |
| **Test Case Description** | Verify home page displays personalized content for logged-in users |
| **Preconditions** | 1. User is logged in as `photo@tfp.local` |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in with valid credentials<br>2. Navigate to home page<br>3. Observe personalized content |
| **Expected Results** | 1. User's name/avatar appears in navigation<br>2. Personalized dashboard or feed is displayed<br>3. Quick access to create new project/contest/event |
| **Actual Results** | _________________ |

---

#### TC-PUB-003: Home Page Navigation Links

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-003 |
| **Test Case Description** | Verify all navigation links on home page work correctly |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to home page<br>2. Click on Projects link<br>3. Click on Contests link<br>4. Click on Events link<br>5. Click on Profile links |
| **Expected Results** | 1. All navigation links redirect to correct pages<br>2. No broken links or 404 errors |
| **Actual Results** | _________________ |

---

#### TC-PUB-004: Home Page Responsive Design

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-004 |
| **Test Case Description** | Verify home page displays correctly on different screen sizes |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Open home page on desktop (1920x1080)<br>2. Open home page on tablet (768x1024)<br>3. Open home page on mobile (375x667)<br>4. Check layout and content visibility |
| **Expected Results** | 1. Page is responsive<br>2. Content adjusts appropriately for each device<br>3. No horizontal scrolling on mobile |
| **Actual Results** | _________________ |

---

#### TC-PUB-005: Featured Projects Display

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-005 |
| **Test Case Description** | Verify featured projects are displayed on home page |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to home page<br>2. Scroll to projects section<br>3. Verify project cards are displayed |
| **Expected Results** | 1. Project cards show image, title, description, creator<br>2. Clicking a project navigates to project detail |
| **Actual Results** | _________________ |

---

#### TC-PUB-006: Featured Contests Display

| Field | Details |
|-------|--------- |
| **Test Case ID** | TC-PUB-006 |
| **Test Case Description** | Verify featured/upcoming contests are displayed on home page |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to home page<br>2. Scroll to contests section<br>3. Verify contest cards are displayed |
| **Expected Results** | 1. Contest cards show image, title, deadline, prize<br>2. Status indicators (Active, Upcoming, etc.) are visible |
| **Actual Results** | _________________ |

---

#### TC-PUB-007: Featured Events Display

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-007 |
| **Test Case Description** | Verify upcoming events are displayed on home page |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to home page<br>2. Scroll to events section<br>3. Verify event cards are displayed |
| **Expected Results** | 1. Event cards show image, title, date, location, price<br>2. Clicking navigates to event detail |
| **Actual Results** | _________________ |

---

### 3.2 Privacy Policy Page

#### TC-PUB-008: Privacy Policy Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-008 |
| **Test Case Description** | Verify privacy policy page loads correctly |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to privacy policy page (`/privacy`) |
| **Expected Results** | 1. Page loads without errors<br>2. Privacy policy content is displayed<br>3. Navigation is accessible |
| **Actual Results** | _________________ |

---

### 3.3 Terms of Service Page

#### TC-PUB-009: Terms of Service Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PUB-009 |
| **Test Case Description** | Verify terms of service page loads correctly |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to terms page (`/terms`) |
| **Expected Results** | 1. Page loads without errors<br>2. Terms of service content is displayed<br>3. Navigation is accessible |
| **Actual Results** | _________________ |

---

## 4. Projects Module

### 4.1 Projects Listing Page

#### TC-PROJ-001: Projects Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-001 |
| **Test Case Description** | Verify projects listing page loads correctly with seeded projects |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to projects page (`/projects`)<br>2. Observe project listings |
| **Expected Results** | 1. Page loads without errors<br>2. Seeded projects are displayed (Fashion Editorial, Urban Portrait, Creative Conceptual, etc.)<br>3. Project cards show title, description, location, type |
| **Actual Results** | _________________ |

---

#### TC-PROJ-002: Projects Filter by Type

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-002 |
| **Test Case Description** | Verify projects can be filtered by type (TFP, PAID, COLLABORATION) |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to projects page<br>2. Apply TFP filter<br>3. Apply PAID filter<br>4. Observe filtered results |
| **Expected Results** | 1. Only projects of selected type are displayed<br>2. Filter indicator is visible<br>3. Clear filter option works |
| **Actual Results** | _________________ |

---

#### TC-PROJ-003: Projects Search Functionality

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-003 |
| **Test Case Description** | Verify projects can be searched by keyword |
| **Preconditions** | 1. Application is running |
| **Test Data** | Search term: "fashion" |
| **Test Steps** | 1. Navigate to projects page<br>2. Enter search term in search field<br>3. Submit search |
| **Expected Results** | 1. Results are filtered based on search term<br>2. Matching projects are displayed |
| **Actual Results** | _________________ |

---

#### TC-PROJ-004: Projects Pagination

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-004 |
| **Test Case Description** | Verify pagination works correctly on projects page |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to projects page<br>2. If multiple pages exist, click next page<br>3. Verify different projects are displayed |
| **Expected Results** | 1. Pagination controls work correctly<br>2. Different projects load for each page |
| **Actual Results** | _________________ |

---

#### TC-PROJ-005: Projects Page as Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-005 |
| **Test Case Description** | Verify guest users can view projects but not apply |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to projects page as guest<br>2. Try to apply to a project |
| **Expected Results** | 1. Projects are visible<br>2. Apply button prompts login modal/page |
| **Actual Results** | _________________ |

---

### 4.2 Project Detail Page

#### TC-PROJ-006: Project Detail Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-006 |
| **Test Case Description** | Verify project detail page displays full project information |
| **Preconditions** | 1. Application is running<br>2. Seeded projects exist |
| **Test Data** | Project: "Fashion Editorial Shoot" |
| **Test Steps** | 1. Navigate to projects page<br>2. Click on "Fashion Editorial Shoot" project<br>3. Observe full project details |
| **Expected Results** | 1. Page loads without errors<br>2. Project title, description, location, type are displayed<br>3. Moodboard images are shown<br>4. Required roles are listed<br>5. Creator information is visible |
| **Actual Results** | _________________ |

---

#### TC-PROJ-007: Project Detail - View Creator Profile

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-007 |
| **Test Case Description** | Verify user can navigate to creator's profile from project detail |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Open any project detail page<br>2. Click on creator's name or avatar |
| **Expected Results** | 1. User is navigated to creator's profile page |
| **Actual Results** | _________________ |

---

#### TC-PROJ-008: Project Application - Logged In User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-008 |
| **Test Case Description** | Verify logged-in user can apply to a project |
| **Preconditions** | 1. User is logged in as `model@tfp.local` |
| **Test Data** | Email: `model@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as model user<br>2. Navigate to a project detail page<br>3. Click "Apply" button<br>4. Fill application form<br>5. Submit application |
| **Expected Results** | 1. Application form is displayed<br>2. User can select role to apply for<br>3. User can add message<br>4. After submission, success message appears<br>5. Application status is shown |
| **Actual Results** | _________________ |

---

#### TC-PROJ-009: Project Application - Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-009 |
| **Test Case Description** | Verify guest user is prompted to login when trying to apply |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to project detail page as guest<br>2. Click "Apply" button |
| **Expected Results** | 1. Login modal or redirect to login page appears<br>2. After login, user can proceed with application |
| **Actual Results** | _________________ |

---

#### TC-PROJ-010: Project Share Functionality

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-010 |
| **Test Case Description** | Verify project can be shared via social media/clipboard |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Open project detail page<br>2. Click share button/icon<br>3. Verify share options are available |
| **Expected Results** | 1. Share options are displayed (copy link, social media) |
| **Actual Results** | _________________ |

---

### 4.3 Create Project Page

#### TC-PROJ-011: Create Project Page Access - Authenticated User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-011 |
| **Test Case Description** | Verify authenticated user can access create project page |
| **Preconditions** | 1. User is logged in as `photo@tfp.local` |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as photographer<br>2. Navigate to create project page (`/projects/create`) |
| **Expected Results** | 1. Create project form is displayed<br>2. All form fields are present |
| **Actual Results** | _________________ |

---

#### TC-PROJ-012: Create Project Page Access - Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-012 |
| **Test Case Description** | Verify guest user cannot access create project page |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Try to navigate directly to `/projects/create` |
| **Expected Results** | 1. User is redirected to login page<br>2. After login, user can access create page |
| **Actual Results** | _________________ |

---

#### TC-PROJ-013: Create Project - Form Validation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-013 |
| **Test Case Description** | Verify form validation for required fields in create project |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to create project page<br>2. Leave all fields empty<br>3. Click submit button |
| **Expected Results** | 1. Validation errors for required fields (title, description, location, roles) |
| **Actual Results** | _________________ |

---

#### TC-PROJ-014: Create Project - Successful Submission

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-014 |
| **Test Case Description** | Verify user can successfully create a new project |
| **Preconditions** | 1. User is logged in |
| **Test Data** | Title: "Test Project"<br>Description: "This is a test project for QA testing"<br>Location: New York, USA<br>Type: TFP<br>Roles: Model, MUA |
| **Test Steps** | 1. Navigate to create project page<br>2. Fill in all required fields<br>3. Add moodboard images if required<br>4. Add required roles<br>5. Click submit/create button |
| **Expected Results** | 1. Project is created successfully<br>2. User is redirected to project detail page<br>3. Success message is displayed |
| **Actual Results** | _________________ |

---

#### TC-PROJ-015: Create Project - Moodboard Image Upload

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROJ-015 |
| **Test Case Description** | Verify image upload for project moodboard |
| **Preconditions** | 1. User is logged in |
| **Test Data** | Image files: JPG/PNG format |
| **Test Steps** | 1. Navigate to create project page<br>2. Locate image upload area<br>3. Select or drag-drop images<br>4. Verify images are previewed |
| **Expected Results** | 1. Images can be uploaded<br>2. Preview thumbnails are displayed<br>3. Images can be removed |
| **Actual Results** | _________________ |

---

## 5. Contests Module

### 5.1 Contests Listing Page

#### TC-CONT-001: Contests Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-001 |
| **Test Case Description** | Verify contests listing page displays all seeded contests |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to contests page (`/contests`) |
| **Expected Results** | 1. Page loads without errors<br>2. Seeded contests are displayed (Street Photography Challenge, Portrait Masterclass, Golden Hour Landscape, etc.)<br>3. Contest cards show image, title, status, deadline, prize |
| **Actual Results** | _________________ |

---

#### TC-CONT-002: Contests Filter by Status

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-002 |
| **Test Case Description** | Verify contests can be filtered by status (Active, Upcoming, Judging, Completed) |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to contests page<br>2. Filter by "Active"<br>3. Filter by "Upcoming"<br>4. Filter by "Completed" |
| **Expected Results** | 1. Only contests with selected status are displayed<br>2. Filter indicator is visible |
| **Actual Results** | _________________ |

---

#### TC-CONT-003: Contests Search

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-003 |
| **Test Case Description** | Verify contests can be searched by keyword |
| **Preconditions** | 1. Application is running |
| **Test Data** | Search term: "portrait" |
| **Test Steps** | 1. Navigate to contests page<br>2. Enter search term<br>3. Submit search |
| **Expected Results** | 1. Results are filtered by search term<br>2. Matching contests are displayed |
| **Actual Results** | _________________ |

---

### 5.2 Contest Detail Page

#### TC-CONT-004: Contest Detail Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-004 |
| **Test Case Description** | Verify contest detail page displays full contest information |
| **Preconditions** | 1. Application is running |
| **Test Data** | Contest: "Street Photography Challenge" |
| **Test Steps** | 1. Navigate to contests page<br>2. Click on "Street Photography Challenge" |
| **Expected Results** | 1. Page loads without errors<br>2. Contest title, description, banner image displayed<br>3. Start date, deadline, judging dates shown<br>4. Prize information is visible<br>5. Number of participants shown<br>6. Top submissions preview displayed (if available) |
| **Actual Results** | _________________ |

---

#### TC-CONT-005: Contest Submit Entry - Logged In User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-005 |
| **Test Case Description** | Verify logged-in user can submit entry to active contest |
| **Preconditions** | 1. User is logged in as `photo@tfp.local`<br>2. Contest is in ACTIVE status |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as photographer<br>2. Navigate to active contest detail<br>3. Click "Submit Entry" or "Enter Contest"<br>4. Upload submission image<br>5. Add description<br>6. Submit entry |
| **Expected Results** | 1. Entry form is displayed<br>2. Image upload works<br>3. Entry is submitted successfully<br>4. Confirmation message displayed |
| **Actual Results** | _________________ |

---

#### TC-CONT-006: Contest Submit Entry - Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-006 |
| **Test Case Description** | Verify guest user is prompted to login when trying to submit entry |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to active contest as guest<br>2. Click "Submit Entry" |
| **Expected Results** | 1. Login modal or redirect appears<br>2. After login, can proceed with submission |
| **Actual Results** | _________________ |

---

#### TC-CONT-007: Contest - View Submissions/Gallery

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-007 |
| **Test Case Description** | Verify user can view contest submissions/gallery |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to contest detail page<br>2. Click "View Gallery" or "View Submissions" |
| **Expected Results** | 1. Gallery page opens<br>2. All submissions are displayed<br>3. Pagination or infinite scroll works |
| **Actual Results** | _________________ |

---

#### TC-CONT-008: Contest - React to Submission (Like/Vote)

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-008 |
| **Test Case Description** | Verify logged-in user can like/vote on contest submissions |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to contest gallery<br>2. Click like button on a submission<br>3. Verify reaction is registered |
| **Expected Results** | 1. Like/reaction count increases<br>2. User's reaction is saved |
| **Actual Results** | _________________ |

---

### 5.3 Contest Gallery Page

#### TC-CONT-009: Contest Gallery Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-009 |
| **Test Case Description** | Verify contest gallery page displays all submissions |
| **Preconditions** | 1. Application is running |
| **Test Data** | Contest: "Street Photography Challenge" |
| **Test Steps** | 1. Navigate to contest gallery (`/contests/[slug]/gallery`) |
| **Expected Results** | 1. All contest submissions are displayed<br>2. Grid layout with submission thumbnails<br>3. Pagination or infinite scroll |
| **Actual Results** | _________________ |

---

#### TC-CONT-010: Contest Gallery - Submission Detail View

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-CONT-010 |
| **Test Case Description** | Verify user can view individual submission details |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to contest gallery<br>2. Click on a submission thumbnail |
| **Expected Results** | 1. Full submission image is displayed<br>2. Photographer info is shown<br>3. Description is visible<br>4. Like/vote counts displayed |
| **Actual Results** | _________________ |

---

## 6. Events Module

### 6.1 Events Listing Page

#### TC-EVT-001: Events Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-001 |
| **Test Case Description** | Verify events listing page displays all seeded events |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to events page (`/events`) |
| **Expected Results** | 1. Page loads without errors<br>2. Seeded events are displayed (Street Photography Workshop, Portrait Masterclass, Night Shoot, etc.)<br>3. Event cards show image, title, date, location, price |
| **Actual Results** | _________________ |

---

#### TC-EVT-002: Events Filter by Category

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-002 |
| **Test Case Description** | Verify events can be filtered by category |
| **Preconditions** | 1. Application is running |
| **Test Data** | Categories: Workshop, Masterclass, Meetup, Expo |
| **Test Steps** | 1. Navigate to events page<br>2. Filter by "Workshop"<br>3. Filter by "Meetup" |
| **Expected Results** | 1. Only events of selected category are displayed<br>2. Filter works correctly |
| **Actual Results** | _________________ |

---

#### TC-EVT-003: Events Filter by Date

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-003 |
| **Test Case Description** | Verify events can be filtered by date range |
| **Preconditions** | 1. Application is running |
| **Test Data** | Date range: This month |
| **Test Steps** | 1. Navigate to events page<br>2. Apply date filter |
| **Expected Results** | 1. Events are filtered by selected date range |
| **Actual Results** | _________________ |

---

### 6.2 Event Detail Page

#### TC-EVT-004: Event Detail Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-004 |
| **Test Case Description** | Verify event detail page displays full event information |
| **Preconditions** | 1. Application is running |
| **Test Data** | Event: "Street Photography Workshop" |
| **Test Steps** | 1. Navigate to events page<br>2. Click on "Street Photography Workshop" |
| **Expected Results** | 1. Page loads without errors<br>2. Event title, description, banner displayed<br>3. Date, time, venue shown<br>4. Price and capacity displayed<br>5. Organizer information visible<br>6. RSVP button displayed |
| **Actual Results** | _________________ |

---

#### TC-EVT-005: Event RSVP - Logged In User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-005 |
| **Test Case Description** | Verify logged-in user can RSVP to an event |
| **Preconditions** | 1. User is logged in as `model@tfp.local`<br>2. Event has available capacity |
| **Test Data** | Email: `model@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as model user<br>2. Navigate to event detail<br>3. Click "RSVP" or "Going" button |
| **Expected Results** | 1. RSVP is confirmed<br>2. Button changes to "Registered" or "Going"<br>3. Attendee count increases |
| **Actual Results** | _________________ |

---

#### TC-EVT-006: Event RSVP - Guest User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-006 |
| **Test Case Description** | Verify guest user is prompted to login when trying to RSVP |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to event detail as guest<br>2. Click RSVP button |
| **Expected Results** | 1. Login modal or redirect appears<br>2. After login, can proceed with RSVP |
| **Actual Results** | _________________ |

---

#### TC-EVT-007: Event - Cancel RSVP

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-007 |
| **Test Case Description** | Verify user can cancel their event RSVP |
| **Preconditions** | 1. User is logged in and has RSVPed to an event |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to event user has RSVPed to<br>2. Click "Cancel RSVP" or "Not Going" |
| **Expected Results** | 1. RSVP is cancelled<br>2. Button reverts to RSVP state<br>3. Attendee count decreases |
| **Actual Results** | _________________ |

---

#### TC-EVT-008: Event - View Attendees

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EVT-008 |
| **Test Case Description** | Verify user can view list of event attendees |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to event detail<br>2. Click on "View Attendees" or similar link |
| **Expected Results** | 1. List of attendees is displayed<br>2. Attendee avatars/names are shown |
| **Actual Results** | _________________ |

---

## 7. User Profile Module

### 7.1 Public Profile Page

#### TC-PROF-001: Public Profile Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-001 |
| **Test Case Description** | Verify public profile page displays user information |
| **Preconditions** | 1. Application is running |
| **Test Data** | Username: `photo` (from photo@tfp.local) |
| **Test Steps** | 1. Navigate to profile page (`/profile/photo`) |
| **Expected Results** | 1. Page loads without errors<br>2. User's display name shown<br>3. Profile image displayed<br>4. Cover image shown<br>5. Bio/description visible<br>6. Role badges displayed<br>7. Portfolio images displayed |
| **Actual Results** | _________________ |

---

#### TC-PROF-002: Public Profile - View Portfolio

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-002 |
| **Test Case Description** | Verify portfolio images are displayed on profile |
| **Preconditions** | 1. User has portfolio images |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to any user profile with portfolio<br>2. Scroll to portfolio section |
| **Expected Results** | 1. Portfolio images displayed in grid<br>2. Image titles visible<br>3. Clicking image shows full view |
| **Actual Results** | _________________ |

---

#### TC-PROF-003: Public Profile - User's Projects

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-003 |
| **Test Case Description** | Verify user's created projects are shown on profile |
| **Preconditions** | 1. User has created projects |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to profile of user who created projects<br>2. Look for projects section |
| **Expected Results** | 1. User's projects are displayed<br>2. Project cards show relevant info |
| **Actual Results** | _________________ |

---

#### TC-PROF-004: Public Profile - User's Contest Entries

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-004 |
| **Test Case Description** | Verify user's contest entries are shown on profile |
| **Preconditions** | 1. User has entered contests |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to profile with contest entries<br>2. Find contest entries section |
| **Expected Results** | 1. Contest entries displayed<br>2. Entry images shown with contest info |
| **Actual Results** | _________________ |

---

#### TC-PROF-005: Public Profile - Contact/Message Option

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-005 |
| **Test Case Description** | Verify user can message/profile owner from public profile |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in as `model@tfp.local`<br>2. Navigate to `photo@tfp.local` profile<br>3. Look for message/contact button |
| **Expected Results** | 1. Message button is available<br>2. Clicking opens message dialog |
| **Actual Results** | _________________ |

---

### 7.2 Edit Profile / Settings Page

#### TC-PROF-006: Edit Profile Page Access

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-006 |
| **Test Case Description** | Verify user can access their own profile settings |
| **Preconditions** | 1. User is logged in as `photo@tfp.local` |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as photographer<br>2. Navigate to settings/profile edit (`/settings/profile`) |
| **Expected Results** | 1. Profile edit form is displayed<br>2. Current user data is pre-filled |
| **Actual Results** | _________________ |

---

#### TC-PROF-007: Edit Profile - Update Display Name

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-007 |
| **Test Case Description** | Verify user can update their display name |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | New Display Name: "Updated Name" |
| **Test Steps** | 1. Navigate to edit profile<br>2. Change display name<br>3. Save changes |
| **Expected Results** | 1. Display name is updated<br>2. Success message shown<br>3. Changes reflected on profile |
| **Actual Results** | _________________ |

---

#### TC-PROF-008: Edit Profile - Update Bio

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-008 |
| **Test Case Description** | Verify user can update their bio |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | New Bio: "This is my updated bio for testing purposes." |
| **Test Steps** | 1. Navigate to edit profile<br>2. Update bio field<br>3. Save changes |
| **Expected Results** | 1. Bio is updated successfully<br>2. Changes visible on profile |
| **Actual Results** | _________________ |

---

#### TC-PROF-009: Edit Profile - Update Profile Image

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-009 |
| **Test Case Description** | Verify user can update their profile picture |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | Image file: JPG/PNG |
| **Test Steps** | 1. Navigate to edit profile<br>2. Find profile image upload<br>3. Select new image<br>4. Save changes |
| **Expected Results** | 1. New profile image is uploaded<br>2. Preview shows new image<br>3. Saved successfully |
| **Actual Results** | _________________ |

---

#### TC-PROF-010: Edit Profile - Update Location

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-010 |
| **Test Case Description** | Verify user can update their location |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | New Location: London, UK |
| **Test Steps** | 1. Navigate to edit profile<br>2. Update location field<br>3. Save changes |
| **Expected Results** | 1. Location is updated<br>2. Changes reflected on profile |
| **Actual Results** | _________________ |

---

#### TC-PROF-011: Edit Profile - Form Validation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-011 |
| **Test Case Description** | Verify form validation for required fields |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to edit profile<br>2. Remove required field data<br>3. Try to save |
| **Expected Results** | 1. Validation error messages appear<br>2. Form is not submitted |
| **Actual Results** | _________________ |

---

#### TC-PROF-012: Edit Profile - Change Password

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-PROF-012 |
| **Test Case Description** | Verify user can change their password from settings |
| **Preconditions** | 1. User is on edit profile page |
| **Test Data** | Current Password: `Seed123!`<br>New Password: `NewPass123!` |
| **Test Steps** | 1. Navigate to edit profile<br>2. Find change password section<br>3. Enter current password<br>4. Enter new password<br>5. Confirm new password<br>6. Save |
| **Expected Results** | 1. Password is changed successfully<br>2. Confirmation message shown<br>3. User can login with new password |
| **Actual Results** | _________________ |

---

## 8. Notifications Module

### 8.1 Notifications Page

#### TC-NOTIF-001: Notifications Page Load

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTIF-001 |
| **Test Case Description** | Verify notifications page displays user notifications |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in as `photo@tfp.local`<br>2. Navigate to notifications page (`/notifications`) |
| **Expected Results** | 1. Page loads without errors<br>2. Notifications list is displayed<br>3. Notification types shown (applications, RSVPs, messages) |
| **Actual Results** | _________________ |

---

#### TC-NOTIF-002: Notifications - Unread Count

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTIF-002 |
| **Test Case Description** | Verify unread notification count is displayed in navigation |
| **Preconditions** | 1. User has unread notifications |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in as user with notifications<br>2. Look at notification icon in navigation |
| **Expected Results** | 1. Badge shows unread count<br>2. Count is accurate |
| **Actual Results** | _________________ |

---

#### TC-NOTIF-003: Notifications - Mark as Read

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTIF-003 |
| **Test Case Description** | Verify user can mark notifications as read |
| **Preconditions** | 1. User has unread notifications |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to notifications page<br>2. Click on a notification<br>3. Observe read status |
| **Expected Results** | 1. Notification is marked as read<br>2. Unread count decreases |
| **Actual Results** | _________________ |

---

#### TC-NOTIF-004: Notifications - Application Status Updates

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTIF-004 |
| **Test Case Description** | Verify notifications for project application status changes |
| **Preconditions** | 1. User has applied to a project |
| **Test Data** | N/A |
| **Test Steps** | 1. Check notifications for application status updates |
| **Expected Results** | 1. Notifications show application status (shortlisted, selected, etc.) |
| **Actual Results** | _________________ |

---

#### TC-NOTIF-005: Notifications - Event RSVP Responses

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-NOTIF-005 |
| **Test Case Description** | Verify notifications for event RSVP activities |
| **Preconditions** | 1. User has RSVPed to events |
| **Test Data** | N/A |
| **Test Steps** | 1. Check notifications for event-related updates |
| **Expected Results** | 1. Event RSVP notifications are displayed |
| **Actual Results** | _________________ |

---

## 9. Admin Module

### 9.1 Admin Moderation Queue

#### TC-ADMIN-001: Admin Moderation Page Access - Admin User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-001 |
| **Test Case Description** | Verify admin user can access moderation queue |
| **Preconditions** | 1. User is logged in as admin |
| **Test Data** | Email: `admin@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as admin user<br>2. Navigate to admin moderation page (`/admin/moderation`) |
| **Expected Results** | 1. Admin moderation dashboard loads<br>2. Pending items are displayed |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-002: Admin Moderation Page Access - Regular User

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-002 |
| **Test Case Description** | Verify regular user cannot access admin moderation |
| **Preconditions** | 1. User is logged in as regular user |
| **Test Data** | Email: `photo@tfp.local`<br>Password: `Seed123!` |
| **Test Steps** | 1. Log in as regular user<br>2. Try to navigate to `/admin/moderation` |
| **Expected Results** | 1. Access is denied<br>2. User is redirected or sees error |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-003: Admin Moderation - Approve Project

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-003 |
| **Test Case Description** | Verify admin can approve pending projects |
| **Preconditions** | 1. Admin is on moderation page<br>2. Pending project exists |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Find pending project<br>3. Click "Approve" or "Approve" button |
| **Expected Results** | 1. Project status changes to APPROVED<br>2. Project becomes visible publicly |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-004: Admin Moderation - Reject Project

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-004 |
| **Test Case Description** | Verify admin can reject pending projects |
| **Preconditions** | 1. Admin is on moderation page<br>2. Pending project exists |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Find pending project<br>3. Click "Reject" button<br>4. Provide rejection reason if required |
| **Expected Results** | 1. Project is rejected<br>2. Status changes accordingly<br>3. Creator is notified |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-005: Admin Moderation - Approve Event

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-005 |
| **Test Case Description** | Verify admin can approve pending events |
| **Preconditions** | 1. Admin is on moderation page<br>2. Pending event exists |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Find pending event<br>3. Click "Approve" |
| **Expected Results** | 1. Event is approved<br>2. Event becomes visible publicly |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-006: Admin Moderation - Reject Event

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-006 |
| **Test Case Description** | Verify admin can reject pending events |
| **Preconditions** | 1. Admin is on moderation page<br>2. Pending event exists |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Find pending event<br>3. Click "Reject" |
| **Expected Results** | 1. Event is rejected |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-007: Admin Moderation - View User Reports

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-007 |
| **Test Case Description** | Verify admin can view user-submitted reports |
| **Preconditions** | 1. Admin is on moderation page |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Look for reports section |
| **Expected Results** | 1. User reports are displayed<br>2. Report details are accessible |
| **Actual Results** | _________________ |

---

#### TC-ADMIN-008: Admin Moderation - Contest Submissions

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ADMIN-008 |
| **Test Case Description** | Verify admin can moderate contest submissions if needed |
| **Preconditions** | 1. Admin is on moderation page |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to admin moderation<br>2. Look for contest submissions |
| **Expected Results** | 1. Contest submissions can be viewed<br>2. Inappropriate content can be removed |
| **Actual Results** | _________________ |

---

## 10. Cross-Cutting Test Cases

### 10.1 UI/UX and Navigation

#### TC-UI-001: Navigation Bar - Logged In State

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-UI-001 |
| **Test Case Description** | Verify navigation bar displays correctly for logged-in users |
| **Preconditions** | 1. User is logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in as any user<br>2. Observe navigation bar |
| **Expected Results** | 1. User avatar/name shown<br>2. Dropdown menu present<br>3. Logout option available<br>4. All navigation links visible |
| **Actual Results** | _________________ |

---

#### TC-UI-002: Navigation Bar - Guest State

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-UI-002 |
| **Test Case Description** | Verify navigation bar displays correctly for guests |
| **Preconditions** | 1. User is not logged in |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to any page as guest<br>2. Observe navigation bar |
| **Expected Results** | 1. Login and Register buttons shown<br>2. No user-specific options |
| **Actual Results** | _________________ |

---

#### TC-UI-003: Mobile Navigation Menu

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-UI-003 |
| **Test Case Description** | Verify mobile navigation menu works correctly |
| **Preconditions** | 1. Viewing on mobile viewport |
| **Test Data** | N/A |
| **Test Steps** | 1. Open site on mobile viewport<br>2. Click hamburger menu<br>3. Verify menu opens<br>4. Test navigation links |
| **Expected Results** | 1. Menu opens/closes correctly<br>2. All links work<br>3. Close button works |
| **Actual Results** | _________________ |

---

#### TC-UI-004: Footer Links

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-UI-004 |
| **Test Case Description** | Verify footer links work correctly |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Scroll to footer on any page<br>2. Click Privacy link<br>3. Click Terms link<br>4. Click other footer links |
| **Expected Results** | 1. All footer links navigate to correct pages<br>2. No broken links |
| **Actual Results** | _________________ |

---

### 10.2 Error Handling

#### TC-ERR-001: 404 Page - Invalid Route

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ERR-001 |
| **Test Case Description** | Verify 404 error page displays for invalid routes |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Navigate to invalid URL (e.g., `/invalid-page-123`) |
| **Expected Results** | 1. 404 page is displayed<br>2. Helpful message shown<br>3. Link to home page available |
| **Actual Results** | _________________ |

---

#### TC-ERR-002: 500 Page - Server Error

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ERR-002 |
| **Test Case Description** | Verify appropriate error handling for server errors |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Trigger a server error condition if possible |
| **Expected Results** | 1. User-friendly error message displayed<br>2. No sensitive information leaked |
| **Actual Results** | _________________ |

---

### 10.3 Edge Cases

#### TC-EDGE-001: Very Long Text Input

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EDGE-001 |
| **Test Case Description** | Verify system handles very long text inputs gracefully |
| **Preconditions** | 1. Application is running |
| **Test Data** | Long text string (1000+ characters) |
| **Test Steps** | 1. Enter very long text in any text field (bio, description)<br>2. Submit form |
| **Expected Results** | 1. Text is handled appropriately<br>2. Either truncated or accepted<br>3. No UI breaking |
| **Actual Results** | _________________ |

---

#### TC-EDGE-002: Special Characters in Input

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EDGE-002 |
| **Test Case Description** | Verify system handles special characters in input fields |
| **Preconditions** | 1. Application is running |
| **Test Data** | Special chars: `<script>alert('xss')</script>`, `O'Brien`, `Test & Co` |
| **Test Steps** | 1. Enter special characters in form fields<br>2. Submit form |
| **Expected Results** | 1. Input is handled safely<br>2. No script execution<br>3. Displayed correctly |
| **Actual Results** | _________________ |

---

#### TC-EDGE-003: Maximum Image Upload Size

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EDGE-003 |
| **Test Case Description** | Verify error handling for files exceeding size limit |
| **Preconditions** | 1. Application is running |
| **Test Data** | Large image file (>10MB) |
| **Test Steps** | 1. Try to upload very large image file<br>2. Observe error handling |
| **Expected Results** | 1. Error message about file size limit<br>2. Upload is rejected |
| **Actual Results** | _________________ |

---

#### TC-EDGE-004: Concurrent Session Handling

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-EDGE-004 |
| **Test Case Description** | Verify session handling when user logs in from multiple devices |
| **Preconditions** | 1. User logged in on one device |
| **Test Data** | N/A |
| **Test Steps** | 1. Log in on browser A<br>2. Log in on browser B with same credentials<br>3. Check session behavior |
| **Expected Results** | 1. Both sessions work or earlier session is invalidated<br>2. Appropriate behavior per design |
| **Actual Results** | _________________ |

---

### 10.4 Accessibility

#### TC-ACC-001: Keyboard Navigation

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ACC-001 |
| **Test Case Description** | Verify all interactive elements are accessible via keyboard |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Use Tab key to navigate through page<br>2. Use Enter/Space to activate elements<br>3. Check all interactive elements |
| **Expected Results** | 1. All buttons/links are focusable<br>2. Focus indicator is visible<br>3. All functions work with keyboard |
| **Actual Results** | _________________ |

---

#### TC-ACC-002: Screen Reader Compatibility

| Field | Details |
|-------|---------|
| **Test Case ID** | TC-ACC-002 |
| **Test Case Description** | Verify page has proper ARIA labels and semantic HTML |
| **Preconditions** | 1. Application is running |
| **Test Data** | N/A |
| **Test Steps** | 1. Inspect page source<br>2. Check for proper heading hierarchy<br>3. Check for alt text on images |
| **Expected Results** | 1. Proper semantic HTML used<br>2. Images have alt text<br>3. Form fields have labels |
| **Actual Results** | _________________ |

---

## Summary

| Module | Test Cases Count |
|--------|------------------|
| Authentication | 21 |
| Public Pages | 9 |
| Projects | 15 |
| Contests | 10 |
| Events | 8 |
| User Profile | 12 |
| Notifications | 5 |
| Admin | 8 |
| UI/UX & Cross-cutting | 10 |
| **Total** | **98** |

---

**Test Case Template Version:** 1.0  
**Last Updated:** March 2026  
**Author:** QA Team
