# ConnectIn

A SwiftUI app that connects mentors with anyone seeking guidance — students, recent grads, and career-changers alike. Mentees subscribe for $4.99/month; mentors join for free, forever.

---

## Features

ConnectIn is a two-sided marketplace with parallel, role-aware experiences. Below is the full feature catalog grouped by area. Anything marked _Pro_ is gated behind the mentee subscription — mentors get every feature without paying.

### Authentication & onboarding

- **Splash → Login → Signup** flow with form validation and a triple-tap escape hatch on the splash logo to enter **Demo Mode** (auto-seeds sample data + an active Pro trial).
- **Role selection** screen with two side-by-side cards: **Mentee** (anyone looking for guidance) and **Mentor** (free, forever).
- **Two parallel 3-step onboarding flows**:
  - Mentee: basic info → interests → goals
  - Mentor: basic info (role, company, years) → expertise → mentorship style (availability, capacity, why I mentor)
- **Inclusive mentee onboarding**: school/company is optional, and graduation year + first-gen options only appear if the user marks themselves as a current student.
- **Persistent session**: auth state, profile, connections, sessions, milestones, quiz result, and subscription all survive app restarts via `UserDefaults`.

### Mentee experience

- **Discovery dashboard** with greeting, subscription banner, your-mentor card, progress snapshot, quick stats, and suggested mentors ranked by match percentage.
- **Browse Mentors** with mentor cards (photo, role, expertise tags, match %, _verified_ badge for credentialed mentors).
- **Mentor detail view** with full bio, expertise, ways-they-help, availability boundaries, and stats.
- **Connection request sheet** (_Pro_) with **pre-built message templates** so no one faces blank-page anxiety.
- **Compatibility quiz** — 5-question questionnaire that updates a personalized match score and writes the result back into the matching pipeline.
- **Subscription management** card with $4.99/mo plan, trial countdown, renewal info, and one-tap cancellation.
- **Goal setting** during onboarding (broad options: land my first role, switch careers, build network, learn skills, work-life balance).

### Mentor experience

- **Mentor dashboard** (separate from the mentee dashboard) with:
  - "Free forever for mentors" celebratory banner
  - **Impact card**: active mentees, completed sessions, hours given, milestones celebrated
  - **Mentee Requests** queue with Accept / Decline buttons + toast feedback
  - **Active Mentees** list with last-note, sessions held, and time connected
  - **Recent Wins** feed showing milestone unlocks
- **Verified credential badge** displayed on the mentor's card and detail view once an admin confirms their role + company.
- **Availability & boundary settings** captured during onboarding (preset chips like "Evenings only" + freeform), plus a max-mentees capacity to prevent burnout.
- **Profile shows "Mentor account · Free"** instead of subscription card; matching quiz is hidden (mentors aren't being matched, they're matching others).

### Sessions tab (4th tab)

- **Structured session templates** library (resume review, mock interview, career roadmap, etc.) so meetings always have an agenda and suggested goals.
- **Schedule a session** sheet — pick a template, mentor, date, and time.
- **Session detail view** — see agenda + goals, mark complete (auto-creates a milestone), or cancel.
- **Upcoming / past sessions** lists, sorted chronologically, with badge count on the tab bar.
- **Progress dashboard card** at the top of the tab — completed sessions, total minutes mentored, milestones achieved.
- **Milestone tracking** — wins are auto-recorded when sessions complete, plus a feed of all achievements (categorized: session, goal, application, skill).
- **Membership pill** — mentors see a static green "Free" badge; mentees see a dynamic "Try Pro / Trial · Xd / Pro / Renew" pill that opens the paywall.

### Profile

- **Role-aware profile header** with photo, name, role badge (Mentee / Mentor), and contextual subtitle ("School · Field" for mentees, "Job Title · Company" for mentors).
- **Profile completion banner** with percentage and a list of missing sections — adapts to role.
- **Editable everywhere** — single edit sheet that conditionally renders mentee or mentor fields.
- **Sections**: About, Details (role-specific), Interests / Expertise, Goals / Ways I help, Settings.
- **Compatibility quiz card** (mentees only) to retake the quiz at any time.
- **Membership card** (mentees) or "Mentor account · Free" card (mentors).
- **Reset Demo** action wipes connections, sessions, and milestones back to seed data.

### Subscription & paywall ($4.99/mo, mentees only)

- **Free trial** with countdown to renewal.
- **Paywall view** with feature highlights, plan comparison, and trial CTA.
- **Gated actions** for non-subscribers: connecting with a mentor, scheduling a session, browsing templates beyond the shortlist.
- **Mentors bypass all gates** via `AppState.hasPremiumAccess` (always `true` for `.mentor`).
- **Subscription state** persists across launches with status (`none` / `trialing` / `active` / `expired`), start date, and renewal date.

### Theme & design system

- **Shades of purple + white** palette (deep royal-purple, vibrant violet, lavender-tinted whites).
- **Reusable components**: `CustomTextField`, `PrimaryButton`, `MentorCard`, `ProfileHeader`, `TagView`, `StepProgressBar`, `Toast`, `InterestChip`, `ExpertiseChip`, `GoalCard`, `RoleCard`, `MentorAvatarBubble`, `StatCard`, `ProfileSection`, and a custom `TagFlowLayout`.
- **Consistent semantic tokens** for primary, secondary, accent, success, error, dividers, borders, and surfaces — defined in `Theme/AppTheme.swift`.
- **Animations & haptics** — smooth transitions between phases and `sensoryFeedback` on key actions.

### Architecture

- **Centralized state**: `AppState` (auth + subscription + quiz + tab routing), `ConnectionsManager` (pending / accepted / declined), `SessionsManager` (sessions + milestones), `ProfileViewModel` (onboarding-time form state).
- **Phase-based root routing** — a single `Phase` enum (`.loggedOut` / `.onboarding` / `.loggedIn`) is the source of truth for top-level navigation.
- **Backwards-compatible role rename** — `UserRole.mentee` keeps `rawValue = "student"` so previously-saved profiles still decode.
- **Demo Mode** — pre-populated mentor catalog, sample sessions, milestones, and an active Pro trial, gated behind a triple-tap on the splash logo.

### Tech stack

- **SwiftUI** + **Combine** (`@StateObject`, `@EnvironmentObject`, `@Published`, `NavigationStack`, `TabView`)
- **Persistence**: `UserDefaults` with `JSONEncoder` / `JSONDecoder`
- **iOS** target (built and tested against iPhone Simulator on iOS 26.4)

---

## Git vs GitHub (in one minute)

- **Git** runs on your computer. It tracks changes to files, saves snapshots called **commits**, and lets you work on separate **branches** without stepping on each other’s work.
- **GitHub** is a website that hosts a copy of the project online. You **push** your commits there so others can see them, and you open **pull requests** to propose changes before they go into the main codebase.

You use both: Git locally, GitHub to share and review.

---

## Before you start

1. **Install Git**  
   - Mac: Git often comes with Xcode Command Line Tools. In Terminal, run `git --version`. If it prompts to install tools, accept.  
   - Or install from [git-scm.com](https://git-scm.com/downloads).

2. **Create a GitHub account** at [github.com](https://github.com) if you don’t have one.

3. **Ask a teammate** to add you as a **collaborator** on the GitHub repository (Settings → Collaborators), or get the repo link if it’s public.

4. **Tell Git who you are** (one time per computer). In Terminal:

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

   Use the **same email** you use on GitHub (or add that email in GitHub → Settings → Emails).

---

## Get the project on your machine (clone)

1. Open **Terminal** (Mac: Spotlight → type “Terminal”).
2. Go to the folder where you keep projects, for example:

   ```bash
   cd ~/Desktop
   ```

3. **Clone** the repository (creates a `ConnectIn` folder with the code):

   ```bash
   git clone https://github.com/fathima-kk/ConnectIn.git
   cd ConnectIn
   ```

   If the team uses **SSH** instead of HTTPS, they will give you a different URL (`git@github.com:...`).

4. Open **`ConnectIn.xcodeproj`** in Xcode from this `ConnectIn` folder.

---

## The branch habit (very important)

The **`main`** branch should stay stable. **Do not commit directly to `main` if your team agreed to use pull requests.**

Instead, always create a **feature branch** for your work:

```bash
git checkout main
git pull origin main
git checkout -b your-name-short-description
```

Examples of branch names: `ali-login-validation`, `sara-profile-ui`.

---

## Daily workflow: make changes → commit → push

1. **Start fresh** (get others’ latest work):

   ```bash
   git checkout main
   git pull origin main
   git checkout your-branch-name    # or create a new branch as above
   ```

2. **Edit files** in Xcode or any editor.

3. **See what changed:**

   ```bash
   git status
   ```

4. **Stage** files you want in this commit:

   ```bash
   git add .
   ```

   Or pick specific files: `git add ConnectIn/SomeFile.swift`

5. **Commit** with a short, clear message:

   ```bash
   git commit -m "Add validation to signup form"
   ```

6. **Push** your branch to GitHub (first time for this branch):

   ```bash
   git push -u origin your-branch-name
   ```

   Next times on the same branch:

   ```bash
   git push
   ```

---

## Open a pull request (PR)

A **pull request** means: “Please review my branch and merge it into `main`.”

1. Push your branch (see above).
2. Open the repo in the browser:  
   [https://github.com/fathima-kk/ConnectIn](https://github.com/fathima-kk/ConnectIn)
3. GitHub often shows a yellow bar **“Compare & pull request”** — click it.  
   If not: **Pull requests** tab → **New pull request** → set **base: `main`** and **compare: your branch** → **Create pull request**.
4. Write a **title** and a few sentences: **what** you changed and **why**.
5. Request **reviewers** (teammates) if your team uses that.
6. After approval, someone (or you, if allowed) clicks **Merge pull request**.

Then everyone should update their local `main`:

```bash
git checkout main
git pull origin main
```

---

## Staying in sync while others work

- Before you start coding for the day: `git checkout main` then `git pull origin main`.
- If your **feature branch** is old and `main` moved forward, update your branch:

  ```bash
  git checkout your-branch-name
  git merge main
  ```

  Resolve any conflicts (Git will mark files; ask the team the first few times if needed), then commit and push.

---

## If something goes wrong (common cases)

| Situation | What to try |
|-----------|-------------|
| **“Permission denied”** when pushing | You need collaborator access, or sign in to GitHub (HTTPS: use a **Personal Access Token** as password when prompted; or set up SSH keys). |
| **“Merge conflict”** | Open the marked files, choose the correct code, remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), then `git add` those files and `git commit`. |
| **Committed on `main` by mistake** | Tell a teammate; you can often fix by moving work to a new branch before pushing, or revert on GitHub with help. Don’t force-push unless the team agrees. |
| **Wrong files in commit** | Before push: `git reset HEAD~1` (undoes last commit but keeps files). Ask for help if you already pushed. |

When in doubt, **ask in the group chat** before running commands you found online—especially anything with `force` or `hard`.

---

## Optional: GitHub Desktop

If Terminal feels intimidating, [GitHub Desktop](https://desktop.github.com/) can clone, branch, commit, and push with buttons. The **ideas** (branch → commit → push → PR) are the same.

---

## Quick cheat sheet

| Goal | Command |
|------|---------|
| Copy repo | `git clone <url>` |
| Current branch / changes | `git status` |
| New branch | `git checkout -b branch-name` |
| Switch branch | `git checkout branch-name` |
| Download latest `main` | `git pull origin main` |
| Save snapshot | `git add .` then `git commit -m "message"` |
| Upload branch | `git push -u origin branch-name` (first time) |

---

Welcome to the team—small commits and clear PR descriptions make everyone’s life easier.
