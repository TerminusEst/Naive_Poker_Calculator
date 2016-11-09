# Naive_Poker_Calculator
A naive (brute-force) Texas Hold 'Em poker calculator written in Cython. Written so that I could learn Cython. Surprisingly fun way to learn about code optimisation.

Calculating flop odds on a Intel Core i7-4790 @ 3.60GHz:
![figure_1](https://cloud.githubusercontent.com/assets/20742138/20135386/69dad068-a667-11e6-8b37-04ad9285c1e0.png)

Exhaustive calculation (1,070,190 hands) takes 1.94s.

##**How It Works**

Every combination of 7 cards is made into a 4*13 (4 suits, 13 cards) matrix, 1's for cards, 0's otherwise.

For example, for a 7 card hand (2 pocket and 5 table cards):

```python
>>> hand = ["2s", "th", "js", "qh", "kh", "ah", "td"]
```

would give a matrix:

```python
array([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]], dtype=int8)
```

 A number of tests are then performed to give a score tuple. The above matrix would give a score tuple of:

```python
>>> SCOREpyx(hand)
(5, 12)
```
where the 5 refers to a straight, and 12 indicates that the straight is to the ace.

When calculating flop odds, there are 2 known hole cards, and 3 known table cards.
There are therefore 47C2 (1081) combinations of river and turn cards, and a further 45C2 (980) combinations of opponents cards.

For every possible combination of opponents and table cards, a score matirx is calculated, and compared to your hand.

##**Monte-Carlo Simulation**
50,000 random flop scenarios were exhaustively calculated to get a true win percentage. For these same trial hands, 75, 50, 25, 10, 5 and 1 thousand random combination of remaining board and opponent hands were calculated. This gave distributions which are plotted above.

What I found nice was that a random selection of 1,000 combinations of the hole and opponent hands gave fairly accurate results (95% of the values were within 8.3% of the true value). 

There is diminishing returns for increasing the number of random combinations.
