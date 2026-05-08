# CI Guide

This project uses GitHub Actions to run tests and frontmatter checks.

- Workflow: `.github/workflows/ci.yml`
- Local quick check:
  - `pip install -r requirements.txt`
  - `pre-commit run --all-files`
  - `python -m pytest -q`

If adding new requirements, update `requirements.txt` and ensure CI installs them.
