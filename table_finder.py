
import sys
import csv
import os

mode=sys.argv[1] # print_table or #find_table
queries_file=sys.argv[2] # file with line #s (find_table) or table names (print_table)
table_map_file=sys.argv[3] #line #s where SQL tables are found in sql dump

table_map=dict()

# Store start line for each SQL table
with open(table_map_file,'r') as file_h:
    t_reader= csv.reader(file_h,delimiter='\t')
    prev_table='none'
    for i,row in enumerate(t_reader):
        #print(row)
        table_name=row[1]
        table_line=int(row[0])
        
        table_map[table_name]={'start':table_line,'end':-1,'i':prev_table}
        prev_table=table_name
        
#print(table_map)

# Find the table's end position based on previous table's start position
table_map['none']={'start':0,'end':0,'i':'none'}
for table_name in table_map:
    table_line=table_map[table_name]['start']
    prev_table=table_map[table_name]['i']
    table_map[prev_table]['end']=table_line
    
#print(table_map)
#table_map={'public.act_table_full':{'start':'2664','end':'19837'},'public.action_type':{'start':'19838','end':'19878'}}

#query=170082 #sys.argv[2]

# find_table - finds which table a line number belongs 
def find_table(queries_file,table_map):
    with open(queries_file,'r') as file_h2:
        q_reader=csv.reader(file_h2,delimiter='\t')
        for row in q_reader:
            success=False
            query=int(row[0])
            for table in table_map:
                t_start=int(table_map[table]['start'])
                t_end=int(table_map[table]['end'])
                if query >=t_start and query <t_end:
                    print(table+"\t"+str(query))
                    success=True
            if not success :
                print("could not find "+str(query))

# print table - prints the table contents to file based on table start/stop
def print_table(queries_file,sql_path,table_map):
    with open(queries_file,'r') as file_h2:
        q_reader=csv.reader(file_h2,delimiter='\t')
        for row in q_reader:
            success=False
            table=row[0]
            start=table_map[table]['start']
            stop=table_map[table]['end']
            #start=stop - table_map[table]['start']
            #cmd="awk 'NR>= {} && NR< {}' {} > {}_table.head.tsv".format(start,stop,sql_path,table)
            cmd="head -n {} {} | tail -n+{} > {}_table.head.tsv".format(stop,sql_path,start,table)
            print(cmd)
            os.system(cmd)

# switch for find_table or print_table
if mode=='find_table':
    find_table(queries_file,table_map)
if mode=='print_table':
    sql_path=sys.argv[4] #'FOO/o_files/sql_dump.sql'
    print_table(queries_file,sql_path,table_map)


1
2
3
4
5
6
7
8
9
10
11
12
13
14
15


