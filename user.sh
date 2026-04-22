#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=user
copy_service_file $component_name
user_build
system_restart