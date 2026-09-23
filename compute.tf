# 1. El Balanceador de Carga (Público)
resource "aws_lb" "alb_portfolio" {
  name               = "ALB-Portfolio"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = aws_subnet.publicas[*].id # Lo conectamos a las 2 subredes públicas
}

# 2. Target Group (El grupo donde el ALB mandará el tráfico)
resource "aws_lb_target_group" "tg_portfolio" {
  name     = "TG-Portfolio"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.red_principal.id
}

# 3. Listener (El que "escucha" en el ALB y lo manda al Target Group)
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb_portfolio.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_portfolio.arn
  }
}

# 4. Plantilla de Lanzamiento (La "receta" para fabricar máquinas)
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # ID de la cuenta oficial de Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "aws_launch_template" "plantilla_backend" {
  name_prefix   = "Plantilla-Backend-"
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = var.tipo_instancia

  vpc_security_group_ids = [aws_security_group.sg_privado.id]

  # Aquí inyectamos el script de Docker que creaste en el Paso 1
  user_data = filebase64("${path.module}/init.sh")

  # Aquí definimos el disco EBS extra (20GB) para cumplir tu petición
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }
}

# 5. El Grupo de Autoescalado (El mánager que crea y destruye máquinas)
resource "aws_autoscaling_group" "asg_portfolio" {
  name                = "ASG-Portfolio"
  vpc_zone_identifier = aws_subnet.privadas[*].id # Las reparte en las 2 subredes privadas
  target_group_arns   = [aws_lb_target_group.tg_portfolio.arn] # Las engancha al ALB

  # Tu petición: 4 máquinas en total (Como hay 2 subredes, pondrá 2 en cada una automáticamente)
  desired_capacity = var.capacidad_minima_asg
  max_size         = var.capacidad_maxima_asg
  min_size         = var.capacidad_minima_asg

  launch_template {
    id      = aws_launch_template.plantilla_backend.id
    version = "$Latest"
  }
}

# Para que nos devuelva la URL del balanceador al terminar
output "url_balanceador" {
  value = "http://${aws_lb.alb_portfolio.dns_name}"
}
