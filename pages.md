TFP Platform: Production Architecture & Implementation Blueprint

This document is the master blueprint for converting the HTML/Vanilla JS UI mockups into a dynamic, production-ready frontend framework (e.g., Next.js, Astro, or Nuxt). It defines the routing structure, component reusability matrix, SCSS architecture, API integration points, and the strict Progressive Enhancement strategy.

1. Dynamic Page Routing Strategy

The Single Page Application (SPA) mockups using CSS :target must be converted into a scalable, file-based routing architecture using Server-Side Rendering (SSR).

Mockup View (#hash)

Dynamic Route Path

Page Responsibility & Data Fetching

#home

/

Home Dashboard: Fetches top trending projects, contests, and events.

#project

/projects

Project Listing: Server-side paginated list of active projects.

#project-detail

/projects/[projectId]

Project Detail: Fetches specific project by ID. Includes ProjectApplication form data.

#create-project

/projects/create

Creation Form: Gated route. Submits POST /api/projects.

#contest

/contests

Contest Listing: Displays upcoming and active contests.

#contest-detail

/contests/[contestSlug]

Contest Detail: Fetches contest brief and top 3 submissions.

#contest-gallery

/contests/[contestSlug]/gallery

Full Gallery: Infinite scroll or paginated view of all ContestSubmission records.

#events

/events

Event Listing: Calendar view of upcoming events.

#event-detail

/events/[eventId]

Event Detail: Fetches event data and EventRSVP user list.

#profile

/profile/[username]

Public Profile: Dynamically loads user info, portfolio images, and created posts.

#edit-profile

/settings/profile

Private Settings: Gated route to edit User model data.

#activity

/notifications

Activity Hub: Real-time feed of user's application statuses and RSVPs.

#admin-queue

/admin/moderation

Admin Dashboard: Gated route (Role: ADMIN). Fetches pending entities.

2. Component Reusability Matrix

To keep the codebase DRY (Don't Repeat Yourself), extract the following logical UI pieces into reusable components that accept dynamic props.

1. MediaCard (Generic Glassmorphic Card)

Props: imageSrc, title, subtitle, badgeText, badgeColor, href.

Reuse Locations: Home Bento Grid, Project Listing, Contest Listing, Profile "Saved Projects".

2. SubmissionThumbnail (Aspect 4/5 Image + Hover Actions)

Props: imageUrl, authorHandle, authorAvatar, voteCount, rank, isInteractive.

Reuse Locations: Contest Detail, Contest Gallery, Profile "Contest Entries".

3. LocationAutocomplete (Smart Input)

Props: onLocationSelect, placeholder, defaultValue.

Behavior: Handles user input with a debounce timer (e.g., 300ms). Queries a location API, displays a dropdown of results, and upon selection, reveals an interactive map component.

Reuse Locations: Create Project, Create Event, Edit Profile.

4. StagedImageUpload (Drag & Drop Zone)

Props: maxFiles, acceptType, onUploadComplete.

Behavior: Handles local staging, renders previews instantly via URL.createObjectURL, and returns file blobs.

Reuse Locations: Create Project (Moodboard), Create Event (Cover), Contest Detail (Submission), Edit Profile (Avatar).

5. AdminReviewModal (Moderation Overlay)

Props: entityType (Project/Event), details (Object), onApprove, onReject.

Behavior: Displays the full context of a pending submission so the admin doesn't have to leave the queue.

3. SCSS Architecture & Breakpoints

To implement the mobile-first compression scaling seen in the mockups, structure your CSS/SCSS into a modular pattern.

_variables.scss (Design Tokens)

:root {
  --bg-base: #0F1115;
  --surface-glass: rgba(255, 255, 255, 0.03);
  --surface-glass-border: rgba(255, 255, 255, 0.08);
  --accent-primary: #6F4BFF;
  --accent-secondary: #A36BFF;
  --accent-cyan: #A3FFFF;
}


_components.scss (Core UI Primitives)

.tfp-glass-card {
  background-color: var(--surface-glass);
  backdrop-filter: blur(12px);
  border: 1px solid var(--surface-glass-border);
  border-radius: 1rem;
  padding: 1rem; // Compact mobile padding
  transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);

  @media (min-width: 768px) {
    padding: 1.5rem; // Expands on desktop
    border-radius: 1.5rem; 
  }

  &.interactive:hover {
    border-color: rgba(111, 75, 255, 0.8);
    box-shadow: 0 8px 32px rgba(111, 75, 255, 0.15);
    transform: translateY(-2px);
  }
}


4. API Integration Map & Data Flow

To power the frontend components, the backend must expose the following critical endpoints:

Authentication & Session:

POST /api/auth/login - Returns JWT/Session and User Role (USER or ADMIN).

GET /api/auth/me - Hydrates the UI with the current user context.

Location Services:

GET /api/locations/search?q={query} - Called by the LocationAutocomplete component. Returns an array of matching cities/coordinates to populate the dropdown.

Upload Staging (Two-Step Flow):

POST /api/upload/stage - Uploads files to a temporary bucket (/temp) before a form is submitted. Returns temp URLs to render in the UI.

POST /api/projects - When the main form is submitted, it passes the temp URLs. The backend moves them to permanent storage.

Admin Moderation:

GET /api/admin/queue - Fetches entities where status === PENDING.

POST /api/admin/moderate - Accepts { entityId, type, action: 'APPROVE' | 'REJECT' }.

5. Progressive Enhancement Strategy (JS Enabled vs. JS Disabled)

All interactive flows must be built with a Server-Side Rendered (SSR) HTML Baseline, progressively enhanced by JavaScript.

A. Routing & Modals (Authentication, Lightbox)

JS Disabled: Elements like "Join Now" act as standard HTML <a> tags pointing to dedicated SSR pages (e.g., <a href="/login">).

JS Enabled: Global click listeners intercept the links (event.preventDefault()) and render the route's content inside an HTML5 <dialog> overlay or React Portal.

B. Location Autocomplete

JS Disabled: The location field renders as a standard <input type="text" name="location" required>. The user must manually type their city, and the server processes the exact string.

JS Enabled: The input attaches an onKeyUp debouncer. It fetches real-time suggestions, displays the dropdown menu, and automatically injects an interactive map preview.

C. Mutations (Voting, Event RSVPs, Admin Approvals)

JS Disabled: The "Like" or "Going" button is wrapped in a <form method="POST">. Clicking it causes a full page reload, after which the server renders the button in its active state.

JS Enabled: The <form> submission is prevented. Optimistic UI instantly changes the button color locally. The network request happens in the background.

D. File Uploads (Moodboards, Contest Entries)

JS Disabled: Renders a standard <input type="file" multiple accept="image/*" />. The user sees the browser's native file picker.

JS Enabled: The native input is hidden and wrapped in a styled drag-and-drop <label> zone. Uses URL.createObjectURL() to instantly render thumbnail previews.