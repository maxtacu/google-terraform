# See https://cloud.google.com/compute/docs/load-balancing/network/example

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

resource "google_compute_http_health_check" "default" {
  name                = "tf-www-basic-check"
  request_path        = "/"
  check_interval_sec  = 60
  healthy_threshold   = 1
  unhealthy_threshold = 10
  timeout_sec         = 10
}

resource "google_compute_target_pool" "default" {
  name          = "tf-www-target-pool"
  instances     = ["${google_compute_instance.www.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

resource "google_compute_forwarding_rule" "default" {
  name       = "tf-www-forwarding-rule"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "80"
}

resource "google_compute_instance" "www" {
  count = 1

  name = "tf-www-${count.index}"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["www-node"]

  disk {
    image = "centos-7"
  }

  network_interface {
    network = "default"

        access_config {
          # Ephemeral
        }
  }

  metadata {
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

//  provisioner "file" {
//    source = "${var.install_script_src_path}"
//    destination = "${var.install_script_dest_path}"
//
//    connection {
//      type = "ssh"
//      user = "mtacu"
//      private_key = "${file("${var.private_key_path}")}"
//      agent = false
//    }
//  }
//
//
//    provisioner "remote-exec" {
//      connection {
//        type        = "ssh"
//        user        = "mtacu"
//        private_key = "${file("${var.private_key_path}")}"
//        agent       = false
//      }
//
//      inline = [
//        "chmod +x ${var.install_script_dest_path}",
//        "sudo ${var.install_script_dest_path} ${count.index}",
//      ]
//    }
}

  resource "google_compute_firewall" "default" {
    name = "tf-www-firewall"
    network = "default"

    allow {
      protocol = "tcp"
      ports = ["80"]
    }

    allow {
      protocol = "tcp"
      ports = ["22"]
    }

    source_ranges = ["195.22.241.18/32"]
    target_tags = ["www-node"]
  }