class GameConstants {
  // Game dimensions - Horizontal landscape field (reduced to fit screen better)
  static const double fieldWidth = 1000; // Wide for landscape
  static const double fieldHeight = 600; // Height for landscape
  
  // Player settings
  static const double playerSpeed = 180.0;
  static const double playerRadius = 18.0;
  
  // Team settings
  static const int playersPerTeam = 5;
  
  // AI player settings
  static const double aiPlayerSpeedBase = 120.0;
  static const double aiPlayerRadius = 18.0;
  static const double aiPlayerChaseDistance = 250.0;
  
  // Ball settings
  static const double ballRadius = 10.0;
  static const double ballSpeed = 200.0;
  
  // Goal settings - Goals on left and right sides
  static const double goalWidth = 20.0;
  static const double goalHeight = 120.0;
  static const double goalOffsetY = (fieldHeight - goalHeight) / 2; // Center vertically
  
  // Referee settings
  static const double refereeRadius = 15.0;
  static const double refereeSpeed = 100.0;
  
  // Difficulty scaling
  static const double difficultySpeedMultiplier = 1.05; // 5% increase per goal
  
  // Power-up settings
  static const double powerUpDuration = 5.0; // seconds
  static const double speedBoostMultiplier = 1.5;
  static const double powerUpSpawnChance = 0.2; // 20% chance per goal
  
  // Visual settings
  static const double lineWidth = 3.0;
  
  // Joystick settings
  static const double joystickSize = 100.0;
  static const double joystickKnobSize = 45.0;
  
  // Action buttons
  static const double actionButtonSize = 70.0;
  static const double actionButtonSpacing = 20.0;
  
  // Gameplay mechanics
  static const double shootPowerMultiplier = 2.0;
  static const double passPowerMultiplier = 1.2;
  static const double tackleDistance = 35.0;
  static const double passDistance = 150.0;
  
  // AI Intelligence
  static const double aiReactionTime = 0.15; // seconds
  static const double aiPassAccuracy = 0.85; // 85% accuracy
  static const double aiShootAccuracy = 0.75; // 75% accuracy
  static const double formationTolerance = 100.0; // Distance from home position
}

