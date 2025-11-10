#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# display list of services
display_services() {
  echo -e "\nWelcome to the salon. Here are our services:"
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

# ask for service id until valid
while true
do
  display_services
  echo -e "\nPlease enter the service_id of the service you'd like:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. Please choose again."
  else
    break
  fi
done

# ask for customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# if not found, ask for name
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

# ask for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# trim spaces and confirm
SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
