# Source the common functions and variables
# This looks for common.sh in the same directory as this script
source "$(dirname "$0")/common.sh"
component_name=frontend
nginx
frontend_build
