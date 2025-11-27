# Bash Script Improvements

This document provides a comprehensive analysis and improvement suggestions for all Bash scripts in the `bin/` directory, focusing on **Performance**, **Longevity**, and **Readability**.

---

## Table of Contents

1. [brain-sort](#binbrain-sort)
2. [braincreate-tmux](#binbraincreate-tmux)
3. [brainsearch-tmux](#binbrainsearch-tmux)
4. [github-tmux](#bingithub-tmux)
5. [qresult](#binqresult)
6. [refresh-app-daemons](#binrefresh-app-daemons)
7. [session-toggle](#binsession-toggle)
8. [sokratos-apply-theme](#binsokratos-apply-theme)
9. [sokratos-cheat-sheet](#binsokratos-cheat-sheet)
10. [sokratos-floaterminal](#binsokratos-floaterminal)
11. [sokratos-focus-mode](#binsokratos-focus-mode)
12. [sokratos-next-theme](#binsokratos-next-theme)
13. [sokratos-night-mode](#binsokratos-night-mode)
14. [sokratos-run-ollama](#binsokratos-run-ollama)
15. [sokratos-switch-nvim](#binsokratos-switch-nvim)
16. [sokratos-themes](#binsokratos-themes)
17. [sokratos-wf-recorder](#binsokratos-wf-recorder)
18. [test-script](#bintest-script)
19. [tmux-sessionizer](#bintmux-sessionizer)
20. [wf-start-recording](#binwf-start-recording)
21. [wf-stop-recording](#binwf-stop-recording)

---

## `bin/brain-sort`

### 🔁 Longevity Suggestion
**Issue:** Multiple `awk` calls to extract different fields from the same file is inefficient and harder to maintain.

**Before:**
```bash
state=$(awk -F': *' '/^State:/{print $2}' "$file")
# ... later
id=$(awk -F': *' '/^Id:/{print $2}' "$file")
```

**After:**
```bash
# Extract all metadata in a single awk pass
eval "$(awk -F': *' '
    /^State:/ { printf "state=%s\n", $2 }
    /^Id:/    { printf "id=%s\n", $2 }
' "$file")"
```

**Explanation:** Combining multiple `awk` extractions into a single pass reduces I/O overhead and makes it easier to add new fields in the future.

---

### 🚀 Performance Suggestion
**Issue:** The `for file in *.md` glob could match no files, causing an error if `nullglob` is not set.

**Before:**
```bash
for file in *.md; do
    [[ -e "$file" ]] || continue
    _sort_inbox "$file" || true
done
```

**After:**
```bash
shopt -s nullglob
for file in *.md; do
    _sort_inbox "$file" || true
done
shopt -u nullglob
```

**Explanation:** Using `nullglob` eliminates the need for the existence check inside the loop, making the code cleaner and slightly faster.

---

### 📖 Readability Suggestion
**Issue:** The `case` statement has inconsistent indentation.

**Before:**
```bash
    *)
        printf 'Warning: Unknown Id "%s" in file "%s"\n' "$id" "$file" >&2
        return 1
        ;;
esac
```

**After:**
```bash
        *)
            printf 'Warning: Unknown Id "%s" in file "%s"\n' "$id" "$file" >&2
            return 1
            ;;
    esac
```

**Explanation:** Consistent indentation improves readability and makes the code structure more apparent.

---

## `bin/braincreate-tmux`

### 🔁 Longevity Suggestion
**Issue:** Hardcoded path `/home/brouzie` makes the script non-portable.

**Before:**
```bash
FPATH="/home/brouzie/Documents/2ndBrain/inbox/$FNAME"
```

**After:**
```bash
FPATH="$HOME/Documents/2ndBrain/inbox/$FNAME"
```

**Explanation:** Using `$HOME` ensures the script works for any user without modification.

---

### 📖 Readability Suggestion
**Issue:** Repeated `if [[ $USR_CHOICE = ... ]]` checks could be consolidated into a `case` statement.

**Before:**
```bash
if [[ $USR_CHOICE == "cheatsheet" ]]; then
    # ...
fi

if [[ $USR_CHOICE = "snippets" ]]; then
    # ...
fi

if [[ $USR_CHOICE = "school" ]]; then
    # ...
fi

if [[ $USR_CHOICE = "full_notes" ]]; then
    # ...
fi
```

**After:**
```bash
case "$USR_CHOICE" in
    cheatsheet)
        read -rp "Enter command/topic: " TITLE || exit 0
        TEMPLATE="# ${TITLE}
..."
        ;;
    snippets)
        topics=("python" "bash" "cpp" "lua" "go" "sql")
        langchoice=$(printf "%s\n" "${topics[@]}" | fzf) || exit 0
        read -rp "Filename: " TITLE || exit 0
        TEMPLATE="# ${TITLE}
..."
        ;;
    school)
        # ...
        ;;
    full_notes)
        # ...
        ;;
esac
```

**Explanation:** A `case` statement is more idiomatic for pattern matching and makes the control flow clearer.

---

### 🚀 Performance Suggestion
**Issue:** Exporting `DATE` and `USR_CHOICE` is unnecessary unless they're used by child processes.

**Before:**
```bash
export USR_CHOICE
export DATE=$(date +"%Y-%m-%d")
export TITLE
```

**After:**
```bash
# Only export what's needed by envsubst or child processes
DATE=$(date +"%Y-%m-%d")
export DATE TITLE USR_CHOICE  # Only if used by envsubst
```

**Explanation:** Unnecessary exports pollute the environment. Only export variables that are actually used by subprocesses (like `envsubst`).

---

## `bin/brainsearch-tmux`

### 📖 Readability Suggestion
**Issue:** Deeply nested `while true` loops make the code hard to follow.

**Before:**
```bash
while true; do
    # ...
    case "$usr_choice" in
        snippets)
            while true; do
                # ...
                while true; do
                    # ...
                done
            done
        ;;
    esac
done
```

**After:**
```bash
# Consider breaking into functions for each category
search_snippets() {
    local langchoice fchoice
    while true; do
        langchoice=$(fd -t d --max-depth 1 . "$root/$usr_choice" --exec basename | fzf --color bw)
        [[ -z "$langchoice" ]] && return

        fchoice=$(fd -e md . "$root/$usr_choice/$langchoice" --exec basename | fzf --color bw)
        [[ -z "$fchoice" ]] && continue

        nvim "$usr_choice/$langchoice/$fchoice"
        exit 0
    done
}

# In main loop:
case "$usr_choice" in
    snippets) search_snippets ;;
esac
```

**Explanation:** Breaking into functions improves modularity and makes each section independently testable.

---

### 🚀 Performance Suggestion
**Issue:** Using `fd --exec basename` spawns a new process for each file found.

**Before:**
```bash
langchoice=$(fd -t d --max-depth 1 . "$root/$usr_choice" --exec basename | fzf --color bw)
```

**After:**
```bash
langchoice=$(fd -t d --max-depth 1 . "$root/$usr_choice" | xargs -I{} basename {} | fzf --color bw)
# Or more efficiently:
langchoice=$(fd -t d --max-depth 1 . "$root/$usr_choice" | sed 's|.*/||' | fzf --color bw)
```

**Explanation:** Using `sed` to strip paths is more efficient than spawning `basename` for each result.

---

## `bin/github-tmux`

### 🔁 Longevity Suggestion
**Issue:** Missing quotes around command substitution can cause word splitting issues.

**Before:**
```bash
cd $(tmux run "echo #{pane_current_path}")
```

**After:**
```bash
cd "$(tmux run "echo #{pane_current_path}")" || exit 1
```

**Explanation:** Always quote command substitutions to prevent word splitting and globbing issues with paths containing spaces.

---

### 🚀 Performance Suggestion
**Issue:** `tmux run` + `echo` is verbose when you can use `tmux display-message`.

**Before:**
```bash
cd $(tmux run "echo #{pane_current_path}")
```

**After:**
```bash
cd "$(tmux display-message -p '#{pane_current_path}')" || exit 1
```

**Explanation:** `tmux display-message -p` directly outputs the format string, avoiding an extra shell spawn.

---

### 📖 Readability Suggestion
**Issue:** The script could use comments explaining what it does.

**Before:**
```bash
#!/usr/bin/env bash

cd $(tmux run "echo #{pane_current_path}")
url=$(git remote get-url origin)

xdg-open "$url" || echo "No remote found"
```

**After:**
```bash
#!/usr/bin/env bash
# Open the GitHub URL for the current tmux pane's git repository

pane_path="$(tmux display-message -p '#{pane_current_path}')"
cd "$pane_path" || exit 1

url=$(git remote get-url origin 2>/dev/null) || {
    echo "No git remote found" >&2
    exit 1
}

xdg-open "$url"
```

**Explanation:** Adding comments and improved error handling makes the script self-documenting.

---

## `bin/qresult`

### 📖 Readability Suggestion
**Issue:** Commented-out code should be removed or explained.

**Before:**
```bash
SQL_DIR="$HOME/Documents/2ndBrain/.cache"

# DAILY=$(sqlite3 -column -header "$SQL_FILE" "SELECT session_type, session_count, total_hours FROM v_daily";)
#
# echo -e "---Daily---"
# printf '%s\n' "$DAILY"
#
# TOTAL=$(sqlite3 -column -header "$SQL_FILE" "SELECT SUM(duration/3600.0) AS 'Total Hours' FROM sessions";)
#
# echo -e "\n$TOTAL"

cd "$SQL_DIR" && nvim "$SQL_DIR" -c DBUIToggle
```

**After:**
```bash
#!/usr/bin/env bash
# Open the 2ndBrain SQLite database in nvim with DBUI

SQL_DIR="$HOME/Documents/2ndBrain/.cache"

cd "$SQL_DIR" && nvim "$SQL_DIR" -c DBUIToggle
```

**Explanation:** Dead code should be removed to improve clarity. Use version control to preserve history.

---

## `bin/refresh-app-daemons`

### 🔁 Longevity Suggestion
**Issue:** Background processes may not start correctly due to race conditions.

**Before:**
```bash
pkill swaync
swaync > /dev/null 2>&1 &

pkill waybar
waybar > /dev/null 2>&1 &
```

**After:**
```bash
# Kill and restart with proper waiting
pkill swaync && sleep 0.1
swaync &>/dev/null &
disown

pkill waybar && sleep 0.1
waybar &>/dev/null &
disown
```

**Explanation:** Using `disown` ensures the background processes are fully detached from the terminal. Adding a small delay prevents race conditions.

---

### 📖 Readability Suggestion
**Issue:** Consider using a function for the restart pattern.

**Before:**
```bash
pkill swaync
swaync > /dev/null 2>&1 &

pkill waybar
waybar > /dev/null 2>&1 &
```

**After:**
```bash
#!/usr/bin/env bash
# Restart desktop daemons (swaync, waybar)

restart_daemon() {
    local daemon="$1"
    pkill "$daemon" 2>/dev/null
    sleep 0.2
    "$daemon" &>/dev/null &
    disown
}

restart_daemon swaync
restart_daemon waybar
```

**Explanation:** A reusable function reduces duplication and makes it trivial to add more daemons.

---

## `bin/session-toggle`

### 🔁 Longevity Suggestion
**Issue:** SQL injection vulnerability in the INSERT statement.

**Before:**
```bash
local escaped_name="${session_name//\'/\'\'}"
sqlite3 "$DB_FILE" <<EOF
INSERT INTO sessions (session_type, duration, start_time, end_time) 
VALUES ('$escaped_name', $duration, '$start_time_readable', '$end_time_readable');
EOF
```

**After:**
```bash
# Use parameterized queries via printf or sqlite3's parameter binding
sqlite3 "$DB_FILE" "INSERT INTO sessions (session_type, duration, start_time, end_time) 
VALUES (?, ?, ?, ?);" \
    "$session_name" "$duration" "$start_time_readable" "$end_time_readable"

# Or use proper quoting with sqlite3's shell quoting:
sqlite3 "$DB_FILE" <<EOF
INSERT INTO sessions (session_type, duration, start_time, end_time) 
VALUES ('$(printf '%s' "$session_name" | sed "s/'/''/g")', $duration, '$start_time_readable', '$end_time_readable');
EOF
```

**Explanation:** While single-quote escaping helps, it's better to use parameterized queries when possible to prevent SQL injection.

---

### 📖 Readability Suggestion
**Issue:** Missing `mkdir -p` for the state file directory.

**Before:**
```bash
TMP_DIR="$HOME/.cache/2ndBrain"
STATE_FILE="$TMP_DIR/state/session-state.txt"

mkdir -p "$TMP_DIR"
mkdir -p "$(dirname "$DB_FILE")"
```

**After:**
```bash
TMP_DIR="$HOME/.cache/2ndBrain"
STATE_FILE="$TMP_DIR/state/session-state.txt"

mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p "$(dirname "$DB_FILE")"
```

**Explanation:** The state file is in a subdirectory; we need to ensure `$TMP_DIR/state` exists, not just `$TMP_DIR`.

---

### 🚀 Performance Suggestion
**Issue:** Inconsistent indentation in the final `case` statement.

**Before:**
```bash
case "$STATE" in
	0)
		start_session
		;;
	1)
    end_session
esac
```

**After:**
```bash
case "$STATE" in
    0) start_session ;;
    1) end_session ;;
esac
```

**Explanation:** Consistent indentation and compact case syntax improves readability.

---

## `bin/sokratos-apply-theme`

### 🔁 Longevity Suggestion
**Issue:** Using `pastel format name` may not be installed on all systems; consider fallback.

**Before:**
```bash
COLOR1=$(pastel format name $PRIMARY_HEX)
```

**After:**
```bash
# Check for pastel availability
if command -v pastel &>/dev/null; then
    COLOR1=$(pastel format name "$PRIMARY_HEX")
else
    echo "Warning: pastel not installed, theme detection may be limited" >&2
    COLOR1="unknown"
fi
```

**Explanation:** Adding dependency checks makes the script more robust across different environments.

---

### 📖 Readability Suggestion
**Issue:** Long awk pipeline is hard to read on one line.

**Before:**
```bash
SHADE=$(magick "$IMAGE" \
  -alpha remove -alpha off -colorspace Gray \
  -format "%[fx:mean]" info: | awk '{print ($1<0.35)?"dark":"light"}'
)
```

**After:**
```bash
# Calculate image brightness to determine if dark or light
brightness=$(magick "$IMAGE" \
    -alpha remove -alpha off \
    -colorspace Gray \
    -format "%[fx:mean]" info:)

if (( $(echo "$brightness < 0.35" | bc -l) )); then
    SHADE="dark"
else
    SHADE="light"
fi
```

**Explanation:** Breaking into multiple lines with comments improves readability and debugging.

---

### 🚀 Performance Suggestion
**Issue:** The script reads from a file but doesn't check if the file exists.

**Before:**
```bash
PRIMARY_HEX=$(<~/.config/sokratOS/matugen/.primary-hex.txt)
```

**After:**
```bash
PRIMARY_HEX_FILE="$HOME/.config/sokratOS/matugen/.primary-hex.txt"
if [[ -f "$PRIMARY_HEX_FILE" ]]; then
    PRIMARY_HEX=$(<"$PRIMARY_HEX_FILE")
else
    echo "Error: Primary hex file not found" >&2
    exit 1
fi
```

**Explanation:** Checking file existence prevents cryptic errors when the file is missing.

---

## `bin/sokratos-cheat-sheet`

### 🔁 Longevity Suggestion
**Issue:** Using backticks for command substitution is deprecated.

**Before:**
```bash
languages=`echo "python golang lua cpp c" | tr ' ' '\n'`
core_utils=`echo "xargs find ssh mv sed awk" | tr ' ' '\n'`

selected=`printf "$languages\n$core_utils" | fzf`
```

**After:**
```bash
languages=$(printf '%s\n' python golang lua cpp c)
core_utils=$(printf '%s\n' xargs find ssh mv sed awk)

selected=$(printf '%s\n%s\n' "$languages" "$core_utils" | fzf)
```

**Explanation:** `$(...)` syntax is preferred over backticks for nesting and readability.

---

### 🚀 Performance Suggestion
**Issue:** Using `echo | tr` is less efficient than direct printf with newlines.

**Before:**
```bash
languages=`echo "python golang lua cpp c" | tr ' ' '\n'`
```

**After:**
```bash
languages="python
golang
lua
cpp
c"
# Or use an array:
languages=("python" "golang" "lua" "cpp" "c")
selected=$(printf '%s\n' "${languages[@]}" | fzf)
```

**Explanation:** Using heredoc or arrays eliminates the need for `tr` and extra subprocesses.

---

### 📖 Readability Suggestion
**Issue:** The `printf` without quotes and missing `-qs` in grep are potential issues.

**Before:**
```bash
if printf $languages | grep -qs $selected; then
    tmux neww bash -c "curl cht.sh/$selected/`echo $query | tr ' ' '+'` & while [ : ]; do sleep 1; done"
else
    tmux neww bash -c "curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
fi
```

**After:**
```bash
# Properly quote variables to prevent word splitting
encoded_query="${query// /+}"

if printf '%s\n' "${languages[@]}" | grep -qx "$selected"; then
    tmux neww bash -c "curl -s 'cht.sh/${selected}/${encoded_query}'; read -rp 'Press Enter to close...'"
else
    tmux neww bash -c "curl -s 'cht.sh/${selected}~${encoded_query}'; read -rp 'Press Enter to close...'"
fi
```

**Explanation:** Using `grep -qx` for exact matching, proper quoting, and replacing the infinite loop with a read prompt.

---

## `bin/sokratos-floaterminal`

### 🔁 Longevity Suggestion
**Issue:** `$1` in bash -c is not properly passed.

**Before:**
```bash
hyprctl dispatch exec "[float; size $W $H] \
	kitty --class $CLASS --title 'Kitty Float' \
	--hold bash -c 'exec $1'"
```

**After:**
```bash
# Properly pass the command as an argument
cmd="${1:-}"
hyprctl dispatch exec "[float; size $W $H] \
    kitty --class $CLASS --title 'Kitty Float' \
    --hold bash -c 'exec \"\$0\"' '$cmd'"
```

**Explanation:** `$1` inside `bash -c` refers to the first positional argument after the script string, not the original script's `$1`.

---

### 📖 Readability Suggestion
**Issue:** Missing description of what the script accepts as input.

**Before:**
```bash
#!/usr/bin/env bash
# ~/.local/bin/kitty-float
# Launch Kitty as a floating window on the current workspace.
```

**After:**
```bash
#!/usr/bin/env bash
# ~/.local/bin/kitty-float
# Launch Kitty as a floating window on the current workspace.
#
# Usage: sokratos-floaterminal [command]
# Example: sokratos-floaterminal htop
```

**Explanation:** Adding usage documentation helps users understand how to use the script.

---

## `bin/sokratos-focus-mode`

### 📖 Readability Suggestion
**Issue:** Duplicate `gaps_out` line in the batch command.

**Before:**
```bash
hyprctl --batch "\
	keyword general:gaps_in 0;\
	keyword general:gaps_out 0;\
	keyword general:gaps_out 0;\
	keyword decoration:rounding 0;\
	keyword decoration:shadow:enabled 0;\
	keyword decoration:blur:enabled 0"
```

**After:**
```bash
hyprctl --batch "\
    keyword general:gaps_in 0;\
    keyword general:gaps_out 0;\
    keyword decoration:rounding 0;\
    keyword decoration:shadow:enabled 0;\
    keyword decoration:blur:enabled 0"
```

**Explanation:** Removed duplicate `gaps_out` line.

---

### 🔁 Longevity Suggestion
**Issue:** Consider making focus mode toggleable.

**Before:**
```bash
hyprctl --batch "..."
pkill -9 waybar
```

**After:**
```bash
#!/usr/bin/env bash
# Toggle focus mode for Hyprland

STATE_FILE="/tmp/sokratos-focus-mode.state"

if [[ -f "$STATE_FILE" ]]; then
    # Restore normal mode
    hyprctl reload
    waybar &>/dev/null &
    disown
    rm -f "$STATE_FILE"
    notify-send "Focus Mode" "Disabled"
else
    # Enable focus mode
    hyprctl --batch "\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword decoration:rounding 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0"
    pkill waybar
    touch "$STATE_FILE"
    notify-send "Focus Mode" "Enabled"
fi
```

**Explanation:** A toggleable focus mode is more practical than a one-way switch.

---

## `bin/sokratos-next-theme`

### 📖 Readability Suggestion
**Issue:** Unquoted variable in `cd` command.

**Before:**
```bash
cd $THEMES_DIR || exit 1
```

**After:**
```bash
cd "$THEMES_DIR" || exit 1
```

**Explanation:** Always quote variables to prevent word splitting with paths containing spaces.

---

### 🔁 Longevity Suggestion
**Issue:** Using `$theme` in the ghostty symlink instead of `$SELECTED_THEME`.

**Before:**
```bash
if [ -n "$SELECTED_THEME" ]; then
	ln -nsf "$THEMES_DIR"/"$SELECTED_THEME"/colors.conf "$CURRENT_THEME_DIR"
	ln -nsf "$THEMES_DIR/$theme/ghostty-colors" "$CURRENT_THEME_DIR1"
fi
```

**After:**
```bash
if [[ -n "$SELECTED_THEME" ]]; then
    ln -nsf "$THEMES_DIR/$SELECTED_THEME/colors.conf" "$CURRENT_THEME_DIR"
    ln -nsf "$THEMES_DIR/$SELECTED_THEME/ghostty-colors" "$CURRENT_THEME_DIR1"
fi
```

**Explanation:** `$theme` is undefined; it should be `$SELECTED_THEME` for the ghostty symlink.

---

### 🚀 Performance Suggestion
**Issue:** Returning to `$CWD` is unnecessary if the script exits afterward.

**Before:**
```bash
CWD="$(pwd)"
cd $THEMES_DIR || exit 1
# ...
cd "$CWD" || exit 1
```

**After:**
```bash
# Use a subshell to avoid changing the parent's directory
(
    cd "$THEMES_DIR" || exit 1
    SELECTED_THEME=$(for theme in *; do echo -en "$theme\0icon\x1f$theme\n"; done | rofi -dmenu -p "")
    # ...
)
```

**Explanation:** Using a subshell keeps directory changes contained without needing to save/restore.

---

## `bin/sokratos-night-mode`

### 📖 Readability Suggestion
**Issue:** Comment mentions "wlsunset" but the script uses "hyprsunset".

**Before:**
```bash
# Check if wlsunset is already running
if pgrep -x "hyprsunset" > /dev/null; then
    # Kill wlsunset if it's running (switch to day mode)
    pkill hyprsunset
```

**After:**
```bash
# Check if hyprsunset is already running
if pgrep -x "hyprsunset" > /dev/null; then
    # Kill hyprsunset to switch to day mode
    pkill hyprsunset
```

**Explanation:** Comments should match the actual code behavior.

---

### 🚀 Performance Suggestion
**Issue:** `pgrep` and `pkill` can be combined more elegantly.

**Before:**
```bash
if pgrep -x "hyprsunset" > /dev/null; then
    pkill hyprsunset
    notify-send "Night Light" "Off" -u "low"
else
    hyprsunset --temperature 4000 &
    notify-send "Night Light" "On" -u "low"
fi
```

**After:**
```bash
if pkill -x hyprsunset 2>/dev/null; then
    notify-send -u low "Night Light" "Off"
else
    hyprsunset --temperature 4000 &
    disown
    notify-send -u low "Night Light" "On"
fi
```

**Explanation:** `pkill` returns 0 if it killed something, so we can use it directly as the condition.

---

## `bin/sokratos-run-ollama`

### 🔁 Longevity Suggestion
**Issue:** Script uses `set -euo pipefail` which is good, but some error handling could be improved.

**Before:**
```bash
set -euo pipefail

check_dependencies() {
  local missing=()
  for cmd in ollama fzf; do command -v "$cmd" &>/dev/null || missing+=("$cmd"); done
  if (( ${#missing[@]} )); then
```

**After:**
```bash
set -euo pipefail
shopt -s inherit_errexit  # Propagate errexit to subshells

check_dependencies() {
  local missing=()
  local cmd
  for cmd in ollama fzf; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if (( ${#missing[@]} )); then
```

**Explanation:** Adding `inherit_errexit` ensures that errors in subshells cause the script to exit. Also, declaring `cmd` as local.

---

### 📖 Readability Suggestion
**Issue:** `printf` color escape with %s placeholder is incorrect.

**Before:**
```bash
echo -e "${RED}❌ Could not run model:%s${NC}" "$(printf ' %q' "$model")"
```

**After:**
```bash
printf '%b\n' "${RED}❌ Could not run model: ${model}${NC}"
```

**Explanation:** The original code incorrectly uses `echo -e` with a `%s` placeholder that won't be substituted.

---

### 🚀 Performance Suggestion
**Issue:** Multiple `find` calls with similar patterns could be combined.

**Before:**
```bash
file_list="$(find . -maxdepth 2 -type f \
    \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' \
     -o -name '*.java' -o -name '*.cpp' -o -name '*.c' -o -name '*.sh' -o -name '*.md' \
     -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name 'Dockerfile' -o -name 'Makefile' \) | head -20)"
```

**After:**
```bash
# Use fd for cleaner syntax if available, fallback to find
if command -v fd &>/dev/null; then
    file_list="$(fd -d 2 -e py -e js -e ts -e go -e rs -e java -e cpp -e c -e sh -e md -e json -e yaml -e yml | head -20)"
else
    file_list="$(find . -maxdepth 2 -type f \
        -regex '.*\.\(py\|js\|ts\|go\|rs\|java\|cpp\|c\|sh\|md\|json\|ya?ml\)$' \
        -o -name 'Dockerfile' -o -name 'Makefile' | head -20)"
fi
```

**Explanation:** Using `fd` when available or regex with `find` is cleaner than multiple `-name` options.

---

## `bin/sokratos-switch-nvim`

### 📖 Readability Suggestion
**Issue:** Using `-e` flag with `echo` is non-portable; prefer `printf`.

**Before:**
```bash
echo -e 'Clearing nvim cache and...'
```

**After:**
```bash
printf '%s\n' 'Clearing nvim cache...'
```

**Explanation:** `printf` is more portable than `echo -e` across different shells.

---

### 🔁 Longevity Suggestion
**Issue:** Using `${HOME}` mixed with `~` is inconsistent.

**Before:**
```bash
if [[ -d ${HOME}/.config/nvim_ancient ]]; then
	echo -e 'Your bloated config is being restored'
	mv ~/.config/nvim ~/.config/nvim_based
```

**After:**
```bash
NVIM_DIR="$HOME/.config/nvim"
NVIM_ANCIENT="$HOME/.config/nvim_ancient"
NVIM_BASED="$HOME/.config/nvim_based"

if [[ -d "$NVIM_ANCIENT" ]]; then
    printf '%s\n' 'Your bloated config is being restored'
    mv "$NVIM_DIR" "$NVIM_BASED"
    mv "$NVIM_ANCIENT" "$NVIM_DIR"
    bob use stable
else
    printf '%s\n' 'Reloading your BASED config!'
    mv "$NVIM_DIR" "$NVIM_ANCIENT"
    mv "$NVIM_BASED" "$NVIM_DIR"
    bob use nightly
fi
```

**Explanation:** Using variables for repeated paths makes the script more maintainable.

---

## `bin/sokratos-themes`

See improvements listed in `bin/sokratos-next-theme` - the issues are identical.

---

## `bin/sokratos-wf-recorder`

### 🔁 Longevity Suggestion
**Issue:** `eval` on WF_CMD is a security risk if any variables contain malicious input.

**Before:**
```bash
WF_CMD="wf-recorder -r $RECORDING_FPS -c $CODEC"
# ... building command
eval "$WF_CMD" &
```

**After:**
```bash
# Build command as an array to avoid eval
wf_args=(-r "$RECORDING_FPS" -c "$CODEC")
[[ -n "$AUDIO_OPTS" ]] && wf_args+=(-a)
[[ -n "$REGION_OPTS" ]] && wf_args+=(-g "$REGION")
[[ "$RECORD_MODE" == "Full Monitor" ]] && wf_args+=(-o "$MONITOR")
wf_args+=(-f "$TMP_FILE")
[[ "$CODEC" =~ ^lib ]] && wf_args+=(--preset "$PRESET")

wf-recorder "${wf_args[@]}" &
```

**Explanation:** Building commands as arrays and using `"${arr[@]}"` is safer than using `eval`.

---

### 📖 Readability Suggestion
**Issue:** Associative array iteration order is unpredictable in Bash.

**Before:**
```bash
for codec in "${!CODECS[@]}"; do
  CODEC_OPTIONS+=("$codec (${CODECS[$codec]})")
done
```

**After:**
```bash
# Use a regular array for consistent ordering
CODEC_LIST=("h264_vaapi" "hevc_vaapi" "libx264" "libx265")
for codec in "${CODEC_LIST[@]}"; do
  CODEC_OPTIONS+=("$codec (${CODECS[$codec]})")
done
```

**Explanation:** If display order matters, use an indexed array to control iteration order.

---

## `bin/test-script`

### 📖 Readability Suggestion
**Issue:** This appears to be a test/debug script with hardcoded test values.

**Before:**
```bash
read -rp "Filename: " TITLE
export TITLE
export DATE="123 424 monday"
export USR_CHOICE="PEEPEEEPOOOOPOOO"
```

**After:**
```bash
#!/usr/bin/env bash
# DEBUG: Test script for template rendering
# Remove or move to tests/ directory before production

# ... rest of script with proper test values
```

**Explanation:** Test scripts should be clearly marked and potentially moved to a tests directory.

---

## `bin/tmux-sessionizer`

### 🔁 Longevity Suggestion
**Issue:** Using `#!/bin/bash` instead of `#!/usr/bin/env bash`.

**Before:**
```bash
#!/bin/bash
```

**After:**
```bash
#!/usr/bin/env bash
```

**Explanation:** `/usr/bin/env bash` is more portable as bash location varies across systems.

---

### 📖 Readability Suggestion
**Issue:** Array syntax could be cleaner.

**Before:**
```bash
DIRS=(
		"$HOME/workspace"
    "$HOME/Documents/2ndBrain"
		"$HOME/workspace/containers"
    "$HOME/dotfiles"
    "$HOME"
)
```

**After:**
```bash
DIRS=(
    "$HOME/workspace"
    "$HOME/Documents/2ndBrain"
    "$HOME/workspace/containers"
    "$HOME/dotfiles"
    "$HOME"
)
```

**Explanation:** Consistent indentation improves readability.

---

### 🚀 Performance Suggestion
**Issue:** Using `$HOME` in `--base-directory` and then adding it back is redundant.

**Before:**
```bash
selected=$(fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory $HOME \
    | sed "s|^$HOME/||" \
    | fzf --color bw)

[[ $selected ]] && selected="$HOME/$selected"
```

**After:**
```bash
# Simpler: just strip $HOME from output without using base-directory
selected=$(fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path \
    | sed "s|^$HOME/||" \
    | fzf --color bw)

[[ -n "$selected" ]] && selected="$HOME/$selected"
```

**Explanation:** The `--base-directory` flag changes the working directory but doesn't affect how paths are displayed.

---

## `bin/wf-start-recording`

### 🔁 Longevity Suggestion
**Issue:** The lock file is written with `echo "$!"` before the recording starts.

**Before:**
```bash
wf-recorder \
  -o "$PRIMARY_MONITOR" \
  # ...
  -f "$TMP_FILE" &

REC_PID=$!

# Create lock and state files
echo "$!" > "$LOCK_FILE"
```

**After:**
```bash
wf-recorder \
  -o "$PRIMARY_MONITOR" \
  # ...
  -f "$TMP_FILE" &

REC_PID=$!

# Create lock file with the recording PID
echo "$REC_PID" > "$LOCK_FILE"
```

**Explanation:** Use `$REC_PID` instead of `$!` for clarity, though they're equivalent here.

---

### 📖 Readability Suggestion
**Issue:** The state file has `PID=` which is then updated via `sed`.

**Before:**
```bash
cat > "$STATE_FILE" << EOF
PID=
TMP_FILE=$TMP_FILE
# ...
EOF

# Update state file with PID
sed -i "s/PID=/PID=$REC_PID/" "$STATE_FILE"
```

**After:**
```bash
# Write state file directly with all values
cat > "$STATE_FILE" << EOF
PID=$REC_PID
TMP_FILE=$TMP_FILE
MONITOR=$PRIMARY_MONITOR
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
EOF
```

**Explanation:** Writing the complete state file once is cleaner than creating and patching.

---

## `bin/wf-stop-recording`

### 🔁 Longevity Suggestion
**Issue:** Using `source` on an untrusted file is a security risk.

**Before:**
```bash
source "$STATE_FILE"
```

**After:**
```bash
# Parse state file safely instead of sourcing
while IFS='=' read -r key value; do
    case "$key" in
        PID) PID="$value" ;;
        TMP_FILE) TMP_FILE="$value" ;;
        START_TIME) START_TIME="$value" ;;
        MONITOR) MONITOR="$value" ;;
    esac
done < "$STATE_FILE"
```

**Explanation:** Sourcing files allows arbitrary code execution. Parsing key-value pairs is safer.

---

### 📖 Readability Suggestion
**Issue:** The conflict resolution loop could be simplified.

**Before:**
```bash
if [[ -e "$DEST" ]]; then
  COUNTER=1
  BASE_NAME="$(date +'%Y-%m-%d_%H-%M-%S')"
  while [[ -e "${SAVE_DIR}/${BASE_NAME}_${COUNTER}.mp4" ]]; do
    ((COUNTER++))
  done
  DEST="${SAVE_DIR}/${BASE_NAME}_${COUNTER}.mp4"
fi
```

**After:**
```bash
# Generate unique filename
BASE_NAME="$(date +'%Y-%m-%d_%H-%M-%S')"
DEST="${SAVE_DIR}/${BASE_NAME}.mp4"

if [[ -e "$DEST" ]]; then
    for i in {1..999}; do
        DEST="${SAVE_DIR}/${BASE_NAME}_${i}.mp4"
        [[ ! -e "$DEST" ]] && break
    done
fi
```

**Explanation:** A bounded loop with clearer logic prevents potential infinite loops.

---

## Summary of Common Issues

| Issue Category | Count | Most Common Problem |
|----------------|-------|---------------------|
| **Longevity** | 15+ | Unquoted variables, hardcoded paths, deprecated syntax |
| **Performance** | 10+ | Multiple subprocess spawns, unnecessary loops |
| **Readability** | 20+ | Inconsistent indentation, missing comments, dead code |

## General Recommendations

1. **Always quote variables**: `"$var"` instead of `$var`
2. **Use `[[` over `[`**: More robust conditional tests
3. **Prefer `$(...)` over backticks**: Better nesting and readability
4. **Use `printf` over `echo -e`**: More portable
5. **Add `set -euo pipefail`**: Fail on errors, undefined variables, and pipe failures
6. **Use `shellcheck`**: Static analysis catches many issues automatically
7. **Prefer arrays over string manipulation**: Safer and more maintainable
8. **Add comments for non-obvious code**: Future maintainers will thank you
