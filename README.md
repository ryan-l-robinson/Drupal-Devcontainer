# Drupal devcontainer

An updated version of this project is now available on (https://gitlab.com/ryan-l-robinson/drupal-dev-environment)[my GitLab], since that now includes some GitLab CI/CD jobs. I do hope to mirror that to GitHub and possibly set up GitHub equivalents for many of the jobs.

This project provides a generic devcontainer setup designed for development of a Drupal website.

## Usage

1. Clone this project to your computer.
1. Open the folder in Visual Studio Code, with [the Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) enabled.
1. When prompted to open in container, accept. If you miss the prompt, you can also open the command prompt and choose "Remote-Containers: Rebuild and Reopen in Container."

This will build the necessary containers and reopen VS Code within the Apache container ("web").

After building, the site can be browsed at https://localhost, or https://local.example.com if you set up your machine's hosts file with a record like:

```
127.0.0.1 local.example.com
```

The admin account is:

Username: admin

Password: ZNB\*ufm1tyz4rwc@yzk

If you would like to change these before building the images, you can do so in .devcontainer/scripts/postCreateCommand.sh.

## Containers

The first container has PHP and Apache and is built on an official Drupal image. The second is a database container, using the official MariaDB image.

The setup includes:

- PHP 8.3 and PHP extensions recommended for Drupal 10: APCU and UploadProgress
- Latest version of composer.
- XDebug for PHP testing.
- User "www-data" with sudo permissions.
- Self-signed certificate for HTTPS browsing.
- Useful Drupal modules module_filter, admin_toolbar, and environment_indicator with configuration.
- Useful VS Code extensions and settings including Drupal formatting standards.
- SSH folder and .gitconfig as volumes, so if your SSH keys are in the standard user profile's .ssh folder and you clone with SSH, there won't be any extra steps necessary to connect to the repository with your configuration.
- A dark mode colour palette.
- Grep colour highlighting for easier reading of results.

## Oracle Linux Version

An older version that required Oracle Linux has been split off into the oracle-linux branch. Work will continue forward with the main branch, but that is maintained for anybody looking for an Oracle Linux version.

## TODO

- [ ] Create alternate version where images are built in GitHub Actions instead of locally. TBD if to overtake this main branch, different branch, or different repo
