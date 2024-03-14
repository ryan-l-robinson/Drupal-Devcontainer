# Drupal devcontainer

This project provides a generic demonstration of a devcontainer setup designed for development of a Drupal website.

## Usage

1. Clone this project to your computer.
1. Open the folder in Visual Studio Code.
1. When prompted to open in container, accept. If you miss the prompt, you can also open the command prompt and choose "Remote-Containers: Rebuild and Reopen in Container."

This will build the necessary containers and reopen VS Code within the Apache container ("web").

## Containers

The first container has PHP and Apache and is built on an official Drupal image. It includes:

- PHP 8.1 and PHP extensions recommended for Drupal 10: APCU and UploadProgress
- Latest version of composer.
- XDebug for PHP testing.
- User named "www-data" with sudo ability.
- Self-signed certificate for HTTPS browsing.

The second is a database container, using the generic official MariaDB image.

## Oracle Linux Version

An older version that required Oracle Linux has been split off into the oracle-linux branch. Work will continue forward with the main branch, but that is maintained for anybody looking for an Oracle Linux version.