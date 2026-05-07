//
//  TestingChecklist.swift
//  ConnectIn
//
//  Manual QA checklist for the demo build. This file intentionally has no
//  runtime code — it lives in the project so the checklist ships alongside the
//  source and stays in sync with new flows.
//

/*

 ╔══════════════════════════════════════════════════════════════════╗
 ║              ConnectIn — Manual Testing Checklist                ║
 ╚══════════════════════════════════════════════════════════════════╝

 Run through this list on a real device or simulator before any demo.

 ── Auth Flow ───────────────────────────────────────────────────────
 [ ] Fresh launch shows splash for ~2 seconds, then login
 [ ] Triple-tap the splash logo enters demo mode (skips splash + auth)
 [ ] Can sign up with a new account (any valid email + 8+ char password)
 [ ] Inline validation errors appear after tapping Create Account
 [ ] Terms checkbox must be checked before Create Account is enabled
 [ ] Can log in with existing account (any non-empty email/password)
 [ ] "Forgot Password?" is present and tappable (placeholder)
 [ ] "Continue with Google" is present and tappable (placeholder)
 [ ] Logout from Profile returns to login screen
 [ ] App relaunch persists the logged-in state via UserDefaults

 ── Onboarding Flow ─────────────────────────────────────────────────
 [ ] Role Selection: only one of Student/Mentor selectable at a time
 [ ] Role card scales up + glows when selected (spring animation)
 [ ] Continue is disabled until a role is selected
 [ ] Step 1 (Basic Info) shows "Step 1 of 3" progress
 [ ] Photo picker opens confirmation dialog
 [ ] Graduation Year picker shows 2024–2030
 [ ] First-gen info button shows tooltip alert
 [ ] Continue is disabled until name + university + major are filled
 [ ] "Skip for now" completes onboarding with whatever is entered
 [ ] Step 2 (Interests): Continue disabled until 2+ interests selected
 [ ] Selected interest chips fill teal with checkmark
 [ ] Step 3 (Goals): can pick up to 3 goals (4th tap is ignored)
 [ ] Goal card visual flips (teal fill + checkmark) when selected
 [ ] Optional bio editor with character counter works
 [ ] "Complete Profile" shows loading spinner, success overlay, haptic
 [ ] After completion, lands on Home tab of main app

 ── Profile View ────────────────────────────────────────────────────
 [ ] Header shows name, role badge, university/major subtitle
 [ ] Camera button on avatar opens edit sheet
 [ ] Completion banner appears when profile is < 100%
 [ ] Banner shows percentage, progress bar, and missing-section list
 [ ] About section shows bio or "Add a bio" placeholder when empty
 [ ] Details rows show university, major, class of, and first-gen badge
 [ ] Interests TagFlowView wraps cleanly with multiple chips
 [ ] Goals list shows checkmark icons
 [ ] Edit Profile button opens edit sheet (large detent)
 [ ] Edit sheet pre-fills all current values
 [ ] Add/remove interests + goals via inline list editor
 [ ] Save persists changes via AppState.updateUser
 [ ] "Reset Demo" button only appears when isDemoMode is true
 [ ] Sign Out triggers confirmation dialog

 ── Browse Mentors ──────────────────────────────────────────────────
 [ ] List loads with 6 mentors from SampleData
 [ ] Search bar filters by name, company, job title, or expertise
 [ ] Clear (x) button appears once search has text and clears it
 [ ] "All" / "Highest Match" / "Available Now" filter chips toggle
 [ ] Highest Match sorts by matchPercentage descending
 [ ] Available Now filters mentors with capacity (currentMentees < max)
 [ ] Filter slider button opens advanced filters sheet (medium detent)
 [ ] Empty state appears when filters yield zero results
 [ ] "Clear Filters" resets to default state
 [ ] Pull-to-refresh shuffles list and fires success haptic
 [ ] Cards show match badge + connection status pill (when applicable)
 [ ] Tab badge shows count of pending requests

 ── Mentor Detail ───────────────────────────────────────────────────
 [ ] Hero shows 150x150 avatar, full name, role line, match badge
 [ ] "Why We Matched" card has teal left accent + checkmark rows
 [ ] About section renders bio text
 [ ] Expertise TagFlowView wraps long lists cleanly
 [ ] Details rows: experience, mentees count, availability
 [ ] Education rows: university, class of
 [ ] Sticky footer button below the scroll
 [ ] "Request Connection" opens sheet with 200-char message editor
 [ ] Send Request shows loading, dismisses sheet, shows success toast
 [ ] After sending, button switches to "Request Sent" disabled state
 [ ] Connected mentors show "Connected" disabled state
 [ ] Share button (top-right) opens system share sheet with deep link

 ── Dashboard / Home ────────────────────────────────────────────────
 [ ] Greeting uses first name + correct time-of-day subtitle
 [ ] If connected: Connected mentor card with Message + Schedule buttons
 [ ] If pending: "Connection Pending" card with mentor preview
 [ ] If neither: Empty state card with "Find a Mentor" button
 [ ] "Find a Mentor" + "See All" switch to the Browse tab
 [ ] Quick Stats horizontal scroll shows three cards
 [ ] Suggested mentors row scrolls horizontally
 [ ] Tapping a suggested mentor pushes Mentor Detail

 ── Tab Navigation ──────────────────────────────────────────────────
 [ ] Three tabs: Home, Browse (badge), Profile
 [ ] Each tab has its own NavigationStack (no double nav bars)
 [ ] State persists when switching tabs
 [ ] Selected tab is preserved across cold launches
 [ ] Tab tint matches AppTheme.Colors.accent

 ── Persistence (UserDefaults) ──────────────────────────────────────
 [ ] Quit + relaunch keeps user logged in
 [ ] Quit + relaunch keeps the most recent profile edits
 [ ] Quit + relaunch keeps any pending/accepted connections
 [ ] Logout clears stored state (relaunch returns to splash → login)

 ── Demo Mode ───────────────────────────────────────────────────────
 [ ] Triple-tap splash logo enters demo as Sofia immediately
 [ ] Profile shows isDemoMode-only "Reset Demo" button
 [ ] Reset Demo restores Sofia profile + seeded connections
 [ ] Logout exits demo mode (isDemoMode returns to false)

 ── Visual Consistency ──────────────────────────────────────────────
 [ ] All colors come from AppTheme.Colors
 [ ] Card padding is 16pt; horizontal screen padding is 16-20pt
 [ ] All buttons feel equally tactile (scale + haptic on press)
 [ ] Forms scroll over the keyboard, dismiss interactively
 [ ] No content hides under nav or tab bar safe areas

 */

enum TestingChecklist {}
