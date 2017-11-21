# rpi-gitlab-ce
the Dockerfile base on https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker
and make some change for raspberry Pi

I suggest enable the [zram](http://yulun.me/2015/enable-zram-for-raspberry-pi-debian/) to increase performance.

## Install Docker on Raspberry Pi
```
curl -sSL https://get.docker.com | sh
```

## Build Gitlab image:
```bash
sudo apt-get install git 
git clone https://github.com/jubilee2/rpi-gitlab-ce.git
cd rpi-gitlab-ce
sudo docker build -t gitlab-ce .
```

## Run Gitlab container:
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
