#!/bin/bash

#############################################################################
# GITLEAKS REMEDIATION SCRIPT - git filter-repo
# Purpose: Remove secrets from git history using git filter-repo
# Target: Remove commit 69b6a12c46a9bb010d2396953294813fe52bb33d
# Author: GitHub Copilot
# Date: 2026-06-03
#############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMMIT_TO_REMOVE="69b6a12c46a9bb010d2396953294813fe52bb33d"
BACKUP_DIR="$HOME/solace-project-backup-$(date +%s)"

#############################################################################
# FUNCTION: Print colored output
#############################################################################
print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

#############################################################################
# STEP 1: Pre-flight checks
#############################################################################
print_header "STEP 1: PRE-FLIGHT CHECKS"

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "git is not installed. Please install git first."
    exit 1
fi
print_success "git is installed"

# Check if git filter-repo is installed
if ! command -v git-filter-repo &> /dev/null; then
    print_warning "git-filter-repo is not installed. Installing now..."
    pip install git-filter-repo
    if ! command -v git-filter-repo &> /dev/null; then
        print_error "Failed to install git-filter-repo. Please install manually: pip install git-filter-repo"
        exit 1
    fi
fi
print_success "git-filter-repo is installed"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a git repository. Please navigate to the solace-project root directory."
    exit 1
fi
print_success "In a valid git repository"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes in your working directory."
    echo -e "${YELLOW}Please stash or commit them before proceeding.${NC}"
    echo -e "${YELLOW}Run: git stash${NC}"
    exit 1
fi
print_success "No uncommitted changes"

# Verify the commit exists
if ! git rev-parse --verify "$COMMIT_TO_REMOVE" &> /dev/null; then
    print_error "Commit $COMMIT_TO_REMOVE not found in repository."
    exit 1
fi
print_success "Target commit found: $COMMIT_TO_REMOVE"

#############################################################################
# STEP 2: Create backup
#############################################################################
print_header "STEP 2: CREATE LOCAL BACKUP"

mkdir -p "$BACKUP_DIR"
cp -r .git "$BACKUP_DIR/git-backup"
print_success "Backup created at: $BACKUP_DIR"
print_warning "Save this path if you need to rollback: $BACKUP_DIR"

#############################################################################
# STEP 3: Show what will be removed
#############################################################################
print_header "STEP 3: COMMIT DETAILS TO BE REMOVED"

echo -e "${YELLOW}Commit Information:${NC}"
git show "$COMMIT_TO_REMOVE" --stat

echo ""
print_warning "This commit will be completely removed from git history."

#############################################################################
# STEP 4: Confirmation
#############################################################################
print_header "STEP 4: CONFIRMATION"

echo -e "${YELLOW}⚠ WARNING ⚠${NC}"
echo "This operation will:"
echo "  1. Rewrite git history"
echo "  2. Remove commit: $COMMIT_TO_REMOVE"
echo "  3. Require force-push to remote (all team members must sync)"
echo "  4. Change ALL commit SHAs after this point"
echo ""
print_warning "Ensure all team members are aware before proceeding!"
echo ""

read -p "Do you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    print_error "Operation cancelled."
    exit 1
fi

#############################################################################
# STEP 5: Notify team (optional)
#############################################################################
print_header "STEP 5: TEAM NOTIFICATION (OPTIONAL)"

echo "Consider notifying your team:"
echo ""
echo "Message template:"
echo "---"
echo "🔐 Security Alert: Removing secrets from git history"
echo "Commit: $COMMIT_TO_REMOVE"
echo "Reason: Gitleaks detected exposed credentials"
echo "Action: Using git filter-repo to rewrite history"
echo "Impact: All SHAs after this commit will change"
echo "Required Action: After push, everyone should:"
echo "  git fetch --all"
echo "  git reset --hard origin/<branch>"
echo "---"
echo ""

#############################################################################
# STEP 6: Execute git filter-repo
#############################################################################
print_header "STEP 6: EXECUTING GIT FILTER-REPO"

print_warning "Filtering repository... this may take a moment"

git filter-repo --commits "$COMMIT_TO_REMOVE" --invert-selection --force

if [ $? -ne 0 ]; then
    print_error "git filter-repo failed!"
    print_warning "Rollback instructions:"
    echo "1. rm -rf .git"
    echo "2. cp -r $BACKUP_DIR/git-backup .git"
    exit 1
fi

print_success "git filter-repo completed successfully"

#############################################################################
# STEP 7: Clean reflog and garbage collect
#############################################################################
print_header "STEP 7: CLEAN REFLOG AND GARBAGE"

print_warning "Cleaning reflog to remove secret references..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

print_success "Reflog cleaned and garbage collected"

#############################################################################
# STEP 8: Verify commit removal
#############################################################################
print_header "STEP 8: VERIFY COMMIT REMOVAL"

if git rev-parse --verify "$COMMIT_TO_REMOVE" &> /dev/null; then
    print_error "Commit still exists! Something went wrong."
    print_warning "Attempting rollback..."
    rm -rf .git
    cp -r "$BACKUP_DIR/git-backup" .git
    print_error "Repository restored from backup."
    exit 1
fi

print_success "Confirmed: Commit $COMMIT_TO_REMOVE has been removed"

# Show current branch status
echo ""
echo -e "${BLUE}Current branch status:${NC}"
git log --oneline -10

#############################################################################
# STEP 9: Ready to push
#############################################################################
print_header "STEP 9: READY TO FORCE PUSH"

echo -e "${YELLOW}The following commands need to be executed:${NC}"
echo ""
echo -e "${GREEN}For feature/solace-queue branch:${NC}"
echo "  git push origin feature/solace-queue --force-with-lease"
echo ""
echo -e "${GREEN}For main branch:${NC}"
echo "  git push origin main --force-with-lease"
echo ""
echo -e "${GREEN}Or for all branches:${NC}"
echo "  git push origin --force-with-lease --all"
echo ""

print_warning "IMPORTANT: --force-with-lease prevents accidentally overwriting team changes"
print_warning "DO NOT use --force without --with-lease"

#############################################################################
# STEP 10: Push confirmation
#############################################################################
print_header "STEP 10: PUSH CONFIRMATION"

read -p "Do you want to push now? (yes/no): " push_confirm

if [ "$push_confirm" = "yes" ]; then
    print_warning "Pushing to remote with --force-with-lease..."
    
    git push origin --force-with-lease --all
    
    if [ $? -eq 0 ]; then
        print_success "Force push completed successfully!"
    else
        print_error "Force push failed. Check your remote and permissions."
        echo "You can retry manually with: git push origin --force-with-lease --all"
        exit 1
    fi
else
    print_warning "Skipping push. You can push later with:"
    echo "  git push origin --force-with-lease --all"
fi

#############################################################################
# STEP 11: Final verification
#############################################################################
print_header "STEP 11: FINAL VERIFICATION"

echo "Run gitleaks scan to verify secrets are removed:"
echo "  gitleaks detect --source . --report-path gitleaks-report.json"
echo ""

echo -e "${GREEN}Remediation completed!${NC}"
echo ""
echo "Backup location (for reference): $BACKUP_DIR"
echo "Keep this for 24 hours in case rollback is needed."
echo ""

#############################################################################
# END
#############################################################################
print_success "Script completed successfully!"
