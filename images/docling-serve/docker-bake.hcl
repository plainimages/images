variable "UPSTREAM_TAG" {
  # renovate: datasource=github-tags depName=docling-project/docling-serve
  default = "v1.40.0"
}
variable "UPSTREAM_COMMIT" {
  default = "5c101b6c67cd57e662e9abfebee7d2a6fc2b0cb4"
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
