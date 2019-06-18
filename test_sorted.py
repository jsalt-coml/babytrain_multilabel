import os,glob

corp="/export/fs01/jsalt19/databases/CHiME5"
folds = ["train", "dev", "test"]

for fold in folds:
    rttm_files= glob.iglob(os.path.join(corp, fold, "gold/*.rttm"))
    for rttm in rttm_files:
        prev_onset = 0
        with open(rttm) as data:
            for line in data:
                splitted = line.split(' ')
                onset = float(splitted[3])
                if onset < prev_onset:
                    raise ValueError("Not sorted %f to %f in %s" % (prev_onset, onset, os.path.basename(rttm)))
                prev_onset = onset
                print(onset)
