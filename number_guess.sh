#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~"
echo -e "\nEnter your username:"
read USERNAME

# look up user account
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

# if user doesn't exist yet
if [[ -z $USER_ID ]]
then
  # insert user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  # get new user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
  # welcome new user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # get statistics from previous games
  GAME_STATS=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM games WHERE user_id = $USER_ID;")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< $GAME_STATS
  # welcome back user
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# starting values for game
NUM_GUESSES=0
TARGET_NUM=$(( $RANDOM % 1000 + 1 ))
echo -e "\nGuess the secret number between 1 and 1000:"

# start game
while [[ true ]]
do
  read GUESS

  # if guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    # continue
  fi

  # check that guess is within the valid range
  if [[ $GUESS -lt 1 ]] || [[ $GUESS -gt 1000 ]]
  then
    echo -e "\nThat is not in the range of 1 to 1000, guess again:"
    # continue
  fi

  # since input is valid, we will count the guess
  NUM_GUESSES=$(($NUM_GUESSES + 1))

  if [[ $TARGET_NUM > $GUESS ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  elif [[ $TARGET_NUM < $GUESS ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  else
    break
  fi
done

# output game results
echo -e "\nYou guessed it in $NUM_GUESSES tries. The secret number was $TARGET_NUM. Nice job!"
# insert game results into database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUM_GUESSES);")
