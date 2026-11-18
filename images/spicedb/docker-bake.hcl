variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=authzed/spicedb
  default = "v1.57.1"
}
variable "UPSTREAM_COMMIT" {
  default = "7074da7242e5aedfeb4586d93a403eca45388ada"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/authzed/spicedb"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  tags = ["ghcr.io/plainimages/spicedb:${UPSTREAM_TAG}"]
}
