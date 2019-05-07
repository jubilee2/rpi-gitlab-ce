# rpi-gitlab-ce
the Dockerfile base on https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker
and make some change for raspberry Pi

I suggest enable the [zram](http://yulun.me/2015/enable-zram-for-raspberry-pi-debian/) to increase performance.

## Install Docker on Raspberry Pi
[official documents link](https://docs.docker.com/install/linux/docker-ce/debian/#install-using-the-convenience-script)
```bash
curl -sSL https://get.docker.com | sh
```

# Install & run container
## Method 1 use pre-build image
```bash
sudo docker run --detach \
    --hostname IP \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    jubilee2/rpi-gitlab-ce:v11.10.4
```

## Method 2 build image by your self
### Build Gitlab image:
```bash
sudo apt-get install git 
git clone https://github.com/jubilee2/rpi-gitlab-ce.git
cd rpi-gitlab-ce
sudo docker build -t gitlab-ce .
```

### Run Gitlab container:
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

# Experience
It's need 20 min for first start up on my `raspberry PI 3 B+` with enable zram
I observe this error occurred [link](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/common_installation_problems/README.md#failed-to-modify-kernel-parameters-with-sysctl), but after several automatic restarts, the initialization was completed.


[More Documents!](https://docs.gitlab.com/omnibus/docker/)
