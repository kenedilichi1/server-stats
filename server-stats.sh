#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

divider="========================================"

get_cpu_usage() {
  echo -e "\n${CYAN}CPU Usage:${RESET}"
  mpstat | awk '$12 ~ /[0-9.]+/ { print 100 -$12"% used" }'
}

get_memory_usage() {
  echo -e "\n${CYAN}Memory Usage:${RESET}"
  free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
}

get_disk_usage() {
  echo -e "\n${CYAN}Disk Usage:${RESET}"
  df -h --total | awk 'END{printf "Size: %s, Used: %s, Free: %s, Usage: %s\n", $2, $3, $4, $5}'
}

get_top_cpu_processes() {
  echo -e "\n${CYAN}Top 5 Processes by CPU Usage:${RESET}"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | column -t
}

get_top_mem_processes() {
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
  echo -e "${BLUE}Server Performance Stats${RESET}"
  echo "$divider"
  get_cpu_usage
  echo "$divider"
  get_memory_usage
  echo "$divider"
  get_disk_usage
  echo "$divider"
  get_top_cpu_processes
  echo "$divider"
  get_top_mem_processes
  echo "$divider"
  get_extra_stats
  echo "$divider"
}
main
