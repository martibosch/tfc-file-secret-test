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
    sodium = {
      source  = "killmeplz/sodium"
      version = ">= 0.0.3"
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
data "github_actions_public_key" "gh_actions_public_key" {
  repository = github_repository.repo.name
}


data "sodium_encrypted_item" "encrypted_file" {
    public_key_base64 = data.github_actions_public_key.gh_actions_public_key.key
    content_base64 = filebase64("vars.tfvars")
}

resource "github_actions_secret" "tfvars" {
  repository      = github_repository.repo.name
  secret_name     = "tfvars"
  plaintext_value = data.sodium_encrypted_item.encrypted_file.encrypted_value_base64
}
