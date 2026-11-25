variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=BerriAI/litellm
  default = "v1.111.0"
}
variable "UPSTREAM_COMMIT" {
  default = "e3370c9d6152cc4407a55e06c101e3c7dd4168ab"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/BerriAI/litellm"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  tags = ["ghcr.io/plainimages/litellm:${UPSTREAM_TAG}"]
}
