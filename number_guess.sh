#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_INFO ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');" > /dev/null
  GAMES_PLAYED=0
  BEST_GAME=1000
else
  # Existing user
  echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
ATTEMPTS=0

while true; 
do
  read GUESS

  # Check if input is an integer
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((ATTEMPTS++))

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update user stats
NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
if (( ATTEMPTS < BEST_GAME )); then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$ATTEMPTS WHERE username='$USERNAME';"
else
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME';"
fi
