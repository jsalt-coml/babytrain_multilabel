Here's the example command to train a model on the FAIR cluster :

```bash
sbatch train.sh babytrain/multilabel_convrnn BabyTrain.SpeakerDiarization.All
```

To run the validation step : 

```bash
sbatch validate_der.sh SPEECH babytrain/multilabel_convrnn BabyTrain.SpeakerDiarization.All
```

