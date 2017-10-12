# rpi-docker-gitlab-ce

Build image:
```bash
sudo docker build .
sudo docker tag 3468f4e6a05c jubilee2/rpi-gitlab-ce:latest
```


Run the image:
```bash
sudo docker run --detach \
    --hostname gitlab.rpi3.local \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    jubilee2/rpi-gitlab-ce:latest
```
