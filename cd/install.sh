#!/bin/bash

set -euo pipefail

# ===== Project configuration =====
PROJECT_NAME="boilerplate-webapp"

# ===== Resolve script directory =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===== Check dependencies =====
# Check if required commands exist, exit if not found
check_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "❌ Command '$1' not found. Please install it before running this script."
        exit 1
    }
}

check_cmd kubectl
check_cmd helm
check_cmd yq

# ===== Default options =====
VERBOSE=false
PORT_FORWARD_PORT=8080

ONLY_DEV=false
ONLY_PROD=false
ONLY_REL=false

SKIP_DEV=false
SKIP_PROD=false
SKIP_REL=false

# ===== Help function =====
print_help() {
    cat <<EOF
🚀 Usage: ./install.sh [OPTIONS]

Options:
  -v, --verbose       Enable verbose output
  --dev               Only install dev environment
  --prod              Only install prod environment
  --rel               Only install release environment
  --no-dev            Skip dev environment
  --no-prod           Skip prod environment
  --no-rel            Skip release environment
  -h, --help          Show this help message and exit

Examples:
  ./install.sh                 # Install everything
  ./install.sh --dev           # Only install dev environment
  ./install.sh --no-rel        # Skip release environment
  ./install.sh -v              # Verbose mode
EOF
}

# ===== Parse flags =====
for arg in "$@"; do
    case $arg in
        -v|--verbose) VERBOSE=true ;;
        --dev) ONLY_DEV=true ;;
        --prod) ONLY_PROD=true ;;
        --rel) ONLY_REL=true ;;
        --no-dev) SKIP_DEV=true ;;
        --no-prod) SKIP_PROD=true ;;
        --no-rel) SKIP_REL=true ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "❌ Unknown option: $arg" && exit 1 ;;
    esac
done

# ===== Validate conflicting flags =====
if { $ONLY_DEV && $SKIP_DEV; } || \
   { $ONLY_PROD && $SKIP_PROD; } || \
   { $ONLY_REL && $SKIP_REL; }; then
    echo "❌ Conflict: Cannot use --dev and --no-dev (or similar) together."
    exit 1
fi

ONLY_FLAGS_COUNT=0
$ONLY_DEV && ((ONLY_FLAGS_COUNT+=1))
$ONLY_PROD && ((ONLY_FLAGS_COUNT+=1))
$ONLY_REL && ((ONLY_FLAGS_COUNT+=1))

if ((ONLY_FLAGS_COUNT > 1)); then
    echo "❌ Conflict: Use only one of --dev, --prod, or --rel."
    exit 1
fi

# ===== Adjust SKIP flags if ONLY_* is used =====
# If installing only one environment, skip the others
if $ONLY_DEV; then
    SKIP_PROD=true
    SKIP_REL=true
fi

if $ONLY_PROD; then
    SKIP_DEV=true
    SKIP_REL=true
fi

if $ONLY_REL; then
    SKIP_DEV=true
    SKIP_PROD=true
fi

# ===== Run command wrapper =====
# Runs a command with optional verbose output
run_cmd() {
    if $VERBOSE; then
        echo "💬 $1"
        eval "$1"
    else
        eval "$1" > /dev/null 2>&1
    fi
}

# ===== Resource creation =====
echo ""
echo "🔧 Creating namespaces..."

# Create Argo CD namespace (always)
run_cmd "kubectl create namespace argocd"

# Create namespaces for dev and prod unless skipped
$SKIP_DEV  || run_cmd "kubectl create namespace ${PROJECT_NAME}-dev"
$SKIP_PROD || run_cmd "kubectl create namespace ${PROJECT_NAME}-prod"

# Extract and create release namespaces dynamically
if ! $SKIP_REL && [[ -f "$SCRIPT_DIR/manifests/applicationset-releases.yaml" ]]; then
    RELEASE_NAMESPACES=$(yq e '.spec.generators[].list.elements[].namespace' "$SCRIPT_DIR/manifests/applicationset-releases.yaml" 2>/dev/null || echo "")
  
    if [[ -z "$RELEASE_NAMESPACES" ]]; then
        echo "⚠️  No release namespaces found in applicationset-releases.yaml"
    else
        while read -r ns; do
            if [[ -n "$ns" ]]; then
                if ! kubectl get namespace "$ns" > /dev/null 2>&1; then
                    run_cmd "kubectl create namespace $ns"
                fi
            fi
        done <<< "$RELEASE_NAMESPACES"
    fi
fi

echo ""
echo "🚀 Adding Argo Helm repo..."
run_cmd "helm repo add argo https://argoproj.github.io/argo-helm"
run_cmd "helm repo update"

echo ""
echo "📦 Installing Argo CD via Helm..."
run_cmd "helm upgrade --install argocd argo/argo-cd -n argocd --wait"

echo ""
echo "🌐 Starting port-forwarding on https://localhost:$PORT_FORWARD_PORT..."
run_cmd "kubectl port-forward svc/argocd-server -n argocd ${PORT_FORWARD_PORT}:443 &"
PORT_FORWARD_PID=$!
# Wait a moment for port-forward to start
sleep 2

echo ""
echo "🔐 Fetching initial admin password..."
PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

# ===== Apply manifests conditionally =====
echo ""
echo "📄 Applying Argo CD manifests..."

apply_manifest() {
    local file=$1
    run_cmd "kubectl apply -f \"$SCRIPT_DIR/manifests/$file\""
}

$SKIP_DEV  || apply_manifest "application-development.yaml"
$SKIP_PROD || apply_manifest "application-production.yaml"
$SKIP_REL  || apply_manifest "applicationset-releases.yaml"

# ===== Final Summary =====
echo ""
echo "✅ Done!"

echo ""
echo "🐙 ${PROJECT_NAME} stack is up and managed via Argo CD:"
echo ""
echo "  🌍 URL: https://localhost:$PORT_FORWARD_PORT"
echo "  🔑 Credentials:"
echo "     Username: admin"
echo "     Password: $PASSWORD"
echo ""
echo "  📌 Port-forward PID: $PORT_FORWARD_PID"
echo "     To stop it, run: kill $PORT_FORWARD_PID"
echo ""