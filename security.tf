# 1. Security Group para recursos en la Subred Pública (ej. Bastión)
resource "aws_security_group" "sg_publico" {
  name        = "SG-Publico-Portfolio"
  description = "Permite acceso SSH desde el exterior"
  vpc_id      = aws_vpc.red_principal.id

  # Reglas de entrada (Ingress)
  ingress {
    description = "SSH desde Internet (Solo para pruebas)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida (Egress) - Permite salir a internet para descargar actualizaciones
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Publico"
  }
}

# 2. Security Group para recursos en la Subred Privada (Backend / Base de datos)
resource "aws_security_group" "sg_privado" {
  name        = "SG-Privado-Portfolio"
  description = "Solo acepta trafico desde el SG Publico"
  vpc_id      = aws_vpc.red_principal.id

  ingress {
    description     = "HTTP desde el Balanceador"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Privado"
  }
}

# 3. Security Group para el Balanceador de Carga (ALB)
resource "aws_security_group" "sg_alb" {
  name        = "SG-ALB-Portfolio"
  description = "Permite trafico HTTP desde Internet"
  vpc_id      = aws_vpc.red_principal.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
