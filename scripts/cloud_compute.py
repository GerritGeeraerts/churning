import json
import os

from azureml.core import Workspace, Experiment, ScriptRunConfig, Environment, ComputeTarget

# Load workspace configuration from file
# with open('config.json') as f:
#     config = json.load(f)

config = {
    "subscription_id": os.getenv("ARM_SUBSCRIPTION_ID"),
    "resource_group": "my-workspace-rg",
    "workspace_name": "my-workspace",
    "compute_name": "my-compute-cluster",
    "environment_file": "requirements_cloud.txt",
}

# Connect to the existing workspace
ws = Workspace(subscription_id=config['subscription_id'],
               resource_group=config['resource_group'],
               workspace_name=config['workspace_name'])

# Get the existing compute target
compute_target = ComputeTarget(workspace=ws, name=config['compute_name'])

# Create an environment (or use an existing environment)
env = Environment.from_pip_requirements(name='my-env', file_path=config['environment_file'])

# Define the ScriptRunConfig
src = ScriptRunConfig(source_directory='.', script='train_model.py', compute_target=compute_target, environment=env)

# Create and submit an experiment
experiment_name = 'train-on-azure'
experiment = Experiment(ws, name=experiment_name)

run = experiment.submit(src)
print("Experiment submitted.")
run.wait_for_completion(show_output=True)

# Optionally, monitor and retrieve results
metrics = run.get_metrics()
print(f"Final Accuracy: {metrics.get('accuracy', 'N/A')}")
