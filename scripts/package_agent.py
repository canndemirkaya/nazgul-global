#!/usr/bin/env python3
import argparse
import pathlib
import zipfile

def package(agent: str, outdir: str = "dist"):
    a_dir = pathlib.Path("agents")
    src_md = a_dir / f"{agent}.agent.md"
    src_yaml = a_dir / f"{agent}.agent.yaml"
    if not src_md.exists():
        raise SystemExit(f"agent markdown not found: {src_md}")
    outdir_p = pathlib.Path(outdir)
    outdir_p.mkdir(parents=True, exist_ok=True)
    dest = outdir_p / f"{agent}.zip"
    with zipfile.ZipFile(dest, "w") as z:
        z.write(src_md, arcname=src_md.name)
        if src_yaml.exists():
            z.write(src_yaml, arcname=src_yaml.name)
    print("Wrote", dest)

def _cli():
    p = argparse.ArgumentParser()
    p.add_argument("agent")
    p.add_argument("--out", default="dist")
    args = p.parse_args()
    package(args.agent, args.out)

if __name__ == "__main__":
    _cli()
