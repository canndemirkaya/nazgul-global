import re
import glob
import yaml
import pathlib

FRONT_RE = re.compile(r"^---\s*$([\s\S]*?)^---\s*$", re.M)

def extract_frontmatter(text):
    m = FRONT_RE.search(text)
    if not m:
        return None
    return yaml.safe_load(m.group(1))

def files_to_check():
    p = pathlib.Path(".")
    patterns = ["agents/*.agent.md", "prompts/*.md", "prompts/**/*.md"]
    files = set()
    for pat in patterns:
        files |= set(map(str, p.glob(pat)))
    return sorted(files)

def test_frontmatter_required_fields():
    files = files_to_check()
    assert files, "No files found to validate"
    required = ["title", "description", "author"]
    for f in files:
        txt = open(f, "r", encoding="utf-8").read()
        fm = extract_frontmatter(txt)
        assert fm, f"Missing frontmatter in {f}"
        for k in required:
            assert k in fm and fm[k], f"Missing required '{k}' in {f}"
