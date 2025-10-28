import os
from pathlib import Path

env_dir = Path(__file__).resolve().parent
os.chdir(env_dir)

Path("3rd").mkdir(parents=True, exist_ok=True)
Path("doc").mkdir(parents=True, exist_ok=True)
Path("include").mkdir(parents=True, exist_ok=True)
Path("internal").mkdir(parents=True, exist_ok=True)
Path("src").mkdir(parents=True, exist_ok=True)