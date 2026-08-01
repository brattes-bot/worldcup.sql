#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS=, read -r YEAR ROUND FIRST_TEAM SECOND_TEAM FIRST_GOAL SECOND_GOAL
  do
    if [[ $YEAR =~ ^[0-9]*$ ]]
    then
      # get team_id
      FIRST_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$FIRST_TEAM'")
      SECOND_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$SECOND_TEAM'")
      # if no team_id
      if [[ -z $FIRST_TEAM_ID ]]
      then
        # add to teams
        INSERT_FIRST_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$FIRST_TEAM')")
        echo "$INSERT_FIRST_TEAM_RESULT"
      fi
      if [[ -z $SECOND_TEAM_ID ]]
      then
        # add to teams
        INSERT_SECOND_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$SECOND_TEAM')")
      fi
      # decide winner of game
      if [[ $FIRST_GOAL > $SECOND_GOAL ]]
      then
        WINNER=$FIRST_TEAM
        OPPONENT=$SECOND_TEAM
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      else
        WINNER=$SECOND_TEAM
        OPPONENT=$FIRST_TEAM
        echo "Second team, $WINNER wins"
      fi
      # get game_id, winner_id + opponent_id identifies game
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID")
      # if no id
      if [[ -z $GAME_ID ]]
      then
        # insert game
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $FIRST_GOAL, $SECOND_GOAL)")
        echo "$INSERT_GAME_RESULT"
      fi
      
    fi
  done
