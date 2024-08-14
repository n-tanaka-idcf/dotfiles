```
$ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing

$ sudo systemctl enable docker.service
$ sudo systemctl start docker.service

$ sudo usermod -aG docker $USER
```
