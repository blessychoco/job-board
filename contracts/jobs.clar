;; Define the job posting data structure
(define-map jobs
  { job-id: uint }
  { employer: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    salary: uint,
    is-active: bool,
    created-at: uint })

;; Define the job application data structure
(define-map applications
  { job-id: uint, applicant: principal }
  { cover-letter: (string-ascii 1000),
    status: (string-ascii 20),
    applied-at: uint })

;; Keep track of the total number of jobs
(define-data-var job-count uint u0)

;; Constants
(define-constant ERR-INVALID-SALARY u1)
(define-constant ERR-JOB-NOT-FOUND u2)
(define-constant ERR-JOB-NOT-ACTIVE u3)
(define-constant ERR-UNAUTHORIZED u4)
(define-constant ERR-ALREADY-APPLIED u5)

;; Function to post a new job
(define-public (post-job (title (string-ascii 100)) (description (string-ascii 1000)) (salary uint))
  (let 
    ((new-job-id (+ (var-get job-count) u1))
     (valid-salary (> salary u0)))
    (asserts! valid-salary (err ERR-INVALID-SALARY))
    (map-set jobs
      { job-id: new-job-id }
      { employer: tx-sender,
        title: title,
        description: description,
        salary: salary,
        is-active: true,
        created-at: block-height })
    (var-set job-count new-job-id)
    (ok new-job-id)))

;; Function to apply for a job
(define-public (apply-for-job (job-id uint) (cover-letter (string-ascii 1000)))
  (match (map-get? jobs { job-id: job-id })
    job-data 
      (if (get is-active job-data)
        (if (is-none (map-get? applications { job-id: job-id, applicant: tx-sender }))
          (begin
            (map-set applications
              { job-id: job-id, applicant: tx-sender }
              { cover-letter: cover-letter,
                status: "pending",
                applied-at: block-height })
            (ok true))
          (err ERR-ALREADY-APPLIED))
        (err ERR-JOB-NOT-ACTIVE))
    (err ERR-JOB-NOT-FOUND)))

;; Function to close a job posting
(define-public (close-job (job-id uint))
  (match (map-get? jobs { job-id: job-id })
    job-data 
      (if (is-eq (get employer job-data) tx-sender)
        (begin
          (map-set jobs
            { job-id: job-id }
            (merge job-data { is-active: false }))
          (ok true))
        (err ERR-UNAUTHORIZED))
    (err ERR-JOB-NOT-FOUND)))

;; Function to update application status
(define-public (update-application-status (job-id uint) (applicant principal) (new-status (string-ascii 20)))
  (match (map-get? jobs { job-id: job-id })
    job-data
      (if (is-eq (get employer job-data) tx-sender)
        (match (map-get? applications { job-id: job-id, applicant: applicant })
          application-data
            (begin
              (map-set applications
                { job-id: job-id, applicant: applicant }
                (merge application-data { status: new-status }))
              (ok true))
          (err ERR-JOB-NOT-FOUND))
        (err ERR-UNAUTHORIZED))
    (err ERR-JOB-NOT-FOUND)))

;; Read-only function to get job details
(define-read-only (get-job (job-id uint))
  (map-get? jobs { job-id: job-id }))

;; Read-only function to get application details
(define-read-only (get-application (job-id uint) (applicant principal))
  (map-get? applications { job-id: job-id, applicant: applicant }))

;; Read-only function to get the total number of jobs
(define-read-only (get-job-count)
  (var-get job-count))

;; Read-only function to get all applications for a job
(define-read-only (get-job-applications (job-id uint))
  (map-get? applications { job-id: job-id }))