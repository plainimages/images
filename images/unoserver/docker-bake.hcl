variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=unoconv/unoserver
  default = "3.7"
}
variable "UPSTREAM_COMMIT" {
  default = "624b39f470b5d739e412ecc1909c3f532b7bd0bb"
}

target "default" {
  context = "."
  args = {
    UPSTREAM_REPO   = "https://github.com/unoconv/unoserver"
    UPSTREAM_TAG    = UPSTREAM_TAG
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  tags = ["ghcr.io/plainimages/unoserver:${UPSTREAM_TAG}"]
}
