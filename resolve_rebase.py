import subprocess
import time
import os

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True)

def resolve_conflicts():
    # Get status
    res = run("git status --porcelain")
    lines = res.stdout.splitlines()
    
    for line in lines:
        if line.startswith("UU") or line.startswith("AA") or line.startswith("DU") or line.startswith("UD"):
            path = line[3:]
            
            if path.endswith(".yml") and "history/" in path and "summary.json" not in path:
                # History status files -> THEIRS
                run(f"git checkout --theirs \"{path}\"")
            elif "api/" in path or "graphs/" in path:
                 # API/Graphs -> THEIRS
                run(f"git checkout --theirs \"{path}\"")
            elif "README.md" in path or "summary.json" in path:
                # Summary files -> OURS (Keep clean)
                run(f"git checkout --ours \"{path}\"")
            else:
                # Unknown -> default to ours? or stop?
                # Default to ours to be safe, or just stop
                print(f"Unknown conflict file: {path}")
                run(f"git checkout --ours \"{path}\"") # Safe fallback

    run("git add .")

def main():
    while True:
        # Check if rebase in progress
        if not os.path.exists(".git/rebase-merge"):
            print("Rebase finished or not found!")
            break
            
        print("Resolving conflicts...")
        resolve_conflicts()
        
        print("Continuing rebase...")
        res = run("GIT_SEQUENCE_EDITOR=true git rebase --continue")
        
        if res.returncode == 0:
            print("Rebase step done.")
        else:
            print(f"Rebase step failed (conflict?): {res.stdout} {res.stderr}")
            if "No changes" in res.stdout:
                print("Empty commit, skipping...")
                run("git rebase --skip")
            
        time.sleep(0.5)

if __name__ == "__main__":
    main()
