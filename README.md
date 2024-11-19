# Web3 Job Board Smart Contract

This project implements a decentralized job board using a smart contract written in Clarity for the Stacks blockchain.

## Overview

The Web3 Job Board smart contract allows users to:

1. Post job listings
2. Apply for jobs
3. Close job listings
4. Update application statuses
5. Retrieve job and application details

## Smart Contract Structure

The smart contract (`job-board.clar`) contains the following main components:

1. Data structures:
   - `jobs`: Stores job posting details
   - `applications`: Stores job application details
   - `job-count`: Keeps track of the total number of jobs posted

2. Public functions:
   - `post-job`: Creates a new job listing
   - `apply-for-job`: Submits an application for a job
   - `close-job`: Closes an active job listing
   - `update-application-status`: Updates the status of a job application

3. Read-only functions:
   - `get-job`: Retrieves details of a specific job
   - `get-application`: Fetches details of a specific job application
   - `get-job-count`: Returns the total number of job listings
   - `get-job-applications`: Retrieves all applications for a specific job

## Features

- Job postings include title, description, salary, and creation timestamp
- Applications include cover letter, status, and application timestamp
- Prevents duplicate applications from the same user
- Only the job poster can close their job or update application statuses
- Robust error handling with specific error codes

## Error Codes

- `ERR-INVALID-SALARY` (u1): Salary must be greater than 0
- `ERR-JOB-NOT-FOUND` (u2): The specified job does not exist
- `ERR-JOB-NOT-ACTIVE` (u3): The job is not active (already closed)
- `ERR-UNAUTHORIZED` (u4): The user is not authorized to perform this action
- `ERR-ALREADY-APPLIED` (u5): The user has already applied for this job

## Usage

To use this smart contract:

1. Deploy the contract to the Stacks blockchain using the Stacks CLI or a development environment like Clarinet.

2. Interact with the contract using a Stacks wallet or a dApp that integrates with the Stacks blockchain.

3. Use the provided functions to post jobs, apply for jobs, manage job listings, and update application statuses.

## Development

To work on this project:

1. Install the Stacks CLI and Clarinet for local development and testing.

2. Use Clarinet to run tests and simulate contract interactions.

3. Deploy to the Stacks testnet for further testing before mainnet deployment.

## Frontend Integration

To create a full dApp:

1. Develop a frontend using web technologies (e.g., React, Next.js).

2. Use the `@stacks/connect` library to interact with the smart contract from your frontend.

3. Create UI components for job posting, job listing, application submission, and application management.

## Security Considerations

- The contract ensures that only the job poster can close their own job listings or update application statuses.
- It prevents users from applying to the same job multiple times.
- Consider implementing additional features like dispute resolution or a rating system for enhanced functionality and trust.

## Contributing

Contributions are welcome to job-board! If you'd like to contribute, please follow these steps:

Fork the repository
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request