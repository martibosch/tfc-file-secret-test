terraform {
  cloud {
    organization = "exaf-epfl"
    workspaces {
      name = "tfc-file-secret-test"
    }
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

resource "github_repository" "repo" {
  name        = "tfc-file-secret-test"
  description = "Test terraform setup for cookiecutter-django-doge."
  visibility  = "public"

  allow_merge_commit = true
  auto_init          = true
  gitignore_template = "Terraform"
  license_template   = "gpl-3.0"
}

resource "github_actions_secret" "tfvars" {
  repository      = github_repository.repo.name
  secret_name     = "tfvars"
  plaintext_value = fileexists("vars.tfvars") ? filebase64("vars.tfvars") : ""

  lifecycle {
    ignore_changes = [
      plaintext_value
    ]
  }
}
