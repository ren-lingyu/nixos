#!/usr/bin/env sh

total=${1-10}
rounds=${2-}

case "$total" in
'' | *[!0-9]*)
  printf 'Error: seconds must be a positive integer\n' >&2
  exit 1
  ;;
esac

if [ "$total" -eq 0 ]; then
  printf 'Error: seconds must be greater than zero\n' >&2
  exit 1
fi

case "$rounds" in
'')
  :
  ;;
*[!0-9]*)
  printf 'Error: rounds must be a positive integer\n' >&2
  exit 1
  ;;
*)
  if [ "$rounds" -eq 0 ]; then
    printf 'Error: rounds must be greater than zero\n' >&2
    exit 1
  fi
  ;;
esac

repo_root=$(git rev-parse --show-toplevel) || exit 1

wait_progress() (
  total=$1
  step=1
  width=10
  bar_char='#'
  pad_char='-'
  elapsed=0

  while :; do
    remain=$((total - elapsed))
    filled=$((width * remain / total))

    bar=$(printf '%*s' "$filled" '' | tr ' ' "$bar_char")
    pad=$(printf '%*s' "$((width - filled))" '' | tr ' ' "$pad_char")

    printf '\r\033[K[%s%s] %ds / %ds' "$bar" "$pad" "$remain" "$total"

    [ "$elapsed" -ge "$total" ] && break
    sleep "$step"
    elapsed=$((elapsed + step))
  done
  printf '\n'
)

round=0
while :; do
  round=$((round + 1))

  echo '===== project ====='
  git -C "$repo_root" push
  echo 'waiting ...'
  wait_progress "$total"

  echo '===== .agents ====='
  git -C "$repo_root/.agents" push
  echo 'waiting ...'
  wait_progress "$total"

  [ -n "$rounds" ] && [ "$round" -ge "$rounds" ] && break
done
