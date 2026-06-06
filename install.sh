#!/bin/bash

# ============================================
# richtofenum - Installation Script
# Author: 0xRichtofen
# Description: Installs all required tools for richtofenum
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="/tools"
RECON_DIR="$INSTALL_DIR/recon/subdomain-enum"
LOG_FILE="$INSTALL_DIR/richtofenum-install-$(date +%Y%m%d-%H%M%S).log"
FAILED_TOOLS=()

log() { echo -e "$1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_progress() { echo -e "${YELLOW}[→]${NC} $1"; }

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         richtofenum - Tool Installation Script               ║"
    echo "║                      by 0xRichtofen                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_dependencies() {
    log_info "Checking system dependencies..."
    sudo apt update -y
    sudo apt install -y golang-go git python3-pip cargo make gcc python3
    log_success "Dependencies installed"
}

setup_directories() {
    log_info "Setting up directories..."
    mkdir -p "$RECON_DIR"
    log_success "Directory created: $RECON_DIR"
}

setup_go_path() {
    log_info "Setting up Go PATH..."
    if ! grep -q "export PATH=\$PATH:\$(go env GOPATH)/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
    fi
    export PATH=$PATH:$(go env GOPATH)/bin
    log_success "Go PATH configured"
}

install_go_tool() {
    local tool_name="$1"
    local install_cmd="$2"
    log_info "Installing $tool_name..."
    if eval "$install_cmd" 2>&1 | tee -a "$LOG_FILE"; then
        touch "$RECON_DIR/$tool_name" 2>/dev/null
        log_success "Done $tool_name"
    else
        log_error "Failed to install $tool_name"
        FAILED_TOOLS+=("$tool_name")
    fi
}

install_github_repo() {
    local repo_url="$1"
    local dir_name="$2"
    cd "$RECON_DIR" || return 1
    if [ -d "$dir_name" ]; then
        log_warning "Directory $dir_name exists. Pulling updates..."
        cd "$dir_name" && git pull
    else
        git clone "$repo_url" "$dir_name" || return 1
        cd "$dir_name" || return 1
    fi
    return 0
}

# Main installation
main() {
    print_banner
    check_dependencies
    setup_directories
    setup_go_path
    
    # Install Go tools
    install_go_tool "subfinder" "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    install_go_tool "assetfinder" "go install github.com/tomnomnom/assetfinder@latest"
    install_go_tool "findomain" "go install github.com/findomain/findomain@latest"
    install_go_tool "crt.sh" "go install github.com/TaurusOmar/crt.sh@latest"
    install_go_tool "csprecon" "go install github.com/edoardottt/csprecon/cmd/csprecon@latest"
    install_go_tool "chaos" "go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    install_go_tool "shuffledns" "go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
    install_go_tool "puredns" "go install github.com/d3mondev/puredns/v2@latest"
    install_go_tool "hakrevdns" "go install github.com/hakluke/hakrevdns@latest"
    install_go_tool "dnsx" "go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    install_go_tool "httpx" "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
    
    # Install knockpy
    log_info "Installing knockpy..."
    if install_github_repo "https://github.com/guelfoweb/knockpy.git" "knockpy"; then
        pip3 install -r requirements.txt --break-system-packages
        chmod +x knockpy.py
        sudo rm -f /usr/local/bin/knockpy
        sudo ln -s "$(pwd)/knockpy.py" /usr/local/bin/knockpy
        log_success "Done knockpy"
    else
        log_error "Failed to install knockpy"
        FAILED_TOOLS+=("knockpy")
    fi
    
    # Install massdns
    log_info "Installing massdns..."
    if install_github_repo "https://github.com/blechschmidt/massdns.git" "massdns"; then
        make && make install
        log_success "Done massdns"
    else
        log_error "Failed to install massdns"
        FAILED_TOOLS+=("massdns")
    fi
    
    log_success "Installation completed!"
    echo -e "\n${YELLOW}Run 'source ~/.bashrc' to update your PATH${NC}"
}

main "$@"
