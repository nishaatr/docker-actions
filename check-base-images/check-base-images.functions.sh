# shellcheck source=../.github/scripts/logging.functions.sh
. .github/scripts/logging.functions.sh

# Determine if the packages in the specified image are updatable
# Returns exit code:
# 0 if the packages in the image are updatable
# 1 if the packages in the image is up-to-date
function packages_updatable_from_dockerfile() {
  local image=$1
  local dockerfile=$2

  local base_image_name
  base_image_name=$(get_base_image_name "${dockerfile}")
  packages_updatable "${image}" "${base_image_name}"
}

# Determine if the packages in the specified image are updatable
# Returns exit code:
# 0 if the packages in the image are updatable
# 1 if the packages in the image is up-to-date
function packages_updatable() {
  local image=$1
  local base_image=$2

  local output

  if [[ "${base_image}" == *"alpine"* ]]; then
    output=$(docker run --user 0 --rm "${image}" sh -c 'apk update >/dev/null && apk list --upgradeable')

    if [[ -n "${output}" ]]; then
      echonotice "${output}"
      return 0
    else
      echodebug "${output}"
      return 1
    fi
  elif [[ "${base_image}" == *"redhat/ubi"* ]]; then
    # use assumeno as a workaround for lack of dry-run option
    output=$(docker run --user 0 --rm "${image}" sh -c "microdnf --assumeno upgrade --nodocs")

    local package_upgrades_count
    package_upgrades_count=$(grep --count Upgrading <<< "${output}")

    if [[ "${package_upgrades_count}" -ne 0 ]]; then
      echonotice "${output}"
      return 0
    else
      echodebug "${output}"
      return 1
    fi
  else
    echoerr "Unsupported base image: ${base_image}"
    exit 1
  fi
}

# Returns the base image of the specified Dockerfile
function get_base_image_name() {
  local dockerfile=$1

  # Read the (implicitly first) `FROM` line
  local line
  line=$(grep '^FROM ' "${dockerfile}")
  cut -d' ' -f2 <<< "${line}"
}

# Determine if the specified image is outdated when compared to it's base image
# Returns exit code:
# 0 if the current image is outdated compared to the base image
# 1 if the current image is up-to-date compared to the base image
function base_image_outdated_from_dockerfile() {
  local current_image=$1
  local dockerfile=$2

  local base_image_name
  base_image_name=$(get_base_image_name "${dockerfile}")
  base_image_outdated "${current_image}" "${base_image_name}"
}

# Determine if the specified image is outdated when compared to it's base image
# Returns exit code:
# 0 if the current image is outdated compared to the base image
# 1 if the current image is up-to-date compared to the base image
function base_image_outdated() {
  local current_image=$1
  local base_image=$2

  local base_image_sha
  base_image_sha=$(get_base_image_sha "${base_image}")
  local current_image_sha
  current_image_sha=$(get_base_image_sha "${current_image}")

  local message="${current_image} has SHA ${current_image_sha}, compared to SHA ${base_image_sha} of ${base_image}"

  if [[ "${current_image_sha}" == "${base_image_sha}" ]]; then
    echodebug "${message}"
    return 1
  else
    echonotice "${message}"
    return 0
  fi
}

function get_base_image_sha() {
  local image=$1
  docker pull "${image}" >/dev/null
  docker image inspect --format '{{index .RootFS.Layers 0}}' "${image}"
}
