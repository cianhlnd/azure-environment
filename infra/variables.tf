variable "location" {
  default     = "northeurope"
  description = "Used to set resource location default as North Europe"
  type        = string

  validation {
    condition     = contains(keys(local.region_short), var.location)
    error_message = "location must be one of: northeurope, westeurope, swedencentral. Add a short code to region_short in main.tf to allow another region."
  }
}

variable "workload" {
  default     = "azure-env"
  description = "Used to populate workload part to resource names"
  type        = string
}

variable "tags" {
  default = {
    project    = "azure-env"
    owner      = "cian"
    managed_by = "terraform"
  }
  description = "Commonly used tags"
  type        = map(string)
}