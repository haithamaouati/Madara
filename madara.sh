#!/bin/bash                                              
# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"
bold_yellow="\e[1;33m"                                  
# ───── Madara: Bash Clone of Get-FileHash ───── #

banner() {
  clear
  echo -e "${bold_red}"
  cat << "EOF"
   __  ___           __
  /  |/  / ___ _ ___/ / ___ _  ____ ___ _
 / /|_/ / / _ `// _  / / _ `/ / __// _ `/
/_/  /_/  \_,_/ \_,_/  \_,_/ /_/   \_,_/
EOF
  echo -e "\nMadara${nc} — File Hashing Tool\n"
  echo -e "  Author: Haitham Aouati"
  echo -e "  GitHub: ${underline}github.com/haithamaouati${nc}\n"
}

check_deps() {
  local missing=0
  for cmd in sha1sum sha256sum sha384sum sha512sum md5sum; do
    if ! command -v "$cmd" &> /dev/null; then
      echo -e "$bold_red}[!] Missing:${nc} $cmd"
      missing=1
    fi
  done
  [[ $missing -eq 1 ]] && echo -e "${bold_red}[!]${nc} Install dependencies first." && exit 1
}

print_usage() {
  echo "Usage:"
  echo "  madara -Path <file(s)> [-Algorithm <algo>]"
  echo "  madara -LiteralPath <file> [-Algorithm <algo>]"
  echo "  madara -InputStream [-Algorithm <algo>]"
  echo ""
  echo -e "Supported algorithms: SHA1, SHA256 (default), SHA384, SHA512, MD5\n"
  exit 1
}

get_hash_cmd() {
  case "${1,,}" in
    sha1) echo "sha1sum";;
    sha256) echo "sha256sum";;
    sha384) echo "sha384sum";;
    sha512) echo "sha512sum";;
    md5) echo "md5sum";;
    *) echo "invalid";;
  esac
}

hash_input_stream() {
  local algo="$1"
  local cmd
  cmd=$(get_hash_cmd "$algo")

  [[ "$cmd" == "invalid" ]] && echo -e "${bold_red}[!] Unsupported algorithm:${nc} $algo" && exit 1
  local hash
  hash=$(cat | "$cmd" | awk '{print $1}')
  echo -e "Algorithm : ${algo^^}"
  echo -e "Hash      : $hash"
  echo -e "Path      : (InputStream)"
}

hash_file() {
  local file="$1"
  local algo="$2"
  local cmd hash

  cmd=$(get_hash_cmd "$algo")
  [[ "$cmd" == "invalid" ]] && echo -e "${bold_red}[!] Unsupported algorithm:${nc} $algo" && return 1
  [[ ! -e "$file" ]] && echo -e "${bold_red}[!] File not found:${nc} $file" && return 1
  [[ -d "$file" ]] && echo -e "${bold_yellow}[!] Skipped directory:${nc} $file" && return 0

  hash=$("$cmd" "$file" | awk '{print $1}')
  echo -e "Algorithm : ${algo^^}"
  echo -e "Hash      : $hash"
  echo -e "Path      : $file"
  echo
}

madara() {
  local algorithm="sha256"
  local mode=""
  local inputs=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -Path)
        mode="path"
        shift
        while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
          inputs+=("$1")
          shift
        done
        ;;
      -LiteralPath)
        mode="literal"
        inputs+=("$2")
        shift 2
        ;;
      -InputStream)
        mode="stdin"
        shift
        ;;
      -Algorithm)
        algorithm="${2,,}"
        shift 2
        ;;
      *)
        echo -e "${bold_red}[!] Unknown option:${nc} $1"
        print_usage
        ;;
    esac
  done

  case "$mode" in
    stdin)
      hash_input_stream "$algorithm"
      ;;
    path)
      for pattern in "${inputs[@]}"; do
        for file in $pattern; do
          hash_file "$file" "$algorithm"
        done
      done
      ;;
    literal)
      hash_file "${inputs[0]}" "$algorithm"
      ;;
    *)
      echo -e "[!] No input specified.\n"
      print_usage
      ;;
  esac
}

# ───── RUN MADARA ───── #
banner
check_deps

if [[ $# -eq 0 ]]; then
  print_usage
else
  madara "$@"
fi
