# Multi-label classifier with `pyannote-audio`

Train, validate and apply a multi-label classifier based on MFCCs and LSTMs, using 
`pyannote-multilabel` command line tool.
The labels are :
- KCHI (key children speech utterances)
- CHI (other children speech utterances)
- FEM (female speech utterance)
- MAL (male speech utterance)

## Installation


First and foremost, make sure that the file `~/.pyannote/database.yml` contains these lines (if running your experiments on the CLSP cluster) :

```bash
Protocols:
  AMI:
    SpeakerDiarization:
      MixHeadset:
        train:
          annotation: /export/fs01/jsalt19/databases/AMI/train/allMix-Headset_train.rttm
          annotated: /export/fs01/jsalt19/databases/AMI/train/allMix-Headset_train.uem
        development:
          annotation: /export/fs01/jsalt19/databases/AMI/dev/allMix-Headset_dev.rttm
          annotated: /export/fs01/jsalt19/databases/AMI/dev/allMix-Headset_dev.uem
        test:
          annotation: /export/fs01/jsalt19/databases/AMI/test/allMix-Headset_test.rttm
          annotated: /export/fs01/jsalt19/databases/AMI/test/allMix-Headset_test.uem
  BabyTrain:
    SpeakerDiarization:
      All:
        train:
          annotation: /export/fs01/jsalt19/databases/BabyTrain/train/all_train.rttm
          annotated: /export/fs01/jsalt19/databases/BabyTrain/train/all_train.uem
        development:
          annotation: /export/fs01/jsalt19/databases/BabyTrain/dev/all_dev.rttm
          annotated: /export/fs01/jsalt19/databases/BabyTrain/dev/all_dev.uem
        test:
          annotation: /export/fs01/jsalt19/databases/BabyTrain/test/all_test.rttm
          annotated: /export/fs01/jsalt19/databases/BabyTrain/test/all_test.uem
  VoxCeleb:
    SpeakerDiarization:
      MaleAugmentation:
        train:
          annotation: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/train/all_train.rttm
          annotated: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/train/all_train.uem
          uris: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/train/male_20h.txt
        development:
          annotation: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/dev/all_dev.rttm
          annotated: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/dev/all_dev.uem
        test:
          annotation: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/test/all_test.rttm
          annotated: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/test/all_test.uem
  CHiME5:
    SpeakerDiarization:
      U01:
        train:
          annotation: /export/fs01/jsalt19/databases/CHiME5/train/allU01_train.rttm
          annotated: /export/fs01/jsalt19/databases/CHiME5/train/allU01_train.uem
        development:
          annotation: /export/fs01/jsalt19/databases/CHiME5/dev/allU01_dev.rttm
          annotated: /export/fs01/jsalt19/databases/CHiME5/dev/allU01_dev.uem
        test:
          annotation: /export/fs01/jsalt19/databases/CHiME5/test/allU01_test.rttm
          annotated: /export/fs01/jsalt19/databases/CHiME5/test/allU01_test.uem
  X:
    SpeakerDiarization:
      # META PROTOCOL JULIEN
      JSALT:
        train:
          BabyTrain.SpeakerDiarization.All: [train]
          VoxCeleb.SpeakerDiarization.MaleAugmentation: [train]
          AMI.SpeakerDiarization.MixHeadset: [train]
        development:
          BabyTrain.SpeakerDiarization.All: [development]
          AMI.SpeakerDiarization.MixHeadset: [development]
        test:
          BabyTrain.SpeakerDiarization.All: [test]
          AMI.SpeakerDiarization.MixHeadset: [test]

Databases:
  AMI: /export/fs01/jsalt19/databases/AMI/*/wav/{uri}.wav
  BabyTrain: /export/fs01/jsalt19/databases/BabyTrain/*/wav/{uri}.wav
  VoxCeleb: /export/fs01/jsalt19/databases/auxiliary/VoxCeleb/train/wav/{uri}.wav
  CHiME5: /export/fs01/jsalt19/databases/CHiME5/*/wav/{uri}.wav
  SRI: /export/fs01/jsalt19/databases/SRI/*/wav/{uri}.wav
  MUSAN: /export/fs01/jsalt19/databases/auxiliary/musan/{uri}.wav
```

Next, we can install the needed dependencies : 

```bash
# Create conda environment
conda create --name pyannote python=3.6
conda activate pyannote
git clone https://github.com/jsalt-coml/babytrain_multilabel.git
cd BabyTrain_multilabel

# Clone forked version of pyannote-audio
git clone https://github.com/jsalt-coml/pyannote-audio.git

# Install the associated local python packages
pip install -e ./pyannote-audio

# tensorboard support (optional) 
pip install tensorflow tensorboard

# support Yaafe feature extraction (optional)
conda install -c conda-forge yaafe

# support Shennong feature extraction (optional)
git clone https://github.com/bootphon/shennong.git
cd ./shennong
conda env update -n pyannote -f environment.yml
make install
make test
```

## Configuration

To ensure reproducibility, `pyannote-multilabel` relies on a configuration file defining the experimental setup:

```bash
cat babytrain/multilabel/config.yml
```

```yaml
task:
   name: Multilabel
   params:
      duration: 2.0      # sequences are 2s long
      batch_size: 64     # 64 sequences per batch
      per_epoch: 1       # one epoch = 1 day of audio
      weighted_loss: True # weight loss by 1/prior for each class 


data_augmentation:
   name: AddNoise                                   # add noise on-the-fly
   params:
      snr_min: 10                                   # using random signal-to-noise
      snr_max: 20                                   # ratio between 10 and 20 dBs
      collection: MUSAN.Collection.BackgroundNoise  # use background noise from MUSAN
                                                    # (needs pyannote.db.musan)
feature_extraction:
   name: LibrosaMFCC      # use MFCC from librosa
   params:
      e: False            # do not use energy
      De: True            # use energy 1st derivative
      DDe: True           # use energy 2nd derivative
      coefs: 19           # use 19 MFCC coefficients
      D: True             # use coefficients 1st derivative
      DD: True            # use coefficients 2nd derivative
      duration: 0.025     # extract MFCC from 25ms windows
      step: 0.010         # extract MFCC every 10ms
      sample_rate: 16000  # convert to 16KHz first (if needed)

architecture:
   name: StackedRNN
   params:
      instance_normalize: True  # normalize sequences
      rnn: LSTM                 # use LSTM (could be GRU)
      recurrent: [128, 128]     # two layers with 128 hidden states
      bidirectional: True       # bidirectional LSTMs
      linear: [32, 32]          # add two linear layers at the end

scheduler:
   name: CyclicScheduler        # use cyclic learning rate (LR) scheduler
   params:
      learning_rate: auto       # automatically guess LR upper bound
      epochs_per_cycle: 14      # 14 epochs per cycle
      
preprocessors:
    annotation:
       name: pyannote.audio.features.GenderChiMapper
```

You might want to change some of these parameters to see if performances improve.

# Running the scripts (locally, or once you asked for an interactive session)
## Training

The following command will train the network using the training set of BabyTrain database for 1000 epochs:

```bash
export EXPERIMENT_DIR=babytrain/multilabel
pyannote-multilabel train --gpu --to=1000 ${EXPERIMENT_DIR} BabyTrain.SpeakerDiarization.All
```

This will create a bunch of files in TRAIN_DIR (defined below). One can follow along the training process using tensorboard.

```bash
tensorboard --logdir=${EXPERIMENT_DIR}
```

## Validation
([↑up to table of contents](#table-of-contents))

To get a quick idea of how the network is doing during training, one can use the `validate` mode.
It can (should!) be run in parallel to training and evaluates the model epoch after epoch.

```bash
export TRAIN_DIR=${EXPERIMENT_DIR}/train/BabyTrain.SpeakerDiarization.All.train
pyannote-multilabel validate SPEECH ${TRAIN_DIR} BabyTrain.SpeakerDiarization.All
```

One can also use the Detection Error Rate metric for validating the model by adding the flag *--use_der*
In practice, it is tuning a simple speech activity detection pipeline (pyannote.audio.pipeline.speech_activity_detection.SpeechActivityDetection) for the specified class, and after each epoch stores the best hyper-parameter configuration on disk:

```bash
cat ${TRAIN_DIR}/validate/BabyTrain.SpeakerDiarization.All/params.yml
```

```yaml
epoch: 280
params:
  min_duration_off: 0.0
  min_duration_on: 0.0
  offset: 0.5503037490496294
  onset: 0.5503037490496294
  pad_offset: 0.0
  pad_onset: 0.0
```

One can also use [tensorboard](https://github.com/tensorflow/tensorboard) to follow the validation process.

## Test

Once the thresholds have been computed in the validation step, we can apply our model on the test test :

```
export VALIDATE_DIR=${TRAIN_DIR}/validate_speech
export OUTPUT_DIR=my_sad_output
export PROTOCOL=BabyTrain.SpeakerDiarization.All
./apply_and_evaluate.sh $VALIDATE_DIR $PROTOCOL $OUTPUT_DIR
```

This script will produce the raw scores in the $OUTPUT_DIR folder, then it will create the .rttm by applying the thresholds on these scores.
Finally, it will compute the detection error rate by using pyannote-metrics.
Based on which task (SPEECH, KCHI, CHI, FEM or MAL) the model has been optimized for, the model will predict only the relevant class. 


## Tensorboard

To use tensoboard, you will need to tunnel both login.clsp.jhu.edu and the node itself, from your local machine run :

```bash
# Tunnel to login.clsp.jhu.edu
ssh <username>@login.clsp.jhu.edu -L 1234:localhost:1234
# Tunnel to the node c05
ssh c05 -L 1234:localhost:1234

# Run tensorboard session
cd BabyTrain_multilabel
source activate pyannote
tensorboard --logdir=babytrain/multilabel --port 1234
```

Then, go to **localhost:1234** in your favourite browser.

# Submitting the jobs
## Training

Submit the script train.sh :

```
qsub train.sh
```

All the parameters for the submission to grid-engine appear at the beginning of **train.sh**

## Validation

Submit the script validate.sh :

```
qsub validate.sh KCHI
```

where the second parameter can be chosen in {KCHI, CHI, FEM, MAL, SPEECH} depending on whether you want to evaluate
the model on a specific class, or as a speech activity detection model.

## References

   - pyannote library

```bibtex
@inproceedings{Yin2017,
  Author = {Ruiqing Yin and Herv\'e Bredin and Claude Barras},
  Title = {{Speaker Change Detection in Broadcast TV using Bidirectional Long Short-Term Memory Networks}},
  Booktitle = {{18th Annual Conference of the International Speech Communication Association, Interspeech 2017}},
  Year = {2017},
  Month = {August},
  Address = {Stockholm, Sweden},
  Url = {https://github.com/yinruiqing/change_detection}
}
```
```bibtex
@inproceedings{Bredin2017,
    author = {Herv\'{e} Bredin},
    title = {{TristouNet: Triplet Loss for Speaker Turn Embedding}},
    booktitle = {42nd IEEE International Conference on Acoustics, Speech and Signal Processing, ICASSP 2017},
    year = {2017},
    url = {http://arxiv.org/abs/1609.04301},
}
```
```bibtex
@inproceedings{Yin2018,
  Author = {Ruiqing Yin and Herv\'e Bredin and Claude Barras},
  Title = {{Neural Speech Turn Segmentation and Affinity Propagation for Speaker Diarization}},
  Booktitle = {{19th Annual Conference of the International Speech Communication Association, Interspeech 2018}},
  Year = {2018},
  Month = {September},
  Address = {Hyderabad, India},
}
```
