# Building-data-pipeline-with-reddit_API

A data pipeline to extract Reddit data from subreddit r/dataengineering.

## Motivation

This is a personal project based on an interest in Data Engineering and the types of post found on the official subreddit, https://www.reddit.com/r/dataengineering/ It also provided a good opportunity to develop skills and experience in a range of tools. As such, project is more complex than required, utilising terraform,airflow, docker and cloud based technologies like redshift,S3 etc.

## Summary of Project
Essentially there is one pipeline which extracts Reddit data from its API using Python's PRAW API wrapper.

It is setup to extract data from the past 24 hours and store in a CSV with fields such as post ID, author name, etc.

This CSV is then loaded directly into an AWS S3 bucket (cloud storage), before being copied to AWS Redshift (cloud data warehouse).

This entire process is running with Apache Airflow (orchestration tool) running with Docker. This saves us having to manually setup Airflow.

Another two components make up this project that are not controlled with Airflow.

First, we use dbt to connect to our data warehouse and transform the data. We're only really using dbt to gain some familiarity with it and build our skills.

Second, we will connect a BI tool to our warehouse and create some looking visualisations.

## Architecture

![architecture](https://user-images.githubusercontent.com/51442225/180514792-98aa000f-644d-45ca-b8a3-a99eec6b93bc.png)


