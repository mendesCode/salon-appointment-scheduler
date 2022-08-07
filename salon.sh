#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SHOW_SERVICES() {
  if [[ $1 ]]
  then
    echo "$1" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
  fi
}

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "$1\n"
    fi

    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo -e "Welcome to My Salon, how can I help you?\n"
    SHOW_SERVICES "$SERVICES"

    read SERVICE_ID_SELECTED

    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    while [[ -z $SERVICE ]]
    do
      echo -e "\nI could not find that service. What would you like today?"
      SHOW_SERVICES "$SERVICES"

      read SERVICE_ID_SELECTED
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    done

    echo $SERVICE

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # save new customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      while [[ -z $CUSTOMER_NAME ]]
      do
        echo -e "\nPlease enter a valid name\nWhat's your name?"
        read CUSTOMER_NAME
      done

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

      # save the customer's new appointment
      if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
      then
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        while [[ -z $SERVICE_TIME ]]
        do
          echo -e "\nPlease enter a valid time\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME
        done

        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
        then
          echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
      fi
    fi
}

MAIN_MENU
