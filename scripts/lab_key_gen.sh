KEY_FILE="${HOME}/.ssh/labkey"

#check for existing key and move it
if test -f "$KEY_FILE"; then
    TIMESTAMP=$(date +%s)
    echo "$KEY_FILE exists, moving to ${KEY_FILE}${TIMESTAMP}"
    mv $KEY_FILE ${KEY_FILE}${TIMESTAMP}
    mv ${KEY_FILE}.pub ${KEY_FILE}${TIMESTAMP}.pub
fi 
echo "Enter your email: "
read EMAIL
ssh-keygen -c -t ed25519 -f $KEY_FILE -N "" -C ${EMAIL} 