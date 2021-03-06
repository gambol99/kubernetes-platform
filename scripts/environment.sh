#!/bin/bash -x
#
#  vim:ts=2:sw=2:et
#
[[ -n "${DEBUG}" ]] && set -x

export NC='\e[0m'
export YELLOW='\e[0;33m'
export RED='\e[0;31m'
export ENVIRONMENT_FILE=${ENVIRONMENT_FILE:-"env.tfvars"}
export TERRAFORM_CONFD="${WORKDIR}/terraform/.config.d"

log() {
  (2>/dev/null echo -e "$@")
}
annonce() { log "[v] --> $@"; }
failed()  { log "[failed] $@" && exit 1; }
error()   { log "[error] $@"; }

# generate_password generates a random password
generate_password() {
  echo $(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c ${1:-24})
}

# terraform_get_config is responsible for getting the config from the environment file
terraform_get_config() {
  config_value=$(hcltool ${ENVIRONMENT_FILE} 2>/dev/null | jq -r ".${1}")
  echo $config_value
}

# prompt_assurance interactively prompts user for ensure they meant it
prompt_assurance() {
  local message="$1"
  local play_check="$2"
  [[ -z "${message}" ]] && return 1
  echo -n -e "${message} (yes/no) "; read choice
  # check: unless yes or y return 1
  [[ ! "${choice}" =~ ^(yes|[yY])$ ]] && return 1
  # check: are we double checking
  if [[ "${play_check}" == true && ! "${PLATFORM_ENV}" =~ ^play.*$ ]]; then
    echo -n -e "Are you ${YELLOW}ABSOLUTELY SURE${NC}, given this is a non-playground account? (yes/no) "; read sure
    [[ "${sure}" =~ ^(yes|[yY])$ ]] || return 1
  fi
  return 0
}

# setup_environment is responsible for prepping a playground environment if required
setup_environment() {
  mkdir -p ${WORKDIR}/terraform
  # step: check all the environment variables as been passed
  for env in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION PLATFORM_ENV; do
    [[ -z "${!env}" ]] && error "you have supplied the ${env} variable on entry"
  done
  # step: check if we are entering a playground
  [[ -d "${TERRAFORM_CONFD}" ]] || failed "you have not mapped your terraform files into: ${TERRAFORM_CONFD}"
  # step: I really don't like this, not i'm not sure how else to provide the functionality
  ln -sf ${TERRAFORM_CONFD}/* ${WORKDIR}/terraform || failed "unable to symlink the environment into the terraform directory"
}

# step: setup the environment
setup_environment

export PLATFORM_ENV=$(terraform_get_config "environment")
export ENVIRONMENT=${PLATFORM_ENV}
export CONFIG_ENVIRONMENT=${ENVIRONMENT}
export CONFIG_AWS_KMS_ID=$(terraform_get_config "kms_master_id")
export CONFIG_DNS_ZONE_NAME=$(terraform_get_config "public_zone_name")
export CONFIG_PRIVATE_ZONE_NAME=$(terraform_get_config "private_zone_name")
export CONFIG_SECRET_BUCKET_NAME=$(terraform_get_config "secrets_bucket_name")
export CONFIG_TERRAFORM_S3_BUCKET=$(terraform_get_config "terraform_bucket_name")
export CONFIG_KUBEAPI_HOSTNAME=$(terraform_get_config "kubeapi_dns")
export CONFIG_KUBEAPI_INTERNAL_HOSTNAME=$(terraform_get_config "kubeapi_internal_dns")
export SECRETS_DIR="secrets"
export KEYPAIR_NAME="${SECRETS_DIR}/locked/${PLATFORM_ENV}"
export KEYPAIR_PRIVATE="${KEYPAIR_NAME}"
export KEYPAIR_PUBLIC="${KEYPAIR_NAME}.pem"
export TERRAFORM=${TERRAFORM:-"/opt/terraform/terraform"}
export TERRAFORM_VAR_FILES="-var-file=../${ENVIRONMENT_FILE}"
export TERRAFORM_BUCKET=${CONFIG_TERRAFORM_S3_BUCKET:-""}
export TERRAFORM_OPTIONS=${CONFIG_TERRAFORM_OPTIONS:-"-parallelism=10"}
export AWS_BUCKET=${CONFIG_SECRET_BUCKET_NAME}
export AWS_KMS_ID=${CONFIG_AWS_KMS_ID}
export AWS_S3_BUCKET=${CONFIG_SECRET_BUCKET_NAME}
export TF_VAR_aws_region=${AWS_DEFAULT_REGION}

[[ -z "${PLATFORM_ENV}"     ]] && failed "you need to specify the environment stack, i.e. dev, prod etc"
[[ -z "${TERRAFORM_BUCKET}" ]] && failed "you have specified a terraform bucket ('terraform_bucket_name') for remote state"

# step: export the terraform variables
#while IFS='=' read NAME VALUE; do
#  TF_NAME=$(echo ${NAME/CONFIG_/} | tr 'A-Z' 'a-z')
#  TF_VALUE=$(echo $VALUE | sed -e "s/[\"']//g")
#  export TF_VAR_${TF_NAME}="${TF_VALUE}"
#done < <(set | grep ^CONFIG_)

mkdir -p ${SECRETS_DIR}/{secure,compute,common,locked}
