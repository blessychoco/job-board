;; Define the job posting data structure
(define-map jobs
  { job-id: uint }
  { employer: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    salary: uint,
    is-active: bool })

;; Define the job application data structure
(define-map applications
  { job-id: uint, applicant: principal }
  { cover-letter: (string-ascii 1000) })

;; Keep track of the total number of jobs
(define-data-var job-count uint u0)

;; Function to post a new job
(define-public (post-job (title (string-ascii 100)) (description (string-ascii 1000)) (salary uint))
  (let 
    ((new-job-id (+ (var-get job-count) u1))
     (valid-salary (> salary u0)))
    (asserts! valid-salary (err u1))
    (map-set jobs
      { job-id: new-job-id }
      { employer: tx-sender,
        title: title,
        description: description,
        salary: salary,
        is-active: true })
    (var-set job-count new-job-id)
    (ok new-job-id)))

;; Function to apply for a job
(define-public (apply-for-job (job-id uint) (cover-letter (string-ascii 1000)))
  (match (map-get? jobs { job-id: job-id })
    job-data 
      (if (get is-active job-data)
        (begin
          (map-set applications
            { job-id: job-id, applicant: tx-sender }
            { cover-letter: cover-letter })
          (ok true))
        (err u3))
    (err u2)))

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
        (err u5))
    (err u4)))

;; Read-only function to get job details
(define-read-only (get-job (job-id uint))
  (map-get? jobs { job-id: job-id }))

;; Read-only function to get application details
(define-read-only (get-application (job-id uint) (applicant principal))
  (map-get? applications { job-id: job-id, applicant: applicant }))

;; Read-only function to get the total number of jobs
(define-read-only (get-job-count)
  (var-get job-count))