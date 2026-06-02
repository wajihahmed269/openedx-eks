#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/envs/dev"

echo "Showing destroy plan for dev environment..."
terraform plan -destroy

echo
echo "If the plan looks correct, run:"
echo "terraform destroy"
