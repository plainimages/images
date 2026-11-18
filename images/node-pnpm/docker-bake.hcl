target "default" {
  name    = "node-pnpm-${replace(item.image_tag, ".", "-")}"
  context = "."
  matrix  = {
    item = [
      {
        node_version = "22~22.23"
        pnpm_version = "10.10"
        image_tag    = "22.23-10.10"
      },
      {
        node_version = "22"
        pnpm_version = "11"
        image_tag    = "22-10"
      },
      {
        node_version = "24"
        pnpm_version = "11.28.10"
        image_tag    = "24-11.28.10"
      }
    ]
  }
  args = {
    NODE_VERSION = item.node_version
    PNPM_VERSION = item.pnpm_version
  }
  tags = ["ghcr.io/plainimages/node-pnpm:${item.image_tag}"]
}
