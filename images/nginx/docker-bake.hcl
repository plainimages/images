target "default" {
  name    = "nginx-${replace(v, ".", "-")}"
  matrix  = {
    v = ["mainline"]
  }
  context = "."
  args    = { UPSTREAM_TAG = v }
  tags    = ["ghcr.io/plainimages/nginx:${v}"]
}
