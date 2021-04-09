import sys
import os
import pandas as pd
#home_dir="/Users/stevensmith/Projects/OpenBioLink_sandbox/"
results_file=sys.argv[1]
training_file=sys.argv[2]
home_dir=os.path.basename(results_file)
out_file=home_dir+results_file+".filtered.tsv" #"TransE_l2_OBL_9_results.filtered.tsv"
training_df=pd.read_csv(training_file,sep="\t",header=None,names=['Node_1','edge','Node_2','score','unknown','source'])
results_df=pd.read_csv(results_file, header=0,sep="\t")
print(results_df)
#print(training_df.head(n=5))
filtered_results=pd.DataFrame(data={},columns=results_df.columns)
for i,t in training_df[173300:173409].iterrows():
    t_i=[t['Node_1'],t['edge'],t['Node_2']]
    for j,r in results_df.iterrows():
        #print("{};{}".format(i,j))
        r_i=[r['head'],r['rel'],r['tail']]
        if t_i!=r_i:
            filtered_results=filtered_results.append(r)
print("finished comparing")
filtered_results.to_csv(out_file,sep="\t",index=None)
print("finished writing")




