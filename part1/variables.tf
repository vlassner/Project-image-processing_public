/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): 
Description: S3 Bucket Creation and Access Configuration 
*/

variable "region" {
  default = "us-west-1"
}

variable "user_name" {
  default = "prj-01-user"
}

// TODO: add your initials suffix for uniqueness 
variable "bucket_name" {
  default = "prj-01-bucket-vl"
}

variable "bucket_policy_name" {
  default = "prj-01-bucket-policy"
}