variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=BerriAI/litellm
  default = "v1.110.1"
}
variable "UPSTREAM_COMMIT" {
  default = "47b394ba1b5bbe7f4b3f119a95b56957f4a32fad"
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
