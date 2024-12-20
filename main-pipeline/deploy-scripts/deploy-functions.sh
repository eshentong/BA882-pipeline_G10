######
## Simple script to deploy Google Cloud Functions
######

# Setup the project
gcloud config set project ba882-group-10

# CDC data extraction function deployment
echo "======================================================"
echo "Deploying the CDC data extraction function"
echo "======================================================"

gcloud functions deploy download-cdc-data \
    --gen2 \
    --runtime python311 \
    --trigger-http \
    --entry-point task \
    --source ./functions/extract-txt \
    --stage-bucket ba882-cloud-functions-stage \
    --service-account etl-pipeline@ba882-group-10.iam.gserviceaccount.com \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 2048MB \
    --timeout 600s

# BigQuery schema creation function deployment
echo "======================================================"
echo "Deploying the BigQuery schema creation function"
echo "======================================================"

gcloud functions deploy create-schema \
    --gen2 \
    --runtime python311 \
    --trigger-http \
    --entry-point create_schema \
    --source ./functions/schema-setup \
    --stage-bucket ba882-cloud-functions-stage \
    --service-account etl-pipeline@ba882-group-10.iam.gserviceaccount.com \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 256MB

# Transforming .txt files into tabular (dataframe data) and save as a parquet file
echo "======================================================"
echo "Deploying the Transform Function"
echo "======================================================"

gcloud functions deploy transform_txt_to_dataframe \
    --gen2 \
    --runtime python311 \
    --trigger-http \
    --entry-point transform_txt_to_dataframe \
    --source ./functions/transform \
    --stage-bucket ba882-cloud-functions-stage \
    --service-account etl-pipeline@ba882-group-10.iam.gserviceaccount.com \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 1024MB \
    --timeout 300s


# Load Parquet data into BigQuery function deployment
echo "======================================================"
echo "Deploying the Load to BigQuery Raw Table Function"
echo "======================================================"

gcloud functions deploy load-to-raw \
    --gen2 \
    --runtime python311 \
    --trigger-http \
    --entry-point load_to_bigquery \
    --source ./functions/load-into-raw \
    --stage-bucket ba882-cloud-functions-stage \
    --service-account etl-pipeline@ba882-group-10.iam.gserviceaccount.com \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 512MB

# Upsert Data from Raw to Staging BigQuery Table Function Deployment
echo "======================================================"
echo "Deploying the Load to BigQuery Stage Table Function"
echo "======================================================"

gcloud functions deploy load_to_stage \
    --gen2 \
    --runtime python311 \
    --trigger-http \
    --entry-point task \
    --source ./functions/load-into-stage \
    --stage-bucket ba882-cloud-functions-stage \
    --service-account etl-pipeline@ba882-group-10.iam.gserviceaccount.com \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 512MB

