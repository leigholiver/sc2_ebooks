# Twitter API keys
variable "CONSUMER_KEY" {
  type = string
}

variable "CONSUMER_SECRET" {
  type = string
}

variable "ACCESS_KEY" {
  type = string
}

variable "ACCESS_SECRET" {
  type = string
}

# path to build zip file to
variable "lambda_zip" {
  default = "lambda.zip"
}