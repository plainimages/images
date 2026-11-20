variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=BerriAI/litellm
  default = "v1.110.2"
}
variable "UPSTREAM_COMMIT" {
  default = "c3cafa3782642685ef10777e4c5931400c0a7176"
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
