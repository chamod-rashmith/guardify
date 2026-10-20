# Contributing to Guardify 🛡️

First off, thank you for considering contributing to **Guardify**! 🎉 

Open-source projects thrive on community contributions, whether it's fixing a bug, adding new features, improving documentation, or reporting issues. This guide will help you get set up and guide you through the contribution process.

---

## 📜 Code of Conduct

We are committed to providing a friendly, safe, and welcoming environment for everyone, regardless of experience level, gender identity, ethnicity, or background. Please treat all contributors with respect, empathy, and kindness.

---

## 🌿 Branching Model & Workflow

To maintain stability and continuous delivery, Guardify follows a Git Flow-inspired branching strategy:

- **`main`**: Production releases. Every commit on `main` matches a published package version on [pub.dev](https://pub.dev/packages/guardify).
- **`dev`**: The active integration branch. **All new pull requests should target `dev`** (not `main`).
- **Feature Branches**: Branch out from `dev` using clear naming conventions:
  - `feat/animated-transitions`
  - `fix/matrix-export-null-check`
  - `docs/clarify-pbac-usage`

```
main (v1.2.0) ───●────────────────────────────● (v1.3.0 Release)
                  \                          /
dev                ●───●───────●────────────●
                        \     /
feature/my-feature       ●───●
```

---

## 💻 Setting Up Your Local Development Environment

### 1. Prerequisites
- **Flutter SDK**: `>=3.0.0`
- **Dart SDK**: `>=3.0.0 <4.0.0`
- **Git**

### 2. Fork and Clone
1. Fork the [Guardify Repository](https://github.com/chamod-rashmith/guardify) on GitHub.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/guardify.git
   cd guardify
   ```
3. Checkout the `dev` branch:
   ```bash
   git checkout dev
   ```
4. Create your feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```

### 3. Install Dependencies
```bash
flutter pub get
```

---

## 🛠️ Development & Testing Workflow

### 1. Code Generation
If you make changes to annotations or the code generator (`lib/src/generator/`), regenerate code using:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Running the ACM CLI Tool
When testing or working on the Access Control Matrix CLI tool:
```bash
# Run CLI on the example folder
dart run bin/matrix.dart --path=example

# Run CLI with markdown formatting
dart run bin/matrix.dart --path=example --format=markdown
```

### 3. Running Static Analysis
Guardify adheres to strict Dart analysis rules. Ensure there are **zero warnings and zero errors**:
```bash
dart analyze
```

### 4. Running the Test Suite
Every new feature or bug fix **must** be accompanied by comprehensive tests in the `test/` directory.
Run the full test suite before committing:
```bash
flutter test
```

### 5. Formatting Code
Follow the official Dart formatting standards:
```bash
dart format .
```

---

## 📝 Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) standard. This makes commit history structured, meaningful, and easy to parse for automated changelogs.

### Format:
`<type>(<optional scope>): <description in imperative mood>`

### Examples:
- `feat(runtime): add AnimatedSwitcher transitions for RoleGate`
- `fix(cli): handle empty allowedRoles list during AST scan`
- `docs(readme): add troubleshooting section for build_runner`
- `test(generator): add tests for generic class parameters`
- `refactor(scope): optimize InheritedWidget notification checks`

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.

---

## 🚀 Submitting a Pull Request (PR)

1. Push your branch to your forked repository:
   ```bash
   git push -u origin feat/your-feature-name
   ```
2. Open a Pull Request against the **`dev`** branch of `chamod-rashmith/guardify`.
3. Provide a clear title and description of your changes:
   - What problem does this PR solve?
   - What approach did you take?
   - Link any related GitHub issues (`Fixes #12`).
4. Complete the PR Checklist:
   - [ ] My code follows the project's formatting and style standards (`dart format .`).
   - [ ] Static analysis passes with zero warnings (`dart analyze`).
   - [ ] All tests pass successfully (`flutter test`).
   - [ ] Unit or widget tests have been added for any new code.
   - [ ] Documentation (`README.md`, doc comments `///`) is updated if applicable.
   - [ ] Target branch is set to `dev`.

---

## 🐛 Reporting Bugs & Requesting Features

- **Reporting Bugs**: Open an issue on GitHub. Please include:
  - A clear and descriptive title.
  - Steps to reproduce the bug.
  - Expected behavior vs. actual behavior.
  - Dart and Flutter SDK versions (`flutter --version`).
  - Minimal reproducible code snippet if possible.

- **Requesting Features**: We'd love to hear your ideas! Check out [ROADMAP.md](ROADMAP.md) first to see if it's already planned, then open an issue with the `enhancement` label describing the use case and desired API design.

---

## ❤️ Thank You!

Thank you for helping make **Guardify** the premier access control and UI security library for Flutter! 🛡️🚀
