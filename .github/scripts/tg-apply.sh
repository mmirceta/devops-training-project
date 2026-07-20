#!/usr/bin/env bash
set -euo pipefail

module_dir=$1
plan_out_dir=$2

cd "$module_dir"

terragrunt run-all apply \
  --terragrunt-non-interactive \
  --terragrunt-parallelism 1 \
  --terragrunt-out-dir "$plan_out_dir"
