data "template_file" "rke2_config" {
  template = file("${path.cwd}/rke2_config.tpl")
  vars = {
    eip   = aws_eip.rancher.public_ip
  }
}