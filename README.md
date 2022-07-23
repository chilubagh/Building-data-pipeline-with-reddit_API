# Building-data-pipeline-with-reddit_API

A data pipeline to extract Reddit data from subreddit r/dataengineering.

## Motivation

This is a personal project based on an interest in Data Engineering and the types of post found on the official subreddit, https://www.reddit.com/r/dataengineering/ It also provided a good opportunity to develop skills and experience in a range of tools. As such, project is more complex than required, utilising terraform,airflow, docker and cloud based technologies like redshift,S3 etc.


## Architecture
=======
## Summary of Project
Essentially there is one pipeline which extracts Reddit data from its API using Python's PRAW API wrapper.It is setup to extract data from the past 24 hours and store in a CSV with fields such as post ID, author name, etc.This CSV is then loaded directly into an AWS S3 bucket (cloud storage), before being copied to AWS Redshift (cloud data warehouse).This entire process is running with Apache Airflow (orchestration tool) running with Docker. This saves us having to manually setup Airflow.
Another two components make up this project that are not controlled with Airflow.
First, we use dbt to connect to our data warehouse and transform the data. We're only really using dbt to gain some familiarity with it and build our skills.
Second, we will connect a BI tool to our warehouse and create some looking visualisations.

## Architecture

![architecture](https://user-images.githubusercontent.com/51442225/180514792-98aa000f-644d-45ca-b8a3-a99eec6b93bc.png)



## Docker & Airflow

The pipeline is scheduled daily.Each day, we'll extract the top Reddit posts for r/DataEngineering. Because LIMIT is set to None in the Reddit extraction script, it should in theory return all posts from the past 24 hours.

we navigate to http://localhost:8080 to access the Airflow Web Interface. This is running within one of the Docker containers, which is mapping onto our local machine. If nothing shows up, give it a few minutes more. Password and username are both airflow. 
The dag `etl_reddit_pipeline` should be set to start running automatically once the containers are created. It may have already finished by the time you login. This option is set within the docker-compose file. The next DAG run will be at midnight. If you click on the DAG and look under the Tree view, all boxes should be dark green if the DAG run was successful. 

If you check in the airflow/dags folder, you'll find a file titled `elt_pipeline.py`. This is our DAG which you saw in Airflow's UI.

It's a very simple DAG. All it's doing is running 3 tasks, one after the other. This DAG will run everyday at midnight. It will also run once as soon as you create the Docker containers. These tasks are using BashOperator, meaning that they are running a bash command. The tasks here are running a bash command to call external Python scripts (these Python scripts also exist within our docker container through the use of volumes). You'll find them under the extraction folder.

<img width="1309" alt="reddit-airflow" src="https://user-images.githubusercontent.com/51442225/180582035-eb0ae186-c965-488e-9056-d6f5d955df5f.png">



## How it works

`extract_reddit_data_task`

This is extracting Reddit data. Specifically, it's taking the top posts of the day from r/DataEngineering and collecting a few different attributes, like the number of comments. It's then saving this to a CSV within the /tmp folder.

`upload_to_s3`

This is uploading the newly created CSV to AWS S3 for storage within the bucket Terraform created.

`copy_to_redshift`

This is creating a table in Redshift if it doesn't already exist. It's then using the COPY command to copy data from the newly uploaded CSV file in S3 to Redshift. This is designed to avoid duplicate data based on post id. If the same post id is in a later DAG run load, then warehouse will be updated with that record. Read here for information on the COPY command.

<img width="1412" alt="redshift" src="https://user-images.githubusercontent.com/51442225/180582148-cb46d612-4cf7-4a57-9bcb-fbe628d5423d.png">


