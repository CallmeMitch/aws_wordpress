# FICHIER POUR Déclarer le bucket(Compartiment)


terraform {
  backend "s3" {
    bucket = "valentinbrisonbucket"
    key    = ".terraform/terraform.tfstate"
    region = "eu-west-1"
  }
}