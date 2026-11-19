variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=temporalio/temporal
  default = "v1.32.2"
}
variable "UPSTREAM_COMMIT" {
  default = "6d085822273f4336796e6959c73ab1d14a23eb77"
}

variable "UPSTREAM_CLI_TAG" {
  # renovate: datasource=github-tags depName=temporalio/cli
  default = "v1.10.1"
}
variable "UPSTREAM_CLI_COMMIT" {
  default = "915a6e982d587c8b40feb3d82c3d8947c8e9e742"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO       = "https://github.com/temporalio/temporal"
    UPSTREAM_CLI_REPO   = "https://github.com/temporalio/cli"
    UPSTREAM_TAG        = UPSTREAM_TAG
    UPSTREAM_COMMIT     = UPSTREAM_COMMIT
    UPSTREAM_CLI_TAG    = UPSTREAM_CLI_TAG
    UPSTREAM_CLI_COMMIT = UPSTREAM_CLI_COMMIT
  }
  tags = ["ghcr.io/plainimages/temporal-admintools:${UPSTREAM_TAG}"]
}
