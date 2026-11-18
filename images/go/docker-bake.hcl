target "default" {
  name    = "go-${replace(version, ".", "-")}"
  matrix  = {
    version = ["1.26", "1.27"]
  }
  context = "."
  args    = {
    SEMVER_VERSION = version
  }
  tags    = ["ghcr.io/plainimages/go:${version}"]
}
