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

#main
if [ "${SCRIPT_PARAM}" == "--build" ]; then
   fn_create_exercise_database
else
   exit 1
fi

fn_generate_random_number
