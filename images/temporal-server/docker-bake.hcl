variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=temporalio/temporal
  default = "v1.32.2"
}
variable "UPSTREAM_COMMIT" {
  default = "6d085822273f4336796e6959c73ab1d14a23eb77"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/temporalio/temporal"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  tags = ["ghcr.io/plainimages/temporal-server:${UPSTREAM_TAG}"]
}
