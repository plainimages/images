target "default" {
  name    = "python-${replace(v, ".", "-")}"
  matrix  = {
    v = ["3.12", "3.13"]
  }
  context = "."
  args    = { SEMVER_VERSION = v }
  tags    = ["ghcr.io/plainimages/python:${v}"]
}
