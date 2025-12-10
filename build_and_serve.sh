#!/bin/bash

# Flutter Web Build and Serve Script
# This script cleans, builds, and serves a Flutter web project

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in a Flutter project directory
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "No pubspec.yaml found. Are you in a Flutter project directory?"
        exit 1
    fi
}

# Main execution
main() {
    print_message "Starting Flutter web build and serve process..."
    
    # Step 1: Check if we're in a Flutter project
    check_flutter_project
    
    # Step 2: Clean the project
    print_message "Cleaning Flutter project..."
    if flutter clean; then
        print_success "Project cleaned successfully"
    else
        print_error "Failed to clean project"
        exit 1
    fi
    
    # Step 3: Get dependencies
    print_message "Getting Flutter dependencies..."
    if flutter pub get; then
        print_success "Dependencies retrieved successfully"
    else
        print_error "Failed to get dependencies"
        exit 1
    fi
    
    # Step 4: Build for web release
    print_message "Building for web release..."
    if flutter build web --release; then
        print_success "Web release build completed successfully"
    else
        print_error "Failed to build for web release"
        exit 1
    fi
    
    # Step 5: Check if build/web directory exists
    if [ ! -d "build/web" ]; then
        print_error "build/web directory not found. Build may have failed."
        exit 1
    fi
    
    # Step 6: Change to build/web directory
    print_message "Changing to build/web directory..."
    cd build/web || {
        print_error "Failed to change to build/web directory"
        exit 1
    }
    
    # Step 7: Check if Python3 is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is not installed or not in PATH"
        exit 1
    fi
    
    # Step 8: Serve the web app
    print_success "Starting HTTP server on http://localhost:3000"
    print_warning "Press Ctrl+C to stop the server"
    echo ""
    print_message "Opening browser in 3 seconds..."
    sleep 3
    
    # Try to open the browser (cross-platform)
    if command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open "http://localhost:3000" &
    elif command -v open &> /dev/null; then
        # macOS
        open "http://localhost:3000" &
    elif command -v start &> /dev/null; then
        # Windows (if using Git Bash or WSL)
        start "http://localhost:3000" &
    fi
    
    # Start the HTTP server
    python3 -m http.server 3000
}

# Run the main function
main
