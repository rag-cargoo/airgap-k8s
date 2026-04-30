resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "SSH access to bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Admin SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-sg"
  })
}

resource "aws_security_group" "k8s_nodes" {
  name        = "${local.name_prefix}-k8s-sg"
  description = "Shared SG for master and worker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "Node-to-node traffic"
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k8s-sg"
  })
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
    Role = "bastion"
  })
}

resource "aws_instance" "master" {
  ami                         = var.ami_id
  instance_type               = var.node_instance_type
  subnet_id                   = aws_subnet.private.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.k8s_nodes.id]
  associate_public_ip_address = false

  tags = merge(local.common_tags, {
    Name = "k8s-master"
    Role = "master"
  })
}

resource "aws_instance" "worker1" {
  ami                         = var.ami_id
  instance_type               = var.node_instance_type
  subnet_id                   = aws_subnet.private.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.k8s_nodes.id]
  associate_public_ip_address = false

  tags = merge(local.common_tags, {
    Name = "k8s-worker1"
    Role = "worker"
  })
}
