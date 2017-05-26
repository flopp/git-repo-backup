# git-repo-backup
Backup a git repository using rsync

## Usage:

Create incremental snapshots of `/path/to/my/project.git` in `/backup/dir`:

```
$ ./git-repo-backup.sh /path/to/my/project.git /backup/dir
```

If there's a change in `/path/to/my/project.git`, `git-repo-backup.sh` creates an incremental snapshot in `/backup/dir` and updates the symbolic link `project-latest` to point to the latest snapshot:

```
$ ls /backup/dir
project-2017-05-26T19:26:35                     # older snapshot
project-2017-05-26T20:15:00                     # older snapshot
project-2017-05-26T21:10:00                     # latest snapshot
project-latest -> project-2017-05-26T21:10:00   # symbolic link to latest snapshot
project.log                                     # logfile
```

You can call `git-repo-backup.sh` nicely from *cron*, since it checks for change sin the epo before creating a new snapshot.

## Features:

- incremental rsync snapshots -> minimal disk space requirements
- [2-step rsync](https://git.seveas.net/how-to-back-up-a-git-repository.html) -> consistent backups
- change detection -> create snapshots only when repository contains new commits

## Todo

- snapshot rotation

## License

`git-repo-backup` is MIT licensed
