import argparse
import os, glob
import numpy as np
import yaml

# Use case : python npy_to_rttm.py --exp ${EXPERIMENT_DIR} --scores ${EXPERIMENT_DIR}/test_sad/BabyTrain --mode speech

parser = argparse.ArgumentParser(description="Given :\n"
                                             "1) a directory where a model has been trained, validated and applied\n"
                                             "2) the directory where the raw scores of the application step have been stored (.npy files)\n"
                                             "3) a predicting mode (speech, or talker role)"
                                             "4) the frame step used for generating the features" 
                                             "Generates .rttm files whose labels have been determined based on the tresholds computed" 
                                             "in the development phase.")

parser.add_argument("--exp", help="The experiment directory where the model has been trained, validated and applied.",
                    type=str, required=True)
parser.add_argument("--scores", help="The directory where the scores are stored (.npy files).",
                    type=str, required=True)
parser.add_argument("--mode", choices=["speech", "role"], help="In mode speech, the scripts produces only .rttm files describing"
                                                               "the speech uterrances. In the role mode, it gives KCHI,CHI,FEM,MAL labels",
                    type=str, required=True)
parser.add_argument("--step", help="Size of a frame (in s, default to 0.01 ms)",
                    type=float, default=0.01)
args = parser.parse_args()

train_dir = os.path.join(args.exp, "train")
validation_dir = os.path.join(args.exp, "train", "BabyTrain.SpeakerDiarization.BB.train", "weights")

if not os.path.isdir(args.exp):
    raise ValueError("The experiment directory you specified doesn't exist.")
if not os.path.isdir(train_dir):
    raise ValueError("The model hasn't been trained yet.")
if args.mode == "speech" and not os.path.isdir(os.path.join(validation_dir, "validate_speech")):
    raise ValueError("The model hasn't been validated for speech yet.")
if args.mode == "role" and not (os.path.isdir(os.path.join(validation_dir, "validate_KCHI"))
                                and os.path.isdir(os.path.join(validation_dir, "validate_CHI"))
                                and os.path.isdir(os.path.join(validation_dir, "validate_FEM"))
                                and os.path.isdir(os.path.join(validation_dir, "validate_MAL"))):
    raise ValueError("The model hasn't been validated for the 4 classes (KCHI,CHI,FEM,MAL) yet.")


labels = np.asarray(["CHI", "FEM", "KCHI", "MAL"]) # numpy array for being able to index by list of indices

# Read tresholds
if args.mode == "speech":
    params = yaml.load(open(os.path.join(validation_dir, "validate_speech",
                                    "BabyTrain.SpeakerDiarization.BB.development",
                                    "params.yml")), Loader=yaml.FullLoader)
    treshold = params["params"]["offset"]
elif args.mode == "role":
    treshold = []
    for label in labels:
        params = yaml.load(os.path.join(validation_dir, "validate_%s" % label,
                                        "BabyTrain.SpeakerDiarization.BB.development",
                                        "params.yml"), Loader=yaml.FullLoader)
        treshold.append(params["params"]["offset"])

# Read scores
npy_files = glob.glob(os.path.join(args.scores, "*.npy"))

if len(list(npy_files)) == 0:
    print("No .npy files have been found.")

for npy in npy_files:
    output_file = npy.replace(".npy", "_%s.rttm" % args.mode)
    basename = os.path.basename(output_file).replace(".rttm", "")

    role_scores = np.load(npy)
    if args.mode == "speech":
        speech_scores = np.sum(role_scores, axis=1)
        is_speech = speech_scores > treshold
        is_speech = np.hstack([False, is_speech, False]) # Useful for boundaries
        # Starts are the ones whose previous element is False, and curr element is True
        # Same principles for ends
        starts = (~is_speech[:-1] & is_speech[1:]).nonzero()
        ends = (is_speech[:-1] & ~is_speech[1:]).nonzero()

        with open(output_file, 'w') as f:
            for start, end in zip(starts[0], ends[0]):
                start_s = start * args.step
                duration_s = (end - start) * args.step
                f.write('SPEAKER %s\t1\t%.3f\t%.3f\t<NA>\t<NA>\t%s\t<NA>\t<NA>\n' % \
                        (basename, start_s, duration_s, "speech"))

    elif args.mode == "role":
        # Same principle but multi-dimensional + we must handle overlap
        is_on = role_scores > treshold
        z = np.zeros((len(labels), 1), dtype='bool').T
        is_on = np.vstack([z, is_on, z])
        # We build the vectors of labels belonging to [KCHI,CHI,MAL,FEM]
        # and all combinations of these 4 classes.
        y = np.asarray(['/'.join(labels[frame.nonzero()]) for frame in is_on])
        boundaries = (y[:-1] != y[1:]).nonzero()[0]

        with open(output_file, 'w') as f:
            for i in range(0, len(boundaries)-1):
                start = boundaries[i]
                end = boundaries[i+1]
                print("from %d to %d" %(start,end))
                start_s = start * args.step
                duration_s = (end - start)*args.step
                label = y[start+1]
                # We want to skip silences
                if label != "":
                    f.write('SPEAKER %s\t1\t%.3f\t%.3f\t<NA>\t<NA>\t%s\t<NA>\t<NA>\n' % \
                            (basename, start_s, duration_s, label))
