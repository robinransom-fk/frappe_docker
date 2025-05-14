# Docker Buildx Bake build definition file for HRMS
variable "REGISTRY_USER" {
    default = "robinfk"
}

variable "PYTHON_VERSION" {
    default = "3.10.12"
}

variable "NODE_VERSION" {
    default = "18.12.0"
}

variable "FRAPPE_VERSION" {
    default = "version-15"
}

variable "ERPNEXT_VERSION" {
    default = "version-15"
}

variable "HRMS_VERSION" {
    default = "version-15"
}

variable "FRAPPE_REPO" {
    default = "https://github.com/frappe/frappe"
}

variable "ERPNEXT_REPO" {
    default = "https://github.com/frappe/erpnext"
}

variable "HRMS_REPO" {
    default = "https://github.com/frappe/hrms"
}

variable "BENCH_REPO" {
    default = "https://github.com/frappe/bench"
}

# Main target groups
group "default" {
    targets = ["hrms"]
}

# Function to generate appropriate tags
function "tag" {
    params = [repo, version]
    result = [
      # Push standard version tag
      "${REGISTRY_USER}/${repo}:${version}",
      # If `version` is a version tag (starts with v), use 'latest' tag as well
      startswith("${version}", "v") ? "${REGISTRY_USER}/${repo}:latest" : "",
      # Make short tag for major version if possible. For example, from v15.5.0 make v15
      can(regex("(v[0-9]+)[.]", "${version}")) ? "${REGISTRY_USER}/${repo}:${regex("(v[0-9]+)[.]", "${version}")[0]}" : "",
    ]
}

# Default arguments for all targets
target "default-args" {
    args = {
        FRAPPE_PATH = "${FRAPPE_REPO}"
        ERPNEXT_PATH = "${ERPNEXT_REPO}"
        HRMS_PATH = "${HRMS_REPO}"
        BENCH_REPO = "${BENCH_REPO}"
        FRAPPE_BRANCH = "${FRAPPE_VERSION}"
        ERPNEXT_BRANCH = "${ERPNEXT_VERSION}"
        HRMS_BRANCH = "${HRMS_VERSION}"
        PYTHON_VERSION = "${PYTHON_VERSION}"
        NODE_VERSION = "${NODE_VERSION}"
        # Set this to avoid interactive prompts during build
        APPS_JSON_BASE64 = ""
    }
}

# HRMS target - the main one we want to build
target "hrms" {
    inherits = ["default-args"]
    context = "."
    dockerfile = "images/custom/Containerfile"
    tags = tag("hrms", substr("${HRMS_VERSION}", 8, 999))  # Remove 'version-' prefix
}
