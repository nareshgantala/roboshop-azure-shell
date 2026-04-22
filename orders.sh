#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=orders
copy_service_file $component_name
orders_build
system_restart