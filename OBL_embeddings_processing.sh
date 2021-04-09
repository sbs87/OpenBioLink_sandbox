

# get DOID mapping 
# rm -f preprocessing/map.*
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i parkin > preprocessing/map.parkinson
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i Diabetes > preprocessing/map.Diabetes
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i Malaria > preprocessing/map.Malaria
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i gout > preprocessing/map.gout
# awk -F '\t' '$3=="DO"' disease_mappings.tsv | grep -i "Dermatitis herpetiformis" > preprocessing/map.Dermatitis




# rm -f preprocessing/rel.*
# cut -f4 preprocessing/map.Diabetes  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:56843207"}' > preprocessing/rel.Diabetes_Colesevelam
# cut -f4 preprocessing/map.parkinson  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:31101"}' > preprocessing/rel.parkinson_Bromocriptine
# cut -f4 preprocessing/map.Malaria  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:2955"}' > preprocessing/rel.Malaria_Dapsone
# cut -f4 preprocessing/map.gout  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:135401907"}' > preprocessing/rel.gout_Allopurinol
# cut -f4 preprocessing/map.Dermatitis  | sort -u | awk '{print "DOID:"$0"\tDIS_DRUG\tPUBCHEM.COMPOUND:2955"}' > preprocessing/rel.Dermatitis_Dapsone

# cat preprocessing/rel.* > preprocessing/rel.all

# cut 1, 2, 3 into node, edge,node OR rull all disease -< 1 drug (each drug) and filter out
# also need to ensure inputs are in training. 


# cut -f1 preprocessing/rel.all > preprocessing/node1.all
# cut -f1 SUBGRAPH_train_samples.no_list1.tsv | grep DOID |sort -u > node1_training
# grep -vwf node1_training preprocessing/node1.all  > node1_not_in_training
# grep -vwf node1_not_in_training preprocessing/rel.all > preprocessing/rel.all.filter

# cut -f3 preprocessing/rel.all > preprocessing/node2.all
# cut -f3 SUBGRAPH_train_samples.no_list1.tsv | grep PUBCHEM |sort -u > node2_training
# grep -vwf node2_training preprocessing/node2.all  > node2_not_in_training
# grep -vwf node2_not_in_training preprocessing/rel.all.filter > tmp # 
# preprocessing/rel.all.filter

# collapse DRUG_GENE edges and reverse the one GENE_DRUG edge


#DIS_DRUG 
awk -F '\t'  '$2~"DIS_DRUG" {print $1}' SUBGRAPH_{train,test,val}_samples.csv | sort -u  > preprocessing/all_dis
awk -F '\t'  '$2~"DIS_DRUG" {print $3}' SUBGRAPH_{train,test,val}_samples.csv | sort -u  > preprocessing/all_drug

while read chr; do
awk -v chr="$chr" '{print chr"\tDIS_DRUG\t"$0}' preprocessing/all_drug >> predict_in.DIS_DRUG
done < preprocessing/all_dis


## GENE_DIS

awk -F '\t'  '$2~"GENE_DIS" {print $1}' ALL_SUBGRAPH_{train,test,val}_samples*.qfiltered.csv | sort -u  > preprocessing/all_gene
awk -F '\t'  '$2~"GENE_DIS" {print $3}' ALL_SUBGRAPH_{train,test,val}_samples*.qfiltered.csv | sort -u  > preprocessing/all_dis

awk -F '\t'  '$2~"GENE_DIS" {print $1}' HQ_DIR.kite.DRUGONLY.{train,test,val}_samples.csv | sort -u  > preprocessing/hq_gene
awk -F '\t'  '$2~"GENE_DIS" {print $3}' HQ_DIR.kite.DRUGONLY.{train,test,val}_samples.csv | sort -u  > preprocessing/hq_dis
awk -F '\t'  '$2~"DRUG_" {print $1}' HQ_DIR.kite.DRUGONLY.{train,test,val}_samples.csv | sort -u  > preprocessing/hq_drug

awk '{print "NCBIGENE:"$2}'  genesymbol_ncbi.txt | sort -u  > preprocessing/RD_gene
##

grep PUBCHEM.COMPOUND entities.tsv  | cut -f2 | sort -u > preprocessing/all_drug
grep NCBIGENE entities.tsv  | cut -f2 | sort -u > preprocessing/all_gene
grep DOID entities.tsv  | cut -f2 | sort -u  > preprocessing/all_dis


cutpoint=12354672
cutpoint_upper=6354672
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f1> node1
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f3 > node2
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f2 > edge


cut -f3 predict_in.DIS_DRUG  | head -n $cutpoint > node2
cut -f2 predict_in.DIS_DRUG  | head -n $cutpoint > edge

./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ TransE_l1_OBL_19 TransE_l1 PREDICT $cutpoint_upper HQ_DIR.kite.DRUGONLY

cut -f1 predict_in.GENE_DIS > node1
cut -f3 predict_in.GENE_DIS  > node2
cut -f2 predict_in.GENE_DIS   > edge

cut -f1 predict_in.DRUG_BINDING_GENE | head -n 9000000 > node1
cut -f3 predict_in.DRUG_BINDING_GENE |  head -n  9000000 > node2
cut -f2 predict_in.DRUG_BINDING_GENE |  head -n 9000000   > edge

cut -f1 predict_in.GENE_DIS | tail -n  4000000> node1
cut -f3 predict_in.GENE_DIS |  tail -n  4000000 > node2
cut -f2 predict_in.GENE_DIS |  tail -n 4000000   > edge

./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ TransE_l1_OBL_1 TransE_L1 PREDICT
RESULTS=/Users/stevensmith/Projects/OpenBioLink_sandbox/TransE_l1_OBL_0_results.csv
grep GENE_DIS SUBGRAPH_train_samples.csv | cut -f1-3 > tmp.training.filt


## My own cross validation
for x in 1 2 3 4 5 6 7 8 9 10
do 
echo $x
seed=$x
awk -v seed=$seed 'NR%10==seed' HQ_DIR.triangle.DRUGONLY.test_samples.csv | cut -f1 >  node1
awk -v seed=$seed 'NR%10==seed' HQ_DIR.triangle.DRUGONLY.test_samples.csv | cut -f2 >  edge
awk -v seed=$seed 'NR%10==seed' HQ_DIR.triangle.DRUGONLY.test_samples.csv | cut -f3 >  node2

./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ TransE_l1_OBL_14 TransE_l1 PREDICT 10000000

cat TransE_l1_OBL_14_results.csv >> homemade_val_results
done

grep -f triangle ../OpenBioLink/HQ_DIR/train_test_data/train_sample.csv > HQ_DIR.triangle.train_samples.csv
grep -f triangle.DRUGONLY  HQ_DIR.triangle.train_samples.csv > HQ_DIR.triangle.DRUGONLY.train_samples.csv

## Create 'kite' and 'kite + DRUG ONLY compound' sets
grep -f kite ../OpenBioLink/HQ_DIR/train_test_data/train_sample.csv > HQ_DIR.kite.DRUGONLY.train_samples.csv
grep -f kite.DRUGONLY  HQ_DIR.kite.train_samples.csv > HQ_DIR.kite.DRUGONLY.train_samples.csv


./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ foo TransE_l1 TRAIN 10 HQ_DIR.kite.DRUGONLY 



#####
#------
###

# Filter train, test, val sets

## First, create a edge-type filtered dataset
SET_PREFIX=HQ_DIR.kite
for set_t in train test val
do
grep -f full_minus_ontology ../OpenBioLink/HQ_DIR/train_test_data/train_sample.csv > $SET_PREFIX.$set_t"_samples.csv"
done

## Then filter for only compounds found in drugcentral (Indications)
grep -v  DRUG full_minus_ontology > full_minus_ontology.DRUGONLY
cat   DRUGCENTRAL_PCCOMPOUND.csv >> full_minus_ontology.DRUGONLY

for set_t in train test val
do
echo $set_t
grep -f full_minus_ontology.DRUGONLY  $SET_PREFIX.$set_t"_samples.csv" > $SET_PREFIX.DRUGONLY.$set_t"_samples.csv"
sed 's/DRUG_.*_GENE/DRUG_GENE/g' $SET_PREFIX.DRUGONLY.$set_t"_samples.csv"  | \
awk -F '\t' '{if ($2=="GENE_DRUG") print $3"\tDRUG_GENE\t"$1; else print $1"\t"$2"\t"$3 }' | sort -u > $SET_PREFIX.DRUGONLY.collapsed.$set_t"_samples.csv"
done

# Train model
# Test model
./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ dummy TransE_l1 TEST 10 $SET_PREFIX.DRUGONLY.collapsed
# Make predictions
## Create combinagtions of novel relations

### Rare disease genes in data
awk '{print "NCBIGENE:"$2}'  genesymbol_ncbi.txt | sort -u > ncbi_list.txt
cut -f2 entities.tsv| grep  -wf ncbi_list.txt  > preprocessing/RD_gene
grep PUBCHEM.COMPOUND entities.tsv  | cut -f2 | sort -u > preprocessing/hq_drug
grep DOID entities.tsv  | cut -f2 | sort -u  > preprocessing/hq_dis
#grep NCBIGENE entities.tsv  | cut -f2 | sort -u > preprocessing/hq_gene
python3 create_prediction.py preprocessing/hq_drug DRUG_GENE preprocessing/RD_gene > predict_in.RD ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_drug > predict_in.RD.DD ## Drug - Dis
python3 create_prediction.py preprocessing/RD_gene GENE_DIS preprocessing/hq_dis >> predict_in.RD ## Gene - Dis ? 

##Teva-specific stuff - filter/obtain Pubchem IDs on DrugCentral non organic IDs
grep -v -w ORGANIC drug_type.tsv  > non_organic_drug_ids.tsv
### or
grep -wf drug_types_of_interest drug_type.tsv  > non_organic_drug_ids.tsv
awk '$3=="PUBCHEM_CID"' public.identifier_table.tsv > public.identifier_table.PUBCHEM_CID.tsv
cut -f2,4 public.identifier_table.PUBCHEM_CID.tsv > map.tmp
#python3 ../map_entity_multimap.py map.tmp non_organic_drug_ids.tsv > non_organic_drug_ids.pubchemcompound.tsv
python3 ../map_entity_multimap.py map.tmp non_organic_drug_ids.tsv | grep -v NOT_FOUND | cut -f2 > ../preprocessing/non_organic_drug
grep -wf ../preprocessing/hq_drug ../preprocessing/non_organic_drug > ../preprocessing/hq_non_organic_drug
cat preprocessing/teva_genes  preprocessing/RD_gene > preprocessing/RD_teva_genes 

python3 create_prediction.py preprocessing/hq_non_organic_drug DRUG_GENE preprocessing/teva_genes > predict_in.teva  ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_non_organic_drug >> predict_in.teva ## Drug - Dis
python3 create_prediction.py preprocessing/RD_teva_genes GENE_DIS preprocessing/hq_dis >> predict_in.teva ## Gene - Dis ? 

python3 create_prediction.py preprocessing/hq_non_organic_drug DRUG_GENE preprocessing/teva_genes > predict_in.teva  ## Drug - Gene
python3 create_prediction.py preprocessing/hq_dis DIS_DRUG preprocessing/hq_non_organic_drug > predict_in.teva ## Drug - Dis
python3 create_prediction.py preprocessing/teva_genes GENE_DIS preprocessing/hq_dis > predict_in.teva ## Gene - Dis ? 


grep PUBCHEM.COMPOUND entities.tsv  | cut -f2 > preprocessing/all_drug
## Create node1, edge and node2 

cutpoint=6354672
cutpoint_upper=1
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f1 > node1
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f3 > node2
awk -v cutpoint_upper=$cutpoint_upper  -v cutpoint=$cutpoint 'NR<cutpoint && NR>=cutpoint_upper' predict_in.RD | cut -f2 > edge

cut -f1 predict_in.teva | head -n  40000000 | tail -n 10000000 > node1
cut -f3 predict_in.RD.DD | head -n 40000000  | tail -n 10000000 > node2
cut -f2 predict_in.RD.DD | head -n 40000000 | tail -n 10000000 > edge

cut -f1 predict_in.teva  > node1
cut -f3 predict_in.teva > node2
cut -f2 predict_in.teva > edge

## Run prediction
MODEL=TransE_l1_OBL_21
SET_PREFIX=HQ_DIR.kite
./OBL_embeddings_workflow.sh ~/Projects/OpenBioLink_sandbox/ $MODEL TransE_l1 PREDICT 50000 $SET_PREFIX.DRUGONLY.collapsed
mv TransE_l1_OBL_21_results.csv TransE_l1_OBL_21_results.teva.csv 

## only did untill 44354672 for Druug-Gene... moved on o Drugf-Dis. Doing top 5000 per iteration, combining. 
## only did untill 40000000 for Dis Drug 

# combined these resuls
cat  *part* | sort -k4 -rn  | head -n 5000 > TransE_l1_OBL_21_results.compiled_results.csv


# stopped after 10 mins. Got to about 2400 which is good enough for now. 
grep -vf in_train TransE_l1_OBL_21_results.teva.csv > TransE_l1_OBL_21_results.teva.rmtrain.csv

python3 map_entity_OBL.py id_mappings.tsv TransE_l1_OBL_21_results.teva.csv
mv TransE_l1_OBL_21_results.teva.rmtrain.csv TransE_l1_OBL_21_results.teva_gene_drug.rmtrain.csv