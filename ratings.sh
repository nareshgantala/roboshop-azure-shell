#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=ratings
copy_service_file $component_name
ratings_build
system_restart