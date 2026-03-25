#!/usr/bin/env python3
"""
EcomNewsHQ — Claude Deploy Tool
================================
Claude uses this to write/update any file on the site.

Usage from bash_tool:
  cd /tmp/ecomnewshq-site
  python3 scripts/claude_deploy.py write "articles/new-post.html" content_string
"""
import sys, os, base64, json, subprocess, tempfile

REPO = "/tmp/ecomnewshq-site"
TOKEN_ENV = "GITHUB_TOKEN"

def git(cmd, **kw):
    return subprocess.run(f"git -C {REPO} {cmd}", shell=True, capture_output=True, text=True, **kw)

def deploy_file(rel_path, content):
    """Write content to src/rel_path, commit and push."""
    full = os.path.join(REPO, "src", rel_path.lstrip("/"))
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        f.write(content)
    git("add -A")
    git(f'commit -m "deploy: {rel_path}"')
    token = os.environ.get("GITHUB_TOKEN", "")
    remote = f"https://amzdoc93:{token}@github.com/amzdoc93/ecomnewshq-site.git"
    r = subprocess.run(f"git -C {REPO} push {remote} main", shell=True, capture_output=True, text=True)
    if r.returncode == 0:
        print(f"✅ Deployed: {rel_path}")
    else:
        print(f"❌ Push failed: {r.stderr}")
    return r.returncode == 0

if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "write":
        deploy_file(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
