variable "iam_token" {
  type        = string
  description = "Yandex Cloud OAth-token"
}
variable "vm_name" {
  type        = list(string)
  description = "VM's name"
}
variable "cloud_id" {
  type = string
  default = "b1g3jddf4nv5e9okle7p"
}
variable "folder_id" {
  type = string
  default = "b1gtmbcndh33d9sk2b5i"
}
variable "zone" {
  type = string
  default = "ru-central1-b" 
}
