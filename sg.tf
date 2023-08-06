resource "aws_security_group" "instances_security_group" {
  name        = "instances-sg"
  description = "SG for cluster"

  dynamic "ingress"{
      for_each = var.ingress_ports
      content {
        from_port = ingress.value
        to_port   = ingress.value
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
}