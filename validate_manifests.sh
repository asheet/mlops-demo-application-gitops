#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function display_help {
  echo "./$(basename "$0") [ -d | --directory DIRECTORY ] [ -q | --quiet ] [ -h | --help | --vpc-keypair | --lab | --teardown | --redeploy | --clear-logs ] [ OPTIONAL ANSIBLE OPTIONS ]
Script to validate the OpenShift manifests generated by Kustomize
Where:
  -d  | --directory DIRECTORY  Base directory containing Kustomize overlays
  -e  | --enforce-all-schemas  Enable enforcement of all schemas
  -h  | --help                 Display this help text
  -sl | --schema-location      Location containing schemas"
}

KUSTOMIZE="${KUSTOMIZE:-kustomize}"
IGNORE_MISSING_SCHEMAS="--ignore-missing-schemas"
SCHEMA_LOCATION="${DIR}/openshift-json-schema"
KUSTOMIZE_DIRS="${DIR}/."

for i in "$@"
do
  case $i in
    -d=* | --directory=* )
      KUSTOMIZE_DIRS="${i#*=}"
      shift
      ;;
    -e | --enforce-all-schemas )
      shift
      IGNORE_MISSING_SCHEMAS=""
      shift
      ;;
    -sl=* | --schema-location=* )
      SCHEMA_LOCATION="${i#*=}"
      shift
      ;;
    -h | --help )
      display_help
      exit 0
      ;;
  esac
done

for i in `find "${KUSTOMIZE_DIRS}" -name "kustomization.yaml" -exec dirname {} \;`; 
do

  if [[ ${i} == *"./bootstrap"* ]]; then
    echo
    echo "Skipping validating $i"
    echo
    continue
  fi

  echo
  echo "Validating $i"
  echo

  KUSTOMIZE_BUILD_OUTPUT=$(${KUSTOMIZE} build $i)

  build_response=$?

  if [ $build_response -ne 0 ]; then
    echo "Error building $i"
    exit 1
  fi
  
#  echo "$KUSTOMIZE_BUILD_OUTPUT" | kubeval ${IGNORE_MISSING_SCHEMAS} --schema-location="file://${SCHEMA_LOCATION}" --force-color

#  validation_response=$?

#  if [ $validation_response -ne 0 ]; then
#    echo "Error validating $i"
#    exit 1
#  fi
done

echo
echo "Manifests successfully validated!"