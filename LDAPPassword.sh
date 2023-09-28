#! /bin/bash

 

SRV01='srv-lin1-01'
DOMAIN='lin1.local'
OU='lin1'

 

# En production le les identifiants ne serait pas configurer comme ceci ! 
LDAPPWD='Pa$$w0rd'
LdapAdminCNString='cn=admin,dc=lin1,dc=local'
LdapDCString='dc=lin1,dc=local'

 

######################################################################################

 

echo -e " \ 
slapd slapd/password2 password $LDAPPWD
slapd slapd/password1 password $LDAPPWD
slapd slapd/move_old_database boolean true
slapd shared/organization string $OU
slapd slapd/no_configuration boolean false
slapd slapd/purge_database boolean false
slapd slapd/domain string $DOMAIN
" | debconf-set-selections

 

export DEBIAN_FRONTEND=noninteractive

 

sudo apt-get install -y slapd ldap-utils

 

LDAP_FILE_CONF="/etc/ldap/ldap.conf"
cat <<EOM >$LDAP_FILE_CONF

 

BASE    dc=lin1,dc=local
URI     ldap://$SRV01.$DOMAIN

 

EOM

 

######################################################################################
# Update Password admin

 

# LDAP Server information
LDAP_SERVER="ldap://"$SRV01.$DOMAIN

 

# Generate LDIF file for modifying the root password
LDIF_FILE="modify_root_password.ldif"

 

echo "dn: ${LdapAdminCNString}
changetype: modify
replace: userPassword
userPassword: ${LDAPPWD}" > $LDIF_FILE

 

# Modify the root password using the LDIF file
ldapmodify -x -H "$LDAP_SERVER" -D "$LdapAdminCNString" -w "$LDAPPWD" -f $LDIF_FILE

 

# Clean up the LDIF file
rm $LDIF_FILE

######################################################################################
