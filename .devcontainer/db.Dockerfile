# Use the default MariaDB image, not a specific Oracle Linux one
FROM mariadb:latest

# Expose the MySQL port to be accessible to the web container.
EXPOSE 3306