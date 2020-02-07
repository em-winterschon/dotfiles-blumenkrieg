#!/usr/bin/env python
from Crypto.Hash import SHA256
import random

'''generate secure hash for public key'''
HASH_REPS = 1024
def __saltedhash(string, salt):
    sha256 = SHA256.new()
    sha256.update(string)
    sha256.update(salt)
    for x in xrange(HASH_REPS): 
        sha256.update(sha256.digest())
        if x % 10: sha256.update(salt)
    return sha256

def saltedhash_hex(string, salt):
    """returns the hash in hex format"""
    return __saltedhash(string, salt).hexdigest()

string = str(random.random())
salt = str(random.random())

salted = saltedhash_hex(string, salt)

print string
print salt
print salted

