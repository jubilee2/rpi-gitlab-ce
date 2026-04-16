# rpi-gitlab-ce

> **Project status: archived / read-only**
>
> GitLab now officially publishes ARM64 Docker images: <https://hub.docker.com/r/gitlab/gitlab-ce>.
> Because of that, this repository is no longer maintained.

## GitLab 18 architecture change (important)

Starting with GitLab 18, the old **armhf** image variant is no longer available. Official ARM container support is now **arm64** only.

If you are running GitLab 17 on armhf hardware, you cannot perform an in-place upgrade to GitLab 18 on the same armhf environment. A practical migration path is:

1. Create a backup on your GitLab 17 instance.
2. Move that backup to a machine that can run an x64 GitLab container.
3. Restore the backup to a matching GitLab 17 instance on the x64 machine, then upgrade that instance to GitLab 18.2.
4. Create a new backup from the upgraded 18.2 instance.
5. Restore that backup on your Raspberry Pi deployment using a GitLab CE 18.2 arm64 container.

This architecture transition is another reason this repository is archived.

## Background

This project was based on the upstream GitLab Omnibus Docker setup:
<https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker>

It includes Raspberry Pi-specific adjustments.

For better performance on low-memory Raspberry Pi devices, consider enabling zram:
<http://yulun.me/2015/enable-zram-for-raspberry-pi-debian/>

## Install Docker on Raspberry Pi

Official docs:
<https://docs.docker.com/install/linux/docker-ce/debian/#install-using-the-convenience-script>

```bash
curl -sSL https://get.docker.com | sh
```

## Install and run the container

### Method 1: Use prebuilt image

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

### Method 2: Build image yourself

#### Build GitLab image

```bash
sudo apt-get install git
git clone https://github.com/jubilee2/rpi-gitlab-ce.git
cd rpi-gitlab-ce
sudo docker build -t gitlab-ce .
```

#### Run GitLab container

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

## Notes from prior Raspberry Pi usage

- On a Raspberry Pi 3 B+ with zram enabled, first startup took about 20 minutes.
- During startup, this known issue sometimes appeared:
  <https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/common_installation_problems/README.md#failed-to-modify-kernel-parameters-with-sysctl>
- In prior testing, initialization still completed after several automatic restarts.

## Additional official documentation

- GitLab Omnibus Docker docs: <https://docs.gitlab.com/omnibus/docker/>
- GitLab Docker install guide: <https://docs.gitlab.com/ee/install/docker.html>
- Memory-constrained environments: <https://docs.gitlab.com/omnibus/settings/memory_constrained_envs/>
