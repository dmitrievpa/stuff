variable "cloud_id" {
  type = string
  default = "<yc_cloud_id>"
}
variable "folder_id" {
  type = string
  default = "<yc_folder_id>"
}
variable "zone" {
  type = string
  default = "<yc_zone_id>" 
}
variable "vm_name" {
  type        = list(string)
  description = "VM's name"
}
variable "image" {
  type = string
  default = "<yc_zone_id>" 
}

