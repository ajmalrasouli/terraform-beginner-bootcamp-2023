variable "user_uuid" {
 type = string
}

variable "bucket_name" {
 type = string
}

variable "index_html_filepath" {
  description = "The file path for index.html"
  type        = string
}

variable "error_html_filepath" {
  description = "The file path for error.html"
  type        = string
}