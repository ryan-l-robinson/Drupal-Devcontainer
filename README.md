# Drupal devcontainer

This project provides a generic devcontainer setup designed for development of a Drupal website.

## Usage

1. Clone this project to your computer.
1. Open the folder in Visual Studio Code, with [the Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) enabled.
1. When prompted to open in container, accept. If you miss the prompt, you can also open the command prompt and choose "Remote-Containers: Rebuild and Reopen in Container."

This will build the necessary containers and reopen VS Code within the Apache container ("web").

After building, the site can be browsed at https://localhost, or https://local.drupal.com if you set up your machine's hosts file with a record like:

```
127.0.0.1 local.drupal.com
```

The admin account is:

Username: admin

Password: ZNB\*ufm1tyz4rwc@yzk

If you would like to change these before building the images, you can do so in .devcontainer/scripts/postCreateCommand.sh.

## Containers

The first container has PHP and Apache and is built on an official Drupal image. It includes:

- PHP 8.1 and PHP extensions recommended for Drupal 10: APCU and UploadProgress
- Latest version of composer.
- XDebug for PHP testing.
- User "www-data" with sudo permissions.
- Self-signed certificate for HTTPS browsing.
- Useful VS Code extensions and settings including Drupal formatting standards.
- Useful Drupal modules module_filter and admin_toolbar.

The second is a database container, using the official MariaDB image.

## Oracle Linux Version

An older version that required Oracle Linux has been split off into the oracle-linux branch. Work will continue forward with the main branch, but that is maintained for anybody looking for an Oracle Linux version.

## TODO

- [ ] Fix warning about XDebug already being loaded, confirm XDebug is working
- [ ] Confirm the Drupal formatter is working
- [ ] Update to PHP 8.2
- [ ] Create alternate version where images are built in GitHub Actions instead of locally
- [ ] Add settings for the MySQL extension to have the database connection ready to go?
