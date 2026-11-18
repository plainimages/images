variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=BerriAI/litellm
  default = "v1.109.1"
}
variable "UPSTREAM_COMMIT" {
  default = "6c4ead4fc064d14e36b0c69d6795acc130c866bf"
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
