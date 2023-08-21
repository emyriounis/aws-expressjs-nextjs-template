# Monorepo for ExpressJS Server, Next.js Website, and Terraform Deployment on AWS

This monorepo contains three main components: an ExpressJS backend server (`backend/`), a Next.js frontend website (`frontend/`), and Terraform configurations (`terraform/`) to deploy the entire application stack on AWS. This repository is organized to streamline development, deployment, and maintenance processes.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Folder Structure](#folder-structure)
- [Backend](#backend)
- [Frontend](#frontend)
- [Terraform](#terraform)
- [Deployment](#deployment)
- [Known Issues](#known-issues)
<!-- - [Contributing](#contributing)
- [License](#license) -->

## Prerequisites
Before you begin, ensure you have the following installed:
- Node.js and npm (for both backend and frontend)
- Terraform (for deployment)
- AWS CLI configured with appropriate credentials

## Getting Started
1. Clone this repository: `git clone https://github.com/emyriounis/aws-expressjs-nextjs-template.git`
2. Navigate to the repository root: `cd aws-expressjs-nextjs-template`
3. Install dependencies for backend: `cd backend && npm install`
4. Install dependencies for frontend: `cd ../frontend && npm install`
5. Ensure Terraform is installed and properly configured: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Folder Structure

## Backend
The `backend/` folder contains the ExpressJS server. To start the backend locally:
1. Navigate to the backend folder: `cd backend`
2. Run: `npm run dev`

## Frontend
The `frontend/` folder contains the Next.js website. To start the frontend locally:
1. Navigate to the frontend folder: `cd frontend`
2. Run: `npm run dev`

## Terraform
The `terraform/` folder contains Terraform configurations for deploying the application stack on AWS. Customize the configurations in this folder according to your AWS environment.

## Deployment
To deploy the entire application stack on AWS:
1. Navigate to the `terraform/` folder: `cd terraform`
2. Initialize Terraform: `terraform init`
3. Review and modify the `main.tf` and other configuration files as needed.
4. Deploy the infrastructure: `terraform apply`

## Known Issues
A list of known issues:
1. Subdomain has a limit on ammount of characters
2. NextJS v12 is required for `milliHQ/next-js/aws` tf module to work
3. Tarraform v4 is required for `milliHQ/next-js/aws` tf module to work
4. Recommendation: use `yarn` instead of `npm` for `frontend/`
5. S3 buckets: `Permissions > Object Ownership > ACLs enabled` required for `milliHQ/next-js/aws` tf module to work
6. `terraform-aws-modules/vpc/aws` v4 is required 

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
