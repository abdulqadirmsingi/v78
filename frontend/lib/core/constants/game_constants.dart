class GameConstants {
  // Game dimensions
  static const double fieldWidth = 800;
  static const double fieldHeight = 1200;
  
  // Player settings
  static const double playerSpeed = 150.0;
  static const double playerRadius = 20.0;
  
  // Defender settings
  static const int initialDefenders = 3;
  static const double defenderSpeedBase = 100.0;
  static const double defenderSpeedIncrement = 10.0; // +10px/s per goal
  static const double defenderRadius = 20.0;
  static const double defenderChaseDistance = 300.0;
  
  // Goal settings
  static const double goalWidth = 200.0;
  static const double goalHeight = 60.0;
  static const double goalY = 50.0; // Distance from top
  
  // Difficulty scaling
  static const double difficultySpeedMultiplier = 1.1; // 10% increase per goal
  static const int maxDefenders = 10;
  
  // Power-up settings
  static const double powerUpDuration = 5.0; // seconds
  static const double speedBoostMultiplier = 1.5;
  static const double powerUpSpawnChance = 0.3; // 30% chance per goal
  
  // Visual settings
  static const double lineWidth = 3.0;
  
  // Joystick settings
  static const double joystickSize = 100.0;
  static const double joystickKnobSize = 40.0;
}

