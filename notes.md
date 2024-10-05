Auto updation of the web urls in config file 

```
#!/bin/bash

# Define domains for each service
CATALOGUE_DOMAIN="catalogue.example.com"
USER_DOMAIN="user.example.com"
CART_DOMAIN="cart.example.com"
SHIPPING_DOMAIN="shipping.example.com"
PAYMENT_DOMAIN="payment.example.com"

# Create the Nginx configuration file
cat << EOF > /etc/nginx/default.d/roboshop.conf
proxy_http_version 1.1;

location /images/ {
  expires 5s;
  root   /usr/share/nginx/html;
  try_files $uri /images/placeholder.jpg;
}

location /api/catalogue/ {
  proxy_pass http://$CATALOGUE_DOMAIN:8080/;
}

location /api/user/ {
  proxy_pass http://$USER_DOMAIN:8080/;
}

location /api/cart/ {
  proxy_pass http://$CART_DOMAIN:8080/;
}

location /api/shipping/ {
  proxy_pass http://$SHIPPING_DOMAIN:8080/;
}

location /api/payment/ {
  proxy_pass http://$PAYMENT_DOMAIN:8080/;
}

location /health {
  stub_status on;
  access_log off;
}
EOF

# Reload Nginx to apply the changes
systemctl reload nginx

```
