import os
import re
destination = open("../algorithmicbotany.pde", "w")
pattern = re.compile(r'public\s+class')
path = "./"

def parse (file, destination):
  with open(file, 'r') as f:
    lines = f.readlines()
    for line in lines:
      if pattern.match(line):
        destination.write(re.sub('public', '', line))
      elif line.find("/*~") >= 0:
        destination.write(line[0:line.find("/*~")] + line[line.find("/*~") + 4:len(line)])
      elif line.find("~*/") >= 0:
        destination.write(line[0:line.find("~*/")] + line[line.find("/*~") + 4:len(line)])
      else:
        destination.write(line)


parse ('source.pde', destination)
for root, dirs, files in os.walk(path):  
  for file in files:
    if (file == "source.pde"):
      continue
    parse(file, destination)


destination.close()