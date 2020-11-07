data "google_project" "project" {}

resource "google_compute_address" "static" {
  name         = "vault-ipv4-address"
  address_type = "EXTERNAL"
}


resource "google_compute_instance" "vault" {
  name         = "vault-server"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = "vpc-shared-svcs"
    subnetwork = "shared"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  metadata_startup_script = data.template_file.gcp-vault-init.rendered

  tags = ["vault-${data.terraform_remote_state.infra.outputs.env}"]

  service_account {
    email  = google_service_account.vault_service_account.email
    scopes = ["cloud-platform", "compute-rw"]
  }

}

data "template_file" "gcp-vault-init" {
  template = file("${path.module}/scripts/gcp_vault.sh")
  vars = {
    project = var.gcp_project_id
    sa      = google_service_account.vault_service_account.email
    env     = data.terraform_remote_state.infra.outputs.env
  }
}

resource "google_compute_firewall" "vault" {
  name    = "allow-vault-external"
  network = "vpc-shared-svcs"

  allow {
    protocol = "tcp"
    ports    = ["22", "8200", "8201"]
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_service_account" "vault_service_account" {
  account_id   = "vault-${data.terraform_remote_state.infra.outputs.env}"
  display_name = "vault-${data.terraform_remote_state.infra.outputs.env}"
}

resource "google_project_iam_member" "crypto_binding" {
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

resource "google_project_iam_member" "sa_binding" {
  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

resource "google_project_iam_member" "reader_binding" {
  role   = "roles/compute.viewer"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

resource "google_project_iam_member" "token_creater_binding" {
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.vault_service_account.email}"
}

resource "google_kms_key_ring" "key_ring" {
  name     = "vault-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = "vault-key"
  key_ring        = google_kms_key_ring.key_ring.self_link
  rotation_period = "100000s"
}
