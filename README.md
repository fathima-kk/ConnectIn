# ConnectIn

A SwiftUI app for connecting mentors and learners. This README is for **new contributors** who want to use Git and GitHub together as a team.

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
