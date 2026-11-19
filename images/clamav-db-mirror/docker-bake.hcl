target "default" {
  name    = "clamav-db-mirror-${replace(v, ".", "-")}"
  matrix  = {
    v = ["v0.1.1"]
  }
  context = "."
  args    = { UPSTREAM_TAG = v }
  tags    = ["ghcr.io/plainimages/clamav-db-mirror:${v}"]
}
