bucket = "tfstate-project-flashcards"
key    = "dev/terraform.tfstate"
region = "us-east-1"
encrypt = true
use_lockfile = true
dynamodb_table = "terraform-state-lock"
