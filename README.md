# 🕵️‍♂️ ReconMaster

**ReconMaster** is a lightweight, automated reconnaissance tool for Bug Bounty hunters and Penetration Testers. It streamlines the process of target enumeration by combining multiple tools into a single, automated workflow.

## ✨ Features

- 🚀 **Automated Scanning**: Runs Nmap, Dirsearch, and crt.sh queries in one go.
- 🎨 **Visual Interface**: Color-coded terminal output for easy reading.
- 🛡️ **Smart Reporting**: Automatically generates a consolidated text report for each target.
- ⚙️ **Error Handling**: Checks for missing dependencies and execution errors.

## 🛠️ Installation & Setup

1. **Clone the repository**
   ```bash
   git clone [https://github.com/YasasChamod/ReconMaster.git](https://github.com/YasasChamod/ReconMaster.git)
Navigate to the directory

Bash
cd ReconMaster
Install Dependencies (Kali Linux)
You must have nmap, jq, and dirsearch installed.

Bash
sudo apt update
sudo apt install nmap jq dirsearch
Make the script executable

Bash
chmod +x recon.sh
💻 Usage
1. Single Target Scan
Run a full scan on a specific domain.

Bash
./recon.sh target.com
2. Interactive Mode
If you prefer a menu-driven approach:

Bash
./recon.sh -i
📂 Output
Results are saved in a dedicated folder for each domain (e.g., google.com_recon/).

nmap.txt: Open ports and services.

dirsearch.txt: Discovered directories and endpoints.

crt.json: Subdomains found via certificate transparency logs.

final_report.txt: A clean summary of all findings.

⚠️ Disclaimer
This tool is for educational purposes and authorized security testing only. Do not use this tool on targets you do not have permission to scan.
