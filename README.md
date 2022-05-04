# Drupal devcontainer

This project provides a generic demonstration of a devcontainer setup designed for development of a Drupal website in Oracle Linux 8 based environments.

## Usage

1. Clone this project to your computer.
1. Open the folder in Visual Studio Code.
1. When prompted to open in container, accept. If you miss the prompt, you can also open the command prompt and choose "Remote-Containers: Rebuild and Reopen in Container."

This will build the necessary containers and reopen VS Code within the Apache container ("web").

## Containers

Three containers:

1. PHP-FPM container built on Oracle Linux 8.
1. Apache container built on Oracle Linux 8.
1. MariaDB container using generic official image.

## Includes

- PHP 8.0 and PHP extensions recommended for Drupal 9: APCU and UploadProgress
- Latest version of composer.
- Pa11y accessibility testing tool.
- XDebug for PHP testing.
- User named "drupal" with sudo ability.
- Self-signed certificate for HTTPS browsing.
