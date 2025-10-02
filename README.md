# Smart Sleep Coach

An intelligent blockchain-powered application that tracks sleep patterns and provides AI-driven suggestions for better rest. Built on the Stacks blockchain using Clarity smart contracts with advanced sleep analytics and personalized coaching features.

## Overview

Smart Sleep Coach revolutionizes personal wellness by creating a comprehensive sleep optimization platform that combines wearable device integration, advanced analytics, and AI-powered coaching recommendations. Our blockchain-based approach ensures data privacy, enables reward mechanisms, and provides transparent sleep improvement tracking.

## Key Features

### 🛌 Advanced Sleep Tracking
- Multi-source data integration (wearables, phone sensors, manual input)
- Comprehensive sleep cycle analysis with REM, deep, and light sleep tracking
- Environmental factor monitoring (temperature, noise, light levels)
- Sleep debt calculation and recovery recommendations
- Historical trend analysis with predictive insights

### 🧠 AI-Powered Coaching
- Personalized bedtime routine generation based on individual patterns
- Adaptive recommendations that learn from user behavior
- Contextual tips considering lifestyle factors and goals
- Circadian rhythm optimization strategies
- Stress and anxiety management techniques for better sleep

### 🔗 Blockchain Integration
- Secure, private sleep data storage with user ownership
- Tokenized rewards for consistent sleep improvement
- Decentralized sleep research data contribution
- Immutable sleep achievement records
- Privacy-preserving analytics and insights

## Smart Contracts Architecture

### Sleep Analyzer (`sleep-analyzer.clar`)
The core contract that processes and analyzes sleep data from multiple sources:

- **Data Collection**: Integration with wearable devices and phone sensors
- **Sleep Cycle Analysis**: Detailed breakdown of sleep stages and quality metrics
- **Pattern Recognition**: Identification of sleep trends and anomalies
- **Environmental Correlation**: Analysis of external factors affecting sleep
- **Research Contribution**: Anonymous data aggregation for sleep studies

### Sleep Coach (`sleep-coach.clar`)
Provides personalized recommendations and coaching based on analyzed data:

- **Personalized Coaching**: AI-driven bedtime routines and sleep strategies
- **Goal Setting**: Custom sleep targets with progress tracking
- **Habit Formation**: Structured programs for developing healthy sleep habits
- **Reward Systems**: Token-based incentives for sleep improvement milestones
- **Community Features**: Anonymous sleep challenges and peer comparisons

## Technical Specifications

### Blockchain Technology
- **Platform**: Stacks Blockchain
- **Smart Contract Language**: Clarity
- **Token Standard**: SIP-010 (Fungible Token Standard)
- **Privacy**: Zero-knowledge proofs for sensitive health data

### Data Architecture
- Sleep session records with comprehensive metrics
- User profiles with preferences and goals
- Environmental data correlation with sleep quality
- ML model training data (anonymized and aggregated)
- Achievement and milestone tracking systems

### Integration Capabilities
- **Wearable Devices**: Fitbit, Apple Watch, Garmin, Oura Ring
- **Smart Home**: Philips Hue, Nest, smart thermostats
- **Health Platforms**: Apple Health, Google Fit, Samsung Health
- **Sleep Apps**: Sleep Cycle, Calm, Headspace integration

## Installation & Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Git](https://git-scm.com/)

### Setup Instructions
```bash
# Clone the repository
git clone https://github.com/jokzyagz/smart-sleep-coach.git
cd smart-sleep-coach

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
clarinet test
```

## Usage Examples

### Recording Sleep Data
```clarity
;; Record a sleep session with comprehensive data
(contract-call? .sleep-analyzer record-sleep-session 
  u480  ;; 8 hours in minutes
  u85   ;; sleep quality score
  u120  ;; REM sleep minutes
  u180  ;; Deep sleep minutes
  u180  ;; Light sleep minutes
)
```

### Getting Personalized Recommendations
```clarity
;; Request coaching recommendations based on recent patterns
(contract-call? .sleep-coach generate-recommendations tx-sender)

;; Set a new sleep goal
(contract-call? .sleep-coach set-sleep-goal u480 u90) ;; 8 hours, 90% quality
```

### Claiming Rewards
```clarity
;; Claim tokens for achieving sleep consistency
(contract-call? .sleep-coach claim-consistency-reward)
```

## Sleep Metrics & Analytics

### Core Sleep Metrics
- **Total Sleep Time**: Duration of actual sleep
- **Sleep Efficiency**: Percentage of time in bed actually sleeping
- **Sleep Latency**: Time taken to fall asleep
- **Wake After Sleep Onset (WASO)**: Time awake during sleep period
- **Sleep Debt**: Cumulative deficit from optimal sleep duration

### Advanced Analytics
- **Circadian Rhythm Analysis**: Natural sleep-wake cycle optimization
- **Heart Rate Variability**: Sleep quality indicator from wearable data
- **Movement Patterns**: Restlessness and sleep disruption tracking
- **Environmental Impact**: Temperature, noise, and light correlation
- **Lifestyle Factors**: Exercise, caffeine, and meal timing effects

## AI Coaching Features

### Personalized Recommendations
- **Optimal Bedtime Calculation**: Based on wake time and sleep requirements
- **Environmental Optimization**: Room temperature, lighting, and noise suggestions
- **Pre-sleep Routines**: Customized activities to improve sleep onset
- **Nutrition Timing**: Meal and caffeine recommendations for better sleep
- **Exercise Scheduling**: Workout timing optimization for sleep quality

### Behavioral Insights
- **Sleep Pattern Recognition**: Identification of personal sleep trends
- **Trigger Analysis**: Factors that positively or negatively impact sleep
- **Habit Recommendations**: Evidence-based suggestions for sleep improvement
- **Progress Tracking**: Visual representation of sleep improvement over time
- **Goal Adjustment**: Dynamic modification of targets based on progress

## Roadmap

### Phase 1: Core Platform ✅
- Basic sleep tracking and analysis
- Simple coaching recommendations
- Blockchain-based data storage and privacy

### Phase 2: Advanced AI (Q1 2025)
- Machine learning model for personalized insights
- Predictive analytics for sleep quality
- Advanced environmental factor analysis

### Phase 3: Ecosystem Integration (Q2 2025)
- Comprehensive wearable device support
- Smart home automation integration
- Collaborative sleep research platform

### Phase 4: Community & Research (Q3 2025)
- Anonymous sleep study participation
- Community challenges and competitions
- Professional sleep consultant connections

## Privacy & Security

### Data Protection
- **Encryption**: All sleep data encrypted before blockchain storage
- **User Ownership**: Users maintain complete control over their data
- **Anonymization**: Research contributions use zero-knowledge proofs
- **Access Control**: Granular permissions for data sharing

### Blockchain Security
- **Smart Contract Audits**: Regular security reviews and updates
- **Immutable Records**: Sleep achievements and progress permanently recorded
- **Decentralized Storage**: No single point of failure for data
- **Privacy by Design**: Minimal data exposure with maximum utility

## Research Contributions

### Sleep Science Advancement
- **Anonymous Data Aggregation**: Contributing to global sleep research
- **Pattern Discovery**: Large-scale sleep trend identification
- **Intervention Effectiveness**: Tracking success rates of different strategies
- **Population Health**: Understanding sleep patterns across demographics

### Academic Partnerships
- Sleep research institutions collaboration
- Clinical study participation opportunities
- Medical professional consultation features
- Evidence-based recommendation validation

## Contributing

We welcome contributions from sleep researchers, developers, and wellness enthusiasts!

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Implement your changes with comprehensive tests
4. Ensure all contracts pass `clarinet check`
5. Submit a pull request with detailed description

### Research Contributions
- Sleep pattern analysis algorithms
- Environmental factor correlation studies
- Coaching recommendation improvements
- Privacy-preserving analytics methods

## Testing

The project includes comprehensive test suites for all smart contracts:

```bash
# Run all tests
clarinet test

# Run specific contract tests
clarinet test tests/sleep-analyzer_test.ts
clarinet test tests/sleep-coach_test.ts
```

## API Integration

### REST API Endpoints
```bash
# Sleep data management
GET /api/sleep/sessions - Retrieve sleep history
POST /api/sleep/sessions - Record new sleep session
GET /api/sleep/analytics - Get sleep pattern analysis

# Coaching system
GET /api/coaching/recommendations - Get personalized tips
POST /api/coaching/goals - Set sleep goals
GET /api/coaching/progress - Track improvement
```

### WebSocket Events
```javascript
// Real-time sleep tracking
socket.on('sleep:started', (sessionData) => {
  // Handle sleep session start
});

socket.on('recommendations:updated', (tips) => {
  // Handle new coaching suggestions
});
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please join our [Discord community](https://discord.gg/smart-sleep-coach) or create an issue on GitHub.

## Acknowledgments

- Built with [Clarinet](https://github.com/hirosystems/clarinet)
- Powered by [Stacks Blockchain](https://stacks.co)
- Sleep research collaboration with leading sleep institutes
- AI recommendations based on peer-reviewed sleep science

---

*Sweet dreams and better sleep through blockchain innovation! 😴✨*