;; sleep-analyzer
;; Module to track and evaluate sleep cycles using wearable or phone sensors

;; Token definition for Sleep Quality Tokens (SQT)
(define-fungible-token sleep-quality-tokens)

;; Constants for sleep analysis
(define-constant OPTIMAL-SLEEP-DURATION u480) ;; 8 hours in minutes
(define-constant MIN-SLEEP-DURATION u240) ;; 4 hours minimum
(define-constant MAX-SLEEP-DURATION u720) ;; 12 hours maximum
(define-constant QUALITY-THRESHOLD u75) ;; 75% minimum quality for rewards
(define-constant DATA-REWARD u50) ;; Tokens for contributing sleep data

;; Sleep stages as constants
(define-constant STAGE-LIGHT u1)
(define-constant STAGE-DEEP u2)
(define-constant STAGE-REM u3)
(define-constant STAGE-AWAKE u4)

;; Error constants
(define-constant ERR-NOT-FOUND u404)
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-INVALID-INPUT u400)
(define-constant ERR-ALREADY-EXISTS u409)
(define-constant ERR-INSUFFICIENT-DATA u422)

;; Data variables for system management
(define-data-var contract-owner principal tx-sender)
(define-data-var session-counter uint u0)
(define-data-var total-data-contributed uint u0)
(define-data-var research-pool uint u0)

;; Sleep session data structure
(define-map sleep-sessions
  { session-id: uint }
  {
    user: principal,
    start-time: uint,
    end-time: uint,
    total-duration: uint,
    sleep-efficiency: uint,
    sleep-latency: uint,
    wake-after-sleep-onset: uint,
    light-sleep-duration: uint,
    deep-sleep-duration: uint,
    rem-sleep-duration: uint,
    awake-duration: uint,
    sleep-quality-score: uint,
    heart-rate-avg: uint,
    movement-count: uint,
    recorded-at: uint,
    data-source: (string-ascii 16)
  }
)

;; User sleep profiles and preferences
(define-map user-profiles
  { user: principal }
  {
    preferred-bedtime: uint, ;; minutes from midnight
    preferred-wake-time: uint,
    sleep-goal-duration: uint,
    sleep-goal-quality: uint,
    total-sessions: uint,
    average-quality: uint,
    best-quality-score: uint,
    current-streak: uint,
    longest-streak: uint,
    total-sleep-debt: int,
    last-session-date: uint,
    is-active: bool
  }
)

;; Environmental factors affecting sleep
(define-map environmental-data
  { session-id: uint }
  {
    room-temperature: uint, ;; in celsius * 10
    humidity-level: uint,
    noise-level: uint, ;; in decibels
    light-exposure: uint, ;; in lux
    air-quality-index: uint,
    weather-condition: (string-ascii 16)
  }
)

;; Sleep pattern analytics
(define-map sleep-patterns
  { user: principal, pattern-type: (string-ascii 16) }
  {
    average-value: uint,
    trend-direction: (string-ascii 8), ;; "up", "down", "stable"
    confidence-level: uint,
    sample-size: uint,
    last-updated: uint
  }
)

;; Weekly sleep summaries
(define-map weekly-summaries
  { user: principal, week-start: uint }
  {
    total-sleep-time: uint,
    average-quality: uint,
    sessions-count: uint,
    goal-achievement-rate: uint,
    sleep-debt-change: int,
    consistency-score: uint,
    recommendations-followed: uint
  }
)

;; Research contribution tracking
(define-map research-contributions
  { user: principal }
  {
    sessions-contributed: uint,
    data-points-shared: uint,
    anonymized-data: bool,
    research-tokens-earned: uint,
    contribution-level: (string-ascii 16),
    last-contribution: uint
  }
)

;; Helper functions
(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)

;; Public function to record a new sleep session
(define-public (record-sleep-session 
                (total-duration uint)
                (sleep-quality-score uint)
                (light-sleep uint)
                (deep-sleep uint)
                (rem-sleep uint)
                (awake-duration uint)
                (sleep-latency uint)
                (heart-rate-avg uint)
                (movement-count uint)
                (data-source (string-ascii 16))
              )
  (let
    (
      (new-session-id (+ (var-get session-counter) u1))
      (current-time stacks-block-height)
      (user-profile (default-to
        {
          preferred-bedtime: u1320, ;; 10 PM
          preferred-wake-time: u420, ;; 7 AM
          sleep-goal-duration: OPTIMAL-SLEEP-DURATION,
          sleep-goal-quality: u85,
          total-sessions: u0,
          average-quality: u0,
          best-quality-score: u0,
          current-streak: u0,
          longest-streak: u0,
          total-sleep-debt: 0,
          last-session-date: u0,
          is-active: true
        }
        (map-get? user-profiles { user: tx-sender })
      ))
    )
    (begin
      ;; Validate input data
      (asserts! (and (>= total-duration MIN-SLEEP-DURATION) (<= total-duration MAX-SLEEP-DURATION)) (err ERR-INVALID-INPUT))
      (asserts! (and (>= sleep-quality-score u0) (<= sleep-quality-score u100)) (err ERR-INVALID-INPUT))
      (asserts! (> (len data-source) u0) (err ERR-INVALID-INPUT))
      
      ;; Calculate sleep efficiency
      (let
        (
          (actual-sleep (- total-duration awake-duration))
          (sleep-efficiency (if (> total-duration u0) (/ (* actual-sleep u100) total-duration) u0))
          (wake-after-sleep-onset awake-duration)
        )
        
        ;; Record the sleep session
        (map-set sleep-sessions
          { session-id: new-session-id }
          {
            user: tx-sender,
            start-time: (- current-time (/ total-duration u10)), ;; Approximate start time
            end-time: current-time,
            total-duration: total-duration,
            sleep-efficiency: sleep-efficiency,
            sleep-latency: sleep-latency,
            wake-after-sleep-onset: wake-after-sleep-onset,
            light-sleep-duration: light-sleep,
            deep-sleep-duration: deep-sleep,
            rem-sleep-duration: rem-sleep,
            awake-duration: awake-duration,
            sleep-quality-score: sleep-quality-score,
            heart-rate-avg: heart-rate-avg,
            movement-count: movement-count,
            recorded-at: current-time,
            data-source: data-source
          }
        )
        
        ;; Update user profile
        (let
          (
            (new-total-sessions (+ (get total-sessions user-profile) u1))
            (new-average-quality (/ (+ (* (get average-quality user-profile) (get total-sessions user-profile)) sleep-quality-score) new-total-sessions))
            (sleep-debt (calculate-sleep-debt total-duration (get sleep-goal-duration user-profile)))
            (new-streak (calculate-sleep-streak user-profile current-time sleep-quality-score))
          )
          (map-set user-profiles
            { user: tx-sender }
            (merge user-profile {
              total-sessions: new-total-sessions,
              average-quality: new-average-quality,
              best-quality-score: (max (get best-quality-score user-profile) sleep-quality-score),
              current-streak: new-streak,
              longest-streak: (max (get longest-streak user-profile) new-streak),
              total-sleep-debt: (+ (get total-sleep-debt user-profile) sleep-debt),
              last-session-date: current-time
            })
          )
          
          ;; Reward user for good sleep quality
          (if (>= sleep-quality-score QUALITY-THRESHOLD)
            (try! (ft-mint? sleep-quality-tokens DATA-REWARD tx-sender))
            true
          )
          
          ;; Update analytics patterns
          (update-sleep-patterns tx-sender sleep-quality-score total-duration)
          
          ;; Update session counter
          (var-set session-counter new-session-id)
          
          (ok new-session-id)
        )
      )
    )
  )
)

;; Public function to record environmental data
(define-public (record-environmental-data
                (session-id uint)
                (room-temperature uint)
                (humidity uint)
                (noise-level uint)
                (light-exposure uint)
                (air-quality uint)
                (weather (string-ascii 16))
              )
  (let
    (
      (session-data (unwrap! (map-get? sleep-sessions { session-id: session-id }) (err ERR-NOT-FOUND)))
    )
    (begin
      ;; Check if user owns this session
      (asserts! (is-eq (get user session-data) tx-sender) (err ERR-UNAUTHORIZED))
      
      ;; Validate environmental data ranges
      (asserts! (and (>= room-temperature u150) (<= room-temperature u300)) (err ERR-INVALID-INPUT)) ;; 15-30C
      (asserts! (and (>= humidity u20) (<= humidity u80)) (err ERR-INVALID-INPUT)) ;; 20-80%
      (asserts! (<= noise-level u100) (err ERR-INVALID-INPUT)) ;; Max 100dB
      
      ;; Record environmental data
      (map-set environmental-data
        { session-id: session-id }
        {
          room-temperature: room-temperature,
          humidity-level: humidity,
          noise-level: noise-level,
          light-exposure: light-exposure,
          air-quality-index: air-quality,
          weather-condition: weather
        }
      )
      
      (ok true)
    )
  )
)

;; Public function to update sleep goals
(define-public (update-sleep-goals (duration-goal uint) (quality-goal uint) (bedtime uint) (wake-time uint))
  (let
    (
      (user-profile (unwrap! (map-get? user-profiles { user: tx-sender }) (err ERR-NOT-FOUND)))
    )
    (begin
      ;; Validate goals
      (asserts! (and (>= duration-goal MIN-SLEEP-DURATION) (<= duration-goal MAX-SLEEP-DURATION)) (err ERR-INVALID-INPUT))
      (asserts! (and (>= quality-goal u50) (<= quality-goal u100)) (err ERR-INVALID-INPUT))
      (asserts! (and (>= bedtime u0) (< bedtime u1440)) (err ERR-INVALID-INPUT)) ;; 0-1439 minutes
      (asserts! (and (>= wake-time u0) (< wake-time u1440)) (err ERR-INVALID-INPUT))
      
      ;; Update user profile with new goals
      (map-set user-profiles
        { user: tx-sender }
        (merge user-profile {
          sleep-goal-duration: duration-goal,
          sleep-goal-quality: quality-goal,
          preferred-bedtime: bedtime,
          preferred-wake-time: wake-time
        })
      )
      
      (ok true)
    )
  )
)

;; Public function to contribute data to research
(define-public (contribute-to-research (sessions-to-contribute (list 10 uint)))
  (let
    (
      (contribution-data (default-to
        {
          sessions-contributed: u0,
          data-points-shared: u0,
          anonymized-data: true,
          research-tokens-earned: u0,
          contribution-level: "bronze",
          last-contribution: u0
        }
        (map-get? research-contributions { user: tx-sender })
      ))
      (sessions-count (len sessions-to-contribute))
    )
    (begin
      ;; Validate user owns all sessions
      (asserts! (> sessions-count u0) (err ERR-INVALID-INPUT))
      
      ;; Calculate research reward
      (let
        (
          (research-reward (* sessions-count u25))
          (new-total-sessions (+ (get sessions-contributed contribution-data) sessions-count))
          (new-contribution-level (calculate-contribution-level new-total-sessions))
        )
        ;; Mint research tokens
        (try! (ft-mint? sleep-quality-tokens research-reward tx-sender))
        
        ;; Update contribution record
        (map-set research-contributions
          { user: tx-sender }
          (merge contribution-data {
            sessions-contributed: new-total-sessions,
            data-points-shared: (+ (get data-points-shared contribution-data) (* sessions-count u10)),
            research-tokens-earned: (+ (get research-tokens-earned contribution-data) research-reward),
            contribution-level: new-contribution-level,
            last-contribution: stacks-block-height
          })
        )
        
        ;; Update global research pool
        (var-set research-pool (+ (var-get research-pool) sessions-count))
        (var-set total-data-contributed (+ (var-get total-data-contributed) sessions-count))
        
        (ok research-reward)
      )
    )
  )
)

;; Read-only function to get sleep session details
(define-read-only (get-sleep-session (session-id uint))
  (match (map-get? sleep-sessions { session-id: session-id })
    session-data (ok session-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user profile
(define-read-only (get-user-profile (user principal))
  (match (map-get? user-profiles { user: user })
    profile-data (ok profile-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get sleep pattern analysis
(define-read-only (get-sleep-patterns (user principal) (pattern-type (string-ascii 16)))
  (match (map-get? sleep-patterns { user: user, pattern-type: pattern-type })
    pattern-data (ok pattern-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get weekly summary
(define-read-only (get-weekly-summary (user principal) (week-start uint))
  (match (map-get? weekly-summaries { user: user, week-start: week-start })
    summary-data (ok summary-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get environmental data
(define-read-only (get-environmental-data (session-id uint))
  (match (map-get? environmental-data { session-id: session-id })
    env-data (ok env-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get research contribution status
(define-read-only (get-research-contributions (user principal))
  (match (map-get? research-contributions { user: user })
    contribution-data (ok contribution-data)
    (err ERR-NOT-FOUND)
  )
)

;; Read-only function to get user's token balance
(define-read-only (get-token-balance (user principal))
  (ok (ft-get-balance sleep-quality-tokens user))
)

;; Read-only function to get platform statistics
(define-read-only (get-platform-stats)
  (ok {
    total-sessions: (var-get session-counter),
    total-research-data: (var-get total-data-contributed),
    research-pool-size: (var-get research-pool),
    total-tokens-issued: (ft-get-supply sleep-quality-tokens)
  })
)

;; Private function to calculate sleep debt
(define-private (calculate-sleep-debt (actual-duration uint) (goal-duration uint))
  (if (>= actual-duration goal-duration)
    0
    (to-int (- goal-duration actual-duration))
  )
)

;; Private function to calculate sleep streak
(define-private (calculate-sleep-streak (user-profile { preferred-bedtime: uint, preferred-wake-time: uint, sleep-goal-duration: uint, sleep-goal-quality: uint, total-sessions: uint, average-quality: uint, best-quality-score: uint, current-streak: uint, longest-streak: uint, total-sleep-debt: int, last-session-date: uint, is-active: bool }) (current-time uint) (quality-score uint))
  (let
    (
      (last-session (get last-session-date user-profile))
      (current-streak (get current-streak user-profile))
      (quality-threshold QUALITY-THRESHOLD)
    )
    (if (>= quality-score quality-threshold)
      (if (is-eq last-session u0)
        u1 ;; First session
        (if (<= (- current-time last-session) u288) ;; Within 2 days (288 blocks)
          (+ current-streak u1)
          u1 ;; Streak broken, start over
        )
      )
      u0 ;; Quality too low, no streak
    )
  )
)

;; Private function to update sleep patterns
(define-private (update-sleep-patterns (user principal) (quality uint) (duration uint))
  (begin
    ;; Update quality pattern
    (map-set sleep-patterns
      { user: user, pattern-type: "quality" }
      {
        average-value: quality,
        trend-direction: "stable",
        confidence-level: u80,
        sample-size: u1,
        last-updated: stacks-block-height
      }
    )
    
    ;; Update duration pattern
    (map-set sleep-patterns
      { user: user, pattern-type: "duration" }
      {
        average-value: duration,
        trend-direction: "stable",
        confidence-level: u80,
        sample-size: u1,
        last-updated: stacks-block-height
      }
    )
  )
)

;; Private function to calculate contribution level
(define-private (calculate-contribution-level (total-sessions uint))
  (if (>= total-sessions u100)
    "platinum"
    (if (>= total-sessions u50)
      "gold"
      (if (>= total-sessions u20)
        "silver"
        "bronze"
      )
    )
  )
)

