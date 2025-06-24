# -*- coding: utf-8 -*
"""
Created on Thu May 27 15:00:24 2021

@author: RS

For parameters see:
    https://xgboost.readthedocs.io/en/latest/parameter.html

"""

import numpy as np
import matplotlib.pyplot as plt
from pyglmnet import GLM
import xgboost as xgb
import copy
import os
import pdb
import tkinter as tk
from tkinter import filedialog

from sklearn.model_selection import train_test_split
from operator import itemgetter
from scipy import io
import warnings
import datetime
import sys
warnings.filterwarnings("ignore")


##############################################################################

def main(filename, output_dir, rs):

    # start keeping time
    start_time = datetime.datetime.now()
    # load data
    X, Y, multi, shuffle = load_data(filename)

    # init Yhats
    Ny = np.size(Y, 1)
    N = np.size(Y, 0)
    dimX = X.shape
    if shuffle ==1:
        if multi == 0:
            n_variables = dimX[1]
            n_shuffles = dimX[2]
            Yhat_xgb = np.zeros((N, Ny, n_variables, n_shuffles))
        else:
            n_variables = 1
            n_shuffles = dimX[2]
            Yhat_xgb = np.zeros((N, Ny, n_shuffles))
    else:
        if multi ==0:
            dimX = X.shape
            n_variables = dimX[1]
            Yhat_xgb = np.zeros((N, Ny, n_variables))
        else:
            n_variables = 1
            Yhat_xgb = np.zeros((N, Ny))

    # calculate pseudo-R2 for single predictors
    if shuffle == 1:
        for i_shuffle in range(n_shuffles):
            for n in range(Ny):
                if n_variables > 1:
                    for m in range(n_variables):
                        Yhat_xgb[:, n, m, i_shuffle] = predict_data(X[:, m, i_shuffle].reshape(-1, 1), Y[:, n], rs)
                        print(filename + ': cell#' + str(n) + ' predictor#' + str(m))
                else:
                    Yhat_xgb[:, n, i_shuffle] = predict_data(X[:, :, i_shuffle], Y[:, n], rs)
                    print(filename + ': cell#' + str(n))
    else:
        for n in range(Ny):
            if n_variables > 1:
                for m in range(n_variables):
                    Yhat_xgb[:, n, m] = predict_data(X[:, m].reshape(-1, 1), Y[:, n], rs)
                    print(filename + ': cell#' + str(n) + ' predictor#' + str(m))
            else:
                Yhat_xgb[:, n] = predict_data(X[:, :], Y[:, n], rs)
                print(filename + ': cell#' + str(n))
    # create a dictionary
    results = {'Yhat_xgb': Yhat_xgb, 'rs': rs}
    end_time = datetime.datetime.now()
    process_time = end_time - start_time
    process_time_s = process_time.total_seconds() / 60
    print("Total time: " + str(process_time_s))
    # save

    save_data(output_dir, os.path.basename(filename) + '_predicted_final.mat', results)



def load_data(file):
    data = io.loadmat(file)
    X = itemgetter('X')(data)
    Y = itemgetter('Y')(data)
    multi = itemgetter('multi')(data)
    shuffle = itemgetter('shuffle')(data)
    return X, Y, multi, shuffle


def save_data(output_dir, filename, results):
    name = output_dir + '/' + filename
    io.savemat(name, results)


##############################################################################

def predict_data(X, y, rs):
    # init misc
    N = np.size(y, 0)
    index = np.array(range(0, N))
    yhat_xgb = np.zeros(N)

    # init xgboost
    # learning_rate - this parameters shrinks the feature weights to make the boosting more conservative [0,1]
    # gamma - Minimum loss reduction required to make a further partition on a leaf node of the tree [0,Inf]
    # Subsample - Ratio of training instances (don't need as we do cross-validation externally)
    #
    xgb_params = {'objective': "count:poisson",  # for poisson output
                  'eval_metric': "logloss",  # loglikelihood loss
                  'learning_rate': 0.025,
                  'subsample': 1,
                  'max_depth': 3,
                  'gamma': 1,
                  'tree_method': 'approx'}
    # exact, approx, hist, gpu_hist
    num_round = 500

    # generate test and training set
    X1, X2, y1, y2, index1, index2 = train_test_split(X, y, index,
                                                      test_size=0.5,
                                                      random_state=rs,
                                                      shuffle=True,
                                                      stratify=None)

    #########set1#############
    # train xgboost
    xgb1 = xgb.DMatrix(X1, label=y1)
    model = xgb.train(xgb_params, xgb1, num_round)

    # predict using fitted xgboost model on the test data
    xgb2 = xgb.DMatrix(X2)
    yhat_xgb[index2] = model.predict(xgb2)
    #########set2#############
    # train xgboost
    xgb2 = xgb.DMatrix(X2, label=y2)
    model = xgb.train(xgb_params, xgb2, num_round)

    # predict using fitted xgboost model on the test data
    xgb1 = xgb.DMatrix(X1)
    yhat_xgb[index1] = model.predict(xgb1)

    # return results
    return yhat_xgb


file = sys.argv[1]
savepath = sys.argv[2]
main(file, savepath, 1)
