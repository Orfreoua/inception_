# Inception
This project aims to automate the deployment of a WordPress environment using Docker Compose, including the following services:

* NGINX (with TLSv1.2 or TLSv1.3 only),
* WordPress (powered by php-fpm),
* MariaDB (database for WordPress).
## Service Structure
### NGINX: Handles secure HTTPS connections using TLS (v1.2 or v1.3).

### WordPress: Managed by `php-fpm` without an integrated HTTP server.

### MariaDB: Manages the WordPress database.

## Additionally:
### A volume to store the WordPress database.
### A separate volume to store WordPress site files.
### A dedicated Docker network to connect all containers.
## Prerequisites
Before starting, ensure your environment meets the following requirements:

- **Operating System**: Linux (compatible with Docker).
- **Docker**: A recent version (20.x or higher recommended).
- **Docker Compose**: Version 2.x or higher.
Installation and Configuration
Clone the Project
Place the project in your home directory and make sure it is named orfreoua. You can modify the path and name in the .env file if needed.

```
git clone https://github.com/Orfreoua/
inception_.git orfreoua

cd orfreoua
```

Configure .env
Fill in the empty fields in the .env file for security and best practices.

## Getting Started
Launch the services using:

`make up`

The services will be deployed and configured automatically. You can access your WordPress site using the URL specified in the .env file.

# Technical Details
NGINX:
Configuration includes support for TLS v1.2/v1.3. The SSL certificate can be generated using Let's Encrypt or another TLS management tool (adjust configuration files as needed).

WordPress:
php-fpm processes PHP requests. NGINX acts as the frontend server.

MariaDB:
The WordPress database is stored in a dedicated Docker volume (DB_PATH specified in .env).

Volumes
Database: Stored in the db_data volume.
WordPress files: Stored in the wordpress_files volume.
Network
All containers communicate through a dedicated Docker network (network). This network is automatically configured during deployment.

# Testing and Validation
Access WordPress
Once the containers are running, open your browser and navigate to the domain configured in the .env file.

Set Up WordPress
Follow the guided setup process to complete the WordPress installation (language selection, admin configuration, etc.).

Verify TLS Security
Use a tool like SSL Labs to verify that TLS v1.2/v1.3 is correctly configured.

# Notes
Volume paths and environment variables in the .env file can be customized to suit your needs.
If you encounter issues, verify that Docker and Docker Compose are installed and up-to-date.
For container or network errors, check the logs:

`make logs`

Uninstallation
To stop and remove the containers and volumes, run:

`make down`

This will also delete persistent data.


Thank you for using this project! I hope it simplifies the deployment of your WordPress environment. If you have any questions, issues, or suggestions, feel free to contribute or contact me. Happy coding! 😁