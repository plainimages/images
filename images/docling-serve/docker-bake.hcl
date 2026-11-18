variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=docling-project/docling-serve
  default = "v1.38.2"
}
variable "UPSTREAM_COMMIT" {
  default = "9c058dbb58f61021e3a16e37edb8a7527b2cb2d4"
}

target "default" {
  name    = "docling-serve${item.tag}"
  context = "."
  matrix  = {
    item = [
      {
        tag     = "-cpu"
        uv_args = "--no-group pypi --group cpu --no-extra flash-attn"
      },
      {
        tag     = "-cu128"
        uv_args = "--no-group pypi --group cu128"
      }
    ]
  }
  args = {
    UPSTREAM_REPO      = "https://github.com/docling-project/docling-serve"
    UPSTREAM_TAG       = UPSTREAM_TAG
    UPSTREAM_COMMIT    = UPSTREAM_COMMIT
    UV_SYNC_EXTRA_ARGS = item.uv_args
    BASE_IMAGE         = "registry.gitlab.com/pm-group9694646/plainimages/python:3.12"
    NODE_IMAGE         = "registry.gitlab.com/pm-group9694646/plainimages/node-npm:24"
  }
  tags = ["ghcr.io/plainimages/docling-serve:${UPSTREAM_TAG}${item.tag}"]
}
