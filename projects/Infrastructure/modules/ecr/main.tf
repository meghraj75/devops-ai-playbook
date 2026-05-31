variable "repositories" {
  type = list(string)
}

//Used for storing: Docker container images
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repositories)

  name = each.value
  force_delete = true  # To delete the images inside the repo
//Enables vulnerability scanning when image pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}
