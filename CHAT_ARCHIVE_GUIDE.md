# Chat Archive System

## Quick Save Method

### Option 1: Using the Script
```bash
./save_chat.sh
```
Then paste your chat content and press `Ctrl+D` when done.

### Option 2: Direct Save with Custom Name
```bash
./save_chat.sh "session_20251113_macromanager_diagnostics.md"
```

## How to Save Chats Before Closing Codespace

### Step 1: Copy Chat Content
1. In GitHub Copilot Chat, select all conversation text
2. Copy to clipboard (Ctrl+C)

### Step 2: Run Save Script
```bash
cd /workspaces/codespaces-blank
./save_chat.sh
```

### Step 3: Paste and Save
1. Paste clipboard content (Ctrl+V or right-click paste)
2. Press `Ctrl+D` to finish
3. Script automatically:
   - Saves to `chat_archives/CHAT_LOG_YYYYMMDD_HHMMSS.md`
   - Commits to git repository
   - Shows confirmation with file size

## Saved Chat Location
All chats are saved in:
```
/workspaces/codespaces-blank/chat_archives/
```

## File Naming Convention
- Auto-generated: `CHAT_LOG_20251113_143022.md`
- Custom: Whatever name you provide

## Manual Save (Without Script)
If script doesn't work, you can manually create files:

```bash
# Create chat archives folder
mkdir -p /workspaces/codespaces-blank/chat_archives

# Create new file with timestamp
nano chat_archives/CHAT_LOG_$(date +"%Y%m%d_%H%M%S").md

# Paste content, save (Ctrl+O), exit (Ctrl+X)

# Commit to git
git add chat_archives/
git commit -m "Archive: Chat log from $(date)"
```

## Export from Codespace
Before closing codespace permanently:
```bash
cd /workspaces/codespaces-blank
git push origin main
```

## Tips
- Save chats at logical breakpoints (end of session, after major fixes)
- Use descriptive custom filenames for important sessions
- All saves are automatically committed to git
- Can view all archived chats: `ls -lh chat_archives/`
