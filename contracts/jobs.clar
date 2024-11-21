;; Define the job posting data structure
(define-map jobs
  { job-id: uint }
  { employer: principal,
    title: (string-ascii 100),
    description: (string-ascii 1000),
    salary: uint,
    is-active: bool,
    created-at: uint,
    updated-at: uint })

;; Define the job application data structure
(define-map applications
  { job-id: uint, applicant: principal }
  { cover-letter: (string-ascii 1000),
    status: (string-ascii 20),
    applied-at: uint })

;; Keep track of the total number of jobs
(define-data-var job-count uint u0)

;; Keep track of application count per job
(define-map job-application-count { job-id: uint } { count: uint })

;; Constants
(define-constant ERR-INVALID-SALARY u1)
(define-constant ERR-JOB-NOT-FOUND u2)
(define-constant ERR-JOB-NOT-ACTIVE u3)
(define-constant ERR-UNAUTHORIZED u4)
(define-constant ERR-ALREADY-APPLIED u5)
(define-constant ERR-INVALID-JOB-ID u6)
(define-constant ERR-INVALID-STATUS u7)
(define-constant ERR-INVALID-INPUT u8)

;; Helper function to validate input strings
(define-private (is-valid-string (input (string-ascii 1000)))
  (and (> (len input) u0) (<= (len input) u1000)))

;; Helper function to validate job ID
(define-private (is-valid-job-id (job-id uint))
  (and (> job-id u0) (<= job-id (var-get job-count))))

;; Function to post a new job
(define-public (post-job (title (string-ascii 100)) (description (string-ascii 1000)) (salary uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-string title) (err ERR-INVALID-INPUT))
    (asserts! (is-valid-string description) (err ERR-INVALID-INPUT))
    (asserts! (> salary u0) (err ERR-INVALID-SALARY))
    
    (let 
      ((new-job-id (+ (var-get job-count) u1)))
      (map-set jobs
        { job-id: new-job-id }
        { employer: tx-sender,
          title: title,
          description: description,
          salary: salary,
          is-active: true,
          created-at: block-height,
          updated-at: block-height })
      (map-set job-application-count { job-id: new-job-id } { count: u0 })
      (var-set job-count new-job-id)
      (ok new-job-id))))

;; Function to edit an existing job posting
(define-public (edit-job (job-id uint) (title (string-ascii 100)) (description (string-ascii 1000)) (salary uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-job-id job-id) (err ERR-INVALID-JOB-ID))
    (asserts! (is-valid-string title) (err ERR-INVALID-INPUT))
    (asserts! (is-valid-string description) (err ERR-INVALID-INPUT))
    
    (let ((job (map-get? jobs { job-id: job-id })))
      (asserts! (is-some job) (err ERR-JOB-NOT-FOUND))
      (let ((job-data (unwrap-panic job)))
        (asserts! (is-eq (get employer job-data) tx-sender) (err ERR-UNAUTHORIZED))
        (asserts! (get is-active job-data) (err ERR-JOB-NOT-ACTIVE))
        (asserts! (> salary u0) (err ERR-INVALID-SALARY))
        (map-set jobs
          { job-id: job-id }
          (merge job-data { 
            title: title,
            description: description,
            salary: salary,
            updated-at: block-height
          }))
        (ok true)))))

;; Function to apply for a job
(define-public (apply-for-job (job-id uint) (cover-letter (string-ascii 1000)))
  (begin
    ;; Input validation
    (asserts! (is-valid-job-id job-id) (err ERR-INVALID-JOB-ID))
    (asserts! (is-valid-string cover-letter) (err ERR-INVALID-INPUT))
    
    (let ((job (map-get? jobs { job-id: job-id })))
      (asserts! (is-some job) (err ERR-JOB-NOT-FOUND))
      (asserts! (get is-active (unwrap-panic job)) (err ERR-JOB-NOT-ACTIVE))
      (asserts! (is-none (map-get? applications { job-id: job-id, applicant: tx-sender })) (err ERR-ALREADY-APPLIED))
      (map-set applications
        { job-id: job-id, applicant: tx-sender }
        { cover-letter: cover-letter,
          status: "pending",
          applied-at: block-height })
      (match (map-get? job-application-count { job-id: job-id })
        count-data (map-set job-application-count
                      { job-id: job-id }
                      { count: (+ (get count count-data) u1) })
        (map-set job-application-count { job-id: job-id } { count: u1 }))
      (ok true))))

;; Function to close a job posting
(define-public (close-job (job-id uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-job-id job-id) (err ERR-INVALID-JOB-ID))
    
    (let ((job (map-get? jobs { job-id: job-id })))
      (asserts! (is-some job) (err ERR-JOB-NOT-FOUND))
      (asserts! (is-eq (get employer (unwrap-panic job)) tx-sender) (err ERR-UNAUTHORIZED))
      (map-set jobs
        { job-id: job-id }
        (merge (unwrap-panic job) { is-active: false }))
      (ok true))))

;; Function to update application status
(define-public (update-application-status (job-id uint) (applicant principal) (new-status (string-ascii 20)))
  (begin
    ;; Input validation
    (asserts! (is-valid-job-id job-id) (err ERR-INVALID-JOB-ID))
    (asserts! (not (is-eq applicant tx-sender)) (err ERR-INVALID-INPUT))
    (asserts! (is-valid-string new-status) (err ERR-INVALID-INPUT))
    
    (let ((job (map-get? jobs { job-id: job-id }))
          (application (map-get? applications { job-id: job-id, applicant: applicant })))
      (asserts! (is-some job) (err ERR-JOB-NOT-FOUND))
      (asserts! (is-eq (get employer (unwrap-panic job)) tx-sender) (err ERR-UNAUTHORIZED))
      (asserts! (is-some application) (err ERR-JOB-NOT-FOUND))
      (asserts! (or 
                  (is-eq new-status "accepted") 
                  (is-eq new-status "rejected") 
                  (is-eq new-status "pending")) 
                (err ERR-INVALID-STATUS))
      (map-set applications
        { job-id: job-id, applicant: applicant }
        (merge (unwrap-panic application) { status: new-status }))
      (ok true))))

;; Read-only function to get job details
(define-read-only (get-job (job-id uint))
  (map-get? jobs { job-id: job-id }))

;; Read-only function to get application details
(define-read-only (get-application (job-id uint) (applicant principal))
  (map-get? applications { job-id: job-id, applicant: applicant }))

;; Read-only function to get the total number of jobs
(define-read-only (get-job-count)
  (var-get job-count))

;; Read-only function to get the number of applications for a job
(define-read-only (get-job-application-count (job-id uint))
  (match (map-get? job-application-count { job-id: job-id })
    count-data (ok (get count count-data))
    (err ERR-JOB-NOT-FOUND)))