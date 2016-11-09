from operator import itemgetter
from itertools import combinations
from itertools import permutations
import math
import numpy as np
import scipy
import random
import numpy

cimport numpy as np
cimport cython

pool = ('2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', 'tc', 'jc', 'qc', 'kc', 'ac', '2d', '3d', '4d', '5d', '6d', '7d', '8d', '9d', 'td', 'jd', 'qd', 'kd', 'ad', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', 'th', 'jh', 'qh', 'kh', 'ah', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s', 'ts', 'js', 'qs', 'ks', 'as')

pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]

pool_variable = list(pool)

######################################################
######################################################
######################################################
######################################################
######################################################
######################################################
######################################################
######################################################

@cython.boundscheck(False)
@cython.wraparound(False)
def SCOREpyx(list hand):
	""" Calculates the "score list" of the hand."""

	cdef int p, r, t

	cdef int sumz, x, y, i, length
	cdef list scorearray, flushstraight
	cdef np.ndarray[np.int8_t, ndim=2] a

	a = np.zeros((4, 13), dtype = np.int8)

	for p in hand:
		r, t = p/13, p%13
		a[r, t] = 1
	
#-----------------------------------------------------------------------
# FLUSH/STRAIGHT FLUSH CHECK FROM MATRIX
	sumz, scorearray, flushstraight = 0, [], []
	
	for x in xrange(4):
		for i in xrange(13):
			sumz += a[x, i]

		if sumz >= 5:
			scorearray.append(6)
			for y in xrange(12, -1, -1):
				if a[x, y] > 0:
					scorearray.append(y)
			
			if a[y, 12] == 1:
				scorearray.append(-1)

			length = sumz + 1
			if length == 6:
				if scorearray[1] - scorearray[5] == 4:
					return (9, scorearray[1])
				return tuple(scorearray[0:6])

			if length == 7:
				for i in xrange(1, 3, 1):
					if scorearray[i] - scorearray[i+4] == 4:
						return (9, scorearray[1])
				return tuple(scorearray[0:6])

			if length == 8:
				for i in xrange(1, 4, 1):
					if scorearray[i] - scorearray[i+4] == 4:
						return (9, scorearray[1])
				return tuple(scorearray[0:6])

			if length == 9:
				for i in xrange(1, 5, 1):
					if scorearray[i] - scorearray[i+4] == 4:
						return (9, scorearray[1])
				return tuple(scorearray[0:6])

		sumz = 0		
#--------------------------------------------------------------------------------
#STRAIGHT/ VALUE ARRAY
	cdef int j, k
	cdef list value, tempstraight

	value, tempstraight= [], []

	for i in xrange(12, -1, -1):
		for j in xrange(4):
			sumz += a[j, i]
		if sumz >0:		
			value.append((sumz, i))
			tempstraight.append(i)
		sumz = 0

	if tempstraight[0] == 12:
		tempstraight.append(-1)

	length = len(tempstraight)

	if length == 7:
		for i in xrange(3):
			if tempstraight[i] - tempstraight[i+4] == 4:
				return (5, tempstraight[i])

	if length == 6:
		for i in xrange(2):
			if tempstraight[i] - tempstraight[i+4] == 4:
				return (5, tempstraight[i])

	if length == 5:
		if tempstraight[0] - tempstraight[4] == 4:
			return (5, tempstraight[i])

	if length == 8:
		for i in xrange(4):
			if tempstraight[i] - tempstraight[i+4] == 4:
				return (5, tempstraight[i])

#--------------------------------------------------------------------------------
# EVERYTHING ELSE
	value.sort(reverse=True)

	if value[0][0] == 1: #High Card
		return (1, value[0][1], value[1][1], value[2][1], value[3][1], value[4][1])

	if value[0][0] == 2:
		if value[1][0] == 1: #Pair
			return (2, value[0][1], value[1][1], value[2][1], value[3][1])			

		else:			# Two Pair
			return (3, value[0][1], value[1][1], value[2][1])

	if value[0][0] == 3:	# Trips
		if value[1][0] == 1:
			return (4, value[0][1], value[1][1], value[2][1])
		else:
			return (7, value[0][1], value[1][1])

	if value[0][0] == 4:	#4-of-a-kind
		if len(value) == 2:
			return(8, value[0][1], value[1][1])
		if value[1][1] > value[2][1]:
			return(8, value[0][1], value[1][1])
		if value[1][1] < value[2][1]:
			return(8, value[0][1], value[2][1])		
	print 'NOW YOU FUCKED UP' # If this comes up, repent, for something went terribly, terribly wrong.

############################################
############################################
############################################
############################################
############################################
############################################
# Calculate
@cython.boundscheck(False)
@cython.wraparound(False)
def flopodds(list hand):
	cdef list pool_numbers, pool_reference, pool
	cdef list blankhand, player_hand, opponent_hand
	cdef list player_hand_reference, opponent_hand_reference
	cdef tuple qqq, www
	cdef str i
	cdef int a, turn, river, opponent1, opponent2, win, loss, length

	blankhand = []
	win, loss = 0, 0
	pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]

	pool = ['2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', 'tc', 'jc', 'qc', 'kc', 'ac', '2d', '3d', '4d', '5d', '6d', '7d', '8d', '9d', 'td', 'jd', 'qd', 'kd', 'ad', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', 'th', 'jh', 'qh', 'kh', 'ah', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s', 'ts', 'js', 'qs', 'ks', 'as']

	for i in hand:
		a = pool.index(i)
		blankhand.append(a)

	opponent_hand = blankhand[2:5]
	opponent_hand_reference = list(opponent_hand)
	player_hand = blankhand
	player_hand_reference = list(player_hand)

	blankhand.sort(reverse=True)
	for a in blankhand:
		del(pool_numbers[a])

	pool_reference = list(pool_numbers)

	for turn, river in combinations(pool_numbers, r=2):
		pool_numbers = list(pool_reference)
		player_hand = list(player_hand_reference)

		if turn > river:
			del(pool_numbers[pool_numbers.index(turn)])
			del(pool_numbers[pool_numbers.index(river)])
		else:
			del(pool_numbers[pool_numbers.index(river)])					
			del(pool_numbers[pool_numbers.index(turn)])

		player_hand.extend((turn, river))
		qqq = SCOREpyx(player_hand)
		length = len(qqq)

		for opponent1, opponent2 in combinations(pool_numbers, r = 2):
			opponent_hand = list(opponent_hand_reference)
			opponent_hand.extend((turn, river, opponent1, opponent2))

			www = SCOREpyx(opponent_hand)

			for a in xrange(length):
				if qqq[a] > www[a]:
					win += 1
					break
				if qqq[a] < www[a]:
					loss += 1
					break
				continue

	return win, loss

############################################
############################################
############################################
############################################
############################################
############################################

@cython.boundscheck(False)
@cython.wraparound(False)
def turnodds(list hand):
	cdef list pool_numbers, pool_reference, pool
	cdef list blankhand, player_hand, opponent_hand
	cdef list player_hand_reference, opponent_hand_reference
	cdef tuple qqq, www
	cdef str i
	cdef int a, turn, river, opponent1, opponent2, win, loss, length

	blankhand = []
	win, loss = 0, 0
	pool = ['2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', 'tc', 'jc', 'qc', 'kc', 'ac', '2d', '3d', '4d', '5d', '6d', '7d', '8d', '9d', 'td', 'jd', 'qd', 'kd', 'ad', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', 'th', 'jh', 'qh', 'kh', 'ah', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s', 'ts', 'js', 'qs', 'ks', 'as']
	pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]

	for i in hand:
		a = pool.index(i)
		blankhand.append(a)

	opponent_hand = blankhand[2:6]
	opponent_hand_reference = list(opponent_hand)
	player_hand = blankhand
	player_hand_reference = list(player_hand)

	blankhand.sort(reverse=True)
	for a in blankhand:
		del(pool_numbers[a])

	pool_reference = list(pool_numbers)

	for river in pool_numbers:
		pool_numbers = list(pool_reference)
		player_hand = list(player_hand_reference)

		del(pool_numbers[pool_numbers.index(river)])

		player_hand.append(river)
		qqq = SCOREpyx(player_hand)
		length = len(qqq)

		for opponent1, opponent2 in combinations(pool_numbers, r = 2):
			opponent_hand = list(opponent_hand_reference)
			opponent_hand.extend((river, opponent1, opponent2))

			www = SCOREpyx(opponent_hand)			
			for a in xrange(length):
				if qqq[a] > www[a]:
					win += 1
					break
				if qqq[a] < www[a]:
					loss += 1
					break
				continue

	return (win/45540.0), (loss/45540.0), ((win + loss)/45540.0)

############################################
############################################
############################################
############################################
############################################
############################################


@cython.boundscheck(False)
@cython.wraparound(False)
def riverodds(list hand):
	cdef list pool_numbers, pool_reference, pool
	cdef list blankhand, player_hand, opponent_hand
	cdef list player_hand_reference, opponent_hand_reference
	cdef tuple qqq, www
	cdef str i
	cdef int a, turn, river, opponent1, opponent2, win, loss, length

	blankhand = []
	win, loss = 0, 0
	pool = ['2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', 'tc', 'jc', 'qc', 'kc', 'ac', '2d', '3d', '4d', '5d', '6d', '7d', '8d', '9d', 'td', 'jd', 'qd', 'kd', 'ad', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', 'th', 'jh', 'qh', 'kh', 'ah', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s', 'ts', 'js', 'qs', 'ks', 'as']
	pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]

	for i in hand:
		a = pool.index(i)
		blankhand.append(a)

	opponent_hand = blankhand[2:7]
	opponent_hand_reference = list(opponent_hand)
	player_hand = blankhand
	player_hand_reference = list(player_hand)

	blankhand.sort(reverse=True)
	for a in blankhand:
		del(pool_numbers[a])


	pool_reference = list(pool_numbers)
	qqq = SCOREpyx(player_hand)
	length = len(qqq)

	for opponent1, opponent2 in combinations(pool_numbers, r = 2):
		opponent_hand = list(opponent_hand_reference)
		opponent_hand.extend((opponent1, opponent2))

		www = SCOREpyx(opponent_hand)

		for a in xrange(length):
			if qqq[a] > www[a]:
				win += 1
				break
			if qqq[a] < www[a]:
				loss += 1
				break
			continue

	return (win/990.0), (loss/990.0), ((win + loss)/990.0)


############################################
############################################
############################################
############################################
############################################
############################################

@cython.boundscheck(False)
@cython.wraparound(False)
def randflopodds(list hand, int x):
	cdef int a, b, length, length1, length2
	cdef str i
	cdef list blankhand, deletez, handz, cards, playerhand, opponenthand, pool, pool_numbers
	cdef tuple qqq, www
	cdef int count, win

	pool = ['2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', 'tc', 'jc', 'qc', 'kc', 'ac', '2d', '3d', '4d', '5d', '6d', '7d', '8d', '9d', 'td', 'jd', 'qd', 'kd', 'ad', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', 'th', 'jh', 'qh', 'kh', 'ah', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s', 'ts', 'js', 'qs', 'ks', 'as']
	pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
	blankhand, deletez = [], []
	win, loss, count = 0, 0, 0

	for i in hand:
		a = pool.index(i)
		blankhand.append(a)
		deletez.append(a)

	deletez.sort(reverse=True)
	for a in deletez:
		del(pool_numbers[a])

	random.shuffle(pool_numbers)

	for b in xrange(x):
		handz = list(blankhand)
		cards = random.sample(pool_numbers, 4)
	
		handz.extend(cards)
		playerhand = handz[0:7]
		opponenthand = handz[2:9]

		qqq = SCOREpyx(playerhand)
		www = SCOREpyx(opponenthand)

		length = len(qqq)

		count += 1

		for j in xrange(length):
			if qqq[j] > www[j]:
				win += 1
				break
			if qqq[j] < www[j]:
				loss += 1
				break
			continue
	return (win/ float(count)), (loss/ float(count)), x
#	return winz, numbers

############################################
############################################
############################################
############################################
############################################
############################################
@cython.boundscheck(False)
@cython.wraparound(False)
def randpreflopodds(list hand, int x):
	cdef int a, b, length, length1, length2
	cdef str i
	cdef list blankhand, deletez, handz, cards, playerhand, opponenthand, pool, pool_numbers
	cdef tuple qqq, www
	cdef int count, win

	pool = ['2A', '3A', '4A', '5A', '6A', '7A', '8A', '9A', 'tA', 'jA', 'qA', 'kA', 'aA', '2B', '3B', '4B', '5B', '6B', '7B', '8B', '9B', 'tB', 'jB', 'qB', 'kB', 'aB', '2C', '3C', '4C', '5C', '6C', '7C', '8C', '9C', 'tC', 'jC', 'qC', 'kC', 'aC', '2D', '3D', '4D', '5D', '6D', '7D', '8D', '9D', 'tD', 'jD', 'qD', 'kD', 'aD']
	pool_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
	blankhand, deletez = [], []
	win, loss, count = 0, 0, 0

	for i in hand:
		a = pool.index(i)
		blankhand.append(a)
		deletez.append(a)

	deletez.sort(reverse=True)
	for a in deletez:
		del(pool_numbers[a])

	random.shuffle(pool_numbers)

	for b in xrange(x):
		handz = list(blankhand)
		cards = random.sample(pool_numbers, 7)
	
		handz.extend(cards)
		playerhand = handz[0:7]
		opponenthand = handz[2:9]

		qqq = SCOREpyx(playerhand)
		www = SCOREpyx(opponenthand)

		length = len(qqq)

		count += 1

		for j in xrange(length):
			if qqq[j] > www[j]:
				win += 1
				break
			if qqq[j] < www[j]:
				loss += 1
				break
			continue

	return (win/ float(count)), (loss/float(count)), ((win+loss)/float(count))










