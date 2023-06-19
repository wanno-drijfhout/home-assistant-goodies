# Wordpress add-on for Home Assistant

This add-on deploys Wordpress on Home Assistant.

## Prerequisites

- [x] MariaDB add-on must be installed
- [x] Reverse proxy to take care of SSL and domain names

## Deployment

The add-on creates a folder `/share/wordpress` if it doesn't exist yet, and subsequently downloads and configures the latest version of WordPress.

## Credits

Inspiration from:

- the [apache2 add-on](https://github.com/FaserF/hassio-addons/tree/master/apache2)
- [WordPress recommendation on reverse proxying](https://wordpress.org/documentation/article/administration-over-ssl/)
- [WordPress recommendation for apache2](https://wordpress.org/documentation/article/nginx/)