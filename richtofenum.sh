#!/bin/bash

# ============================================
# richtofenum - Subdomain Enumeration Tool
# Author: 0xRichtofen
# Description: Comprehensive subdomain enumeration with DNS resolution
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Global variables
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="richtofenum-$TIMESTAMP"
TARGET="$1"

# ============================================
# Helper Functions
# ============================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           richtofenum - Subdomain Enumeration Tool           ║"
    echo "║                      by 0xRichtofen                          ║"
    echo "║                    DNS & IP Extraction                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_progress() {
    echo -e "${YELLOW}[→]${NC} $1"
}

check_target() {
    if [ -z "$TARGET" ]; then
        log_error "No target domain specified!"
        echo -e "\n${YELLOW}Usage: $0 <domain>${NC}"
        echo -e "${YELLOW}Example: $0 example.com${NC}\n"
        exit 1
    fi
    
    log_info "Target domain: ${BOLD}$TARGET${NC}"
}

setup_directories() {
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/temp"
    log_success "Output directory: $OUTPUT_DIR"
}

check_tools() {
    log_progress "Checking required tools..."
    
    local tools=(
        "subfinder"
        "assetfinder" 
        "findomain"
        "crt.sh"
        "csprecon"
        "chaos"
        "knockpy"
        "httpx"
        "anew"
        "dnsx"
    )
    
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing tools: ${missing[*]}"
        echo -e "${YELLOW}Please install missing tools and try again${NC}"
        exit 1
    else
        log_success "All tools are available"
    fi
}

run_enumeration() {
    echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${NC}"
    log_progress "Starting subdomain enumeration for ${BOLD}$TARGET${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}\n"
    
    # Array to store temp files
    declare -a temp_files=()
    
    # Subfinder
    log_info "Running Subfinder..."
    if subfinder -d "$TARGET" -all -silent -o "$OUTPUT_DIR/temp/subfinder.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/subfinder.txt" 2>/dev/null || echo "0")
        log_success "Subfinder found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/subfinder.txt")
    else
        log_error "Subfinder failed"
    fi
    
    # Assetfinder
    log_info "Running Assetfinder..."
    if assetfinder --subs-only "$TARGET" > "$OUTPUT_DIR/temp/assetfinder.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/assetfinder.txt" 2>/dev/null || echo "0")
        log_success "Assetfinder found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/assetfinder.txt")
    else
        log_error "Assetfinder failed"
    fi
    
    # Findomain
    log_info "Running Findomain..."
    if findomain --quiet -t "$TARGET" > "$OUTPUT_DIR/temp/findomain.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/findomain.txt" 2>/dev/null || echo "0")
        log_success "Findomain found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/findomain.txt")
    else
        log_error "Findomain failed"
    fi
    
    # crt.sh
    log_info "Running crt.sh..."
    if crt.sh "$TARGET" > "$OUTPUT_DIR/temp/crtsh.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/crtsh.txt" 2>/dev/null || echo "0")
        log_success "crt.sh found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/crtsh.txt")
    else
        log_error "crt.sh failed"
    fi
    
    # csprecon
    log_info "Running csprecon..."
    if csprecon -u "$TARGET" -o "$OUTPUT_DIR/temp/csprecon.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/csprecon.txt" 2>/dev/null || echo "0")
        log_success "csprecon found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/csprecon.txt")
    else
        log_error "csprecon failed"
    fi
    
    # chaos
    log_info "Running chaos-client..."
    if chaos -d "$TARGET" -silent > "$OUTPUT_DIR/temp/chaos.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/chaos.txt" 2>/dev/null || echo "0")
        log_success "Chaos found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/chaos.txt")
    else
        log_warning "Chaos failed (may need API key)"
    fi
    
    # knockpy
    log_info "Running knockpy..."
    if knockpy -d "$TARGET" --recon --silent > "$OUTPUT_DIR/temp/knockpy.txt" 2>/dev/null; then
        local count=$(wc -l < "$OUTPUT_DIR/temp/knockpy.txt" 2>/dev/null || echo "0")
        log_success "knockpy found $count subdomains"
        temp_files+=("$OUTPUT_DIR/temp/knockpy.txt")
    else
        log_error "knockpy failed"
    fi
    
    # Combine and deduplicate
    echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${NC}"
    log_progress "Combining and deduplicating results..."
    
    # Combine all temp files
    cat "${temp_files[@]}" 2>/dev/null | \
        sort -u | \
        grep -E "^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" | \
        anew "$OUTPUT_DIR/all-subs.txt" > /dev/null
    
    local total=$(wc -l < "$OUTPUT_DIR/all-subs.txt" 2>/dev/null || echo "0")
    log_success "Total unique subdomains found: ${BOLD}$total${NC}"
    
    # DNS Resolution and IP Extraction
    if [ -s "$OUTPUT_DIR/all-subs.txt" ]; then
        echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${NC}"
        log_progress "Performing DNS resolution and IP extraction..."
        
        # Resolve A records and extract IPs
        log_info "Resolving A records with dnsx..."
        cat "$OUTPUT_DIR/all-subs.txt" | \
            dnsx -a -resp-only -silent 2>/dev/null | \
            sort -u > "$OUTPUT_DIR/resolved-ips.txt"
        
        local ip_count=$(wc -l < "$OUTPUT_DIR/resolved-ips.txt" 2>/dev/null || echo "0")
        log_success "Unique IP addresses resolved: ${BOLD}$ip_count${NC}"
        
        # Get detailed DNS info (A, CNAME, TXT)
        log_info "Fetching detailed DNS records..."
        cat "$OUTPUT_DIR/all-subs.txt" | \
            dnsx -a -cname -txt -resp -silent 2>/dev/null > "$OUTPUT_DIR/dns-details.txt"
        
        log_success "DNS details saved to dns-details.txt"
        
        # Extract CNAME records
        grep -E "CNAME" "$OUTPUT_DIR/dns-details.txt" 2>/dev/null | \
            awk '{print $1, $NF}' > "$OUTPUT_DIR/cname-records.txt" || true
        
        # Extract TXT records
        grep -E "TXT" "$OUTPUT_DIR/dns-details.txt" 2>/dev/null > "$OUTPUT_DIR/txt-records.txt" || true
        
        # Check for alive domains with httpx
        log_progress "Checking for alive domains..."
        httpx -l "$OUTPUT_DIR/all-subs.txt" \
            -follow-redirects \
            -silent \
            -status-code \
            -title \
            -content-length \
            -o "$OUTPUT_DIR/alive.txt" \
            2>/dev/null
        
        local alive_count=$(wc -l < "$OUTPUT_DIR/alive.txt" 2>/dev/null || echo "0")
        log_success "Alive domains found: ${BOLD}$alive_count${NC}"
        
        # Extract just URLs from alive hosts
        cat "$OUTPUT_DIR/alive.txt" | cut -d' ' -f1 > "$OUTPUT_DIR/alive-urls.txt" 2>/dev/null
        
        # Generate statistics
        generate_statistics
    else
        log_error "No subdomains found to process"
    fi
}

generate_statistics() {
    echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${NC}"
    log_info "Generating statistics..."
    
    # Count by status codes
    if [ -s "$OUTPUT_DIR/alive.txt" ]; then
        echo -e "\n${YELLOW}Status Code Distribution:${NC}"
        cat "$OUTPUT_DIR/alive.txt" | \
            grep -oP '(?<=\[)[0-9]+(?=\])' | \
            sort | uniq -c | \
            while read count code; do
                printf "  ${GREEN}%s${NC}: ${CYAN}%s${NC}\n" "$code" "$count"
            done
    fi
    
    # Summary of DNS records
    if [ -s "$OUTPUT_DIR/cname-records.txt" ]; then
        local cname_count=$(wc -l < "$OUTPUT_DIR/cname-records.txt")
        echo -e "\n${YELLOW}DNS Records Summary:${NC}"
        echo -e "  ${CYAN}CNAME records:${NC} $cname_count"
    fi
    
    if [ -s "$OUTPUT_DIR/txt-records.txt" ]; then
        local txt_count=$(wc -l < "$OUTPUT_DIR/txt-records.txt")
        echo -e "  ${CYAN}TXT records:${NC} $txt_count"
    fi
}

create_report() {
    echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${NC}"
    log_progress "Creating summary report..."
    
    local report_file="$OUTPUT_DIR/SUMMARY.txt"
    
    cat > "$report_file" << EOF
╔══════════════════════════════════════════════════════════════╗
║              richtofenum - Enumeration Summary               ║
║                     Target: $TARGET                          ║
║                Generated by: 0xRichtofen 🧉                  ║
║                     Date: $(date)                            ║
╚══════════════════════════════════════════════════════════════╝

📊 STATISTICS:
═══════════════════════════════════════════════════════════════
Total Unique Subdomains: $(wc -l < "$OUTPUT_DIR/all-subs.txt" 2>/dev/null || echo "0")
Alive Domains (HTTP/HTTPS): $(wc -l < "$OUTPUT_DIR/alive.txt" 2>/dev/null || echo "0")
Unique IP Addresses: $(wc -l < "$OUTPUT_DIR/resolved-ips.txt" 2>/dev/null || echo "0")

📁 OUTPUT FILES:
═══════════════════════════════════════════════════════════════
$(ls -lh "$OUTPUT_DIR" | grep -v "^d" | awk '{print "  " $9 " (" $5 ")"}')

📝 FILE DESCRIPTIONS:
═══════════════════════════════════════════════════════════════
  all-subs.txt      - All unique subdomains discovered
  alive.txt         - Live hosts with status codes and titles
  alive-urls.txt    - Just the URLs of alive hosts
  resolved-ips.txt  - Unique IP addresses from A records
  dns-details.txt   - Complete DNS records (A, CNAME, TXT)
  cname-records.txt - CNAME records showing aliases
  txt-records.txt   - TXT records (SPF, DKIM, verifications)

🔧 NEXT STEPS (Manual):
═══════════════════════════════════════════════════════════════
  # Port scanning on discovered IPs
  nmap -iL resolved-ips.txt -p 1-1000
  
  # Or use naabu for faster scanning
  naabu -list resolved-ips.txt -top-ports 1000

EOF

    log_success "Report generated: $OUTPUT_DIR/SUMMARY.txt"
}

cleanup() {
    log_info "Results saved in: $OUTPUT_DIR"
}

print_footer() {
    echo -e "\n${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ richtofenum completed successfully!${NC}"
    echo -e "${CYAN}📁 Results: ${BOLD}$OUTPUT_DIR/${NC}"
    echo -e "${CYAN}📝 Summary: ${BOLD}$OUTPUT_DIR/SUMMARY.txt${NC}"
    echo -e "\n${YELLOW}📋 Output files:${NC}"
    echo -e "  • ${GREEN}all-subs.txt${NC} - All discovered subdomains"
    echo -e "  • ${GREEN}resolved-ips.txt${NC} - Unique IP addresses"
    echo -e "  • ${GREEN}dns-details.txt${NC} - Complete DNS records"
    echo -e "  • ${GREEN}alive.txt${NC} - Live hosts with status codes"
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}\n"
}

# ============================================
# Main Execution
# ============================================

main() {
    print_banner
    check_target "$@"
    setup_directories
    check_tools
    run_enumeration
    create_report
    cleanup
    print_footer
}

# Run main function with all arguments
main "$@"
