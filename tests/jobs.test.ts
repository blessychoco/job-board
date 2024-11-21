import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock functions and state
const mockContractState = {
  jobCount: 0,
  jobs: new Map(),
  applications: new Map(),
  jobApplicationCount: new Map(),
};

const mockBlockHeight = 100;
let txSender = "employer-1";

const resetState = () => {
  mockContractState.jobCount = 0;
  mockContractState.jobs.clear();
  mockContractState.applications.clear();
  mockContractState.jobApplicationCount.clear();
};

const postJob = (title, description, salary) => {
  if (!title || !description || salary <= 0) return { error: "Invalid input" };

  const newJobId = mockContractState.jobCount + 1;
  mockContractState.jobs.set(newJobId, {
    employer: txSender,
    title,
    description,
    salary,
    isActive: true,
    createdAt: mockBlockHeight,
    updatedAt: mockBlockHeight,
  });
  mockContractState.jobCount = newJobId;
  mockContractState.jobApplicationCount.set(newJobId, 0);

  return { success: newJobId };
};

const applyForJob = (jobId, coverLetter) => {
  if (!mockContractState.jobs.has(jobId)) return { error: "Job not found" };
  const job = mockContractState.jobs.get(jobId);
  if (!job.isActive) return { error: "Job not active" };

  const applicantKey = `${jobId}-${txSender}`;
  if (mockContractState.applications.has(applicantKey))
    return { error: "Already applied" };

  mockContractState.applications.set(applicantKey, {
    coverLetter,
    status: "pending",
    appliedAt: mockBlockHeight,
  });
  mockContractState.jobApplicationCount.set(
    jobId,
    (mockContractState.jobApplicationCount.get(jobId) || 0) + 1
  );

  return { success: true };
};

const getJobCount = () => mockContractState.jobCount;

const getApplicationsForJob = (jobId) =>
  Array.from(mockContractState.applications.entries()).filter(
    ([key]) => key.startsWith(`${jobId}-`)
  );

describe("Job Posting Smart Contract", () => {
  beforeEach(() => {
    resetState();
  });

  it("should allow posting a new job", () => {
    const result = postJob("Developer", "Write code", 50000);
    expect(result.success).toBe(1);
    expect(getJobCount()).toBe(1);
    const job = mockContractState.jobs.get(1);
    expect(job).toEqual({
      employer: txSender,
      title: "Developer",
      description: "Write code",
      salary: 50000,
      isActive: true,
      createdAt: mockBlockHeight,
      updatedAt: mockBlockHeight,
    });
  });

  it("should prevent posting a job with invalid data", () => {
    const result = postJob("", "Description", 50000);
    expect(result.error).toBe("Invalid input");
  });

  it("should allow applying for a job", () => {
    postJob("Developer", "Write code", 50000);
    txSender = "applicant-1";
    const result = applyForJob(1, "I am a great developer.");
    expect(result.success).toBe(true);

    const applications = getApplicationsForJob(1);
    expect(applications.length).toBe(1);
    expect(applications[0][1].coverLetter).toBe("I am a great developer.");
  });

  it("should prevent applying for a non-existent job", () => {
    txSender = "applicant-1";
    const result = applyForJob(1, "I am a great developer.");
    expect(result.error).toBe("Job not found");
  });

  it("should prevent applying to an inactive job", () => {
    postJob("Developer", "Write code", 50000);
    const job = mockContractState.jobs.get(1);
    job.isActive = false;

    txSender = "applicant-1";
    const result = applyForJob(1, "I am a great developer.");
    expect(result.error).toBe("Job not active");
  });

  it("should prevent duplicate applications for the same job", () => {
    postJob("Developer", "Write code", 50000);
    txSender = "applicant-1";
    applyForJob(1, "I am a great developer.");

    const result = applyForJob(1, "Another application.");
    expect(result.error).toBe("Already applied");
  });

  it("should track the number of applications for a job", () => {
    postJob("Developer", "Write code", 50000);
    txSender = "applicant-1";
    applyForJob(1, "I am a great developer.");

    txSender = "applicant-2";
    applyForJob(1, "Me too!");

    expect(mockContractState.jobApplicationCount.get(1)).toBe(2);
  });
});
