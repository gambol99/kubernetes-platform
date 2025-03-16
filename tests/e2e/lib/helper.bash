#!/usr/bin/env bash
#

# Retry a command $1 times until it succeeds. If a second command is given, it will be run on the output of the first command.
retry() {
  local attempts
  local cmd
  local subcmd

  if [ $# -gt 3 ]; then
    echo "Invalid number of arguments for retry: \"$*\" ($#)"
    exit 1
  fi

  attempts=$1
  shift
  cmd=$1
  shift

  local delay=5
  local i
  local result

  for ((i = 1; i <= attempts; i++)); do
    run bash -c "$cmd"
    result="${output}"

    run bash -c "${subcmd}" < <(echo -n "${result}")
    if [[ ${status} -eq 0   ]]; then
      echo "${output}"
      return 0
    fi

    if [[ $i -lt $attempts ]]; then
      sleep $delay
    fi
  done

  printf "Error: command \"%s\" (subcommand: \"%s\") failed %d times\nStatus: %s\nOutput: %s\n" "${cmd}" "${subcmd}" "${attempts}" "${status}" "${result}" | sed 's/WAYFINDER_TOKEN=.* //' >&2
  false
}

runit() {
  retry 5 "$@"
}

kubectl_argocd() {
  runit "kubectl -n argocd $@"
}

kubectl() {
  runit "kubectl $@"
}
