#!/bin/bash
if [ $# -eq 1]; then
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
   $PSQL "drop database if exists number_guess" > /dev/null 2>&1

   $PSQL "create database number_guess"

   # create exercise table
   PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

}

function fn_generate_random_number(){
   RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
}

#main
if [ "${SCRIPT_PARAM}" == "--build"]; then
   fn_create_exercise_database
else
   exit 1
fi

fn_generate_random_number
