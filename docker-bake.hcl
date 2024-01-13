# Docker Buildx Bake build definition file
# Reference: https://github.com/docker/buildx/blob/master/docs/reference/buildx_bake.md

variable "REGISTRY_NAME" {
  default = "ghcr.io"
}

variable "REGISTRY_USER" {
    default = "tacten"
}

variable "REPO" {
    default = "s3-backup"
}

variable "VERSION" {
  default = "v1.0"
}

group "default" {
    targets = ["s3-backup"]
}

function "tag" {
    params = [repo, version]
    result = [
      # If `version` param is develop (development build) then use tag `latest`
      "${version}" == "develop" ? "${REGISTRY_NAME}/${REGISTRY_USER}/${repo}:latest" : "${REGISTRY_NAME}/${REGISTRY_USER}/${repo}:${version}",
      # Make short tag for major version if possible. For example, from v13.16.0 make v13.
      can(regex("(v[0-9]+)[.]", "${version}")) ? "${REGISTRY_NAME}/${REGISTRY_USER}/${repo}:${regex("(v[0-9]+)[.]", "${version}")[0]}" : "",
    ]
}

target "default-args" {
    args = {
        
    }
}

target "s3-backup" {
    inherits = ["default-args"]
    context = "."
    dockerfile = "Dockerfile"
    target = "cron"
    tags = tag("${REPO}", "${VERSION}")
}