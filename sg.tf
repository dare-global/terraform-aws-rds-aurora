resource "aws_security_group" "main" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name_prefix}-"

  description = "Inbound and outbound traffic to ${var.database_name} RDS database"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge(
    var.security_group_tags,
    {
      Name = var.name_prefix
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  description = "Ingress for RDS cluster"

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.main[0].id
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "default_egress" {
  type              = "egress"
  description       = "Default egress for RDS cluster"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main[0].id
}
