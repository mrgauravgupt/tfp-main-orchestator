# Project Detail Page - Mockup Implementation Guide

This document provides step-by-step instructions to make the project detail page (`/projects/[id].astro`) match the mockup design (`mockups/project-detail.html`).

---

## 📋 Overview

**Target:** [`tfp-workspace/apps/web/src/pages/projects/[id].astro`](tfp-workspace/apps/web/src/pages/projects/[id].astro)  
**Reference:** [`mockups/project-detail.html`](mockups/project-detail.html)  
**Preserved:** All existing functionality (API fetching, form submissions, authentication)

---

## 🎯 Key Differences Summary

| Feature | Current | Mockup |
|---------|---------|--------|
| Header | Standard BaseLayout | Glassmorphic sticky with blur |
| Back Button | ❌ Missing | ✅ Present |
| Date Range | ❌ Missing | ✅ Shows "Oct 14-20" |
| Mood Board | Basic grid | 5-img grid with shadows & hover |
| Roles Sidebar | Standard panel | Sticky glassmorphic card |
| Background | Solid dark | Ambient gradient blobs |
| Mobile Nav | Hamburger menu | Bottom tab bar |
| Animations | None | Fade-in, hover transitions |

---

## 📝 Step-by-Step Implementation

### Step 1: Add Back Button

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Add after line ~142 (inside the project block, before hero-card):

```astro
<!-- Back Button - Add after <div class="project-detail-page"> -->
<a href="/projects" class="back-link">
  <Icon name="arrow-left" size={18} />
  <span>Back to Projects</span>
</a>
```

**CSS to add in `<style>` block:**

```scss
.back-link {
  display: flex;
  align-items: center;
  gap: $space-2;
  color: $color-text-secondary;
  text-decoration: none;
  font-size: $text-sm;
  font-weight: $font-weight-medium;
  margin-bottom: $space-6;
  transition: color $transition-fast;
  
  &:hover {
    color: $color-text;
  }
}
```

---

### Step 2: Add Date Range to Project Metadata

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

In the hero section, add date range display. First, ensure the project data includes dates, then update the hero-meta section:

```astro
<!-- In hero-card section, update to: -->
<div class="hero-meta">
  <Badge variant={project.status === 'APPROVED' ? 'success' : 'warning'}>
    {project.status}
  </Badge>
  {locationLabel && (
    <span class="hero-meta__location">
      <Icon name="map-pin" size={14} />
      {locationLabel}
    </span>
  )}
  {project.dateRange && (
    <span class="hero-meta__date">
      {project.dateRange}
    </span>
  )}
</div>
```

**CSS:**

```scss
.hero-meta__location,
.hero-meta__date {
  display: flex;
  align-items: center;
  gap: $space-1;
  color: $color-text-secondary;
  font-size: $text-sm;
  
  svg {
    color: #A3FFFF; // Cyan accent from mockup
  }
}
```

---

### Step 3: Enhance Mood Board Gallery

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Update the mood board section to match mockup styling:

```astro
<!-- Replace the gallery section with: -->
{moodImages.length > 0 && (
  <section class="panel panel--gallery">
    <div class="moodboard-grid" class:list={[hasFeatureMoodboard ? 'moodboard-grid--feature' : 'moodboard-grid--simple']}>
      {moodImages.map((img, index) => (
        <figure 
          class="moodboard-item" 
          class:list={[
            hasFeatureMoodboard 
              ? (index === 0 ? 'moodboard-item--hero' : 'moodboard-item--small')
              : 'moodboard-item--simple'
          ]}
        >
          <img 
            src={img} 
            alt={`Mood ${index + 1}`} 
            loading="lazy" 
            width="800" 
            height="800" 
          />
        </figure>
      ))}
    </div>
  </section>
)}
```

**CSS - Update the styles:**

```scss
.moodboard-grid {
  margin-top: $space-4;
  display: grid;
  gap: $space-3;
}

.moodboard-grid--feature {
  grid-template-columns: repeat(4, minmax(0, 1fr));
  height: 24rem; // ~96px * 4 = 384px
  
  @media (max-width: 640px) {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    height: auto;
  }
}

.moodboard-item {
  overflow: hidden;
  border-radius: $radius-xl; // 1rem - larger than before
  border: none;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(0, 0, 0, 0.3);
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 700ms ease;
  }
  
  &:hover img {
    transform: scale(1.05);
  }
}

.moodboard-item--hero {
  grid-column: span 2;
  grid-row: span 2;
  min-height: 24rem; // ~384px
  
  @media (max-width: 640px) {
    min-height: 14rem;
  }
}

.moodboard-item--small {
  min-height: 11.5rem; // ~184px
  
  @media (max-width: 640px) {
    min-height: 8.5rem;
  }
}

.moodboard-item--simple {
  min-height: 14rem;
}
```

---

### Step 4: Update "Project Goals" Section

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Add proper heading structure:

```astro
<!-- Replace hero-card section with: -->
<section class="hero-card">
  <div class="hero-meta">
    <Badge variant={project.status === 'APPROVED' ? 'success' : 'warning'}>
      {project.status}
    </Badge>
    {locationLabel && (
      <span class="hero-meta__location">
        <Icon name="map-pin" size={14} />
        {locationLabel}
      </span>
    )}
    {project.dateRange && (
      <span class="hero-meta__date">
        {project.dateRange}
      </span>
    )}
  </div>
  <h1>{project.title}</h1>
  
  <!-- Add Project Goals section -->
  <div class="project-goals">
    <h3>Project Goals</h3>
    <p>{project.description}</p>
  </div>
</section>
```

**CSS:**

```scss
.project-goals {
  margin-top: $space-6;
  
  h3 {
    font-size: $text-lg;
    font-weight: $font-weight-medium;
    color: $color-text;
    margin-bottom: $space-2;
  }
  
  p {
    color: $color-text-secondary;
    line-height: $leading-relaxed;
  }
}
```

---

### Step 5: Make Roles Sidebar Sticky with Glassmorphic Style

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Update the roles sidebar section:

```astro
<aside class="content-side">
  <section class="panel panel--roles roles-card">
    <h2>Required Roles</h2>
    <ul class="roles-list">
      {(project.roles || []).map((role) => {
        const roleStatus = String(role?.status || 'OPEN').toUpperCase();
        const isOpen = roleStatus !== 'FILLED' && roleStatus !== 'CLOSED';
        return (
          <li class={`role-item ${isOpen ? '' : 'role-item--filled'}`}>
            <div class="role-item__head">
              <span>{role?.role || 'Role'}</span>
              <span class={`role-state ${isOpen ? 'role-state--open' : 'role-state--filled'}`}>
                {roleStatus}
              </span>
            </div>
            {isOpen && project.creatorId !== currentUserId && (
              <a href="#apply-form" class="role-item__cta">Apply for Role</a>
            )}
          </li>
        );
      })}
    </ul>
  </section>
</aside>
```

**CSS - Add/update styles:**

```scss
.roles-card {
  position: sticky;
  top: 6rem; // 96px from top
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  
  h2 {
    padding-bottom: $space-3;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }
}

.role-item {
  padding: $space-3;
  border-radius: $radius-lg;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.role-state--open {
  background: rgba($color-success, 0.2);
  color: #4ade80; // Brighter green
}

.role-state--filled {
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.5);
}

.role-item__cta {
  display: block;
  width: 100%;
  padding: $space-2 $space-3;
  text-align: center;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: $radius-md;
  font-size: $text-xs;
  font-weight: $font-weight-bold;
  color: $color-text;
  text-decoration: none;
  transition: background-color 120ms ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.15);
  }
}
```

---

### Step 6: Add Ambient Background Effects

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Add background effects inside the `<div class="project-detail-page">` wrapper:

```astro
<!-- Add at the very top of project-detail-page div -->
<div class="project-detail-page">
  <!-- Ambient Background -->
  <div class="ambient-bg ambient-bg--primary"></div>
  <div class="ambient-bg ambient-bg--secondary"></div>
  
  <!-- Rest of content -->
  {error ? ...
```

**CSS - Add new styles:**

```scss
.ambient-bg {
  position: fixed;
  top: 0;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  filter: blur(100px);
  pointer-events: none;
  z-index: -1;
  
  @media (min-width: 768px) {
    width: 600px;
    height: 600px;
    blur(140px);
  }
}

.ambient-bg--primary {
  left: 25%;
  background: rgba(#6F4BFF, 0.15);
  animation: pulse 4s ease-in-out infinite;
}

.ambient-bg--secondary {
  right: 25%;
  bottom: 0;
  background: rgba(#A3FFFF, 0.1);
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}
```

---

### Step 7: Add Animations (Fade In)

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

Add animation class to the main container and elements:

```astro
<!-- Add animation class to main wrapper -->
<div class="project-detail-page animate-fade-in">
```

**CSS:**

```scss
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out forwards;
}

// Stagger child elements
.hero-card {
  animation-delay: 0.1s;
}

.panel {
  animation-delay: 0.2s;
}
```

---

### Step 8: Update Content Grid Layout

**File:** `tfp-workspace/apps/web/src/pages/projects/[id].astro`

The current 2fr/1fr grid is similar, but ensure it matches:

```scss
.content-grid {
  margin-top: $space-6;
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(320px, 1fr);
  gap: $space-6;
  align-items: start;
  
  @media (max-width: 960px) {
    grid-template-columns: 1fr;
  }
}
```

---

### Step 9: Mobile Bottom Navigation

The mockup shows a bottom tab bar for mobile. This is typically handled in the BaseLayout. For project detail page, ensure proper mobile spacing:

**CSS:**

```scss
// Add to [id].astro styles
@media (max-width: 768px) {
  .project-detail-page {
    padding-bottom: 5rem; // Space for mobile nav
  }
}
```

---

### Step 10: Add Custom Scrollbar

**File:** `tfp-workspace/apps/web/src/styles/base.scss`

Add global scrollbar styles:

```scss
// Custom Scrollbar
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
}

::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  
  &:hover {
    background: rgba(255, 255, 255, 0.2);
  }
}
```

---

## 🔧 Helper: Icon Component Usage

The mockup uses Lucide icons. Ensure Icon component is imported:

```astro
---
import Icon from '../../components/Icon.astro';
---
```

Available icons from [`tfp-workspace/apps/web/src/components/Icon.astro`](tfp-workspace/apps/web/src/components/Icon.astro):
- `arrow-left` - Back button
- `map-pin` - Location
- `calendar` - Date
- `user` - Profile
- `layout-grid` - Home
- `image` - Projects
- `trophy` - Contests
- `calendar` - Events

---

## ✅ Verification Checklist

After implementation, verify:

- [ ] Back button appears and links to /projects
- [ ] Location shows with map pin icon
- [ ] Date range displays (if data available)
- [ ] Mood board has hover zoom effect
- [ ] Mood board has shadows and larger border radius
- [ ] Roles sidebar is sticky
- [ ] Roles have proper OPEN/FILLED badges
- [ ] Ambient background effects visible
- [ ] Page has fade-in animation
- [ ] Mobile layout is responsive
- [ ] All existing functionality still works

---

## 📂 Related Files

| File | Purpose |
|------|---------|
| [`mockups/project-detail.html`](mockups/project-detail.html) | Reference design |
| [`tfp-workspace/apps/web/src/pages/projects/[id].astro`](tfp-workspace/apps/web/src/pages/projects/[id].astro) | Main page file |
| [`tfp-workspace/apps/web/src/styles/pages/_detail-shared.scss`](tfp-workspace/apps/web/src/styles/pages/_detail-shared.scss) | Shared detail styles |
| [`tfp-workspace/apps/web/src/styles/tokens.scss`](tfp-workspace/apps/web/src/styles/tokens.scss) | Design tokens |
| [`tfp-workspace/apps/web/src/components/Icon.astro`](tfp-workspace/apps/web/src/components/Icon.astro) | Icon component |
| [`tfp-workspace/apps/web/src/components/Badge.astro`](tfp-workspace/apps/web/src/components/Badge.astro) | Badge component |

---

## ⚠️ Notes

1. **Date Range Data:** The mockup shows "Oct 14-20" but the current project data may not have a dateRange field. You'll need to either:
   - Add `dateRange` field to the project data/schema
   - Or derive it from `startDate`/`endDate` fields

2. **Functionality Preservation:** All changes are visual/styling only. The existing functionality for:
   - API data fetching
   - Form submissions
   - Authentication
   - User interactions
   
   ...are preserved.

3. **CSS Organization:** For production, consider moving new styles to a dedicated SCSS file like `projects-detail.scss` similar to other page-specific styles.

---

*Last updated: 2026-03-02*
