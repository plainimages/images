target "default" {
  name    = "go-${replace(v, ".", "-")}"
  matrix  = {
    v = ["1.27"]
  }
  context = "."
  args    = { SEMVER_VERSION = v }
  tags    = ["ghcr.io/plainimages/go:${v}"]
}
