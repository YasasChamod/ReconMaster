#!/bin/bash

# ==========================================
# RECON MASTER - AUTOMATED RECONNAISSANCE
# ==========================================

# --- CONFIGURATION ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- BANNER ---
echo -e "${BLUE}"
echo "  ____                      __  __           _            "
echo " |  _ \ ___  ___ ___  _ __ |  \/  | __ _ ___| |_ ___ _ __ "
echo " | |_) / _ \/ __/ _ \| '_ \| |\/| |/ _\` / __| __/ _ \ '__|"
echo " |  _ <  __/ (_| (_) | | | | |  | | (_| \__ \ ||  __/ |   "
echo " |_| \_\___|\___\___/|_| |_|_|  |_|\__,_|___/\__\___|_|   "
echo "                                            v1.1 GitHub Edition"
echo -e "${NC}"

# --- DEPENDENCY CHECK ---
check_dependency() {
    TOOL=$1
    if ! command -v $TOOL &> /dev/null; then
        echo -e "${RED}[!] Error: $TOOL is not installed.${NC}"
        echo "    Please install it: sudo apt install $TOOL"
        exit 1
    fi
}
check_dependency "nmap"
check_dependency "jq"

# --- SCANNING FUNCTIONS ---

nmap_scan() {
  echo -e "${YELLOW}[+] Starting Nmap scan for $DOMAIN...${NC}"
  nmap -F $DOMAIN > "$DIRECTORY/nmap.txt"
  if [ "$?" -ne "0" ]; then
      echo -e "${RED}[!] Nmap scan failed!${NC}"
  else
      echo -e "${GREEN}    [OK] Results saved.${NC}"
  fi
}

dirsearch_scan() {
  echo -e "${YELLOW}[+] Starting Dirsearch for $DOMAIN...${NC}"
  
  # --- FIX: REMOVED REPORT FLAG. USING DIRECT REDIRECTION (>) ---
  if command -v dirsearch &> /dev/null; then
      dirsearch -u $DOMAIN -e php,html,js -x 400,403,404 > "$DIRECTORY/dirsearch.txt"
      
      if [ -s "$DIRECTORY/dirsearch.txt" ]; then
          echo -e "${GREEN}    [OK] Results saved.${NC}"
      else
          echo -e "${RED}[!] Dirsearch finished but output is empty.${NC}"
      fi
  else
      echo -e "${RED}[!] Dirsearch not found. Skipping.${NC}"
  fi
}

crt_scan() {
  echo -e "${YELLOW}[+] Querying crt.sh for $DOMAIN...${NC}"
  curl -s "https://crt.sh/?q=$DOMAIN&output=json" -o "$DIRECTORY/crt.json"
  if [ -s "$DIRECTORY/crt.json" ]; then
      echo -e "${GREEN}    [OK] Results saved.${NC}"
  else
      echo -e "${RED}[!] crt.sh failed.${NC}"
  fi
}

# --- WRAPPER FUNCTIONS ---

scan_domain(){
  DOMAIN=$1
  DIRECTORY="${DOMAIN}_recon"
  
  if [ ! -d "$DIRECTORY" ]; then
    echo -e "${BLUE}[*] Creating directory $DIRECTORY...${NC}"
    mkdir "$DIRECTORY"
  fi

  case $MODE in
    nmap-only) nmap_scan ;;
    dirsearch-only) dirsearch_scan ;;
    crt-only) crt_scan ;;
    *) 
      nmap_scan
      dirsearch_scan
      crt_scan
      ;;     
  esac
}

report_domain(){
  DOMAIN=$1
  DIRECTORY="${DOMAIN}_recon"
  REPORT_FILE="$DIRECTORY/final_report.txt"
  
  echo -e "${BLUE}[*] Generating report for $DOMAIN...${NC}"
  TODAY=$(date)
  echo "Recon Report - $TODAY" > "$REPORT_FILE"
  echo "===========================================" >> "$REPORT_FILE"

  if [ -f "$DIRECTORY/nmap.txt" ]; then
    echo -e "\n[NMAP RESULTS]" >> "$REPORT_FILE"
    grep -E "^\s*\S+\s+\S+\s+\S+\s*$" "$DIRECTORY/nmap.txt" >> "$REPORT_FILE"
  fi

  if [ -f "$DIRECTORY/dirsearch.txt" ]; then
    echo -e "\n[DIRSEARCH RESULTS]" >> "$REPORT_FILE"
    # Filter out the logo and progress bars, keep results
    grep -E "\[[0-9]{2}:[0-9]{2}:[0-9]{2}\] [0-9]{3} -" "$DIRECTORY/dirsearch.txt" >> "$REPORT_FILE"
  fi

  if [ -f "$DIRECTORY/crt.json" ]; then
    echo -e "\n[SUBDOMAINS]" >> "$REPORT_FILE"
    jq -r ".[] | .name_value" "$DIRECTORY/crt.json" | sort -u >> "$REPORT_FILE"
  fi
  
  echo -e "${GREEN}[SUCCESS] Report saved at: $REPORT_FILE${NC}"
  echo "------------------------------------------------"
}

# --- MAIN EXECUTION ---

while getopts "m:i" OPTION; do
  case $OPTION in
    m) MODE=$OPTARG ;; 
    i) INTERACTIVE=true ;;
  esac
done

shift $((OPTIND -1))

if [ "$INTERACTIVE" = true ]; then
  INPUT=""
  while [ "$INPUT" != "quit" ]; do
    echo -e "${BLUE}Enter domain (type 'quit' to exit):${NC}"
    read INPUT 
    if [ "$INPUT" != "quit" ] && [ ! -z "$INPUT" ]; then
      scan_domain $INPUT
      report_domain $INPUT
    fi
  done
else
  if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No domain provided.${NC}"
    exit 1
  fi
  for DOMAIN in "$@"; do
    scan_domain $DOMAIN
    report_domain $DOMAIN
  done
fi
