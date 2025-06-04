#!/bin/bash

# ─── Haitham Aouati's Madara GUI ─── #

show_license() {
  accepted=$(zenity --text-info \
    --title="Madara License" \
    --filename="LICENSE" \
    --checkbox="I read and accept the terms." \
    --width=400 --height=600)
}

select_file() {
  zenity --file-selection --title="Select a file to hash"
}

select_algorithm() {
  zenity --list --radiolist \
    --title="Select Hash Algorithm" \
    --width=400 --height=450 \
    --column="Select" --column="Algorithm" \
    TRUE  "SHA256" \
    FALSE "SHA1" \
    FALSE "SHA384" \
    FALSE "SHA512" \
    FALSE "MD5"
}

show_result() {
  local algo="$1"
  local hash="$2"
  local path="$3"

  zenity --list \
    --title="Hash Result" \
    --width=600 --height=350 \
    --column="Field" --column="Value" \
    "Algorithm" "$algo" \
    "Hash" "$hash" \
    "File" "$path"

  # Ask to save
  zenity --question --title="Save Result" \
    --text="Do you want to save the hash result to a text file?"

  if [[ $? -eq 0 ]]; then
    save_path=$(zenity --file-selection --save --confirm-overwrite --title="Save Hash As")
    if [[ -n "$save_path" ]]; then
      echo -e "Algorithm: $algo\nHash: $hash\nFile: $path" > "$save_path"
      zenity --info --title="Saved" --text="Hash saved to: $save_path"
    fi
  fi
}

show_error() {
  zenity --error --title="Error" --text="$1"
}

# ─── Run Madara GUI ─── #

show_license

file=$(select_file) || exit 1
[[ ! -f "$file" ]] && show_error "Invalid file." && exit 1

algo=$(select_algorithm) || exit 1
algo_lower=$(echo "$algo" | awk '{print tolower($0)}')

# Get command
case "$algo_lower" in
  sha1|sha256|sha384|sha512|md5) cmd=$(command -v "${algo_lower}sum");;
  *) show_error "Unsupported algorithm."; exit 1;;
esac

# Hash it
if ! hash=$("$cmd" "$file" | awk '{print $1}'); then
  show_error "Failed to compute hash."
  exit 1
fi

show_result "$algo" "$hash" "$file"

# Exit prompt
zenity --question --title="Exit" --text="Do you want to exit now?"
if [[ $? -ne 0 ]]; then
  exec "$0"
fi