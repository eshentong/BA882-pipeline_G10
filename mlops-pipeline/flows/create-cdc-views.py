# CDC Disease Occurrences View Creation Job

# imports
import requests
from prefect import flow, task
from prefect.events import DeploymentEventTrigger

# helper function - generic invoker
def invoke_gcf(url: str, payload: dict):
    response = requests.post(url, json=payload)
    response.raise_for_status()
    return response.json()

@task(retries=2)
def create_cdc_views():
    """Invoke the CDC occurrences Cloud Function to create views and export data to GCS."""
    url = "https://create-cdc-views-162771833878.us-central1.run.app"  
    resp = invoke_gcf(url, payload={})
    return resp

# the flow
@flow(name="cdc-disease-ml-datasets", log_prints=True)
def cdc_ml_datasets():
    # Execute the CDC occurrences view creation
    create_cdc_views()

# Set up the deployment with an event trigger
if __name__ == "__main__":
    # Trigger the cdc_ml_datasets flow when the weekly-cdc-pipeline deployment completes
    cdc_ml_datasets().deploy(
        name="cdc-disease-ml-datasets",
        triggers=[
            DeploymentEventTrigger(
                expect={"prefect.flow-run.Completed"},
                match_related={"prefect.resource.name": "weekly-cdc-pipeline"}
            )
        ]
    )
