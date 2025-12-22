import subprocess
import json

def get_commits_to_drop():
    # Get log with details
    # Format: hash|date|author|subject
    cmd = ["git", "log", "--since=2025-12-20", "--until=2025-12-24", "--format=%h|%ad|%s", "--date=short"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    lines = result.stdout.strip().split('\n')
    drop_hashes = []
    
    targets = ["2025-12-21", "2025-12-23"]
    bot_keywords = ["is down (403", "is up", "Update status summary", "Update summary in README", "Update graphs"]
    
    print(f"Scanning {len(lines)} commits...")
    
    for line in lines:
        if not line: continue
        parts = line.split('|', 2)
        if len(parts) < 3: continue
        
        chash, cdate, cmsg = parts
        
        if cdate in targets:
            # Check if it matches bot patterns
            is_bot = False
            for kw in bot_keywords:
                if kw in cmsg:
                    is_bot = True
                    break
            
            # Also catch "Update uptime metrics" if it was a bot? No, that was human on Dec 22.
            # Only match the specific patterns.
            
            if is_bot:
                print(f"Marking for drop: {chash} {cdate} {cmsg}")
                drop_hashes.append(chash)
            else:
                print(f"KEEPING: {chash} {cdate} {cmsg}")
                
    return drop_hashes

if __name__ == "__main__":
    hashes = get_commits_to_drop()
    print(f"Found {len(hashes)} commits to drop.")
    with open("commits_to_drop.json", "w") as f:
        json.dump(hashes, f)
