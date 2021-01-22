import emmet
import sys

emmetstring=""

for line in sys.stdin:
  emmetstring=emmet.expand(line.rstrip('\n'))
  
print(emmetstring)

