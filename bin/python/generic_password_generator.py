#!/usr/bin/env python
''' @PACKAGE generic_password_generator.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''

import random
import re

def find_words(num=None, 
               dictfile=None):
  dictfile = "/usr/share/dict/american-english"
  r = random.SystemRandom() 
  f = open(dictfile, "r")

  count = 0
  chosen = []

  for i in range(num):
    chosen.append("")

  prog = re.compile("^[a-z]{5,9}$") 
  for word in f:
    if(prog.match(word)):
      for i in range(num): 
        if(r.randint(0,count) == 0): 
          chosen[i] = word.strip()
        count += 1

  return(chosen)

def genpass(num=3):
  return(" ".join(find_words(num)))

if(__name__ == "__main__"):
  print genpass()
