# richtofenum - Advanced Subdomain Enumeration Tool

## Overview

richtofenum is a comprehensive subdomain enumeration tool that combines multiple powerful tools to discover subdomains, resolve DNS records, and extract IP addresses. It is designed for penetration testers, bug bounty hunters, and security professionals who need efficient and thorough subdomain discovery.

## Author

- Nickname: 0xRichtofen

## Features

- 8+ Enumeration Tools - Combines subfinder, assetfinder, findomain, crt.sh, csprecon, chaos, and knockpy
- Fast and Efficient - Parallel execution and smart deduplication
- DNS Resolution - Extracts A, CNAME, and TXT records
- IP Extraction - Unique IP addresses from resolved subdomains
- Alive Host Checking - Identifies live HTTP/HTTPS services
- Detailed Reports - Automatic summary generation with statistics
- Color Output - Beautiful and readable console output

## Prerequisites

- Linux distribution (recommended)
- Go version 1.18 or higher
- Python3 and pip3
- Cargo (for findomain)
- Git
- Sudo privileges for installation

## Installation

### One-liner Installation

```bash
# Clone the repository
git clone https://github.com/ToxicRootVip/richtofenum.git
cd richtofenum

# Make scripts executable
chmod +x install.sh richtofenum.sh

# Run installation
./install.sh

# Add to PATH (optional)
sudo cp richtofenum.sh /usr/local/bin/richtofenum

# Reload your shell configuration
source ~/.bashrc
```

## Usage
### Basic Usage
```
./richtofenum.sh example.com
```
### Advanced Usage
```
for domain in $(cat domains.txt); do
    richtofenum $domain
done
```
## Output Example
```
╔══════════════════════════════════════════════════════════════╗
║           richtofenum - Subdomain Enumeration Tool           ║
║                      by 0xRichtofen                          ║
║                     DNS & IP Extraction                      ║
╚══════════════════════════════════════════════════════════════╝

[INFO] Target domain: example.com
[→] Starting subdomain enumeration for example.com
[✓] Subfinder found 127 subdomains
[✓] Assetfinder found 89 subdomains
[✓] Findomain found 156 subdomains
[✓] crt.sh found 203 subdomains
[✓] csprecon found 45 subdomains
[✓] Chaos found 312 subdomains
[✓] knockpy found 67 subdomains

════════════════════════════════════════════════════════════════
[→] Combining and deduplicating results...
[✓] Total unique subdomains found: 487

════════════════════════════════════════════════════════════════
[→] Performing DNS resolution and IP extraction...
[✓] Unique IP addresses resolved: 89
[✓] DNS details saved to dns-details.txt
[→] Checking for alive domains...
[✓] Alive domains found: 156

════════════════════════════════════════════════════════════════
[✓] richtofenum completed successfully!
📁 Results: richtofenum-20250606-143022/
```

## Disclaimer
Use this tool only on authorized targets. The author is not responsible for any misuse or damage caused by this tool.

<div align="center">
Made with ❤️ and lots of 🧉

</div> 
