# rpi-gitlab-ce

## Raspberry install Docker
```
curl -sSL https://get.docker.com | sh
```
install brctl
```
sudo apt-get install bridge-utils 
```

check docker version > 1.10
```
sudo docker version
```


Setup internet
```
sudo docker network create --subnet 192.168.1.0/24 --aux-address "DefaultGatewayIPv4=192.168.1.1" --gateway=192.168.1.200 homebr0
brctl show
sudo brctl addif br-475dbcd287db eth0
sudo ip a del 192.168.1.200/24 dev br-475dbcd287db
```
br-475dbcd287db will different

## Build image:
```bash
sudo apt-get install git 
git clone https://github.com/jubilee2/rpi-gitlab-ce.git
cd rpi-gitlab-ce
sudo docker build -t gitlab-ce .
```


## Run the image:
```bash
sudo docker run --detach \
    --hostname IP \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab-ce:latest
```

[More Documents!](https://docs.gitlab.com/omnibus/docker/)
