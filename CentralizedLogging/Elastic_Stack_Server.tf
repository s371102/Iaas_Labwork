terraform {
  required_providers {
    openstack = {
        source = "terraform-provider-openstack/openstack"
    }
  }
}
provider "openstack" {
    cloud = "openstack"
}

# variable "htpasswd_password"{
#       type = string
#       description = "The password to use for the htpasswd file"
#     }
resource "openstack_compute_instance_v2" "elastic_Stack_instance" {
    name = "Elastic_Stack_Server"
    image_name = "ubuntu-22.04"
    flavor_name = "l2.c2r4.100"
    key_pair = "VM170-Key"
    
    network {
    name = "public"
    }
    
    connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    host = openstack_compute_instance_v2.elastic_Stack_instance.access_ip_v4
    }

    provisioner "file" {
    source = "/home/ubuntu/Iaas_LabWork/CentralizedLogging/domain_file.txt"
    destination = "/home/ubuntu/your_domain"
    }

    provisioner "file" {
    source = "/home/ubuntu/Iaas_LabWork/CentralizedLogging/02-beats-input.conf"
    destination = "/home/ubuntu/02-beats-input.conf"
    }

    provisioner "file" {
    source = "/home/ubuntu/Iaas_LabWork/CentralizedLogging/30-elasticsearch-output.conf"
    destination = "/home/ubuntu/30-elasticsearch-output.conf"
    }
    provisioner "remote-exec" {
      inline = [
        "sleep 20",
        "sudo apt update",
        "sudo apt -y install default-jre",
        "sudo apt -y install default-jdk",
        "sudo update-alternatives --config java",
        "sudo update-alternatives --config javac",
        "sudo update-alternatives --config java",
        "echo 'JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\"' | sudo tee -a /etc/environment > /dev/null",
        "source /etc/environment",
        "echo $JAVA_HOME",
        # Installing and Configuring Elasticsearch 
        "curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch |sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg",
        "echo 'deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
        "sudo apt update",
        "sudo apt install elasticsearch",
        "echo 'network.host: localhost' | sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null",
        "sudo systemctl start elasticsearch",
        "sudo systemctl enable elasticsearch",
        "sudo apt update",#Install Nginx
        "sudo apt -y install nginx",
        "sudo ufw allow 'Nginx HTTP'",
        "sudo apt install kibana",
        "sudo systemctl restart nginx",
        "sudo systemctl enable kibana",
        "sudo systemctl start kibana",
        "sleep 10",
        "echo \"kibanaadmin:`echo password | openssl passwd -apr1 -stdin`\" | sudo tee -a /etc/nginx/htpasswd.users",
        "sudo cp /home/ubuntu/your_domain /etc/nginx/sites-available/your_domain",
        "sudo sed -i 's/your_domain/${openstack_compute_instance_v2.elastic_Stack_instance.access_ip_v4}/g' /etc/nginx/sites-available/your_domain",
        # "sudo bash -c 'echo -e server { \\n\\tlisten 80\\;\\n\\tserver_name ${openstack_compute_instance_v2.elastic_Stack_instance.access_ip_v4}\\;\\n\\tauth_basic \"Restricted Access\"\\;\\n\\tauth_basic_user_file /etc/nginx/htpasswd.users\\;\\n\\tlocation \\/ {\\n\\tproxy_pass http://localhost:5601\\;\\n\\tproxy_http_version 1.1\\;\\n\\tproxy_set_header Upgrade $http_upgrade\\;\\n\\tproxy_set_header Host $host\\;\\n\\tproxy_cache_bypass $http_upgrade\\;\\n\\t}\\n}>> /etc/nginx/sites-available/your_domain'",
        #"sudo bash -c 'echo -e server { \\n\\tlisten 80\\;\\n\\tserver_name openstack_compute_instance_v2.elastic_Stack_instance.access_ip_v4\\;\\n\\tauth_basic_user_file /etc/nginx/htpasswd.users\\;\\n\\tauth_basic_user_file /etc/nginx/htpasswd.users\\;\\n\\tlocation / {\\n\\tproxy_pass http://localhost:5601\\;\\n\\tproxy_http_version 1.1\\;\\n\\tproxy_set_header Upgrade \\$http_upgrade\\;\\n\\tproxy_set_header Host \\$host\\;\\n\\tproxy_cache_bypass \\$http_upgrade\\;\\n\\t}\\n}>> /etc/nginx/sites-available/your_domain'",
        #"sudo bash -c \"echo -e \\\"server {\\\n\\\\\tlisten 80;\\\\\n\\\\\tserver_name yourdomain_name;\\\\\n\\\\\tauth_basic \\\\\"Restricted Access\\\\\";\\\\\n\\\\\tauth_basic_user_file /etc/nginx/htpasswd.users;\\\\\n\\\\\tlocation / {\\\\\n\\\\\t\\\\\tproxy_pass http://localhost:5601;\\\\\n\\\t\\\\\tproxy_http_version 1.1;\\\\\n\\\\\t\\\\\tproxy_set_header Upgrade \\$http_upgrade;\\\\\n\\\\\t\\\\\tproxy_set_header Connection 'upgrade';\\\\\n\\\\\t\\\\\tproxy_set_header Host \\$host;\\\\\n\\\\\t\\\\\tproxy_cache_bypass \\$http_upgrade;\\\\\n\\\\\t}\\\\\n}\" >> /etc/nginx/sites-available/your_domain\"",
        #"sudo bash -c 'echo -e \"server {\\\n\\\tlisten 80/;>> /etc/nginx/sites-available/your_domain'",
        "sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/your_domain",
        "sudo nginx -t",
        "sudo systemctl reload nginx",
        "sudo ufw allow 'Nginx Full'",
        "sudo ufw delete allow 'Nginx HTTP'",
        #Installing and Configuring Logstash
        "sleep 10",
        "sudo apt install logstash",
        "sudo cp /home/ubuntu/02-beats-input.conf /etc/logstash/conf.d/02-beats-input.conf",
        "sudo cp /home/ubuntu/30-elasticsearch-output.conf /etc/logstash/conf.d/30-elasticsearch-output.conf",
        "sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t",
        "sudo systemctl start logstash",
        "sudo systemctl enable logstash",
        # # Installing and Configuring Filebeat
        "sudo apt -y install filebeat",
        "sudo sed -i 's/output.elasticsearch:/#output.elasticsearch:/g' /etc/filebeat/filebeat.yml",
        "sudo sed -i 's/hosts: \\[\"localhost:9200\"\\]/#&/' /etc/filebeat/filebeat.yml",
        "sudo sed -i 's/#output.logstash:/output.logstash:/g' /etc/filebeat/filebeat.yml",
        #"sudo sed -i 's/#hosts: [\"localhost:5044\"]/hosts: [\"localhost:5044\"]/g' /etc/filebeat/filebeat.yml",
        "sudo sed -i 's/#hosts: \\[\"localhost:5044\"\\]/hosts: \\[\"localhost:5044\"\\]/' /etc/filebeat/filebeat.yml",
        "sudo filebeat modules enable system",
        "sudo filebeat modules list",
        "sudo filebeat setup --pipelines --modules system",
        "sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=[\"localhost:9200\"]'",
        "sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601",
        "sleep 10",
        "sudo systemctl start filebeat",
        "sudo systemctl enable filebeat",
        "curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'",
      ]
    }
}