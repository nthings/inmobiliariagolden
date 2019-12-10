#terraform {
#  backend "remote" {
#    hostname     = "app.terraform.io"
#    organization = "tecnoly"

#    workspaces {
#      name = "golden"
#    }
#  }
#}

provider "google" {
  credentials = file("./credentials.json")
  project     = var.gcp_project
  region      = var.gcp_region
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_firewall" "firewall" {
  name    = "golden-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3306"]
  }

  # These IP ranges are required for health checks
  source_ranges = ["0.0.0.0/0"]

  # Target tags define the instances to which the rule applies
  target_tags = ["golden"]
}

resource "google_compute_instance" "golden" {
  name         = "golden"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    host        = self.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    content = templatefile("templates/init_script.tmpl", {
      #domain = var.domain
      mysql_root_password = var.mysql_root_password,
      domain              = var.domain,
      contact_email       = var.contact_email,
      DB_NAME             = var.DB_NAME
      DB_PASS             = var.DB_PASS
      DB_USER             = var.DB_USER
    })
    destination = "~/init_script.sh"
  }

  provisioner "file" {
    content = templatefile("templates/nginx.tmpl", {
      domain = var.domain
    })
    destination = "~/nginx.conf"
  }

  provisioner "file" {
    content = templatefile("templates/env.tmpl", {
      DB_HOST        = var.DB_HOST
      DB_NAME        = var.DB_NAME
      DB_PASS        = var.DB_PASS
      DB_PORT        = var.DB_PORT
      DB_USER        = var.DB_USER
      NODE_ENV       = var.NODE_ENV
      SESSION_SECRET = var.SESSION_SECRET
    })
    destination = "~/env"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ~/init_script.sh",
      "sudo ~/init_script.sh",
      "sudo mv ~/nginx.conf /etc/nginx/sites-available/default",
      "sudo systemctl reload nginx",
      "sudo mv ~/env ~/inmobiliariagolden/.env",
      "cd ~/inmobiliariagolden",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} ~/inmobiliariagolden",
      "npm i",
      "pm2 start app.js --name='golden'",
      "pm2 save",
      "sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ${var.ssh_user} --hp /home/${var.ssh_user}",
      "pm2 status"
    ]
  }

  tags = ["golden"]
}

resource "google_dns_managed_zone" "dns-zone" {
  name     = var.dns_managed_zone_name
  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "dns" {
  name = google_dns_managed_zone.dns-zone.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.dns-zone.name

  rrdatas = [google_compute_instance.golden.network_interface.0.access_config.0.nat_ip]
}

resource "google_dns_record_set" "dns_www" {
  name = google_dns_managed_zone.dns-zone.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.dns-zone.name

  rrdatas = [google_compute_instance.golden.network_interface.0.access_config.0.nat_ip]
}

resource "null_resource" "godaddy_dns" {
  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/dns.py ${join(",", google_dns_managed_zone.dns-zone.name_servers)} ${google_dns_record_set.dns.name} ${var.godaddy_api_key}"
  }

  triggers = {
    dns_name = google_dns_record_set.dns.name
    script   = filesha256("${path.module}/scripts/dns.py")
  }
}

resource "null_resource" "certbot" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    host        = google_compute_instance.golden.network_interface.0.access_config.0.nat_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo certbot --nginx -d ${var.domain} -d www.${var.domain} --non-interactive --agree-tos -m ${var.contact_email}",
      "sudo certbot renew --dry-run"
    ]
  }

  depends_on = [null_resource.godaddy_dns, null_resource.restore]
}

/* resource "null_resource" "restore" {
  count = var.restore_backup == true ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    host        = google_compute_instance.golden.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "backup/backup.sql"
    destination = "~/data.sql"
  }

  provisioner "file" {
    source      = "backup/fotoscasas/"
    destination = "~/inmobiliariagolden/assets/fotoscasas"
  }

  provisioner "remote-exec" {
    inline = [
      "mysql --user='root' --password='${var.mysql_root_password}' -e 'use inmobiliariagolden;source ~/data.sql;'",
    ]
  }
} */