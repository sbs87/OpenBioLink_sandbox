
import sys
import csv

table_map_file=sys.argv[2]
queries_file=sys.argv[1]
table_map=dict()

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

table_map['none']={'start':0,'end':0,'i':'none'}
for table_name in table_map:
    table_line=table_map[table_name]['start']
    prev_table=table_map[table_name]['i']
    table_map[prev_table]['end']=table_line
    
    
        
#print(table_map)
#table_map={'public.act_table_full':{'start':'2664','end':'19837'},'public.action_type':{'start':'19838','end':'19878'}}


# In[65]:


#query=170082 #sys.argv[2]

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
        if(not success):
            print("could not find "+str(query))
