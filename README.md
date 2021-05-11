# HelloBraveNewWorld

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 10.1.1.

## Infrastructure as Code
This project follows the principle of infrastructure as a code.
It uses terraform to create an EKS Cluster and all the necessary infrastructure on AWS.
Builds and pushes a docker image to the container registry and finally deploys the application to the EKS Cluster.

## Steps to built the project in AWS with Jenkins Pipeline
- Install one instance of Jenkins;
- Install docker and git in the Jenkins istance;
- Create necessary credentials on Jenkins alike [this print](Jenkins_Pipeline_Credentials.PNG). 
- Create new pipeline job on Jenkins with custom variables (Type: pipeline. Parameters: alike [this print](Jenkins_Pipeline_Setup_Cluster_Parameters.PNG)) and use the Jenkinsfile on repo.


## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `--prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).
