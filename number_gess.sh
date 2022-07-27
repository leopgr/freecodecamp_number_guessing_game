#!/bin/bash

function fn_create_exercise_database(){
   # check if postgresql is running
   PGSQL_RUNNING=$(ps -ef|grep postgresql |grep config_file|grep -v grep |wc -l)
   [ $PGSQL_RUNNING -eq 0 ] && exit 1
   
   PSQL_QUERY="/usr/bin/psql --username=freecodecamp --dbname=postgres -q -t --no-align -c"
   # create exercise database
   $PSQL_QUERY "drop database if exists number_guess" > /dev/null 2>&1

   $PSQL_QUERY "create database number_guess"
}

function fn_generate_random_number(){
   RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
}

#main
fn_create_exercise_database
fn_generate_random_number
