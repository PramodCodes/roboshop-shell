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
shell Globbing and word splitting

In shell scripting (e.g., Bash), double-quoting variables helps prevent unintended behavior due to **globbing** and **word splitting**. Let's break this down with your two examples:

### 1. **Without Double Quotes: `if [ $ID -eq 0 ]`**

In this case, `$ID` is not quoted, which can lead to problems if:

- **$ID is empty**: If `$ID` is an empty string or undefined, the script will evaluate the condition as `if [ -eq 0 ]`, which is a syntax error because the shell is expecting a value to compare with `0`.

- **$ID contains spaces**: If `$ID` contains spaces (e.g., `"1 2"`), the shell will interpret this as multiple words and could break your logic. For example, it might split `1 2` into two separate values, leading to unexpected behavior.

- **$ID contains wildcard characters**: If `$ID` contains characters like `*` or `?`, these can be expanded by the shell into matching filenames in the current directory (this is called **globbing**), which could result in comparing filenames rather than numeric values.

#### Example:
```bash
ID="*"
if [ $ID -eq 0 ]; then
  echo "ID is zero"
fi
```
If the current directory contains files, the `*` will expand to all the filenames in that directory, leading to unexpected errors or results.

### 2. **With Double Quotes: `if [ "$ID" -eq 0 ]`**

When you use double quotes around `$ID`, like `"$ID"`, the shell treats `$ID` as a single entity, regardless of its contents.

- **$ID is empty**: If `$ID` is empty or undefined, the condition will be evaluated as `if [ "" -eq 0 ]`. This will not cause a syntax error, but the comparison will fail because an empty string is not equal to `0`.

- **$ID contains spaces**: If `$ID` contains spaces, those spaces will be preserved, and the variable will still be treated as one string. No word splitting will occur.

- **$ID contains wildcard characters**: If `$ID` contains `*`, `?`, or other wildcard characters, they will not be expanded to filenames. The shell will compare the literal string.

#### Example:
```bash
ID="*"
if [ "$ID" -eq 0 ]; then
  echo "ID is zero"
fi
```
In this case, the script will check if the literal string `"*"` is equal to `0`, preventing unintended behavior due to globbing.

### Key Differences:

- **Unquoted `$ID`**: Can result in syntax errors, unexpected word splitting, or filename expansion (globbing).
- **Quoted `"$ID"`**: Prevents these issues by treating the entire variable's value as a single entity, regardless of whether it’s empty, contains spaces, or contains wildcard characters.

### Best Practice:
It is generally recommended to **always quote variables** in shell scripting, especially when performing comparisons or when the value could be empty or contain special characters. Therefore, `if [ "$ID" -eq 0 ]` is safer and more reliable than `if [ $ID -eq 0 ]`.