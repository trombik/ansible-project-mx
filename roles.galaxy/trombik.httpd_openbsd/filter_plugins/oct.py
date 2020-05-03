from ansible import errors
import hashlib
import itertools
import re

def octal(string):
    '''returns octal value of string when string is digits, or string itself unmodified when not'''
    m = re.match("\d+$", str(string))
    if m:
        return oct(int(str(string)))
    else:
        return string

class FilterModule(object):
    ''' A filter to convert string to octal'''
    def filters(self):
        return {
            'oct' : octal
        }
