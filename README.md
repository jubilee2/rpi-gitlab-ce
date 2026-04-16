# rpi-gitlab-ce

**Project status: read-only**

GitLab now officially supports ARM64 Docker images: https://hub.docker.com/r/gitlab/gitlab-ce
Because of that, this repository is now in **read-only mode** and will not receive further updates.

## Important note about GitLab 18 and CPU architecture

GitLab 18 no longer provides the old **armhf** image variant. From GitLab 18 onward, the official ARM container support is **arm64**.

If you are currently running GitLab 17 on armhf hardware, you cannot do an in-place package/image upgrade to GitLab 18 on the same armhf environment because the CPU architecture changed. A practical migration path is:

1. Create a GitLab backup on your GitLab 17 instance.
2. Move that backup to a machine that can run an x64 GitLab container.
3. Restore the backup there and upgrade to GitLab 18.2.
4. Create a new backup from the upgraded 18.2 instance.
5. Restore that backup on your Raspberry Pi deployment using a GitLab CE 18.2 arm64 container.

This architecture transition is one more reason this repository is not being updated further.

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
    jubilee2/rpi-gitlab-ce:v12.4.1
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

The latest Docker guide can be found here: [GitLab Docker images](https://docs.gitlab.com/ee/install/docker.html).

For low-hardware deployments, also review GitLab's official memory-constrained guidance:
[Memory-constrained environments](https://docs.gitlab.com/omnibus/settings/memory_constrained_envs/).
