#!/bin/bash
if [ $# -eq 1 ]; then
   SCRIPT_PARAM="$1"
else
   SCRIPT_PARAM="NONE"
fi

function fn_create_exercise_database(){
   # check if postgresql is running
   PGSQL_RUNNING=$(ps -ef|grep postgresql |grep config_file|grep -v grep |wc -l)
   [ $PGSQL_RUNNING -eq 0 ] && exit 1
   
   PSQL="/usr/bin/psql --username=freecodecamp --dbname=postgres -q -t --no-align -c"
   # create exercise database
   echo -e "# Dropping existent number_guess database"
   $PSQL "drop database if exists number_guess"
   
   echo -e "# Creating new number_guess database"
   $PSQL "create database number_guess"

   # create exercise tables
   PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

   echo -e "# Creating \"users\" table"
   $PSQL "create table users(user_id serial primary key, name varchar(22))"
   
   echo -e "# Creating \"matches\" table"
   $PSQL "create table matches(match_id serial primary key, user_id int, match_date timestamp, score int, \
   constraint user_id_fk foreign key(user_id) references users(user_id))"
}

function fn_generate_random_number(){
   RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
}

function fn_handle_user_info(){
   local USER_EXISTS

   PSQL="psql --username=freecodecamp --dbname=number_guess -q -t --no-align -c"
   
   USER_EXISTS=$($PSQL "select count(*) from users where name='$USERNAME'")
   if [ $USER_EXISTS -eq 0 ]; then
      $PSQL "insert into users(name) values('$USERNAME')" 
      echo -e "Welcome, $USERNAME! It looks like this is your first time here."
   fi

   USER_ID=$($PSQL "select user_id from users where name='$USERNAME'") 
   PLAYED_GAMES=$($PSQL "select count(*) from matches where user_id=$USER_ID") 
   BEST_SCORE=$($PSQL "select min(score) from matches where user_id=$USER_ID") 

   USER_ID="$(echo -e "${USER_ID}" | tr -d '[:space:]')"
   USERNAME="$(echo -e "${USERNAME}" | tr -d '[:space:]')"
   PLAYED_GAMES="$(echo -e "${PLAYED_GAMES}" | tr -d '[:space:]')"
   BEST_SCORE="$(echo -e "${BEST_SCORE}" | tr -d '[:space:]')"
   

   [ $USER_EXISTS -ne 0 ] && echo -e "Welcome back, $USERNAME! You have played $PLAYED_GAMES games, and your best game took ${BEST_SCORE:-0} guesses."
}

function fn_run_game(){
   GUESS_COUNT=0

   PSQL="psql --username=freecodecamp --dbname=number_guess -q -t --no-align -c"

   fn_generate_random_number

   echo -e "Guess the secret number between 1 and 1000:"
   read USER_GUESS
   GUESS_COUNT=$((GUESS_COUNT+1))

   re='^[0-9]+$'
   while [[ ! $USER_GUESS =~ $re ]]
   do
      echo -e "That is not an integer, guess again:"
      read USER_GUESS
   done
   
   while [[ $USER_GUESS != $RANDOM_NUMBER ]]
   do
      if [ $USER_GUESS -gt $RANDOM_NUMBER ]; then
         echo -e "It's lower than that, guess again:"
      else
         echo -e "It's higher than that, guess again:"
      fi

      read USER_GUESS
      GUESS_COUNT=$((GUESS_COUNT+1))
      re='^[0-9]+$'
      while [[ ! $USER_GUESS =~ $re ]]
      do
         echo -e "That is not an integer, guess again:"
         read USER_GUESS
      done
      
   done
   $PSQL "insert into matches(user_id,match_date,score) values($USER_ID,NOW(),$GUESS_COUNT)"
   echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

#main
if [ "${SCRIPT_PARAM}" == "--build" ]; then
   fn_create_exercise_database
   exit
elif [ "${SCRIPT_PARAM}" != "NONE" ]; then
   exit 1
fi

echo -e "Enter your username:\n"

read USERNAME

fn_handle_user_info

fn_run_game

