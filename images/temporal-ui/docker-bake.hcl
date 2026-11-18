variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=temporalio/ui
  default = "v2.58.1"
}
variable "UPSTREAM_COMMIT" {
  default = "32edd95c5d2e09d5fceaecbe9d4277c794b6df48"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/temporalio/ui"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  tags = ["ghcr.io/plainimages/temporal-ui:${UPSTREAM_TAG}"]
}
