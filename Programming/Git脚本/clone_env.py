import os
import pathlib
import shutil
import subprocess

env_dir = pathlib.Path(__file__).resolve().parent
os.chdir(env_dir)

repo_url = "https://github.com/Lujiang0111/env.git"
repo_dir = pathlib.Path(repo_url).stem

if os.path.exists(repo_dir):
    shutil.rmtree(repo_dir)

subprocess.run(["git", "clone", repo_url, repo_dir], check=True)

os.chdir(repo_dir)
subprocess.run(["python3", "generate_env.py"], check=True)

print("clone done.")
