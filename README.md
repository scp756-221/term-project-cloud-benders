[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-f059dc9a6f8d3a56e377f745f24479a46679e63a5d9fe6f495e02850cd0d8118.svg)](https://classroom.github.com/online_ide?assignment_repo_id=6744746&assignment_repo_type=AssignmentRepo)
# This is the github repository for the term project for CMPT 756 (Cloud Benders)

Name: Abhishek Rungta, Shubham Saini, Siddhant Sood, Bhawna Arya

## Structure:
- `cluster`: Configuration files for our cluster
- `db`: This is the for the database service
- `mcli`: For the music cli
- `s1`: This is the user service
- `s2`: This is the music service
- `s3`: This is the playlist service
- `tools`: Scripts that are useful in make-files
- `loader` : loads csv files to dynamo db 

# Initial setup
### 1. Dependencies required

- istioctl
- kubectl
- aws
- gcloud
- build-essentials


### 2. Instantiate the templates

First we need to fill in the required values in the template variable file.
~~~
tpl-vars.txt
~~~
Then initiate the template 
~~~
$ make -f k8s-tpl.mak templates
~~~


# Deployment

### 1. Setting up gcp

~~~
make -f gcp.mak start
~~~ 
It will create 3 nodes.

### 2. Provisioning the cluster

~~~
make -f k8s.mak provision
~~~

### 3. install kiali

~~~
make -f k8s.mak kiali
~~~

### 4. Ensure AWS DynamoDB is accessible/running

~~~
$ aws dynamodb list-tables
~~~

## Monitoring

### Grafana

To get the URL for grafana , run the command.

username: admin
password: prom-operator
~~~
make -f k8s.mak grafana-url
~~~

### Kiali

To get the kiali URL , run the command

~~~
make -f k8s.mak kiali-url
~~~

### Prometheus

To get the prometheus URL, run the command

~~~
make -f k8s.mak prometheus-url
~~~

## Gatling - Load Testing

we created 3 gatling scripts one for each microservice

~~~
./gatling-music.sh 1000
./gatling-playlist.sh 1000
./gatling-user.sh 1000
~~~
 The above command basically generates test load on all the three applications. Where the argument specifies the number of service objects.

we can adjust the load by specifying the argument.

### Stopping gatling

~~~
./tools/kill-gatling.sh
~~~

### Close the cluster

~~~
make -f gcp.mak stop
~~~




