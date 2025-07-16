#!/bin/bash

# Frail IPA Build Script
# This script automates the process of building an IPA for the Frail app

set -e

echo "🚀 Starting Frail IPA Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Runner"
SCHEME_NAME="Runner"
WORKSPACE_PATH="ios/Runner.xcworkspace"
PROJECT_PATH="ios/Runner.xcodeproj"
EXPORT_OPTIONS_PATH="ios/exportOptions.plist"
OUTPUT_DIR="build/ios/ipa"
ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$ARCHIVE_PATH")"

echo -e "${BLUE}📱 Building Frail IPA...${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build Flutter for iOS
echo -e "${YELLOW}🔨 Building Flutter for iOS...${NC}"
flutter build ios --release --no-codesign

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script must be run on macOS to build iOS apps${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed or not in PATH${NC}"
    exit 1
fi

# Archive the app
echo -e "${YELLOW}📦 Archiving the app...${NC}"
xcodebuild -workspace "$WORKSPACE_PATH" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           -archivePath "$ARCHIVE_PATH" \
           archive

# Export IPA
echo -e "${YELLOW}📤 Exporting IPA...${NC}"
xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportOptionsPlist "$EXPORT_OPTIONS_PATH" \
           -exportPath "$OUTPUT_DIR"

# Check if IPA was created
IPA_FILE=$(find "$OUTPUT_DIR" -name "*.ipa" | head -n 1)
if [ -n "$IPA_FILE" ]; then
    echo -e "${GREEN}✅ IPA created successfully: $IPA_FILE${NC}"
    echo -e "${BLUE}📊 IPA size: $(du -h "$IPA_FILE" | cut -f1)${NC}"
else
    echo -e "${RED}❌ Failed to create IPA${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Frail IPA build completed successfully!${NC}"
echo -e "${BLUE}📁 IPA location: $IPA_FILE${NC}" 