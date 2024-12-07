# Introduction
This project aims to provide an infrastructure setup for the end-to-end test of a hypothetical application.
In my assumptions, I have mostly disregarded the provided service, but I could offer a more robust and reliable solution. 
It configures the `AWS` resources, especially `AWS EKS` and after finishing up the K8s setup, it provisions the basic resources like externalDNS and nginx in the k8s cluster.

# Changes to assumptions and services
- ECS replaced with EKS
- HCL used instead of the s3+Athena for backend lock and state
- GitHub actions used instead of Gitlab runners.
- RDS snapshot replaced by a simple backup dump in s3

# Code Structure
```plaintext
└── infra: it has the terraform definitions to build the infrastructure
    └── modules
        ├── eks: this module is responsible for generating the AWS resources like EKS and Node groups 
        │
        ├── Kubernetes: this module is responsible for configuring the k8s cluster inside EKS
        │ └── services: holds a series of custom helm charts to be deployed in k8s
        │    └── base: helm chart to deploy common resources in k8s like nginx proxy and external DNS
        │
        └── Kubernetes-e2e: this module is responsible for spinning up apps for e2e tests
            └── services:  holds a series of custom helm charts for each application to be deployed in k8s
                └── myapp: It's a hypothetical application that includes a helm chart that defines the app and mocks the services for it so later an end-to-end test gets executed.
```
# Provisioned resources
- VPC
- Multizone subnets
- Required Policies
- Routing tables 
- Security groups
- NLB
- EKS
- Route53
- CertManager
- ExternalDNS
- Nginx-proxy

# Solution
each e2e run can use resources that have been configured in a dedicated namespace of k8s.

## Isolation
each e2e run can use resources that has been configured in a dedicated namespace of k8s.

## Automated hosting
the solution provides the integration of ExternalDNS with Route53. So whenever we deploy our app for e2e purposes,
we can use the generated URL to be included as a service URL point in the e2e configurations.
For example, we have e2e tests written in golang. We deploy the app and its mock services into k8s and define an ingress for them, then we include an endpoint in our e2e code so the tests use that endpoint.
Now, we can execute the e2e in our CI/CD pipeline using `go test -v -args -service-url="https://myapp.example.com"`.
The mock services also can have their URL.

## Database
We want to run the e2e test against our real-world data or a heavy amount of prepopulated database dump.
We set up a Postgres workload and database per app in k8s. Then restore the database using a dump(ex: real-world DB dump)
that has been placed in the S3 bucket(we can have an extra Lambda function that is scheduled to take dumps from the main DB and store them in the s3 bucket). 
We set the app connection string to this Postgres database.

## benefits:
- reduced cost in comparison to RDS
- isolated databases so no data pollution as a result of e2e execution
- the RDS snapshots can have multiple DB in them so we drag unnecessary resources 
 if we snapshot our RDS machines. If we have a single DB RDS, it would be a waste of resources sometimes.
- Isolated e2e environments.

#### Staging Database Accuracy
we can place different database dumps(heavy, randomized data, ...) and configure them for `kubernetes-e2e` terraform module.
so for multiple purposes, the DB dump can be configured in `Kubernetes-e2e` module using variables: `aws_iam_role_backup_bucket_arn` and `aws_s3_bucket_backup_file`.


#### Isolated Test Environments for Developers
this `kubernetes-e2e` module deploys app,mocks and DB for e2e purpose, into dedicated namespace of K8S.
we can configure multiple dedicated namespaces per Developer or use case even. the namespace dynamically gets adjusted
in `./infra/modules/kubernetes-e2e/services-myapp.tf` .
so it can be generated per Workspace, Username, or anything else.


#### Data Pollution in E2E Tests
In this solution, we spin up temporary a DB and then restore the data dump, and in the end, we discard it.
So it does not share among e2e executions or users.

#### Resource Removal
After the execution of e2e tests, we can simply destroy the deployed module using :
`terraform -chdir=./infra destroy -target=module.kubernetes-e2e` so the test environment remains but the deployed app will be cleaned up perfectly.

#### Mock services
For mocking services, we can deploy workloads based on the Nginx that could return dummy outputs.
Check these files : 
- `infra/modules/kubernetes-e2e/services/myapp/templates/mock-app-one.yaml`
- `infra/modules/kubernetes-e2e/services/myapp/templates/mock-app-two.yaml`

#### Local execution
when we are developing e2e for our main app we simply can do port forwarding using `kubectl` to our local machine and
configure the e2e code to use these endpoints.
