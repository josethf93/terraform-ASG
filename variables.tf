variable "vpc_id" {
  default = "vpc-7a22a707"
}

variable "amiid" {
  description = "AMI ID of the instance"
  default     = "ami-0742b4e673072066f"
  #default     = "ami-0fde50fcbcd46f2f7"   #SUSE Linux Enterprise Server 15 Service Pack 2 (HVM), EBS General Purpose (SSD) Volume Type. Amazon EC2 AMI Tools preinstalled; Apache 2.2, MySQL 5.5, PHP 5.3, and Ruby 1.8.7 available.
  type = string
}

variable "tags" {
  default = ["DL_APP", "RT_APP"]
}

variable "instance_count" {
  default = 2
}
