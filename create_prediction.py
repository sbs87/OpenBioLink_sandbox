import sys
import csv
node1_fn=sys.argv[1]
edge_n=sys.argv[2]
node2_fn=sys.argv[3]

node1=[]
node2=[]
edges=[edge_n]

def read_stuff(fn):
    container=[]
    with open(fn, 'r') as fd:
        reader = csv.reader(fd)
        for row in reader:
            container.append(row[0])
    return(container)
node1=read_stuff(node1_fn)
#edges=read_stuff(edge_fn)
node2=read_stuff(node2_fn)

for n1 in node1:
    for e in edges:
        for n2 in node2:
            print("{}\t{}\t{}".format(n1,e,n2))
