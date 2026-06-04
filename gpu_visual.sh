#!/usr/bin/env bash

USER="csl-stu"
PORT=22222
IP_PREFIX="133.78.130"

START=21
END=30
INTERVAL=5

# 横棒グラフの幅
BAR_WIDTH=30

# ANSI colors
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
CYAN=$'\033[36m'

if ! command -v sshpass >/dev/null 2>&1; then
  echo "sshpass がありません。先にインストールしてください:"
  echo "  sudo apt install sshpass"
  exit 1
fi

if [ -z "${SSHPASS:-}" ]; then
  printf "SSH password: "
  read -rs SSHPASS
  export SSHPASS
  echo
fi

while true; do
  clear

  printf "%s%s===== GPU Monitor: csl-%s ~ csl-%s =====%s\n" \
    "$BOLD" "$CYAN" "$START" "$END" "$RESET"

  printf "%sUpdated at: %s | Refresh: %ss%s\n\n" \
    "$DIM" "$(date '+%Y-%m-%d %H:%M:%S')" "$INTERVAL" "$RESET"

  for i in $(seq "$START" "$END"); do
    HOST="${IP_PREFIX}.${i}"

    printf "%s%s┌─ csl-%s (%s)%s\n" \
      "$BOLD" "$BLUE" "$i" "$HOST" "$RESET"

    OUTPUT=$(
      sshpass -e ssh \
        -p "$PORT" \
        -o ConnectTimeout=3 \
        -o StrictHostKeyChecking=accept-new \
        "${USER}@${HOST}" \
        "LC_ALL=C nvidia-smi \
          --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw,power.limit \
          --format=csv,noheader,nounits" \
        2>&1
    )

    STATUS=$?

    if [ "$STATUS" -ne 0 ]; then
      printf "%s│  ✗ SSH failed or nvidia-smi unavailable%s\n" \
        "$RED" "$RESET"

      while IFS= read -r line; do
        printf "%s│  %s%s\n" "$DIM" "$line" "$RESET"
      done <<< "$OUTPUT"

    elif [ -z "$OUTPUT" ]; then
      printf "%s│  ! Connected, but no GPU info returned%s\n" \
        "$YELLOW" "$RESET"

    else
      printf "%s\n" "$OUTPUT" | LC_ALL=C awk -F ', ' \
        -v width="$BAR_WIDTH" \
        -v c_reset="$RESET" \
        -v c_bold="$BOLD" \
        -v c_dim="$DIM" \
        -v c_red="$RED" \
        -v c_green="$GREEN" \
        -v c_yellow="$YELLOW" \
        -v c_cyan="$CYAN" '
        function is_number(value) {
          return value ~ /^[0-9]+([.][0-9]+)?$/
        }

        function color_for_percent(percent) {
          if (percent >= 90) {
            return c_red
          }

          if (percent >= 60) {
            return c_yellow
          }

          return c_green
        }

        function make_bar(percent, color,    filled, empty, result, j) {
          if (percent < 0) {
            percent = 0
          }

          if (percent > 100) {
            percent = 100
          }

          filled = int((percent * width / 100) + 0.5)
          empty = width - filled
          result = color

          for (j = 0; j < filled; j++) {
            result = result "█"
          }

          result = result c_dim

          for (j = 0; j < empty; j++) {
            result = result "░"
          }

          return result c_reset
        }

        {
          gpu_index = $1
          gpu_name = $2
          gpu_util_raw = $3
          mem_used_raw = $4
          mem_total_raw = $5
          temp = $6
          power_draw = $7
          power_limit = $8

          if (is_number(gpu_util_raw)) {
            gpu_util = gpu_util_raw + 0
          } else {
            gpu_util = 0
          }

          if (is_number(mem_used_raw)) {
            mem_used = mem_used_raw + 0
          } else {
            mem_used = 0
          }

          if (is_number(mem_total_raw)) {
            mem_total = mem_total_raw + 0
          } else {
            mem_total = 0
          }

          if (mem_total > 0) {
            mem_percent = mem_used / mem_total * 100
          } else {
            mem_percent = 0
          }

          gpu_color = color_for_percent(gpu_util)
          mem_color = color_for_percent(mem_percent)

          print "│"

          printf "│  %sGPU %s%s  %s%s%s\n", \
            c_bold, gpu_index, c_reset, c_cyan, gpu_name, c_reset

          printf "│  Util   %s %s%6.1f%%%s\n", \
            make_bar(gpu_util, gpu_color), \
            gpu_color, gpu_util, c_reset

          printf "│  Memory %s %s%6.1f%%%s  %.0f / %.0f MiB\n", \
            make_bar(mem_percent, mem_color), \
            mem_color, mem_percent, c_reset, \
            mem_used, mem_total

          printf "│  Temp: %s°C", temp

          if (is_number(power_draw) && is_number(power_limit)) {
            printf "  |  Power: %s / %s W", power_draw, power_limit
          } else {
            printf "  |  Power: N/A"
          }

          print ""
        }
      '
    fi

    printf "%s└────────────────────────────────────────────────────────────%s\n\n" \
      "$BLUE" "$RESET"
  done

  sleep "$INTERVAL"
done
