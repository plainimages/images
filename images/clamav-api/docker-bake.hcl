variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=DevHatRo/ClamAV-API
  default = "v2.0.1"
}
variable "UPSTREAM_COMMIT" {
  default = "9b58a636e6251ce2e35929ddb85ce536229e4942"
}

target "default" {
  name    = "clamav-api-${UPSTREAM_TAG}"
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/DevHatRo/ClamAV-API"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
    GO_IMAGE        = "registry.gitlab.com/pm-group9694646/plainimages/go:1.27"
  }
  tags = ["ghcr.io/plainimages/clamav-api:${UPSTREAM_TAG}"]
}
