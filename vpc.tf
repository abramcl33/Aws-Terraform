# 1. La VPC (La red global de tu empresa)
resource "aws_vpc" "red_principal" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Portfolio-DevOps"
  }
}

# 2. El Internet Gateway (La puerta de salida a internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.red_principal.id

  tags = {
    Name = "IGW-Portfolio"
  }
}

# 3. Subredes Públicas (2 Zonas de Disponibilidad)
resource "aws_subnet" "publicas" {
  count                   = 2
  vpc_id                  = aws_vpc.red_principal.id
  cidr_block              = "10.0.${count.index}.0/24" # Genera 10.0.0.0/24 y 10.0.1.0/24
  availability_zone       = "us-east-1${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true # Asigna IPs públicas automáticamente

  tags = {
    Name = "Subred-Publica-${count.index + 1}"
  }
}

# 4. Subredes Privadas (2 Zonas de Disponibilidad)
resource "aws_subnet" "privadas" {
  count             = 2
  vpc_id            = aws_vpc.red_principal.id
  cidr_block        = "10.0.${count.index + 10}.0/24" # Genera 10.0.10.0/24 y 10.0.11.0/24
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "Subred-Privada-${count.index + 1}"
  }
}

# 5. Tabla de Rutas Pública (Para que las subredes públicas salgan por el IGW)
resource "aws_route_table" "tabla_publica" {
  vpc_id = aws_vpc.red_principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Tabla-Rutas-Publica"
  }
}

# 6. Asociar las subredes públicas a la tabla de rutas
resource "aws_route_table_association" "asociacion_publica" {
  count          = 2
  subnet_id      = aws_subnet.publicas[count.index].id
  route_table_id = aws_route_table.tabla_publica.id
}
