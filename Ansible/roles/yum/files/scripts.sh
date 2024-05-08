#!/bin/sh
yum install httpd php php-mysqlnd php-gd php-xml mariadb105-server php-mbstring php-json mod_ssl php-intl -y
systemctl start mariadb
MYSQL_COMMANDS=(
"CREATE USER 'wiki6'@'localhost' IDENTIFIED BY 'THISpasswordSHOULDbeCHANGED';"
"CREATE DATABASE wikidatabase6;"
"GRANT ALL PRIVILEGES ON wikidatabase6.* TO 'wiki6'@'localhost';"
"FLUSH PRIVILEGES;"
"SHOW DATABASES;"
"SHOW GRANTS FOR 'wiki6'@'localhost';"
"exit"
)

# Execute MySQL commands
for command in "${MYSQL_COMMANDS[@]}"; do
    echo "$command" | mysql -u root 
done

systemctl enable mariadb
systemctl enable httpd

#download packages
cd /tmp
#wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.1.tar.gz
# Download the GPG signature for the tarball and verify the tarball's integrity:
wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.1.tar.gz.sig
gpg --verify mediawiki-1.41.1.tar.gz.sig mediawiki-1.41.1.tar.gz

cd /var/www
tar -zxf /tmp/mediawiki-1.41.1.tar.gz
ln -s mediawiki-1.41.1/ mediawiki

#Webserver post-install configuration
# Define the Apache configuration file path
conf_file="/etc/httpd/conf/httpd.conf"

# Define the search and replace strings
search_docroot='DocumentRoot "/var/www/html"'
replace_docroot='DocumentRoot "/var/www"'

search_directory='<Directory "/var/www">'
replace_directory='<Directory "/var/www">'

search_directory_index='DirectoryIndex index.html'
replace_directory_index='DirectoryIndex index.html index.html.var index.php'

# Perform the replacements using sed
sed -i "s|$search_docroot|$replace_docroot|g" "$conf_file"
sed -i "s|$search_directory|$replace_directory|g" "$conf_file"
sed -i "s|$search_directory_index|$replace_directory_index|g" "$conf_file"

echo "Replacements completed successfully!"

# Directory modification
cd /var/www
ln -s mediawiki-1.41.1/ mediawiki
chown -R apache:apache /var/www/mediawiki-1.41.1

# Restart service
service httpd restart

# Install firewall if not installed
yum install firewalld -y
# Firewall config
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
systemctl restart firewalld

# Check SELinux status
status=$(getenforce)

# Display current SELinux status
echo "Current SELinux status: $status"

# If SELinux is enforcing
if [ "$status" == "Enforcing" ]; then
    # Set correct SELinux context for MediaWiki files
    restorecon -FR /var/www/mediawiki-1.41.1/
    restorecon -FR /var/www/mediawiki

    # Check correct context for /var/www/
    echo "Checking SELinux context for /var/www/"
    ls -lZ /var/www/
else
    echo "SELinux is not enforcing. No action required."
fi