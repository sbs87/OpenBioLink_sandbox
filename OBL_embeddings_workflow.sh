# BIOG-69
# Steve Smith
# March 2021 

# Run embeddings analysis from dgl-ke on OBL subgraphs and full graphs

# generate input data & removing special set 

# get/set iteration variables

# run model with given parameters, including
##model alroithim
##input data 
##hyperparameters
##results output variables
MODEL="TransE_l2"
ROOT=$1
MODEL_NAME=$2
DATA_PATH=$ROOT #"/Users/stevensmith/Projects/OpenBioLink_sandbox/"

TRAIN=DRUG_train_samples.csv
TEST=DRUG_test_samples.csv 
VAL=DRUG_val_samples.csv
ENTITY_MAP="entities.tsv"
REL_MAP="relations.tsv"
SCORE_FUNC="logsigmoid"
SAVE_PATH=$ROOT"/models/"
MODEL_PATH=$SAVE_PATH""$MODEL_NAME"/"

PREDICT_OUT=$ROOT""$MODEL_NAME"_results.csv"

# dglke_train --model_name $MODEL \
# --format 'raw_udd_hrt'  \
# --data_path $DATA_PATH \
# --data_files $TRAIN $TEST $VAL \
# --batch_size 1000 \
# --neg_sample_size 200 \
# --hidden_dim 400 \
# --gamma 19.9 \
# --lr 0.25 \
# --max_step 500 \
# --log_interval 100 \
# --batch_size_eval 16 \
# -adv \
# --regularization_coef 1.00E-09  \
# --num_thread 1 \
# --num_proc 1 \
# --dataset OBL \
# --test \
# --save_path $SAVE_PATH

# store model performance (somehow)

#eval perfomance - compare to dgl_train
# dglke_eval --model_name $MODEL \
# --format 'raw_udd_hrt'  \
# --data_path $DATA_PATH \
# --data_files $TEST $VAL $TRAIN \
# --batch_size 1000 \
# --neg_sample_size 200 \
# --hidden_dim 400 \
# --gamma 19.9 \
# --batch_size_eval 16 \
# --num_thread 1 \
# --num_proc 1 \
# --dataset OBL \
# --model_path $MODEL_PATH

# run predictions (what wouldve been predicted vs new predictions)
## all possible combinations - flag training
## special set 

dglke_predict --model_path $MODEL_PATH  \
--format h_r_t \
--data_files influenza.raw edge.raw amantadine.raw \
--exec_mode 'triplet_wise' \
--topK 10 \
--score_func $SCORE_FUNC \
--raw_data \
--entity_mfile $ENTITY_MAP \
--rel_mfile $REL_MAP \
--output $PREDICT_OUT
# summary stats
## score histogram, annotated by training, testing, valition, special set 


