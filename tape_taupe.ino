// Déclarations et initialisations
const int buzzerCount = 8; // Déclarations des constantes pour le nombre de buzzers
const int buzzer[buzzerCount] = {2, 3, 4, 5, 6, 7, 8, 9}; // Initialisations des LEDs des buzzers
const int button[buzzerCount] = {11, 12, 13, A0, A1, A2, A3, A4}; // Initialisations des bouttons des buzzers
int multvalue = 1;

bool buzzerPressed[buzzerCount] = {false, false, false, false, false, false, false, false};
unsigned long buzzerPressTime[buzzerCount] = {0, 0, 0, 0, 0, 0, 0, 0};

unsigned long startTime;
const unsigned long gameDuration = 90000; // Déclarations de la constante pour la durée du jeu
int score = 0; // Déclarations de la variable pour stocker le score du joueur.

enum GameState { WAITING, PLAYING, FINISHED }; // On défini les différents stade pour le code
GameState gameState = WAITING; // Au début on attend que le jeu ce lance

bool startGame = false; // Variable pour voir si le jeux est en cours ou non

// Configuration initiale dans la fonction setup()
void setup() {
  // Configuration des broches des buzzers et des boutons
  for (int i = 0; i < buzzerCount; i++) {
    pinMode(buzzer[i], OUTPUT);
    pinMode(button[i], INPUT_PULLUP);
    digitalWrite(buzzer[i], LOW);
  }
  // Initialisation de la communication avec le port, de l'aléatoire et du chronomètre
  Serial.begin(9600);
  randomSeed(analogRead(0));
  startTime = millis();
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    if (command == "START") { // Si on reçoit START dans le serial
      startGame = true; // On passe la variable de jeu à true 
      gameState = PLAYING; // On met le stade du jeu à PLAYING
      score = 0; // On réinitialise la variable de score si jamais le jeu est relancé 
    }
  }

  if(gameState == PLAYING){ // Si le stade de jeu est à PLAYING on lance le jeu
    // Compte à rebours lumineux avant le début du jeu
    delay(234);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], HIGH); // Allume toutes les LEDs
    }
    delay(420);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], LOW); // Éteins toutes les LEDs
    }
    delay(520);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], HIGH); // Allume toutes les LEDs
    }
    delay(420);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], LOW); // Éteins toutes les LEDs
    }
    delay(520);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], HIGH); // Allume toutes les LEDs
    }
    delay(420);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], LOW); // Éteins toutes les LEDs
    }
    delay(520);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], HIGH); // Allume toutes les LEDs
    }
    delay(984);
    for (int j = 0; j < buzzerCount; j++) {
      digitalWrite(buzzer[j], LOW); // Éteins toutes les LEDs
    }
    delay(1285);
  
    startTime = millis(); // Lancement du chronomètre du jeu
  
    // Sélection aléatoire des buzzers et gestion de la réaction du joueur
    while (millis() - startTime < gameDuration) {
      int randomBuzzer = random(0, buzzerCount);
      int randomTime = random(800, 3000);
  
      digitalWrite(buzzer[randomBuzzer], HIGH);
      //Serial.print("Led n°");
      Serial.print(buzzer[randomBuzzer]);
      Serial.print(",");
      //Serial.print("Etat:");
      Serial.println(digitalRead(buzzer[randomBuzzer]));
  
      // Initialisations des variables utiles pour les calculs
      unsigned long tapStartTime = millis();
      unsigned long buttonPressTime = 0;
      bool buttonPressed = false;
  
      // Temps de réaction limité à 800ms
      while (millis() - tapStartTime < 800) {
        if (digitalRead(button[randomBuzzer]) == LOW) {
          buttonPressed = true;
          digitalWrite(buzzer[randomBuzzer], LOW);
          buttonPressTime = millis(); // Enregistre le moment où le bouton a été pressé
          //Serial.print("Led n°");
          Serial.print(buzzer[randomBuzzer]);
          Serial.print(",");
          //Serial.print("Etat:");
          Serial.println(2);
          break;
        }
      }
  
      if (buttonPressed) {
        // Si des données sont disponibles sur le port série
        if (Serial.available() > 0) {
          // Lis les données jusqu'à la fin de la ligne
          multvalue = Serial.parseInt();
          Serial.println(multvalue);
        }
        // Calcul du temps de réaction et mise à jour du score
        unsigned long reactionTime = buttonPressTime - tapStartTime; // Calcul du temps de réaction
        score += map(reactionTime, 0, 800, 100, 0)*multvalue; // Ajout du score en fonction du temps de réaction
        // Affichage du score dans la console série pour Processing
        Serial.print("Score : ");
        Serial.println(score);
        delay(random(500, 1000)); // Attendre un temps aléatoire avant d'allumer un nouveau buzzer
      } else {
        // Si le bouton n'est pas pressé, éteins le buzzer actuel et attend un temps aléatoire
        digitalWrite(buzzer[randomBuzzer], LOW);
        // Numero du buzzer
        Serial.print(buzzer[randomBuzzer]);
        Serial.print(",");
        // Etat de LED (soit allumer 1 ou éteins 0)
        Serial.println(digitalRead(buzzer[randomBuzzer]));
        delay(random(800, 2000));
      }
      
      bool allPressed = true;
      bool anyPressedTooLong = false;
      unsigned long currentTime = millis();
  
      for (int i = 0; i < buzzerCount; i++) {
          if (digitalRead(button[i]) == LOW) { // Si le bouton est appuyé
              if (!buzzerPressed[i]) {
                  buzzerPressed[i] = true;
                  buzzerPressTime[i] = currentTime; // Enregistrer le temps de pression
              } else if (currentTime - buzzerPressTime[i] > 3000) { // Vérifier si appuyé trop longtemps
                  anyPressedTooLong = true;
              }
          } else {
              allPressed = false;
              buzzerPressed[i] = false;
          }
      }
  
      if (allPressed || anyPressedTooLong) {
          gameState = FINISHED; // Passer à l'état FINISHED
          Serial.println("SPECIAL_END"); // Envoyer un signal spécial à Processing
          break;
      }
    }

  
    // Affichage du score final et signalisation de la fin du jeu
    Serial.print("Temps écoulé ! Score final : ");
    Serial.println(score);
  
    if (millis() - startTime >= gameDuration) { // Si le temps de jeu est écoulé on lance la fin du jeu
      // Signalisation de la fin du jeu en alternant l'allumage et l'extinction des buzzers
      delay(700);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(734);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(177);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(850);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(111);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(900);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(125);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(1500);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(112);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(925);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(15);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], HIGH);
      }
      delay(815);
      for (int j = 0; j < buzzerCount; j++) {
        digitalWrite(buzzer[j], LOW);
      }
      delay(30);
      gameState = FINISHED; // On passe le stade du jeu à FINISHED
      Serial.println("END"); // On signale au processing que le jeu est fini
      Serial.print("Score"); // On envoie le score à processing pour qu'il puisse l'afficher
      Serial.print(",");
      Serial.println(score);
      startGame = false; // On dit que la partie est finie 
    }

  } else if (gameState == FINISHED){ 
    // Si jamais on veut faire clignoter les LEDs une fois que le jeu est terminé on peut le faire ici 
  }
}
