#!/usr/bin/python
import numpy as np
import xgboost as xgb
import sys
trainFile = sys.argv[1]
testFile = sys.argv[2]
modelOutFile = sys.argv[3]

dtrain = xgb.DMatrix(trainFile)
dtest = xgb.DMatrix(testFile)
param = {'silent':1, 'objective':'binary:logistic','booster':'gblinear',\
         'eval_metric': ['auc','error']}
watchlist  = [(dtest,'eval'), (dtrain,'train')]
num_round = 15

def logregobj(preds, dtrain):
    labels = dtrain.get_label()
    weights = labels + 0.03
    #print weights
    preds = 1.0 / (1.0 + np.exp(-preds))
    grad = (preds - labels)*weights
    hess = preds * (1.0-preds)*weights
    return grad, hess
def evalerror(preds, dtrain):
    labels = dtrain.get_label()
    # return a pair metric_name, result
    # since preds are margin(before logistic transformation, cutoff at 0)
    print "#"*20
    print sum((preds > 0.5))
    print "#"*20
    print float(sum(labels*(preds > 0.5)))
    print "#"*20
    #print len(labels)
    #print "#"*20
    #print sum((labels > 0.0))
    #print "#"*20
    #print preds
    return 'recall', float(sum(labels*(preds > 0.5))) / float(sum((labels > 0.0)))

bst = xgb.train(param, dtrain, num_round, watchlist)

bst.dump_model(modelOutFile)
#bst.dump_model('a.model', featsMap)
