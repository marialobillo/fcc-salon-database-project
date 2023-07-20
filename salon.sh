#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~ MY SALON ~~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?"

MAIN(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
IS_SERVICE_AVAILABLE=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
if [[ -z $IS_SERVICE_AVAILABLE ]]
then
  MAIN "Sorry, that is not a valid number! Please, choose again."
else
  SERVICE_SELECTED_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  echo "we got a service from the list, $SERVICE_SELECTED_NAME"

  if [[ -z $SERVICE_SELECTED_NAME ]]
  then
    MAIN "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    HAS_CUSTOMER=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    if [[ -z $HAS_CUSTOMER ]]
    then
      # new customer case
      echo -e "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new custumer
      CUSTOMER_NAME_INSERTED=$($PSQL "insert into customers (name, phone) values ('$NEW_CUSTOMER_NAME', '$CUSTOMER_PHONE') RETURNING name")
      
      echo "What time would you like your $SERVICE_SELECTED_NAME, $CUSTOMER_NAME_INSERTED?"
      read SERVICE_TIME
      
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      INSERT_NEW_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      echo "I have put you down for a $SERVICE_SELECTED_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      
    fi
  fi
fi
}

MAIN




