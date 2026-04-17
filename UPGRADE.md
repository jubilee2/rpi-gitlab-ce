# GitLab 18 architecture migration guide (Docker Compose)

This guide expands the **"GitLab 18 architecture change (important)"** note in `README.md` and shows a practical, copy/paste flow for users currently running:

- `jubilee2/rpi-gitlab-ce:v17.11.7`
- `platform: linux/arm/v7` (armhf)

Goal:

1. Back up data from your current armhf GitLab 17 container.
2. Restore on an **x64** host using the official `gitlab/gitlab-ce` image.
3. Upgrade on x64 to `18.2.8-ce.0` and create a new backup.
4. Move to Raspberry Pi **arm64** with `gitlab/gitlab-ce:18.2.8-ce.0` and restore.

---

## 0) Prerequisites and assumptions

- Your current compose service is named `web` and creates container `rpi-gitlab-ce-web-1`.
- Your bind mounts are:
  - `/srv/gitlab/config:/etc/gitlab`
  - `/srv/gitlab/logs:/var/log/gitlab`
  - `/srv/gitlab/data:/var/opt/gitlab`
- You can run Docker Compose on:
  - current Raspberry Pi (armhf)
  - one x64 Linux machine
  - target Raspberry Pi (arm64 OS)

> Important:
>
> - GitLab backup/restore must use the **same GitLab version and edition** at restore time.
> - For upgrades across major versions, follow GitLab's required upgrade stops.

---

## 1) Back up on current armhf GitLab 17

From the host running your current container:

```bash
docker exec -it rpi-gitlab-ce-web-1 gitlab-backup create
```

(Optional but recommended) Back up config and secrets too:

```bash
sudo tar -C /srv/gitlab/config -czf gitlab-config-$(date +%F).tar.gz .
```

Backup file will be created under:

- `/srv/gitlab/data/backups`

Copy it to your x64 host (example):

```bash
scp /srv/gitlab/data/backups/*_gitlab_backup.tar user@x64-host:/srv/gitlab/data/backups/
scp gitlab-config-*.tar.gz user@x64-host:/tmp/
```

---

## 2) Run matching GitLab 17 on x64 and restore

On the x64 host, create a compose file (example `docker-compose.x64-17.yml`) using the same GitLab version:

```yaml
services:
  web:
    image: 'gitlab/gitlab-ce:17.11.7-ce.0'
    platform: linux/amd64
    restart: always
    hostname: 'gitlab-x64.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab-x64.example.com'
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
```

Start container:

```bash
docker compose -f docker-compose.x64-17.yml up -d
```

If you copied `gitlab.rb` / `gitlab-secrets.json`, restore them into `/srv/gitlab/config` first.

Put backup tar in `/srv/gitlab/data/backups`, then restore:

```bash
docker exec -it <x64-container-name> gitlab-backup restore BACKUP=<backup_timestamp>
docker exec -it <x64-container-name> gitlab-ctl reconfigure
docker exec -it <x64-container-name> gitlab-ctl restart
```

`<backup_timestamp>` is the prefix before `_gitlab_backup.tar`.

---

## 3) Modify compose on x64 to upgrade to GitLab 18.2.8 and create new backup

Edit image tag in your x64 compose file:

```yaml
services:
  web:
    image: 'gitlab/gitlab-ce:18.2.8-ce.0'
    platform: linux/amd64
```

Apply upgrade:

```bash
docker compose -f docker-compose.x64-17.yml pull
docker compose -f docker-compose.x64-17.yml up -d
```

After upgrade is complete and healthy, create a fresh backup from 18.2.8:

```bash
docker exec -it <x64-container-name> gitlab-backup create
```

Copy this **new 18.2.8 backup** to your target Raspberry Pi arm64 host:

```bash
scp /srv/gitlab/data/backups/*_gitlab_backup.tar pi@arm64-host:/srv/gitlab/data/backups/
```

---

## 4) Modify compose on Raspberry Pi to run official arm64 image

On target Raspberry Pi (arm64 OS), use compose like:

```yaml
services:
  web:
    image: 'gitlab/gitlab-ce:18.2.8-ce.0'
    platform: linux/arm64
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.example.com'
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
```

Start container:

```bash
docker compose up -d
```

Restore the 18.2.8 backup:

```bash
docker exec -it <arm64-container-name> gitlab-backup restore BACKUP=<backup_timestamp>
docker exec -it <arm64-container-name> gitlab-ctl reconfigure
docker exec -it <arm64-container-name> gitlab-ctl restart
```

---

## 5) Recommended verification checklist

Inside final arm64 container:

```bash
docker exec -it <arm64-container-name> gitlab-rake gitlab:check SANITIZE=true
docker exec -it <arm64-container-name> gitlab-rake db:migrate:status
```

From browser/UI:

- Users can sign in.
- Projects/repositories exist.
- CI/CD variables and runners are present (if used).
- SSH/HTTP clone works.
- New pipeline can run.

---

## 6) Quick command summary

```bash
# armhf old instance
# create backup
docker exec -it rpi-gitlab-ce-web-1 gitlab-backup create

# x64 instance
# restore old backup, then upgrade image to 18.2.8, then create new backup
docker exec -it <x64-container-name> gitlab-backup restore BACKUP=<backup_timestamp>
docker exec -it <x64-container-name> gitlab-backup create

# arm64 final instance
# restore 18.2.8 backup
docker exec -it <arm64-container-name> gitlab-backup restore BACKUP=<backup_timestamp>
```

---

## 7) Real-world command log example (local → remote → local)

If you prefer concrete commands, this is a cleaned-up version of an actual successful flow using container `rpi-gitlab-ce-web-1`.

> Notes:
>
> - Replace hostnames/IPs and usernames (`jubilee2`, `192.168.1.91`) with your values.
> - Replace backup filenames with the ones created on your run.
> - `gitlab-backup restore` prompts for confirmation unless you set `GITLAB_ASSUME_YES=1`.

### A) Create backup on source machine and pull it out of container

```bash
docker exec -t rpi-gitlab-ce-web-1 gitlab-backup create
sudo docker cp rpi-gitlab-ce-web-1:/var/opt/gitlab/backups/1776397105_2026_04_17_17.11.7_gitlab_backup.tar .
sudo chown jubilee2 1776397105_2026_04_17_17.11.7_gitlab_backup.tar
```

### B) Transfer backup to the target host and place it in GitLab backup path

```bash
scp 1776397105_2026_04_17_17.11.7_gitlab_backup.tar 192.168.1.91:~/
# on target host:
cp 1776397105_2026_04_17_17.11.7_gitlab_backup.tar /srv/gitlab/data/backups/
docker exec -it rpi-gitlab-ce-web-1 chown git:git /var/opt/gitlab/backups/1776397105_2026_04_17_17.11.7_gitlab_backup.tar
```

### C) Restore that backup on target host

```bash
docker exec -it rpi-gitlab-ce-web-1 bash
GITLAB_ASSUME_YES=1 gitlab-backup restore
```

You can also run restore directly without opening an interactive shell:

```bash
docker exec -it rpi-gitlab-ce-web-1 sh -lc 'GITLAB_ASSUME_YES=1 gitlab-backup restore'
```

### D) After upgrade, create a new backup and send it back

```bash
docker exec -t rpi-gitlab-ce-web-1 gitlab-backup create
sudo docker cp rpi-gitlab-ce-web-1:/var/opt/gitlab/backups/1776400425_2026_04_17_18.2.8_gitlab_backup.tar .
sudo chown jubilee2 1776400425_2026_04_17_18.2.8_gitlab_backup.tar
scp 1776400425_2026_04_17_18.2.8_gitlab_backup.tar 192.168.1.91:~/
```

### E) Final restore on destination machine

```bash
sudo cp 1776400425_2026_04_17_18.2.8_gitlab_backup.tar /srv/gitlab/data/backups/
sudo docker exec -it rpi-gitlab-ce-web-1 chown git:git /var/opt/gitlab/backups/1776400425_2026_04_17_18.2.8_gitlab_backup.tar
sudo docker exec -it rpi-gitlab-ce-web-1 gitlab-backup restore
```
