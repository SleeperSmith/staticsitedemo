# A demonstration of how to host a static HTML website.

The website is created using AWS S3 and Cloudfront. It is a relatively well established pattern and a terraform module was selected to achieve what is required. Here were the [list of modules](https://registry.terraform.io/search/modules?q=cloudfront%20static%20site) considered. Of which, only the first two are actively maintained. [SPHTech-Platform's module](https://registry.terraform.io/modules/SPHTech-Platform/s3-cloudfront-static-site/aws/latest#provider_aws) was selected in the end due to it having a more trimmed down implementation.

To cover some basics of what I looked for in the module:  
- CloudFront and S3 integration with Origin Access Identity to ensure only CloudFront can access the S3.
- Handling of ACM for TLS certificate (whether the ability to plug in the ARN externally or automatically provisioning it within the template)
- Route53 for domain name provisioning
- Ability to output s3 bucket name and CloudFront distribution ID to facilitate deployment.

Essentially I expected the template to be a one stop shop for everything needed and that there should be no further manual intervention required.

## Usage

From git repository root
```
docker build -t deployutils .
docker run -it --rm -v "%cd%:/workspace" -v "%USERPROFILE%\.aws\:/root/.aws" deployutils
```

From within the container
```
./deploy.sh
```

This will:  
1. Update the infrastructure
2. Upload website content in the ./website folder
3. Refresh cloudfront invalidation and wait for completion.

## What else you would do with your website, and how you would go about doing it if you had more time.

The module itself is relatively flexible, however, if certain aspects of the flexibility is not required, they should be removed. Any extra lines of code that does not actively provide value is extra burden on engineers to consume and understand.

These extra flexibility includes:
- Ability to attach additional optional s3 access bucket policy, ACL, life cycles rules, etc.
- The way TLS certificate is handled in ACM. There is almost certainly only one approach to how TLS certificate is managed within the organisation, and it should not be something that needs to be flexible and changeable on the fly.
- Similar situation with DNS Records as TLS certificate.

If the assessment is that we'll be trimming a significant portion of the module itself, the source code will be copied into the project repository and the module would no longer be relied upon.

There are many more that I would add in the areas other than the hosting infrastructure specifically. However, it's more fitting to outline them in the last question.


## Alternative solutions that you could have taken but didn’t and explain why.

In terms of implementation, I have considered writing the template from scratch. On the other hand I believe that it is a well established pattern and that there should be ample readily available options to choose from. I decided to use a module in the end as changing and testing CloudFront configuration is a relatively slow process and trimming an existing well tested module is more likely to take less time.

To fulfill the specific requirement of hosting only a static html website, using CloudFront and S3 is the most cost effective and simple solution (on AWS). However, it is usually the case that many other requirements are present in addition to hosting a static html site itself.

A web application may be divided into a static HTML react app interacting with a backend API. While the static HTML hosting can remain unchanged, the backend API container/lambda hosting and code is best included in the terraform template currently containing CloudFront and S3. Or perhaps the html will be folded into the backend API if server side rendering is considered. If the backend API is a frontend specific API (backend for frontend pattern), it's best to bind them together to ensure unity between them.

Many other enhancement to the current solution of CloudFront and S3 can also be considered if other requirements are present:  
- If authentication is required, lambda@edge can be considered
- If network level security / VPN is required, WAF can be added to the CloudFront to lock down access to particular IP addresses.


## What would be required to make this a production grade website that would be developed on by various development teams. The more detail, the better!

First of all, trimming away uneeded funcationality as outlined in the answer to the first question.

There are a few other components that are likely needed for the website to be considered production grade (and are currently missing from the terraform module):  
- Enable access logging - There are usually centralised logging facility and convention that needs to be integrated into all applications hosted.
- WAF - depending on the company's security policy.
- Cache and header policy adjustment -  depending on the content hosted.
- Monitoring and alerting - Route53 healthcheck. I usually include this in the service/application specific infrastructure template as opposed to a centralised approach because each service/application team has better understanding and visibility of its entrypoints.

As well, other aspects of build and deployment process needs to be implemented
- It is a given that the CICD platform leverages OIDC provider to authenticate against AWS to provision resources. (Instead of mounting .aws folder)
- CICD process where artifacts are built and archived for the purpose of deployment and rollback.
- The usual CICD process of building, scanning (SAST/DAST) and QA.
- For a separate build process (depending on how the CICD is structured) to build the Dockerfile included. It is inefficient and unecessary to be rebuilding the build environment container on every commit.
- Set up tfvars for different build, test and production environments.
- All modules, container images and external dependencies should be mirrored and scanned for vulnerabilities. This also helps strengthen continuity in the event of data loss at supply chain level.
- Set up DynamoDB (or some other mutex lock provider that's in line with the state store provider) to safeguard against concurrent changes to the resources managed by terraform.
- A locked down AWS role may be required for executing the deployment for the purpose of security.

Lastly, for the entire CICD build and deployment process all the way to production to be ready on day 1 of development. That as opposed to leaving deployment as the last step of the software delivery. This eliminates the deployment risk at time of going live.



