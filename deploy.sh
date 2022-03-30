#!/usr/bin/env bash

set -e
set -u

source ./.environment
environment=""
stack=""
mode="help"
cli_arguments=""
run_all=""
confirm=""
function print_help() {
  echo "help"
}
function clean_tf() {
  echo "Cleaning up old terraform files"
  old_tf_files=$(find . \( -iname "cache" ! -iname ".terraform" ! -iname ".terraform-docs*" ! -iname ".terragrunt-cache" \))

  for path in $old_tf_files; do
    echo "Found directory under $path. Deleting"
    rm -rf -- "$path"
  done
}
function execute_tf() {
  echo "Starting to execute terragrunt"
  pushd "./environment/$environment/$stack"
  command="terragrunt $run_all $mode $cli_arguments"
  echo "Going to execute $command"
  if [ -z $confirm ]; then
    echo "Do you want to start the execution?"
    read -r confirm
  fi

  if  test "$confirm" = "yes"  || test "$confirm" = "y"; then
    $command
  fi
  popd
}
function start() {
  echo "Starting deployment"
  echo "Environment: $environment"
  echo "Stack: $stack"
  if [ -z "$environment" ]; then
    echo "No environment found"
    echo "Please specify your environment with parameter -e"
    exit 1
  fi
#  if [ -z "$stack" ]; then
#    echo "No stack found"
#    echo "Please specify your stack with parameter -s"
#    exit 1
#  fi
}
while getopts e:m:dacs flag; do
  case "${flag}" in
  a) run_all="run-all" ;;
  e) environment=${OPTARG} ;;
  s) stack=${OPTARG} ;;
  m) mode=${OPTARG} ;;
  d) cli_arguments="--terragrunt-log-level debug --terragrunt-debug" ;;
  c) confirm="yes" ;;
  esac
done

if [ "$mode" == "help" ]; then
  print_help
  exit 0
fi

start
clean_tf
execute_tf
