# ----------------------------------
# Create train, test and val sets
# ----------------------------------

## First, create a edge-type filtered dataset ('kite')
SET_PREFIX=HQ_DIR.kite
for set_t in train test val
do
grep -f kite ../OpenBioLink/HQ_DIR/train_test_data/train_sample.csv > $SET_PREFIX.$set_t"_samples.csv"
done

## Next filter for only compounds found in drugcentral (Indications)

### Create list of DRUGSONLY by first inlcuding all edges minus DRUG
grep -v  DRUG kite > kite.DRUGONLY
### Then explicitly add back in approved drugs only
cat   DRUGCENTRAL_PCCOMPOUND.csv >> kite.DRUGONLY
### TODO: DRUGCENTRAL_PCCOMPOUND, kite

### Now pick out based on edge type (non drugs) or explictly for compound ID (nodes)
for set_t in train test val
do
echo $set_t
grep -f kite.DRUGONLY  $SET_PREFIX.$set_t"_samples.csv" > $SET_PREFIX.DRUGONLY.$set_t"_samples.csv"
### To improve power, collapse all iterations of Drug-Gene edge types so that they are only DRUG_GENE (e.g., no DRUG_INHIBITS_GENE)
### Also, reverse the edgetupe that is GENE_DRUG to DRUG_GENE
sed 's/DRUG_.*_GENE/DRUG_GENE/g' $SET_PREFIX.DRUGONLY.$set_t"_samples.csv"  | \
awk -F '\t' '{if ($2=="GENE_DRUG") print $3"\tDRUG_GENE\t"$1; else print $1"\t"$2"\t"$3 }' | sort -u > $SET_PREFIX.DRUGONLY.collapsed.$set_t"_samples.csv"
done

# ----------------------------------
# Train model
# ----------------------------------
### TODO workflow.sh
./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ dummy TransE_l1 TRAIN 10 $SET_PREFIX.DRUGONLY.collapsed

## This will produce a new model based on model's name and iteration
MODEL=TransE_l1_OBL_21

# ----------------------------------
# Test model
# ----------------------------------
./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ $MODEL TransE_l1 TEST 10 $SET_PREFIX.DRUGONLY.collapsed

# ----------------------------------
# Create prediction dataset
# ----------------------------------
# Create sets based on subsets or full sets of entities in train/test/val data (entities.tsv, created by dgl-ke) 

# ///////////
# Rare Disease
# ///////////

## Genes: filter for only Rare disease genes
### Map RD gene symbol from Orphanet to NCBI ID (genesymbol_ncbi.txt). 
awk '{print "NCBIGENE:"$2}'  genesymbol_ncbi.txt | sort -u > ncbi_list.txt
### Intersect NCBI genes in RD gene set
cut -f2 entities.tsv| grep  -wf ncbi_list.txt  > preprocessing/RD_gene

## Drugs: filter for Pubchem Compounds that have an 'inidcated' status from DrugCentral
### Map DrugCentral indicated drugs to PUBCHEM.COMPOUND ID (PUBCHEM.COMPOUND)
grep PUBCHEM.COMPOUND entities.tsv  | cut -f2 | sort -u > preprocessing/hq_drug

## Disease : use all diseases in original training set
grep DOID entities.tsv  | cut -f2 | sort -u  > preprocessing/hq_dis

## Create all desired novel triplet combinations for prediction 
### TODO create_prediction.py 
python3 create_prediction.py preprocessing/hq_drug DRUG_GENE preprocessing/RD_gene > predict_in.RD ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_drug > predict_in.RD ## Drug - Dis
python3 create_prediction.py preprocessing/RD_gene GENE_DIS preprocessing/hq_dis > predict_in.RD ## Gene - Dis ? 

#grep NCBIGENE entities.tsv  | cut -f2 | sort -u > preprocessing/hq_gene

# ///////////
# Teva-specific interest 
# ///////////

## Genes: 
### TODO teva_genes
cat preprocessing/teva_genes  preprocessing/RD_gene > preprocessing/RD_teva_genes 

## Drugs: Pubchem IDs on DrugCentral annoated as 'non organic' drug types
grep -v -w ORGANIC drug_type.tsv  > non_organic_drug_ids.tsv
### or
grep -wf drug_types_of_interest drug_type.tsv  > non_organic_drug_ids.tsv
### Get the Pubchem ID -> Structure ID map from DrugCentral's SQL dump
awk '$3=="PUBCHEM_CID"' public.identifier_table.tsv > public.identifier_table.PUBCHEM_CID.tsv
cut -f2,4 public.identifier_table.PUBCHEM_CID.tsv > map.tmp
### Map the drug_types_of_interest Structure ID (DrugCentral) to Pubchem Compound ID
python3 ../map_entity_multimap.py map.tmp non_organic_drug_ids.tsv | grep -v NOT_FOUND | cut -f2 > ../preprocessing/non_organic_drug
### TODO drug_types_of_interes
### Filter the original drug dataset (all DrugCentral approved drugs, above) for only non-organic type drugs
grep -wf ../preprocessing/hq_drug ../preprocessing/non_organic_drug > ../preprocessing/hq_non_organic_drug

### In tevas portfolio AND in model
awk '$4=="TEVA"'  data/public.ob_product_table.tsv | cut -f2  | sort -u > teva_products
grep -f teva_products  data/public.active_ingredient.table.tsv | cut -f7,9  | sort -u > teva_products.structure
##///map_uid_unit_test.py:
## mapping_fn="mapping_files/pubchem_to_struct"
## query_df=pd.read_csv("teva_products.structure",sep="\t",dtype="str")
## mapped_df=map_uid.map_uid(mapping_fn,query_df)
## mapped_df.to_csv("teva_products.pubchem.tsv",sep="\t")
cut -f3 teva_products.pubchem.tsv | sort -u  > teva_products.pubchem.in.tsv
cut -f2 entities.tsv | grep PUBCHEM  | grep -wf  preprocessing/teva_products.pubchem.in.tsv > preprocessing/teva_products.pubchem.inmodel.tsv 

## Disease: 
### Same as above

## Create all desired novel triplet combinations for prediction 
python3 create_prediction.py preprocessing/hq_non_organic_drug DRUG_GENE preprocessing/teva_genes > predict_in.teva  ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_non_organic_drug >> predict_in.teva ## Drug - Dis
python3 create_prediction.py preprocessing/RD_teva_genes GENE_DIS preprocessing/hq_dis > predict_in.teva ## Gene - Dis ? 

python3 create_prediction.py preprocessing/hq_non_organic_drug DRUG_GENE preprocessing/teva_genes > predict_in.teva  ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_non_organic_drug > predict_in.teva ## Drug - Dis
python3 create_prediction.py preprocessing/teva_genes GENE_DIS preprocessing/hq_dis > predict_in.teva ## Gene - Dis ? 

### Repurposing Teva drugs
python3 create_prediction.py preprocessing/teva_products.pubchem.inmodel.tsv  DRUG_GENE preprocessing/RD_gene > predict_in.teva
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/teva_products.pubchem.inmodel.tsv >> predict_in.teva ## Drug - Dis

### TL1A
echo "DOID:12236" > preprocessing/teva_PBC
grep -i TNF id_mappings.tsv | grep NCB | cut -f1    > tmp.tl1a 
grep -f tmp.tl1a entities.tsv | cut -f2 > preprocessing/teva_TL1A_genes
rm -f tmp.tl1a 

python3 create_prediction.py preprocessing/hq_drug DRUG_GENE preprocessing/teva_TL1A_genes > predict_in.teva_TL1A  ## Drug - Gene
python3 create_prediction.py preprocessing/teva_PBC DIS_DRUG preprocessing/hq_drug > predict_in.teva_TL1A ## Drug - Dis
python3 create_prediction.py preprocessing/teva_TL1A_genes GENE_DIS preprocessing/teva_PBC > predict_in.teva_TL1A ## Gene - Dis ? 


# ///////////
# Split input triples into node1, egde and node2 files; some need to be batched in
# ///////////

# Rare diseases prediction input
cutpoint=6354672
cutpoint_upper=1
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f1 > node1
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f3 > node2
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f2 > edge

cut -f1 predict_in.teva | head -n  40000000 | tail -n 10000000 > node1
cut -f3 predict_in.RD.DD | head -n 40000000  | tail -n 10000000 > node2
cut -f2 predict_in.RD.DD | head -n 40000000 | tail -n 10000000 > edge

# Teva-specific input 
cut -f1 predict_in.teva  > node1
cut -f3 predict_in.teva > node2
cut -f2 predict_in.teva > edge


cut -f1 predict_in.teva_TL1A  > node1
cut -f3 predict_in.teva_TL1A > node2
cut -f2 predict_in.teva_TL1A > edge

# ----------------------------------
# Make predictions
# ----------------------------------

./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ $MODEL TransE_l1 PREDICT 50000 $SET_PREFIX.DRUGONLY.collapsed
mv TransE_l1_OBL_21_results.csv TransE_l1_OBL_21_results.teva_TL1A.csv 
# For rare disase:
## only did untill 44354672 for Druug-Gene... moved on o Drugf-Dis. Doing top 5000 per iteration, combining. 
## only did untill 40000000 for Dis Drug 

# For teva: did all in one batch since it's a low amount

# ----------------------------------
# Format, rank, process predictions
# ----------------------------------

# RD - combined these resuls 
cat  *part* | sort -k4 -rn  | head -n 5000 > TransE_l1_OBL_21_results.compiled_results.csv

# stopped after 10 mins. Got to about 2400 which is good enough for now. 

# ///////////
# Remove triplets that are in training data from predictions
# ///////////
cut -f1-3 $SET_PREFIX.DRUGONLY."train_samples.csv" > in_train
cut -f1-3 data/$SET_PREFIX.DRUGONLY.{train,test,val}"_samples.csv" > in_train
cut -f1-3 train_test_input/$SET_PREFIX.DRUGONLY.train_samples.csv > in_train
cut -f1-3 train_test_input/$SET_PREFIX.DRUGONLY.{val,test}"_samples.csv" > in_test_val
grep -vf in_train TransE_l1_OBL_21_results.teva_TL1A.csv > TransE_l1_OBL_21_results.teva_TL1A.rmtrain.csv

# ///////////
# Map entity IDs to common name
# ///////////
python3 map_entity_OBL.py id_mappings.tsv TransE_l1_OBL_21_results.teva_TL1A.rmtrain.csv > TransE_l1_OBL_21_results.teva_TL1A.rmtrain.mapped.csv

## Remember to mv the model so it can be saved from overwrite
mv TransE_l1_OBL_21_results.teva.rmtrain.csv TransE_l1_OBL_21_results.teva_gene_drug.rmtrain.csv