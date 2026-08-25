#!/usr/bin/env bash

set -Eeuo pipefail

on_error() {
  local line_number="$1"
  local command_text="$2"
  echo "Command failed at line $line_number: $command_text" >&2
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

BASE_URL="https://api.animethemes.moe"
SITE_URL="https://animethemes.moe"
INCLUDE="video.audio,animethemeentry.animetheme.anime.images,animethemeentry.animetheme.song.artists"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ACCOUNT_FILE="$SCRIPT_DIR/account.txt"
PLAYLIST_EXPORT_FILE="$SCRIPT_DIR/playlist_export.txt"

cleanup() {
  [[ -n "${COOKIE_JAR:-}" && -f "$COOKIE_JAR" ]] && rm -f "$COOKIE_JAR"
  [[ -n "${TMP_LOGIN_BODY:-}" && -f "$TMP_LOGIN_BODY" ]] && rm -f "$TMP_LOGIN_BODY"
  [[ -n "${TMP_TRACKS:-}" && -f "$TMP_TRACKS" ]] && rm -f "$TMP_TRACKS"
  [[ -n "${TMP_IMPORT_RESPONSE:-}" && -f "$TMP_IMPORT_RESPONSE" ]] && rm -f "$TMP_IMPORT_RESPONSE"
}

trap cleanup EXIT

require_tool() {
  local tool_name="$1"
  if ! command -v "$tool_name" >/dev/null 2>&1; then
    echo "Missing required tool: $tool_name" >&2
    exit 1
  fi
}

require_tool curl
require_tool jq
require_tool python3

slugify() {
  local name="$1"
  local slug
  slug=$(printf '%s' "$name" | tr '[:space:]' '_' | tr -cd '[:alnum:]_.-')
  slug=${slug##_}
  slug=${slug%%_}
  printf '%s' "${slug:-playlist}"
}

extract_xsrf_token() {
  python3 - "$1" <<'PY'
import sys
import urllib.parse

path = sys.argv[1]
token = ""
with open(path, "r", encoding="utf-8") as handle:
    for line in handle:
        if line.startswith("#") or not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) >= 7 and parts[5] == "XSRF-TOKEN":
            token = urllib.parse.unquote(parts[6].strip())
print(token)
PY
}

read_prompt() {
  local prompt="$1"
  local value
  read -r -p "$prompt" value
  printf '%s' "$value"
}

read_password() {
  local prompt="$1"
  local value
  read -r -s -p "$prompt" value
  printf '\n'
  printf '%s' "$value"
}

choose_action() {
  echo "1. Export" >&2
  echo "2. Import" >&2
  local choice
  choice=$(read_prompt "Select option number (1=export,2=import): ")
  case "$choice" in
    1) printf '%s' "export" ;;
    2) printf '%s' "import" ;;
    *)
      echo "Invalid option selection." >&2
      exit 1
      ;;
  esac
}

load_export_pairs() {
  local export_file="$1"
  if [[ ! -f "$export_file" ]]; then
    echo "Missing export file: $export_file" >&2
    exit 1
  fi

  if [[ ! -s "$export_file" ]]; then
    echo "Export file is empty: $export_file" >&2
    exit 1
  fi

  : > "$TMP_TRACKS"
  while IFS= read -r line; do
    video_id=""
    entry_id=""
    case "$line" in
      *"'video_id'"*"'entry_id'"*)
        video_id=$(sed -n "s/.*'video_id': *\([0-9][0-9]*\).*/\1/p" <<<"$line")
        entry_id=$(sed -n "s/.*'entry_id': *\([0-9][0-9]*\).*/\1/p" <<<"$line")
        ;;
      *"video_id"*"entry_id"*)
        video_id=$(sed -n 's/.*"video_id"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' <<<"$line")
        entry_id=$(sed -n 's/.*"entry_id"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' <<<"$line")
        ;;
      *)
        continue
        ;;
    esac

    if [[ -n "$video_id" && -n "$entry_id" ]]; then
      printf '%s\t%s\n' "$video_id" "$entry_id" >> "$TMP_TRACKS"
    fi
  done < "$export_file"

  if [[ ! -s "$TMP_TRACKS" ]]; then
    echo "No valid video_id/entry_id pairs found in $export_file" >&2
    exit 1
  fi
}

get_selected_playlist() {
  local playlists_json="$1"

  playlist_rows=()
  while IFS=$'\t' read -r playlist_id playlist_name playlist_visibility; do
    playlist_rows+=("$playlist_id"$'\t'"$playlist_name"$'\t'"$playlist_visibility")
  done < <(jq -r '.playlists[] | [.id, .name, .visibility] | @tsv' <<<"$playlists_json")

  echo "Available playlists:"
  for index in "${!playlist_rows[@]}"; do
    IFS=$'\t' read -r playlist_id playlist_name playlist_visibility <<<"${playlist_rows[$index]}"
    printf '%s. %s [%s] id=%s\n' "$((index + 1))" "$playlist_name" "$playlist_visibility" "$playlist_id"
  done

  choice=$(read_prompt "Select playlist number: ")
  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid playlist selection." >&2
    exit 1
  fi

  selected_index=$((choice - 1))
  if (( selected_index < 0 || selected_index >= ${#playlist_rows[@]} )); then
    echo "Invalid playlist selection." >&2
    exit 1
  fi

  IFS=$'\t' read -r playlist_id playlist_name playlist_visibility <<<"${playlist_rows[$selected_index]}"
  if [[ -z "$playlist_id" || -z "$playlist_name" ]]; then
    echo "Selected playlist is missing a valid id or name." >&2
    exit 1
  fi

  SELECTED_PLAYLIST_ID="$playlist_id"
  SELECTED_PLAYLIST_NAME="$playlist_name"
}

read_account_file() {
  if [[ ! -f "$ACCOUNT_FILE" ]]; then
    echo "Missing account file: $ACCOUNT_FILE" >&2
    exit 1
  fi

  if [[ ! -s "$ACCOUNT_FILE" ]]; then
    echo "Account file is empty: $ACCOUNT_FILE" >&2
    exit 1
  fi

  username="$(awk 'NF { sub(/[[:space:]]+$/, "", $0); print; exit }' "$ACCOUNT_FILE")"
  password="$(awk 'NF { count++; if (count == 2) { sub(/[[:space:]]+$/, "", $0); print; exit } }' "$ACCOUNT_FILE")"

  if [[ -z "$username" || -z "$password" ]]; then
    echo "Account file must contain username/email on the first non-empty line and password on the second non-empty line: $ACCOUNT_FILE" >&2
    exit 1
  fi
}

COOKIE_JAR=$(mktemp)
TMP_LOGIN_BODY=$(mktemp)
TMP_TRACKS=$(mktemp)
TMP_IMPORT_RESPONSE=$(mktemp)

read_account_file
ACTION=$(choose_action)

curl -sS -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "Origin: $SITE_URL" \
  -H "Referer: $SITE_URL/" \
  -H "X-Requested-With: XMLHttpRequest" \
  "$BASE_URL/sanctum/csrf-cookie" >/dev/null

XSRF_TOKEN=$(extract_xsrf_token "$COOKIE_JAR")
if [[ -z "$XSRF_TOKEN" ]]; then
  echo "Failed to read XSRF-TOKEN from cookie jar." >&2
  exit 1
fi

curl -sS -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "Origin: $SITE_URL" \
  -H "Referer: $SITE_URL/" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Content-Type: application/json" \
  -H "X-XSRF-TOKEN: $XSRF_TOKEN" \
  -X POST "$BASE_URL/auth/login" \
  -d "$(jq -n \
      --arg email "$username" \
      --arg password "$password" \
      '{email: $email, password: $password, remember: true}')" \
  | tee "$TMP_LOGIN_BODY"

echo "Login API response:"
if [[ -s "$TMP_LOGIN_BODY" ]]; then
  cat "$TMP_LOGIN_BODY"
  echo
else
  echo "<empty response>"
fi

if jq -e '.errors? or (.message? // empty)' "$TMP_LOGIN_BODY" >/dev/null 2>&1; then
  echo "Login failed; see the API response above." >&2
  cat "$TMP_LOGIN_BODY" >&2
  exit 1
fi

XSRF_TOKEN=$(extract_xsrf_token "$COOKIE_JAR")
if [[ -z "$XSRF_TOKEN" ]]; then
  echo "Failed to read XSRF-TOKEN from the login cookie jar." >&2
  exit 1
fi

playlists_json=$(curl -sS -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "Origin: $SITE_URL" \
  -H "Referer: $SITE_URL/" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Accept: application/json, text/plain, */*" \
  -H "X-XSRF-TOKEN: $XSRF_TOKEN" \
  "$BASE_URL/me/playlist/")

if ! jq -e '.playlists | length > 0' >/dev/null 2>&1 <<<"$playlists_json"; then
  echo "No playlists found for this account, or the response shape is different." >&2
  echo "Raw playlist response:" >&2
  printf '%s\n' "$playlists_json" >&2
  exit 1
fi

get_selected_playlist "$playlists_json"
playlist_id="$SELECTED_PLAYLIST_ID"
playlist_name="$SELECTED_PLAYLIST_NAME"

if [[ "$ACTION" == "export" ]]; then
  echo "Starting export for playlist: $playlist_name"
  : > "$TMP_TRACKS"

  page_number=1
  page_size=100
  while true; do
    echo "Fetching export page $page_number..."
    if ! tracks_json=$(curl -sS -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
      -H "Origin: $SITE_URL" \
      -H "Referer: $SITE_URL/" \
      -H "X-Requested-With: XMLHttpRequest" \
      -H "Accept: application/json, text/plain, */*" \
      -H "X-XSRF-TOKEN: $XSRF_TOKEN" \
      --get "$BASE_URL/playlist/$playlist_id/track" \
      --data-urlencode "include=$INCLUDE" \
      --data-urlencode "page[size]=$page_size" \
      --data-urlencode "page[number]=$page_number"); then
      echo "Failed to fetch tracks for export page $page_number." >&2
      exit 1
    fi

    if ! jq -e '.tracks | length > 0' >/dev/null 2>&1 <<<"$tracks_json"; then
      break
    fi

    jq -r '
      .tracks[]
      | select(.video.id? and .animethemeentry.id?)
      | [.video.id, .animethemeentry.id]
      | @tsv
    ' <<<"$tracks_json" >> "$TMP_TRACKS"

    next_link=$(jq -r '.links.next // empty' <<<"$tracks_json")
    if [[ -z "$next_link" && $(jq -r '.tracks | length' <<<"$tracks_json") -lt $page_size ]]; then
      break
    fi

    page_number=$((page_number + 1))
  done

  {
    echo "["
    first=1
    while IFS=$'\t' read -r video_id entry_id; do
      [[ -z "$video_id" || -z "$entry_id" ]] && continue
      if [[ $first -eq 0 ]]; then
        echo ","
      fi
      printf "  { 'video_id': %s, 'entry_id': %s }" "$video_id" "$entry_id"
      first=0
    done < "$TMP_TRACKS"
    echo
    echo "]"
  } > "$PLAYLIST_EXPORT_FILE"

  echo "Saved $(wc -l < "$TMP_TRACKS" | tr -d ' ') entries to $PLAYLIST_EXPORT_FILE"
  exit 0
fi

if [[ "$ACTION" == "import" ]]; then
  echo "Starting import for playlist: $playlist_name"
  if [[ ! -f "$PLAYLIST_EXPORT_FILE" ]]; then
    echo "Missing import file: $PLAYLIST_EXPORT_FILE" >&2
    exit 1
  fi

  load_export_pairs "$PLAYLIST_EXPORT_FILE"

  total_pairs=$(wc -l < "$TMP_TRACKS" | tr -d ' ')
  current_pair=0
  while IFS=$'\t' read -r video_id entry_id; do
    [[ -z "$video_id" || -z "$entry_id" ]] && continue
    current_pair=$((current_pair + 1))
    echo "Importing $current_pair of $total_pairs: video_id=$video_id entry_id=$entry_id"

    import_payload=$(jq -n --argjson video_id "$video_id" --argjson entry_id "$entry_id" '{video_id: $video_id, entry_id: $entry_id}')
    if ! import_response=$(curl -sS -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
      -H "Origin: $SITE_URL" \
      -H "Referer: $SITE_URL/" \
      -H "X-Requested-With: XMLHttpRequest" \
      -H "Accept: application/json, text/plain, */*" \
      -H "Content-Type: application/json" \
      -H "X-XSRF-TOKEN: $XSRF_TOKEN" \
      -X POST "$BASE_URL/playlist/$playlist_id/track" \
      -d "$import_payload" ); then
      echo "Failed to import pair $current_pair of $total_pairs." >&2
      exit 1
    fi

    printf '%s\n' "$import_response" > "$TMP_IMPORT_RESPONSE"
    if ! jq -e '.track.id? // empty' "$TMP_IMPORT_RESPONSE" >/dev/null 2>&1; then
      echo "Import failed for pair $current_pair of $total_pairs." >&2
      cat "$TMP_IMPORT_RESPONSE" >&2
      exit 1
    fi
  done < "$TMP_TRACKS"

  echo "Import complete for playlist: $playlist_name"
fi