#!/bin/sh

SELF="$0"
get_data() {
  sed '1,/^#EOF$/d' < "$SELF" | tar xzf - -O "$1"
}

show_help() {
  echo "usage: $(basename "$0") <book> [chapter] [verse]"
  exit 2
}

show_license() {
  get_data drb.txt | \
    awk '/START: FULL LICENSE/,0' | \
    "${PAGER:-less}"
  exit 2
}

if [ "$#" -lt 1 ]
then
  show_help
fi

if [ "$1" = "license" ]
then
  show_license
fi

# Resolve book name
BOOK_ALIASES=$(get_data drb_aliases.txt | grep -i -m1 ":$1:")
if [ -z "$BOOK_ALIASES" ]
then
  exit 1
fi

# Parse reference from arguments
FLAG=$(echo "$BOOK_ALIASES" | cut -d: -f1)
TITLE=$(echo "$BOOK_ALIASES" | awk -F: '{print $NF}')
BOOK=$(echo "$BOOK_ALIASES" | cut -d: -f2)
if [ "$FLAG" = "sc" ]
then
  # The book only contains one chapter: chapter no. is optional.
  # (Example: The NABRE xref in Jer 49:9 refers to Obadiah 1:5 as Ob 5.)
  CH="1"
  VERSE="${3:-${2:-1}}"
else
  CH="${2:-1}"
  VERSE="${3:-1}"
fi
  
# Render into temporary file
TEMPFILE=$(mktemp)
trap 'rm -rf "$TEMPFILE"; trap - EXIT; exit' EXIT INT HUP

get_data drb.txt | \
  awk -v lookup="^%$BOOK $CH\$" \
  -v title="$TITLE" \
  -v chapter="$CH" \
  -v flag="$FLAG" \
  -v width="$(tput cols 2> /dev/null)" \
  "$(get_data print_chapter.awk)" | \
  groff -Tutf8 2> /dev/null \
  > "$TEMPFILE"

# Display the temporary file via pager
if [ "$VERSE" = "1" ]
then
  less -R "$TEMPFILE"
else
  LINE=$(grep -n -m1 "~$VERSE." "$TEMPFILE" | cut -d: -f1)
  if [ -z "$LINE" ]
  then
    less -R "$TEMPFILE"
  else
    less -R "+$LINE" "$TEMPFILE"
  fi
fi
