# Web3 Job Board Smart Contract

This project implements a decentralized job board using smart contract technologies. The implementation includes both a Clarity smart contract for the Stacks blockchain and comprehensive test coverage.

## Features

- Post new job listings with title, description, and salary
- Apply for job postings
- Prevent duplicate job applications
- Track number of applications per job
- Apply input validation
- Error handling for various scenarios

## Smart Contract Functions

### Job Posting
- `post-job`: Create a new job listing
  - Validates job title, description, and salary
  - Sets job as active
  - Assigns a unique job ID
  - Tracks creation timestamp

### Job Application
- `apply-for-job`: Submit a job application
  - Validates job existence and active status
  - Prevents multiple applications from the same user
  - Tracks cover letter and application timestamp
  - Increments application count for the job

### Job Management
- `edit-job`: Modify an existing job listing
  - Only allowed by the original job poster
  - Update title, description, or salary
- `close-job`: Deactivate a job listing
  - Only allowed by the job poster
- `update-application-status`: Change application status
  - Supports "pending", "accepted", and "rejected" statuses
  - Only allowed by the job poster

## Query Functions
- `get-job`: Retrieve job details
- `get-application`: Fetch specific application details
- `get-job-count`: Total number of job listings
- `get-job-application-count`: Number of applications for a specific job

## Error Handling

The contract provides comprehensive error handling with specific error codes:
- `ERR-INVALID-SALARY`: Invalid salary amount
- `ERR-JOB-NOT-FOUND`: Job does not exist
- `ERR-JOB-NOT-ACTIVE`: Job is no longer active
- `ERR-UNAUTHORIZED`: Unauthorized action
- `ERR-ALREADY-APPLIED`: Duplicate job application
- `ERR-INVALID-INPUT`: Invalid input data

## Testing

The project includes a comprehensive test suite using Vitest, covering:
- Job posting validation
- Application submission
- Error scenario handling
- Application count tracking

### Test Coverage
- Posting jobs with valid and invalid data
- Applying for jobs
- Preventing duplicate applications
- Handling inactive job listings
- Tracking application counts

## Development

### Prerequisites
- Stacks blockchain development environment
- Clarinet for local development and testing
- Vitest for running tests

### Local Setup
1. Clone the repository
2. Install dependencies
3. Run tests with `vitest`
4. Deploy to local or test network

## Security Considerations
- Input validation for all functions
- Authorization checks
- Prevents unauthorized modifications
- Tracks job and application states

## Potential Improvements
- Implement job expiration
- Add rating or review system
- Enhanced application tracking
- More granular permission management

## Contributing
Contributions are welcome! Please:
- Fork the repository
- Create a feature branch
- Commit your changes
- Open a pull request
