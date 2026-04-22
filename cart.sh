#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=cart
copy_service_file $component_name
nodejs
system_restart
