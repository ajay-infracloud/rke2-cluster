resource "aws_eip" "rancher" {
  domain   = "vpc"
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.rke2_server.id
  allocation_id = aws_eip.rancher.id

  depends_on = [ aws_instance.rke2_server ]
}