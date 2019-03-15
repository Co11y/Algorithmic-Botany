import os
destination = open("../algorithmicbotany.pde", "w")

path = "./"

source_file = "source.pde"

def parse_file (filepath):
  _file = open(path+"\\"+filepath)
  data = _file.readlines()
  for line in data:
    if line.find("public") != -1:
      destination.write(line[0:line.find("public")]+line[line.find("public")+7:len(line)])
      continue
    destination.write(line)
  destination.write("\n")

parse_file(source_file)

for root, dirs, files in os.walk(path):  
  for file in files:
    if (file == "source.pde"):
      continue
    parse_file(file)

destination.close()