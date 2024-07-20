#!/bin/bash

# Define the export directory path
EXPORT_DIR="/home/junaid/export-demo"

# Function to check for deprecated APIs using Pluto
check_deprecated_apis() {
  local export_dir=$1
  echo "Checking for deprecated APIs in $export_dir..."
  # List the files being checked
  find "$export_dir" -type f -name "*.yaml"
  # Run Pluto check
  pluto detect-files -d "$export_dir"
}

# Get list of namespaces except 'default', 'kube-node-lease', 'kube-public', and 'kube-system'
namespaces=$(kubectl get namespaces --no-headers | awk '$1 != "default" && $1 != "kube-node-lease" && $1 != "kube-public" && $1 != "kube-system" {print $1}')

# Loop through each namespace and check for deprecated APIs
for namespace in $namespaces; do
  namespace_dir="$EXPORT_DIR/$namespace"
  if [ -d "$namespace_dir" ]; then
    check_deprecated_apis "$namespace_dir"
  else
    echo "Directory $namespace_dir does not exist. Skipping..."
  fi
done
