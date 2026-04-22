#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=payment
copy_service_file $component_name
payment_build
system_restart
