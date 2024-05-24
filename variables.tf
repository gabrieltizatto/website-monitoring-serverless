variable "function_name" {
    type = string
}

variable "sender_email" {
    type = string
}

variable "recipient_emails" {
  type = list(string)
}

variable "websites" {
  type = list(object({
    name = string
    url  = string
  }))
}

variable "monitoring_rate" {
    type = string
}