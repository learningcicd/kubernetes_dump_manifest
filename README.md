#!/bin/bash

# Define the export directory path
EXPORT_DIR="/c/Users/Amir/export-demo"

# Create the directory if it doesn't exist
mkdir -p "$EXPORT_DIR"

# Function to check if resources exist and are in the desired state
check_and_export() {
  local resource_type=$1
  local namespace=$2
  local export_dir=$3

  echo "Checking for $resource_type in namespace $namespace..."

  case $resource_type in
    "pods")
      kubectl get pods -n "$namespace" --field-selector=status.phase=Running --no-headers | grep -q "Running" && {
        echo "Exporting running pods..."
        kubectl get pods -n "$namespace" -o yaml --field-selector=status.phase=Running > "$export_dir/pods.yaml"
      } || echo "No running pods found in namespace $namespace."
      ;;
    "services")
      kubectl get services -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting services..."
        kubectl get services -n "$namespace" -o yaml > "$export_dir/services.yaml"
      } || echo "No services found in namespace $namespace."
      ;;
    "deployments")
      kubectl get deployments -n "$namespace" --no-headers | awk '$2 > 0' | grep -q . && {
        echo "Exporting available deployments..."
        kubectl get deployments -n "$namespace" -o yaml > "$export_dir/deployments.yaml"
      } || echo "No available deployments found in namespace $namespace."
      ;;
    "statefulsets")
      kubectl get statefulsets -n "$namespace" --no-headers | awk '$2 > 0' | grep -q . && {
        echo "Exporting available statefulsets..."
        kubectl get statefulsets -n "$namespace" -o yaml > "$export_dir/statefulsets.yaml"
      } || echo "No available statefulsets found in namespace $namespace."
      ;;
    "daemonsets")
      kubectl get daemonsets -n "$namespace" --no-headers | awk '$2 > 0' | grep -q . && {
        echo "Exporting available daemonsets..."
        kubectl get daemonsets -n "$namespace" -o yaml > "$export_dir/daemonsets.yaml"
      } || echo "No available daemonsets found in namespace $namespace."
      ;;
    "jobs")
      kubectl get jobs -n "$namespace" --no-headers | awk '$3 == "Complete"' | grep -q . && {
        echo "Exporting succeeded jobs..."
        kubectl get jobs -n "$namespace" -o yaml --field-selector=status.succeeded>0 > "$export_dir/jobs.yaml"
      } || echo "No succeeded jobs found in namespace $namespace."
      ;;
    "configmaps")
      kubectl get configmaps -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting configmaps..."
        kubectl get configmaps -n "$namespace" -o yaml > "$export_dir/configmaps.yaml"
      } || echo "No configmaps found in namespace $namespace."
      ;;
    "secrets")
      kubectl get secrets -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting secrets..."
        kubectl get secrets -n "$namespace" -o yaml > "$export_dir/secrets.yaml"
      } || echo "No secrets found in namespace $namespace."
      ;;
    "clusterrolebindings")
      kubectl get clusterrolebindings --no-headers | grep -q "namespace: $namespace" && {
        echo "Exporting clusterrolebindings..."
        kubectl get clusterrolebindings -o yaml > "$export_dir/clusterrolebindings.yaml"
      } || echo "No ClusterRoleBindings found."
      ;;
    "rolebindings")
      kubectl get rolebindings -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting rolebindings..."
        kubectl get rolebindings -n "$namespace" -o yaml > "$export_dir/rolebindings.yaml"
      } || echo "No RoleBindings found in namespace $namespace."
      ;;
    "ingresses")
      kubectl get ingresses -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting ingresses..."
        kubectl get ingresses -n "$namespace" -o yaml > "$export_dir/ingresses.yaml"
      } || echo "No ingresses found in namespace $namespace."
      ;;
    "pv")
      kubectl get pv --no-headers | grep -q . && {
        echo "Exporting persistent volumes..."
        kubectl get pv -o yaml > "$export_dir/pv.yaml"
      } || echo "No PersistentVolumes found."
      ;;
    "pvc")
      kubectl get pvc -n "$namespace" --no-headers | grep -q . && {
        echo "Exporting persistent volume claims..."
        kubectl get pvc -n "$namespace" -o yaml > "$export_dir/pvc.yaml"
      } || echo "No PersistentVolumeClaims found in namespace $namespace."
      ;;
    *)
      echo "Resource type $resource_type is not supported."
      ;;
  esac
}

# List of resource types to export
RESOURCE_TYPES=(
  "pods"
  "services"
  "deployments"
  "statefulsets"
  "daemonsets"
  "jobs"
  "configmaps"
  "secrets"
  "clusterrolebindings"
  "rolebindings"
  "ingresses"
  "pv"
  "pvc"
)

# Get list of namespaces except 'default', 'kube-node-lease', 'kube-public', and 'kube-system'
namespaces=$(kubectl get namespaces --no-headers | awk '$1 != "default" && $1 != "kube-node-lease" && $1 != "kube-public" && $1 != "kube-system" {print $1}')

# Loop through each namespace and export resources
for namespace in $namespaces; do
  namespace_dir="$EXPORT_DIR/$namespace"
  mkdir -p "$namespace_dir"
  for resource_type in "${RESOURCE_TYPES[@]}"; do
    check_and_export "$resource_type" "$namespace" "$namespace_dir"
  done
done
