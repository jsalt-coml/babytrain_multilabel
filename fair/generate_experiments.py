import yaml
import operator
from functools import reduce
from itertools import product
import os

NB_EXPERIMENTS = 3
EXPERIMENT_DIR = "../gridsearch_experiments"
if not os.path.exists(EXPERIMENT_DIR):
        os.mkdir(EXPERIMENT_DIR)

# List of parameters that will participate in the cartesian product
cross_parameters = ["others/corpora_protocol","architecture/params/dropout",
                    "architecture/params/kernel_size","architecture/params/conv_out",
                    "architecture/params/linear","architecture/params/recurrent",
                    "architecture/name","data_augmentation/params/snr_min",
                    "data_augmentation/params/scheduler","data_augmentation/params/max_epoch",
                    "task/params/duration"
                    ]

# List of parameters that won't participate in the cartesian product
linear_parameters = ["preprocessors/annotation/name",
                     "scheduler/name","scheduler/params/learning_rate",
                     "scheduler/params/epochs_per_cycle","architecture/params/norm",
                     "architecture/params/bidirectional","architecture/params/rnn",
                     "feature_extraction/params/sample_rate","feature_extraction/params/step",
                     "feature_extraction/params/duration","feature_extraction/params/n_mels",
                     "feature_extraction/params/spec_augment","feature_extraction/params/frequency_masking_para",
                     "feature_extraction/params/time_masking_para","feature_extraction/params/nb_frequency_masks",
                     "feature_extraction/params/nb_time_masks","feature_extraction/params/sample_rate",
                     "feature_extraction/name","data_augmentation/name",
                     "data_augmentation/params/snr_min","data_augmentation/params/snr_max",
                     "data_augmentation/params/db_yml","task/name",
                     "task/params/batch_size","task/params/per_epoch",
                     "task/params/speech"]

# List of parameters that need to be replaced by another parameter
special_replace_parameters = ["data_augmentation/params/protocol","feature_extraction/params/scheduler",
                              "feature_extraction/params/max_epoch"]

# Parameters whose dimension must match
dimension_match_conditions = [["architecture/params/conv_out", "architecture/params/kernel_size"]]


# Load yaml
with open("grid-search.yml", 'r') as stream:
    try:
        grid_config = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)


def find(element, yaml):
    values = reduce(operator.getitem, element.split('/'), yaml)
    res = [{element: v} for v in values]
    return res


def unflatten(input_dict):
    # Then, unflatten the keys
    res = dict()
    for key, value in input_dict.items():
        parts = key.split('/')
        d = res
        for part in parts[:-1]:
            if part not in d:
                d[part] = dict()
            d = d[part]
        d[parts[-1]] = value
    return res


def merge_dict_list(input_tuple):
    # First, merge dictionnaries into one big one
    res = dict()
    for d in input_tuple:
        res.update(d)
    return res


params = [find(elem, grid_config) for elem in cross_parameters+linear_parameters]
nb_experiments = 0
for experiment in product(*params):
    valid_experiment = True
    experiment_dict = merge_dict_list(experiment)

    # Get values of special parameters
    for special_replace_parameter in special_replace_parameters:
        elem = find(special_replace_parameter, grid_config)[0]
        key, value = list(elem.keys())[0], list(elem.values())[0]
        experiment_dict[key] = experiment_dict[value]

    # Check if dimensions matching conditions are respected
    for dimension_cond in dimension_match_conditions:
        dim1 = len(experiment_dict[dimension_cond[0]])
        dim2 = len(experiment_dict[dimension_cond[1]])
        if dim1 != dim2:
            valid_experiment = False

    if valid_experiment:
        nb_experiments += 1
        experiment = unflatten(experiment_dict)
        corpora = experiment["others"]["corpora_protocol"]
        del experiment["others"]

        output_folder = "%s/%s.%d" % (EXPERIMENT_DIR, corpora, nb_experiments)
        if not os.path.exists(output_folder):
            os.mkdir(output_folder)

        for wrong_formatted in ["conv_out", "kernel_size", "recurrent", "linear"]:
            experiment["architecture"]["params"][wrong_formatted] = \
                str(experiment["architecture"]["params"][wrong_formatted])

        with open(os.path.join(output_folder, "config.yml"), "w") as config_file:
            stream = yaml.dump(experiment)
            stream = stream.replace('\'', '')
            config_file.write(stream)

        if nb_experiments == NB_EXPERIMENTS:
            break

print("Number of experiments : %d" % nb_experiments)


