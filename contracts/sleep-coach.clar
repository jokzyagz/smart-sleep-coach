;; sleep-coach
;; Module that gives personalized tips and bedtime routines

;; Token definition for Coaching Tokens (CT)
(define-fungible-token coaching-tokens)

;; Constants for coaching system
(define-constant MAX-RECOMMENDATIONS u10)
(define-constant RECOMMENDATION-REWARD u30)
(define-constant CONSISTENCY-BONUS u100)
(define-constant ACHIEVEMENT-REWARD u200)
(define-constant STREAK-MILESTONE u7)

;; Coaching categories
(define-constant CATEGORY-BEDTIME u1)
(define-constant CATEGORY-ENVIRONMENT u2)
(define-constant CATEGORY-LIFESTYLE u3)
(define-constant CATEGORY-RELAXATION u4)

;; Error constants
(define-constant ERR-NOT-FOUND u404)
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-INVALID-INPUT u400)
(define-constant ERR-ALREADY-CLAIMED u409)
(define-constant ERR-INSUFFICIENT-PROGRESS u422)

;; Data variables for coaching system
(define-data-var contract-owner principal tx-sender)
(define-data-var recommendation-counter uint u0)
(define-data-var total-coaching-sessions uint u0)
(define-data-var active-coaches uint u1)

;; User coaching profiles
(define-map coaching-profiles
  { user: principal }
  {
    coaching-level: (string-ascii 16),
    total-recommendations-received: uint,
    recommendations-followed: uint,
    current-program: (optional (string-ascii 32)),
    program-progress: uint,
    last-coaching-session: uint,
    coaching-streak: uint,
    total-achievements: uint,
    preferred-coaching-time: uint,
    coaching-tokens-earned: uint,
    is-active: bool
  }
)

;; Personalized recommendations
(define-map recommendations
  { recommendation-id: uint }
  {
    user: principal,
    category: uint,
    title: (string-ascii 64),
    description: (string-ascii 256),
    priority: uint,
    created-at: uint,
    expires-at: uint,
    is-followed: bool,
    effectiveness-score: uint,
    feedback-rating: (optional uint)
  }
)

;; Sleep improvement programs
(define-map sleep-programs
  { program-id: uint }
  {
    name: (string-ascii 32),
    description: (string-ascii 128),
    duration-days: uint,
    difficulty-level: uint,
    target-improvements: (list 5 (string-ascii 16)),
    success-rate: uint,
    participant-count: uint,
    is-active: bool
  }
)

;; User program enrollment
(define-map program-enrollments
  { user: principal, program-id: uint }
  {
    enrolled-at: uint,
    current-day: uint,
    completion-rate: uint,
    daily-checkins: (list 30 bool),
    milestone-achievements: uint,
    final-score: (optional uint),
    completed-at: (optional uint)
  }
)

;; Coaching achievements and milestones
(define-map achievements
  { achievement-id: uint }
  {
    name: (string-ascii 32),
    description: (string-ascii 64),
    category: (string-ascii 16),
    requirement-type: (string-ascii 16),
    requirement-value: uint,
    reward-tokens: uint,
    rarity: (string-ascii 16),
    unlock-count: uint
  }
)

;; User achievement tracking
(define-map user-achievements
  { user: principal, achievement-id: uint }
  {
    unlocked-at: uint,
    progress-value: uint,
    is-claimed: bool
  }
)

;; Bedtime routine templates
(define-map bedtime-routines
  { routine-id: uint }
  {
    name: (string-ascii 32),
    description: (string-ascii 128),
    estimated-duration: uint, ;; in minutes
    activities: (list 10 (string-ascii 32)),
    difficulty: uint,
    effectiveness-rating: uint,
    usage-count: uint
  }
)

;; User routine customizations
(define-map user-routines
  { user: principal }
  {
    active-routine-id: (optional uint),
    custom-activities: (list 10 (string-ascii 32)),
    routine-start-time: uint,
    adherence-rate: uint,
    last-updated: uint,
    effectiveness-feedback: (optional uint)
  }
)

;; Helper functions
(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)

;; Initialize default achievements
(map-set achievements { achievement-id: u1 } {
  name: "First Night",
  description: "Complete your first sleep session",
  category: "milestone",
  requirement-type: "sessions",
  requirement-value: u1,
  reward-tokens: u50,
  rarity: "common",
  unlock-count: u0
})

(map-set achievements { achievement-id: u2 } {
  name: "Weekly Warrior",
  description: "Maintain 7-day sleep consistency",
  category: "streak",
  requirement-type: "streak",
  requirement-value: u7,
  reward-tokens: u150,
  rarity: "uncommon",
  unlock-count: u0
})

(map-set achievements { achievement-id: u3 } {
  name: "Quality Sleeper",
  description: "Achieve 90%+ sleep quality",
  category: "quality",
  requirement-type: "quality",
  requirement-value: u90,
  reward-tokens: u100,
  rarity: "rare",
  unlock-count: u0
})

;; Initialize default sleep programs
(map-set sleep-programs { program-id: u1 } {
  name: "Sleep Foundation",
  description: "Basic sleep hygiene program",
  duration-days: u14,
  difficulty-level: u1,
  target-improvements: (list "consistency" "quality" "duration"),
  success-rate: u78,
  participant-count: u0,
  is-active: true
})

(map-set sleep-programs { program-id: u2 } {
  name: "Advanced Sleep Optimization",
  description: "Comprehensive sleep improvement",
  duration-days: u30,
  difficulty-level: u3,
  target-improvements: (list "efficiency" "rem" "recovery" "environment"),
  success-rate: u85,
  participant-count: u0,
  is-active: true
})

;; Public function to generate personalized recommendations
(define-public (generate-recommendations (user principal))
  (let
    (
      (coaching-profile (default-to
        {
          coaching-level: "beginner",
          total-recommendations-received: u0,
          recommendations-followed: u0,
          current-program: none,
          program-progress: u0,
          last-coaching-session: u0,
          coaching-streak: u0,
          total-achievements: u0,
          preferred-coaching-time: u1200, ;; 8 PM
          coaching-tokens-earned: u0,
          is-active: true
        }
        (map-get? coaching-profiles { user: user })
      ))
      (new-recommendation-id (+ (var-get recommendation-counter) u1))
    )
    (begin
      ;; Create basic bedtime recommendation
      (map-set recommendations
        { recommendation-id: new-recommendation-id }
        {
          user: user,
          category: CATEGORY-BEDTIME,
          title: "Optimize Your Bedtime",
          description: "Maintain consistent sleep schedule for better sleep quality",
          priority: u8,
          created-at: stacks-block-height,
          expires-at: (+ stacks-block-height u1008), ;; 1 week
          is-followed: false,
          effectiveness-score: u85,
          feedback-rating: none
        }
      )
      
      ;; Update coaching profile
      (map-set coaching-profiles
        { user: user }
        (merge coaching-profile {
          total-recommendations-received: (+ (get total-recommendations-received coaching-profile) u1),
          last-coaching-session: stacks-block-height
        })
      )
      
      ;; Reward user for engaging with coaching
      (try! (ft-mint? coaching-tokens RECOMMENDATION-REWARD user))
      
      ;; Update counters
      (var-set recommendation-counter new-recommendation-id)
      (var-set total-coaching-sessions (+ (var-get total-coaching-sessions) u1))
      
      (ok new-recommendation-id)
    )
  )
)

;; Public function to set sleep goals
(define-public (set-sleep-goal (duration-goal uint) (quality-goal uint))
  (let
    (
      (coaching-profile (default-to
        {
          coaching-level: "beginner",
          total-recommendations-received: u0,
          recommendations-followed: u0,
          current-program: none,
          program-progress: u0,
          last-coaching-session: u0,
          coaching-streak: u0,
          total-achievements: u0,
          preferred-coaching-time: u1200,
          coaching-tokens-earned: u0,
          is-active: true
        }
        (map-get? coaching-profiles { user: tx-sender })
      ))
    )
    (begin
      ;; Validate goals
      (asserts! (and (>= duration-goal u240) (<= duration-goal u720)) (err ERR-INVALID-INPUT)) ;; 4-12 hours
      (asserts! (and (>= quality-goal u50) (<= quality-goal u100)) (err ERR-INVALID-INPUT))
      
      ;; Generate personalized recommendations based on goals
      (try! (generate-recommendations tx-sender))
      
      ;; Reward goal setting
      (try! (ft-mint? coaching-tokens u25 tx-sender))
      
      (ok true)
    )
  )
)

;; Public function to enroll in a sleep program
(define-public (enroll-in-program (program-id uint))
  (let
    (
      (program-data (unwrap! (map-get? sleep-programs { program-id: program-id }) (err ERR-NOT-FOUND)))
      (existing-enrollment (map-get? program-enrollments { user: tx-sender, program-id: program-id }))
      (coaching-profile (map-get? coaching-profiles { user: tx-sender }))
    )
    (begin
      ;; Check program is active and user not already enrolled
      (asserts! (get is-active program-data) (err ERR-INVALID-INPUT))
      (asserts! (is-none existing-enrollment) (err ERR-ALREADY-CLAIMED))
      
      ;; Create enrollment record
      (map-set program-enrollments
        { user: tx-sender, program-id: program-id }
        {
          enrolled-at: stacks-block-height,
          current-day: u1,
          completion-rate: u0,
          daily-checkins: (list),
          milestone-achievements: u0,
          final-score: none,
          completed-at: none
        }
      )
      
      ;; Update coaching profile
      (match coaching-profile
        profile
          (map-set coaching-profiles
            { user: tx-sender }
            (merge profile {
              current-program: (some (get name program-data)),
              program-progress: u0
            })
          )
        ;; Create new profile if doesn't exist
        (map-set coaching-profiles
          { user: tx-sender }
          {
            coaching-level: "beginner",
            total-recommendations-received: u0,
            recommendations-followed: u0,
            current-program: (some (get name program-data)),
            program-progress: u0,
            last-coaching-session: stacks-block-height,
            coaching-streak: u0,
            total-achievements: u0,
            preferred-coaching-time: u1200,
            coaching-tokens-earned: u0,
            is-active: true
          }
        )
      )
      
      ;; Update program participant count
      (map-set sleep-programs
        { program-id: program-id }
        (merge program-data {
          participant-count: (+ (get participant-count program-data) u1)
        })
      )
      
      ;; Reward enrollment
      (try! (ft-mint? coaching-tokens u50 tx-sender))
      
      (ok true)
    )
  )
)

;; Public function to mark recommendation as followed
(define-public (follow-recommendation (recommendation-id uint) (effectiveness-rating uint))
  (let
    (
      (recommendation-data (unwrap! (map-get? recommendations { recommendation-id: recommendation-id }) (err ERR-NOT-FOUND)))
      (coaching-profile (unwrap! (map-get? coaching-profiles { user: tx-sender }) (err ERR-NOT-FOUND)))
    )
    (begin
      ;; Check user owns this recommendation and hasn't already followed it
      (asserts! (is-eq (get user recommendation-data) tx-sender) (err ERR-UNAUTHORIZED))
      (asserts! (not (get is-followed recommendation-data)) (err ERR-ALREADY-CLAIMED))
      (asserts! (and (>= effectiveness-rating u1) (<= effectiveness-rating u10)) (err ERR-INVALID-INPUT))
      
      ;; Update recommendation as followed
      (map-set recommendations
        { recommendation-id: recommendation-id }
        (merge recommendation-data {
          is-followed: true,
          feedback-rating: (some effectiveness-rating)
        })
      )
      
      ;; Update coaching profile
      (map-set coaching-profiles
        { user: tx-sender }
        (merge coaching-profile {
          recommendations-followed: (+ (get recommendations-followed coaching-profile) u1),
          coaching-tokens-earned: (+ (get coaching-tokens-earned coaching-profile) RECOMMENDATION-REWARD)
        })
      )
      
      ;; Reward for following recommendation
      (try! (ft-mint? coaching-tokens RECOMMENDATION-REWARD tx-sender))
      
      (ok true)
    )
  )
)

;; Public function to claim consistency reward
(define-public (claim-consistency-reward)
  (let
    (
      (coaching-profile (unwrap! (map-get? coaching-profiles { user: tx-sender }) (err ERR-NOT-FOUND)))
    )
    (begin
      ;; Check if user has sufficient streak
      (asserts! (>= (get coaching-streak coaching-profile) STREAK-MILESTONE) (err ERR-INSUFFICIENT-PROGRESS))
      
      ;; Reset streak and reward
      (map-set coaching-profiles
        { user: tx-sender }
        (merge coaching-profile {
          coaching-streak: u0,
          coaching-tokens-earned: (+ (get coaching-tokens-earned coaching-profile) CONSISTENCY-BONUS)
        })
      )
      
      ;; Mint consistency bonus tokens
      (try! (ft-mint? coaching-tokens CONSISTENCY-BONUS tx-sender))
      
      (ok CONSISTENCY-BONUS)
    )
  )
)

;; Public function to create custom bedtime routine
(define-public (create-custom-routine (activities (list 10 (string-ascii 32))) (start-time uint))
  (let
    (
      (user-routine (default-to
        {
          active-routine-id: none,
          custom-activities: (list),
          routine-start-time: u1200,
          adherence-rate: u0,
          last-updated: u0,
          effectiveness-feedback: none
        }
        (map-get? user-routines { user: tx-sender })
      ))
    )
    (begin
      ;; Validate inputs
      (asserts! (> (len activities) u0) (err ERR-INVALID-INPUT))
      (asserts! (and (>= start-time u0) (< start-time u1440)) (err ERR-INVALID-INPUT))
      
      ;; Update user's custom routine
      (map-set user-routines
        { user: tx-sender }
        (merge user-routine {
          custom-activities: activities,
          routine-start-time: start-time,
          last-updated: stacks-block-height
        })
      )
      
      ;; Reward routine creation
      (try! (ft-mint? coaching-tokens u40 tx-sender))
      
      (ok true)
    )
  )
)

;; Read-only function to get coaching profile
(define-read-only (get-coaching-profile (user principal))
  (match (map-get? coaching-profiles { user: user })
    profile-data (ok profile-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get recommendation details
(define-read-only (get-recommendation (recommendation-id uint))
  (match (map-get? recommendations { recommendation-id: recommendation-id })
    recommendation-data (ok recommendation-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get sleep program details
(define-read-only (get-sleep-program (program-id uint))
  (match (map-get? sleep-programs { program-id: program-id })
    program-data (ok program-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user's program enrollment
(define-read-only (get-program-enrollment (user principal) (program-id uint))
  (match (map-get? program-enrollments { user: user, program-id: program-id })
    enrollment-data (ok enrollment-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get achievement details
(define-read-only (get-achievement (achievement-id uint))
  (match (map-get? achievements { achievement-id: achievement-id })
    achievement-data (ok achievement-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user achievement status
(define-read-only (get-user-achievement (user principal) (achievement-id uint))
  (match (map-get? user-achievements { user: user, achievement-id: achievement-id })
    user-achievement-data (ok user-achievement-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user's bedtime routine
(define-read-only (get-user-routine (user principal))
  (match (map-get? user-routines { user: user })
    routine-data (ok routine-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user's token balance
(define-read-only (get-coaching-token-balance (user principal))
  (ok (ft-get-balance coaching-tokens user))
)

;; Read-only function to get coaching platform statistics
(define-read-only (get-coaching-stats)
  (ok {
    total-recommendations: (var-get recommendation-counter),
    total-coaching-sessions: (var-get total-coaching-sessions),
    active-coaches: (var-get active-coaches),
    total-coaching-tokens: (ft-get-supply coaching-tokens)
  })
)

