# Monorepo for ExpressJS Server, Next.js Website, and Terraform Deployment on AWS

This monorepo contains three main components: an ExpressJS expressjs server (`expressjs/`), a Next.js nextjs website (`nextjs/`), and Terraform configurations (`terraform/`) to deploy the entire application stack on AWS. This repository is organized to streamline development, deployment, and maintenance processes.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [ExpressJS](#expressjs)
- [NextJS](#nextjs)
- [Terraform](#terraform)
- [Deployment](#deployment)
- [Known Issues](#known-issues)
<!-- - [Contributing](#contributing)
- [License](#license) -->

## Prerequisites
Before you begin, ensure you have the following installed:
- Node.js and npm (for both expressjs and nextjs)
- Terraform (for deployment)
- AWS CLI configured with appropriate credentials

## Getting Started
1. Clone this repository: `git clone https://github.com/emyriounis/aws-expressjs-nextjs-template.git`
2. Navigate to the repository root: `cd aws-expressjs-nextjs-template`
3. Install dependencies for expressjs: `cd expressjs && npm install`
4. Install dependencies for nextjs: `cd ../nextjs && npm install`
5. Ensure Terraform is installed and properly configured: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Folder Structure

## ExpressJS
The `expressjs/` folder contains the ExpressJS server. To start the expressjs locally:
1. Navigate to the expressjs folder: `cd expressjs`
2. Run: `npm run dev`

## NextJS
The `nextjs/` folder contains the Next.js website. To start the nextjs locally:
1. Navigate to the nextjs folder: `cd nextjs`
2. Run: `npm run dev`

## Terraform
The `terraform/` folder contains Terraform configurations for deploying the application stack on AWS. Customize the configurations in this folder according to your AWS environment.

## Deployment
To deploy the entire application stack on AWS:
1. Navigate to the `terraform/` folder: `cd terraform`
2. Initialize Terraform: `terraform init`
3. Review and modify the `main.tf` and other configuration files as needed.
4. Deploy the infrastructure: `terraform apply`
5. Visualize the infrastructure: `terraform graph -type=plan | dot -Tpng > graph.png`

## Known Issues
A list of known issues:
1. Subdomain has a limit on ammount of characters
2. NextJS v12 is required for `milliHQ/next-js/aws` tf module to work
3. Tarraform v4 is required for `milliHQ/next-js/aws` tf module to work
4. S3 buckets: `Permissions > Object Ownership > ACLs enabled` required for `milliHQ/next-js/aws` tf module to work
5. `terraform-aws-modules/vpc/aws` v4 is required 

<!-- ## Contributing
We welcome contributions! To contribute to this repository:
1. Fork the repository.
2. Create a new branch for your feature: `git checkout -b feature-name`
3. Make your changes and commit them: `git commit -m "Add new feature"`
4. Push your changes to your fork: `git push origin feature-name`
5. Create a pull request to the main repository.

## License
This project is licensed under the [MIT License](LICENSE).

Feel free to reach out to us with any questions or concerns.

Happy coding! -->
