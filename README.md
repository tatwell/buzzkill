# BuzzKill
Spelling Bee is a daily puzzle from the New York Times. The digital version can
be found online here:

https://www.nytimes.com/puzzles/spelling-bee

I was lured into it during the pandemic by the daily tweets on the official
New York Times Twitter account. Apparently, I'm not alone and there is a
thriving community of daily puzzle solvers:

https://www.nytimes.com/2020/10/16/crosswords/spellingbee-puzzles.html

This script programmatically searches out words based on the rules of the puzzle.


## Spoiler Alert
As the article above notes, there a number of solvers available online. I wrote this
script for the same reason I play the puzzle: to exercise my mind. I only use it
after I've reached genius level and want to see what I've missed or reach the Queen
Bee.

It's also worth noting that the New York Times uses its own proprietary word list.
So this script will generally find words not recognized by the Times and usually
seems to mess one or two this it does count.


## Usage

```
$ cd buzzkill
$ ruby ruby/buzzkill.rb RWYKACT

Solving for RWYKACT [requires: R]
Using word file: ruby/../wordlists/english-109583.txt
TESTING...
Tests passed!

Solving for RWYKACT [requires: R]
Using word file: ruby/../wordlists/english-109583.txt
{"A"=>"(6) ARRACK  ARRAY  ARTY  ATTAR  ATTRACT  AWRY",
 "C"=>
  "(9) CARAT  CARAWAY  CARRY  CART  CARTWAY  CATARACT  CRACK  CRACKY  CRAW",
 "K"=>"(2) KARAT  KART",
 "R"=>"(6) RACK  RACY  RARA  RATA  RATATAT  RATTY",
 "T"=>"(8) TARRY  TART  TARTAR  TATAR  TRACK  TRACKWAY  TRACT  TRAY",
 "W"=>"(5) WARK  WART  WARTY  WARY  WRACK",
 "PANGRAMS"=>"(1) TRACKWAY"}
{:pangrams=>1, :count=>36, :max_score=>148}
```
