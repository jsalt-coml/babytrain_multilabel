# Multi-label classifier with `pyannote-audio`

Train, validate and apply a multi-label classifier based on MFCCs and LSTMs, using 
`pyannote-multiclass-babytrain` command line tool.
The labels are :
- KCHI (key children speech utterances)
- CHI (other children speech utterances)
- FEM (female speech utterance)
- MAL (male speech utterance)

## Installation


First and foremost, make sure that the file `~/.pyannote/database.yml` contains these 2 lines :

```bash
Databases:
  MUSAN: /path/to/musan/{uri}.wav
  BabyTrain: /path/to/BabyTrain/*/wav/{uri}.wav
```

Where `/path/to` needs to be replaced by the path to the folder containing the corpus.
Then, we can install the needed dependencies : 

```bash
# Create conda environment
conda create --name pyannote python=3.6
source activate pyannote
git clone https://github.com/MarvinLvn/BabyTrain_multilabel.git
cd BabyTrain_multilabel

# Clone forked version of pyannote-audio and pyannote-db-template
git clone https://github.com/MarvinLvn/pyannote-audio.git
git clone https://github.com/MarvinLvn/pyannote-db-template.git

# Install the associated local python packages
pip install -e ./pyannote-audio
pip install -e ./pyannote-db-template

# support Yaafe feature extraction (optional)
$ conda install -c conda-forge yaafe

```

## Configuration

To ensure reproducibility, `pyannote-multiclass-babytrain` relies on a configuration file defining the experimental setup:

```bash
cat babytrain/multilabels/config.yml
```

```yaml
task:
   name: MulticlassBabyTrain
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
```

You might want to change some of these parameters to see if performances improve.


## Training

The following command will train the network using the training set of BabyTrain database for 1000 epochs:

```bash
EXPERIMENT_DIR=babytrain/multilabels
pyannote-multiclass-babytrain train --gpu --to=1000 ${EXPERIMENT_DIR} BabyTrain.SpeakerDiarization.BB
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
export TRAIN_DIR=${EXPERIMENT_DIR}/train/BabyTrain.SpeakerDiarization.BB.train
pyannote-multiclass-babytrain validate speech ${TRAIN_DIR} BabyTrain.SpeakerDiarization.BB
```

In practice, it is tuning a simple speech activity detection pipeline (pyannote.audio.pipeline.speech_activity_detection.SpeechActivityDetection) for each speaker class, and after each epoch and stores the best hyper-parameter configuration on disk:

```bash
cat ${TRAIN_DIR}/validate/BabyTrain.SpeakerDiarization.BB/params.yml```

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