/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): 
*/

variable "region" {
  default = "us-west-1"
}

// TODOd add your initials suffix for uniqueness 
variable "bucket_name" {
  default = "prj-01-bucket-vl"
}

// TODOd: update with your default VPC ID
variable "vpc_id" {
  default = "vpc-02153249c434071a2"
}

// TODOd update with a public subnet id from your default VPC
variable "subnet_id" {
  default = "subnet-06b351bb99568a2fd"
}

// TODOd update with your Docker image URI
variable "docker_image_uri" {
  default = "060795946302.dkr.ecr.us-west-1.amazonaws.com/dsml3850:prj-01-v1"
} 