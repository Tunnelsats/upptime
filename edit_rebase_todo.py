#!/usr/bin/env python3
import sys
import os

import json

def load_drops():
    try:
        with open("commits_to_drop.json", 'r') as f:
            return set(json.load(f))
    except FileNotFoundError:
        return set()

DROP_COMMITS = load_drops()

def main():
    if len(sys.argv) < 2:
        print("Usage: edit_rebase_todo.py <file>")
        sys.exit(1)

    filepath = sys.argv[1]
    
    with open(filepath, 'r') as f:
        lines = f.readlines()

    new_lines = []
    dropped_count = 0
    
    for line in lines:
        parts = line.strip().split()
        if not parts:
            new_lines.append(line)
            continue
            
        # Format usually: pick <hash> <message>
        # Ensure we identify lines that are actually commands
        if parts[0] in ('pick', 'reword', 'edit', 'squash', 'fixup', 'exec', 'drop'):
            commit_hash = parts[1]
            # Check if this hash (or short hash) is in our drop list
            # The rebase list usually uses short hashes, but might vary. 
            # We'll just check if our target hash starts with the one in the file or vice versa.
            should_drop = False
            for drop_h in DROP_COMMITS:
                if commit_hash.startswith(drop_h) or drop_h.startswith(commit_hash):
                    should_drop = True
                    break
            
            if should_drop:
                # Replace pick with drop
                new_lines.append(line.replace(parts[0], 'drop', 1))
                dropped_count += 1
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)

    with open(filepath, 'w') as f:
        f.writelines(new_lines)
        
    print(f"Set {dropped_count} commits to drop.")

if __name__ == "__main__":
    main()
