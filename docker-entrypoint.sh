#!/bin/bash

# Run Laravel migrations
php artisan migrate --force

# Clear and cache configurations
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# Set permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"