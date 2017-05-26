# git-repo-backup
Backup a git repository using rsync

## Usage:

Create incremental snapshots of `/path/to/my/project.git` in `/backup/dir`:

```./git-repo-backup.sh /path/to/my/project.git /backup/dir```

## Features:

- incremental rsync snapshots -> minimal disk space requirements
- [2-step rsync](https://git.seveas.net/how-to-back-up-a-git-repository.html) -> consistent backups
- change detection -> create snapshots only when repository contains new commits

## Todo

- snapshot rotation

## License

`git-repo-backup` is MIT licensed
