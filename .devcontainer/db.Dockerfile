# Use the default MariaDB image
FROM mariadb:latest

ENV MARIADB_ROOT_PASSWORD=drupalroot
ENV MARIADB_DATABASE=drupal
ENV MARIADB_USER=drupal
ENV MARIADB_PASSWORD=drupal

# Expose the MySQL port to be accessible to the web container.
EXPOSE 3306
