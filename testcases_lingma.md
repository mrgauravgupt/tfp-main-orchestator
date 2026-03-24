# Comprehensive Manual Test Cases for TFP Application

## Seeded User Credentials

### Default Login Password for All @tfp.local Users
- **Password**: `Seed123!`

### Seeded Test Users
1. **Admin User**
   - Email: `admin@tfp.local`
   - Role: ADMIN
   - Password: `Seed123!`

2. **Photographer User**
   - Email: `photo@tfp.local`
   - Role: PHOTOGRAPHER
   - Password: `Seed123!`

3. **Model User**
   - Email: `model@tfp.local`
   - Role: MODEL
   - Password: `Seed123!`

4. **Additional Participants**
   - `seed.participant.1@tfp.local`, `seed.participant.2@tfp.local`, etc.
   - Role: USER
   - Password: `Seed123!`

---

## Page 1: Home/Index Page

### Test Case 1.1: Home Page Load
- **Test Case ID**: TC_HOME_001
- **Description**: Verify that the home page loads successfully
- **Preconditions**: Application is deployed and accessible
- **Test Steps**:
  1. Open browser and navigate to the home page URL
  2. Wait for the page to fully load
- **Test Data**: N/A
- **Expected Results**: Home page loads without errors, all content displays properly, navigation menu is accessible
- **Actual Results**: 

### Test Case 1.2: Navigation Menu Links
- **Test Case ID**: TC_HOME_002
- **Description**: Verify that all navigation menu links work properly
- **Preconditions**: Home page is loaded
- **Test Steps**:
  1. Click on each navigation menu item (contests, events, projects, login, register)
  2. Verify page transitions
- **Test Data**: N/A
- **Expected Results**: Each menu item navigates to the correct page
- **Actual Results**: 

### Test Case 1.3: Hero Section Elements
- **Test Case ID**: TC_HOME_003
- **Description**: Verify all hero section elements are displayed
- **Preconditions**: Home page is loaded
- **Test Steps**:
  1. Verify the main headline text is displayed
  2. Check that call-to-action buttons are visible
  3. Confirm any featured content is visible
- **Test Data**: N/A
- **Expected Results**: All hero section elements are visible and functional
- **Actual Results**: 

### Test Case 1.4: Footer Links
- **Test Case ID**: TC_HOME_004
- **Description**: Verify that all footer links work properly
- **Preconditions**: Home page is loaded
- **Test Steps**:
  1. Scroll to the bottom of the page
  2. Click on each footer link (Privacy Policy, Terms of Service, Guidelines)
  3. Verify page transitions
- **Test Data**: N/A
- **Expected Results**: Each footer link navigates to the correct page
- **Actual Results**: 

---

## Page 2: Login Page

### Test Case 2.1: Successful Login with Valid Credentials
- **Test Case ID**: TC_LOGIN_001
- **Description**: Verify successful login with valid credentials
- **Preconditions**: User has valid account credentials
- **Test Steps**:
  1. Navigate to the login page
  2. Enter valid email address (e.g., `photo@tfp.local`)
  3. Enter valid password (`Seed123!`)
  4. Click "Login" button
  5. Verify redirection to the dashboard or home page
- **Test Data**: 
  - Email: `photo@tfp.local`
  - Password: `Seed123!`
- **Expected Results**: User logs in successfully, session is maintained, and redirected to the correct landing page
- **Actual Results**: 

### Test Case 2.2: Login with Invalid Email
- **Test Case ID**: TC_LOGIN_002
- **Description**: Verify error handling when invalid email is entered
- **Preconditions**: On login page
- **Test Steps**:
  1. Enter invalid email format (e.g., `invalid-email`)
  2. Enter valid password
  3. Click "Login" button
- **Test Data**: 
  - Email: `invalid-email`
  - Password: `Seed123!`
- **Expected Results**: Error message appears indicating invalid email format
- **Actual Results**: 

### Test Case 2.3: Login with Non-existent Email
- **Test Case ID**: TC_LOGIN_003
- **Description**: Verify error handling when non-existent email is entered
- **Preconditions**: On login page
- **Test Steps**:
  1. Enter non-existent email address (e.g., `nonexistent@test.com`)
  2. Enter any password
  3. Click "Login" button
- **Test Data**: 
  - Email: `nonexistent@test.com`
  - Password: `any_password`
- **Expected Results**: Error message appears indicating account does not exist
- **Actual Results**: 

### Test Case 2.4: Login with Incorrect Password
- **Test Case ID**: TC_LOGIN_004
- **Description**: Verify error handling when incorrect password is entered
- **Preconditions**: On login page
- **Test Steps**:
  1. Enter valid email address (e.g., `photo@tfp.local`)
  2. Enter incorrect password (e.g., `wrongpassword`)
  3. Click "Login" button
- **Test Data**: 
  - Email: `photo@tfp.local`
  - Password: `wrongpassword`
- **Expected Results**: Error message appears indicating invalid credentials
- **Actual Results**: 

### Test Case 2.5: Empty Email Field Validation
- **Test Case ID**: TC_LOGIN_005
- **Description**: Verify validation when email field is empty
- **Preconditions**: On login page
- **Test Steps**:
  1. Leave email field empty
  2. Enter any password
  3. Click "Login" button
- **Test Data**: 
  - Email: (empty)
  - Password: `Seed123!`
- **Expected Results**: Error message appears requesting email input
- **Actual Results**: 

### Test Case 2.6: Empty Password Field Validation
- **Test Case ID**: TC_LOGIN_006
- **Description**: Verify validation when password field is empty
- **Preconditions**: On login page
- **Test Steps**:
  1. Enter valid email address
  2. Leave password field empty
  3. Click "Login" button
- **Test Data**: 
  - Email: `photo@tfp.local`
  - Password: (empty)
- **Expected Results**: Error message appears requesting password input
- **Actual Results**: 

### Test Case 2.7: Both Fields Empty Validation
- **Test Case ID**: TC_LOGIN_007
- **Description**: Verify validation when both email and password fields are empty
- **Preconditions**: On login page
- **Test Steps**:
  1. Leave email field empty
  2. Leave password field empty
  3. Click "Login" button
- **Test Data**: 
  - Email: (empty)
  - Password: (empty)
- **Expected Results**: Error messages appear for both fields
- **Actual Results**: 

### Test Case 2.8: Forgot Password Link
- **Test Case ID**: TC_LOGIN_008
- **Description**: Verify the forgot password link functionality
- **Preconditions**: On login page
- **Test Steps**:
  1. Click on "Forgot Password?" link
  2. Verify navigation to forgot password page
- **Test Data**: N/A
- **Expected Results**: User is navigated to the forgot password page
- **Actual Results**: 

### Test Case 2.9: Register Link
- **Test Case ID**: TC_LOGIN_009
- **Description**: Verify the register link functionality
- **Preconditions**: On login page
- **Test Steps**:
  1. Click on "Register" or "Sign Up" link
  2. Verify navigation to registration page
- **Test Data**: N/A
- **Expected Results**: User is navigated to the registration page
- **Actual Results**: 

### Test Case 2.10: Session Maintenance After Login
- **Test Case ID**: TC_LOGIN_010
- **Description**: Verify that session is maintained after successful login
- **Preconditions**: User has logged in successfully
- **Test Steps**:
  1. Log in with valid credentials
  2. Navigate to different pages within the application
  3. Refresh the page multiple times
  4. Verify that user remains logged in
- **Test Data**: 
  - Email: `photo@tfp.local`
  - Password: `Seed123!`
- **Expected Results**: User remains logged in across different pages and refreshes
- **Actual Results**: 

---

## Page 3: Registration Page

### Test Case 3.1: Successful Registration
- **Test Case ID**: TC_REG_001
- **Description**: Verify successful registration with valid information
- **Preconditions**: On registration page
- **Test Steps**:
  1. Fill in all required fields with valid information
  2. Submit the registration form
  3. Verify successful registration message
- **Test Data**: Valid name, email, password, confirm password
- **Expected Results**: Account created successfully with confirmation message
- **Actual Results**: 

### Test Case 3.2: Registration with Already Existing Email
- **Test Case ID**: TC_REG_002
- **Description**: Verify error handling when registering with existing email
- **Preconditions**: On registration page
- **Test Steps**:
  1. Enter an email that already exists in the system
  2. Fill in other required fields
  3. Submit the registration form
- **Test Data**: 
  - Email: `photo@tfp.local` (already exists)
  - Other valid data
- **Expected Results**: Error message appears indicating email already registered
- **Actual Results**: 

### Test Case 3.3: Password Strength Validation
- **Test Case ID**: TC_REG_003
- **Description**: Verify password strength validation during registration
- **Preconditions**: On registration page
- **Test Steps**:
  1. Enter weak password (e.g., less than 8 characters)
  2. Fill in other fields
  3. Submit the form
- **Test Data**: 
  - Weak password: `pass`
- **Expected Results**: Error message appears indicating password strength requirements
- **Actual Results**: 

### Test Case 3.4: Password Confirmation Validation
- **Test Case ID**: TC_REG_004
- **Description**: Verify password confirmation validation
- **Preconditions**: On registration page
- **Test Steps**:
  1. Enter mismatched passwords in password and confirm password fields
  2. Submit the form
- **Test Data**: 
  - Password: `Seed123!`
  - Confirm Password: `different`
- **Expected Results**: Error message appears indicating passwords do not match
- **Actual Results**: 

### Test Case 3.5: Empty Required Fields Validation
- **Test Case ID**: TC_REG_005
- **Description**: Verify validation when required fields are empty
- **Preconditions**: On registration page
- **Test Steps**:
  1. Leave required fields empty
  2. Submit the form
- **Test Data**: Empty required fields
- **Expected Results**: Error messages appear for all empty required fields
- **Actual Results**: 

---

## Page 4: Contests Pages

### Test Case 4.1: View Contests List
- **Test Case ID**: TC_CONTEST_001
- **Description**: Verify that the contests list page loads and displays contests
- **Preconditions**: User is on the contests page
- **Test Steps**:
  1. Navigate to the contests page
  2. Verify that the list of contests is displayed
  3. Check that contest cards show relevant information
- **Test Data**: N/A
- **Expected Results**: Contests list displays correctly with titles, dates, and images
- **Actual Results**: 

### Test Case 4.2: View Contest Detail
- **Test Case ID**: TC_CONTEST_002
- **Description**: Verify that contest detail page loads correctly
- **Preconditions**: User is on contests list page
- **Test Steps**:
  1. Click on a specific contest from the list
  2. Verify contest details page loads
  3. Check that all contest information is displayed correctly
- **Test Data**: N/A
- **Expected Results**: Detailed contest page loads with full information
- **Actual Results**: 

### Test Case 4.3: Submit Entry to Contest
- **Test Case ID**: TC_CONTEST_003
- **Description**: Verify the contest submission process
- **Preconditions**: User is logged in and on a contest detail page
- **Test Steps**:
  1. Click on "Submit Entry" button
  2. Upload an image/file according to requirements
  3. Fill in description if required
  4. Submit the entry
- **Test Data**: Valid contest entry image/file
- **Expected Results**: Entry submitted successfully with confirmation message
- **Actual Results**: 

### Test Case 4.4: Contest Voting Feature
- **Test Case ID**: TC_CONTEST_004
- **Description**: Verify voting functionality on contest entries
- **Preconditions**: User is on a contest page with entries
- **Test Steps**:
  1. Find a contest entry
  2. Click on the vote/react button
  3. Verify the reaction is recorded
- **Test Data**: N/A
- **Expected Results**: Vote/reaction is successfully recorded and reflected in the UI
- **Actual Results**: 

### Test Case 4.5: Create New Contest
- **Test Case ID**: TC_CONTEST_005
- **Description**: Verify contest creation functionality for authorized users
- **Preconditions**: User is logged in with contest creation permissions
- **Test Steps**:
  1. Navigate to contest creation page
  2. Fill in all required contest details
  3. Submit the new contest
- **Test Data**: Valid contest details
- **Expected Results**: New contest is created and listed appropriately
- **Actual Results**: 

---

## Page 5: Events Pages

### Test Case 5.1: View Events List
- **Test Case ID**: TC_EVENT_001
- **Description**: Verify that the events list page loads and displays events
- **Preconditions**: User is on the events page
- **Test Steps**:
  1. Navigate to the events page
  2. Verify that the list of events is displayed
  3. Check that event cards show relevant information
- **Test Data**: N/A
- **Expected Results**: Events list displays correctly with titles, dates, and locations
- **Actual Results**: 

### Test Case 5.2: View Event Detail
- **Test Case ID**: TC_EVENT_002
- **Description**: Verify that event detail page loads correctly
- **Preconditions**: User is on events list page
- **Test Steps**:
  1. Click on a specific event from the list
  2. Verify event details page loads
  3. Check that all event information is displayed correctly
- **Test Data**: N/A
- **Expected Results**: Detailed event page loads with full information
- **Actual Results**: 

### Test Case 5.3: RSVP to Event
- **Test Case ID**: TC_EVENT_003
- **Description**: Verify the event RSVP functionality
- **Preconditions**: User is logged in and on an event detail page
- **Test Steps**:
  1. Click on "RSVP" or "Join Event" button
  2. Confirm attendance intention
  3. Verify RSVP status is updated
- **Test Data**: N/A
- **Expected Results**: RSVP is successfully recorded and status is updated
- **Actual Results**: 

### Test Case 5.4: Create New Event
- **Test Case ID**: TC_EVENT_004
- **Description**: Verify event creation functionality for authorized users
- **Preconditions**: User is logged in with event creation permissions
- **Test Steps**:
  1. Navigate to event creation page
  2. Fill in all required event details
  3. Submit the new event
- **Test Data**: Valid event details
- **Expected Results**: New event is created and listed appropriately
- **Actual Results**: 

---

## Page 6: Projects Pages

### Test Case 6.1: View Projects List
- **Test Case ID**: TC_PROJECT_001
- **Description**: Verify that the projects list page loads and displays projects
- **Preconditions**: User is on the projects page
- **Test Steps**:
  1. Navigate to the projects page
  2. Verify that the list of projects is displayed
  3. Check that project cards show relevant information
- **Test Data**: N/A
- **Expected Results**: Projects list displays correctly with titles, types, and locations
- **Actual Results**: 

### Test Case 6.2: View Project Detail
- **Test Case ID**: TC_PROJECT_002
- **Description**: Verify that project detail page loads correctly
- **Preconditions**: User is on projects list page
- **Test Steps**:
  1. Click on a specific project from the list
  2. Verify project details page loads
  3. Check that all project information is displayed correctly
- **Test Data**: N/A
- **Expected Results**: Detailed project page loads with full information
- **Actual Results**: 

### Test Case 6.3: Apply to Project
- **Test Case ID**: TC_PROJECT_003
- **Description**: Verify the project application process
- **Preconditions**: User is logged in and on a project detail page
- **Test Steps**:
  1. Click on "Apply" or "Express Interest" button
  2. Fill in application message if required
  3. Submit the application
- **Test Data**: Valid application message
- **Expected Results**: Application submitted successfully with confirmation message
- **Actual Results**: 

### Test Case 6.4: Create New Project
- **Test Case ID**: TC_PROJECT_004
- **Description**: Verify project creation functionality for authorized users
- **Preconditions**: User is logged in with project creation permissions
- **Test Steps**:
  1. Navigate to project creation page
  2. Fill in all required project details
  3. Submit the new project
- **Test Data**: Valid project details
- **Expected Results**: New project is created and listed appropriately
- **Actual Results**: 

---

## Page 7: Profile Pages

### Test Case 7.1: View Own Profile
- **Test Case ID**: TC_PROFILE_001
- **Description**: Verify that user can view their own profile
- **Preconditions**: User is logged in
- **Test Steps**:
  1. Navigate to the profile page
  2. Verify that profile information is displayed correctly
  3. Check that all profile sections are visible
- **Test Data**: N/A
- **Expected Results**: Profile page displays user's information correctly
- **Actual Results**: 

### Test Case 7.2: Edit Profile Information
- **Test Case ID**: TC_PROFILE_002
- **Description**: Verify that user can edit their profile information
- **Preconditions**: User is on their profile page
- **Test Steps**:
  1. Click on edit profile button
  2. Modify profile information
  3. Save changes
- **Test Data**: Updated profile information
- **Expected Results**: Profile information is updated successfully
- **Actual Results**: 

### Test Case 7.3: Update Profile Picture
- **Test Case ID**: TC_PROFILE_003
- **Description**: Verify that user can update their profile picture
- **Preconditions**: User is on their profile page
- **Test Steps**:
  1. Click on profile picture or edit button
  2. Select a new image file
  3. Upload the new profile picture
- **Test Data**: Valid image file
- **Expected Results**: Profile picture is updated successfully
- **Actual Results**: 

### Test Case 7.4: View Other User Profiles
- **Test Case ID**: TC_PROFILE_004
- **Description**: Verify that users can view other users' profiles
- **Preconditions**: User is logged in and knows another user's profile
- **Test Steps**:
  1. Navigate to another user's profile page
  2. Verify that their public information is displayed
- **Test Data**: Another user's profile URL
- **Expected Results**: Other user's public profile information is displayed
- **Actual Results**: 

---

## Page 8: Forgot Password Page

### Test Case 8.1: Request Password Reset
- **Test Case ID**: TC_FP_001
- **Description**: Verify password reset request functionality
- **Preconditions**: On forgot password page
- **Test Steps**:
  1. Enter registered email address
  2. Submit the password reset request
  3. Verify success message appears
- **Test Data**: 
  - Email: `photo@tfp.local`
- **Expected Results**: Password reset email is sent with confirmation message
- **Actual Results**: 

### Test Case 8.2: Request Reset for Non-existent Email
- **Test Case ID**: TC_FP_002
- **Description**: Verify behavior when requesting reset for non-existent email
- **Preconditions**: On forgot password page
- **Test Steps**:
  1. Enter non-existent email address
  2. Submit the password reset request
- **Test Data**: 
  - Email: `nonexistent@test.com`
- **Expected Results**: Generic success message appears (without revealing if email exists)
- **Actual Results**: 

### Test Case 8.3: Empty Email Field Validation
- **Test Case ID**: TC_FP_003
- **Description**: Verify validation when email field is empty
- **Preconditions**: On forgot password page
- **Test Steps**:
  1. Leave email field empty
  2. Submit the form
- **Test Data**: 
  - Email: (empty)
- **Expected Results**: Error message appears requesting email input
- **Actual Results**: 

---

## Page 9: Reset Password Page

### Test Case 9.1: Successful Password Reset
- **Test Case ID**: TC_RP_001
- **Description**: Verify successful password reset with valid token
- **Preconditions**: User has received password reset email with valid token
- **Test Steps**:
  1. Navigate to reset password page with valid token
  2. Enter new password
  3. Confirm new password
  4. Submit the form
- **Test Data**: Valid reset token, new password
- **Expected Results**: Password is reset successfully with confirmation message
- **Actual Results**: 

### Test Case 9.2: Password Reset with Invalid Token
- **Test Case ID**: TC_RP_002
- **Description**: Verify error handling with invalid/expired token
- **Preconditions**: On reset password page
- **Test Steps**:
  1. Enter invalid or expired token
  2. Enter new password
  3. Submit the form
- **Test Data**: Invalid/expired token
- **Expected Results**: Error message appears indicating invalid or expired token
- **Actual Results**: 

### Test Case 9.3: Password Mismatch Validation
- **Test Case ID**: TC_RP_003
- **Description**: Verify validation when passwords don't match
- **Preconditions**: On reset password page
- **Test Steps**:
  1. Enter mismatched passwords in the new password fields
  2. Submit the form
- **Test Data**: 
  - New Password: `NewPassword123!`
  - Confirm Password: `DifferentPassword456!`
- **Expected Results**: Error message appears indicating passwords do not match
- **Actual Results**: 

---

## Page 10: Admin Pages

### Test Case 10.1: Access Admin Dashboard
- **Test Case ID**: TC_ADMIN_001
- **Description**: Verify admin user can access admin dashboard
- **Preconditions**: Admin user is logged in
- **Test Steps**:
  1. Log in with admin credentials
  2. Navigate to admin section
  3. Verify admin dashboard loads
- **Test Data**: 
  - Email: `admin@tfp.local`
  - Password: `Seed123!`
- **Expected Results**: Admin dashboard is accessible with admin controls
- **Actual Results**: 

### Test Case 10.2: Moderate Content
- **Test Case ID**: TC_ADMIN_002
- **Description**: Verify admin can moderate user-generated content
- **Preconditions**: Admin user is on admin dashboard
- **Test Steps**:
  1. Navigate to content moderation section
  2. Review flagged content
  3. Approve or reject content as appropriate
- **Test Data**: Flagged content requiring review
- **Expected Results**: Admin can approve/reject content with changes saved
- **Actual Results**: 

---

## Page 11: Search Functionality

### Test Case 11.1: Search for Content
- **Test Case ID**: TC_SEARCH_001
- **Description**: Verify search functionality works correctly
- **Preconditions**: User is on search page or has search bar access
- **Test Steps**:
  1. Enter search query in search field
  2. Execute search
  3. Verify relevant results are displayed
- **Test Data**: Search term (e.g., "photography")
- **Expected Results**: Search results page displays relevant content
- **Actual Results**: 

### Test Case 11.2: Search with Special Characters
- **Test Case ID**: TC_SEARCH_002
- **Description**: Verify search handles special characters properly
- **Preconditions**: On search page
- **Test Steps**:
  1. Enter search query with special characters
  2. Execute search
- **Test Data**: Search term with special characters (e.g., "photo&graphy!")
- **Expected Results**: Search executes without errors and returns relevant results
- **Actual Results**: 

---

## Page 12: Messages/Notifications

### Test Case 12.1: View Notifications
- **Test Case ID**: TC_NOTIFY_001
- **Description**: Verify user can view their notifications
- **Preconditions**: User is logged in and has notifications
- **Test Steps**:
  1. Navigate to notifications page
  2. Verify notifications are displayed
- **Test Data**: N/A
- **Expected Results**: List of notifications is displayed correctly
- **Actual Results**: 

### Test Case 12.2: Send Message
- **Test Case ID**: TC_MSG_001
- **Description**: Verify user can send a message to another user
- **Preconditions**: User is logged in
- **Test Steps**:
  1. Navigate to messaging page
  2. Select recipient
  3. Compose and send message
- **Test Data**: Recipient and message content
- **Expected Results**: Message is sent successfully
- **Actual Results**: 

---

## Cross-Cutting Functional Tests

### Test Case CC_001: Logout Functionality
- **Test Case ID**: TC_CC_001
- **Description**: Verify user can log out successfully
- **Preconditions**: User is logged in
- **Test Steps**:
  1. Click on logout button or link
  2. Confirm logout if prompted
- **Test Data**: N/A
- **Expected Results**: User is logged out and redirected to login/home page
- **Actual Results**: 

### Test Case CC_002: Responsive Design
- **Test Case ID**: TC_CC_002
- **Description**: Verify application responsiveness across devices
- **Preconditions**: Application is running
- **Test Steps**:
  1. Open application on desktop
  2. Resize browser window to simulate mobile/tablet
  3. Test on actual mobile device if possible
- **Test Data**: Various screen sizes (mobile: 375x667, tablet: 768x1024)
- **Expected Results**: Layout adapts properly to different screen sizes
- **Actual Results**: 

### Test Case CC_003: Error Page Handling
- **Test Case ID**: TC_CC_003
- **Description**: Verify proper error page handling for invalid URLs
- **Preconditions**: Application is running
- **Test Steps**:
  1. Enter an invalid URL in the address bar
  2. Verify custom error page is displayed
- **Test Data**: Invalid URL (e.g., `/nonexistent-page`)
- **Expected Results**: Custom 404 error page is displayed with helpful information
- **Actual Results**: 

### Test Case CC_004: Session Timeout
- **Test Case ID**: TC_CC_004
- **Description**: Verify behavior when session expires
- **Preconditions**: User is logged in
- **Test Steps**:
  1. Leave application idle for extended period (beyond session timeout)
  2. Attempt to perform an action requiring authentication
- **Test Data**: Idle time exceeding session timeout
- **Expected Results**: User is redirected to login page with appropriate message
- **Actual Results**: 

### Test Case CC_005: Legal Pages Accessibility
- **Test Case ID**: TC_CC_005
- **Description**: Verify legal pages (terms, privacy, guidelines) are accessible
- **Preconditions**: Application is running
- **Test Steps**:
  1. Navigate to terms of service page
  2. Navigate to privacy policy page
  3. Navigate to community guidelines page
- **Test Data**: N/A
- **Expected Results**: All legal pages load and display content correctly
- **Actual Results**: 

---

## Edge Cases and Negative Tests

### Test Case EC_001: Rapid Form Submissions
- **Test Case ID**: TC_EC_001
- **Description**: Verify application handles rapid form submissions gracefully
- **Preconditions**: On any form page
- **Test Steps**:
  1. Fill in a form completely
  2. Rapidly click the submit button multiple times
- **Test Data**: Valid form data
- **Expected Results**: Form submits only once, preventing duplicate submissions
- **Actual Results**: 

### Test Case EC_002: Large File Upload
- **Test Case ID**: TC_EC_002
- **Description**: Verify error handling when uploading oversized files
- **Preconditions**: On a page allowing file uploads
- **Test Steps**:
  1. Select a file larger than the allowed size limit
  2. Attempt to upload the file
- **Test Data**: File exceeding size limits (e.g., 50MB when limit is 10MB)
- **Expected Results**: Clear error message indicating file size exceeded
- **Actual Results**: 

### Test Case EC_003: Invalid File Type Upload
- **Test Case ID**: TC_EC_003
- **Description**: Verify error handling when uploading unsupported file types
- **Preconditions**: On a page allowing file uploads
- **Test Steps**:
  1. Select an unsupported file type (e.g., .exe, .bat)
  2. Attempt to upload the file
- **Test Data**: Unsupported file type
- **Expected Results**: Clear error message indicating unsupported file type
- **Actual Results**: 

### Test Case EC_004: Network Interruption During Action
- **Test Case ID**: TC_EC_004
- **Description**: Verify behavior when network connection is lost during an action
- **Preconditions**: Performing an action that requires server communication
- **Test Steps**:
  1. Start an action that communicates with the server
  2. Simulate network interruption mid-process
  3. Observe application behavior
- **Test Data**: N/A
- **Expected Results**: Appropriate error message is displayed, no data corruption occurs
- **Actual Results**: 

### Test Case EC_005: Browser Back Button
- **Test Case ID**: TC_EC_005
- **Description**: Verify browser back button behavior throughout the application
- **Preconditions**: Navigated to a subsequent page from a previous page
- **Test Steps**:
  1. Navigate to several pages in sequence
  2. Use browser back button to return
  3. Verify proper state management
- **Test Data**: N/A
- **Expected Results**: Back button returns to previous states correctly
- **Actual Results**: 