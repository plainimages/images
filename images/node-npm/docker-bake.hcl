target "default" {
  name    = "node-npm-${replace(version, ".", "-")}"
  context = "."
  matrix  = {
    version = ["24", "26"]
  }
  args = {
    NODE_VERSION = version
  }
  tags = ["ghcr.io/plainimages/node-npm:${version}"]
}
