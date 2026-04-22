#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=cart
copy_service_file $component_name
user_build
system_restart
