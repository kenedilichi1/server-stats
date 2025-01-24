#!/bin/bash

# Utils for colors and divider
source ./utils.sh

check_dependencies() {
  for cmd in mpstat free df ps awk tput; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}Error: $cmd is not installed. Please install it first.${RESET}"
      exit 1
    fi
  done
}

cpu_usage() {
  echo -e "\n${CYAN}CPU Usage:${RESET}"
  if ! mpstat_output=$(mpstat 2>/dev/null); then
    echo -e "${RED}Error: mpstat failed. Ensure sysstat is installed.${RESET}"
    return
  fi
  echo "$mpstat_output" | awk '$12 ~ /[0-9.]+/ { print 100 -$12"% used" }'
}

memory_usage() {
  echo -e "\n${CYAN}Memory Usage:${RESET}"
  free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
}

disk_usage() {
  echo -e "\n${CYAN}Disk Usage:${RESET}"
  df -h --total | awk 'END{printf "Size: %s, Used: %s, Free: %s, Usage: %s\n", $2, $3, $4, $5}'
}

top_cpu_processes() {
  echo -e "\n${CYAN}Top 5 Processes by CPU Usage:${RESET}"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | column -t
}

top_memory_processes() {
  echo -e "\n${CYAN}Top 5 Processes by Memory Usage:${RESET}"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 | column -t
}

get_extra_stats() {
  echo -e "\n${CYAN}Extra Stats:${RESET}"
  echo -e "${GREEN}OS Version:${RESET}"
  lsb_release -a 2>/dev/null || cat /etc/os-release
  echo -e "\n${GREEN}Uptime:${RESET}"
  uptime
  echo -e "\n${GREEN}Load Average:${RESET}"
  cat /proc/loadavg
  echo -e "\n${GREEN}Logged in Users:${RESET}"
  who
  echo -e "\n${GREEN}Failed Login Attempts:${RESET}"
  grep "Failed password" /var/log/auth.log | awk '{print $1, $2, $3, $11}' | sort | uniq -c
}

main() {
  check_dependencies

  echo -e "${BLUE}Server Performance Stats${RESET}"
  cpu_usage
  echo "$divider"
  memory_usage
  echo "$divider"
  disk_usage
  echo "$divider"
  top_cpu_processes
  echo "$divider"
  top_memory_processes
  echo "$divider"
  get_extra_stats
  echo "$divider"
}

main
