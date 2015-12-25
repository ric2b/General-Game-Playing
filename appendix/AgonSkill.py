import json

dataPoints = []

f = open("matchesFrom2011", 'r')
for line in f.readlines():
  # Load the match data in JSON format.
  match = json.loads(line)['data']
  # Discard matches that aren't signed.
  if not 'matchHostPK' in match:
    continue
  # Discard matches that aren't signed by Tiltyard.
  if hash(match['matchHostPK']) != -859967508381652683:
    continue
  # Discard matches that didn't record player names.
  if not 'playerNamesFromHost' in match:
    continue
  # Discard matches that didn't complete successfully.
  if not match['isCompleted']:
    continue
  # Discard matches where a player had errors.
  if 'errors' in match:
    hasErrors = False
    for errorsForTurn in match['errors']:
      for error in errorsForTurn:
        if len(error) > 0:
          hasErrors = True
    if hasErrors:
      continue
  # Store the relevant parts for computing ratings: when the match started,
  # the players involved, and the final scores.
  dataPoints.append((match['startTime'], match['gameMetaURL'], match['playerNamesFromHost'], match['goalValues']))

# Agon rating, like Elo rating, is order dependant: if a player that's currently weak
# beats a player that's currently strong, that's more important than if a player that
# was once weak (but is now average) beats a player that was once strong (but is now
# also average). Thus we need to process matches in the order in which they occurred.
# This is done by sorting them by start time.
dataPoints.sort()

# Ratings will be tracked in this map.
agonRating = {}

# An essential part of Agon rating, like Elo rating, is determining the expected score
# for players when they're matched against each other, based on their current ratings.
# This is done exactly as it is done in ordinary Elo rating.
def getExpectedScore(aPlayer, bPlayer):
  if not aPlayer in agonRating:
    agonRating[aPlayer] = 0
  if not bPlayer in agonRating:
    agonRating[bPlayer] = 0
  RA = agonRating[aPlayer]
  RB = agonRating[bPlayer]
  QA = pow(10.0, RA / 400.0)
  QB = pow(10.0, RB / 400.0)
  return QA / (QA + QB)

# Updating ratings also works exactly like in Elo rating: compute the expected score,
# and then increase ratings if the players exceeded that score, and decrease ratings
# if the players fell below the expected score.
def updateRating(aPlayer, bPlayer, aScore, bScore):
  if aScore + bScore != 100:
    return
  EA = getExpectedScore(aPlayer, bPlayer)
  EB = 1.0 - EA
  agonRating[aPlayer] = agonRating[aPlayer] + (aScore/100.0 - EA)
  agonRating[bPlayer] = agonRating[bPlayer] + (bScore/100.0 - EB)

# For every recorded match, we do pairwise ratings updates between all of the players
# involved in the match, *and* we do a ratings update between each player in the match
# and their role in the game, representing the roles in the game as distinct players
# with their own ratings that vary just like player ratings.
for dataPoint in dataPoints:
  gameURL = dataPoint[1]
  playerNames = dataPoint[2]
  goalValues = dataPoint[3]
  for i in range(len(goalValues)):
    updateRating(playerNames[i], gameURL + '_role' + str(i), goalValues[i], 100 - goalValues[i])
    for j in range(i+1,len(goalValues)):
      updateRating(playerNames[i], playerNames[j], goalValues[i], goalValues[j])

# Display a list of (rating,player) sorted by rating in ascending order.
ratingsForPlayers = [ (i,j) for (j,i) in agonRating.items() ]
ratingsForPlayers.sort()
for rating, playerName in ratingsForPlayers:
  print str(rating).rjust(20), playerName