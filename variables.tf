variable "tipo_instancia" {
  description = "El tamaño de las maquinas virtuales EC2"
  type        = string
}

variable "capacidad_minima_asg" {
  description = "Numero minimo de maquinas en el Autoescalado"
  type        = number
  default     = 2
}

variable "capacidad_maxima_asg" {
  description = "Numero maximo de maquinas permitidas en picos de trafico"
  type        = number
  default     = 6
}
