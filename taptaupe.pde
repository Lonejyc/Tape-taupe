import processing.serial.*;
import processing.sound.*;
import java.util.Collections;

// Final veut dire que c'est une constante, une fois que la variable est initialisée, sa valeur ne peut pas être chagée 
final int TITLE = 0;
final int GAME = 1;
final int END = 2;
final int SPECIAL_END = 3;

int gameState = TITLE; // On initialise le jeu pour qu'il affiche l'écran titre quand il se lance

SoundFile start;
SoundFile end;
SoundFile music;
SoundFile jog;
SoundFile noa;
SoundFile jul;
SoundFile tom;
SoundFile luc;
SoundFile nice;
SoundFile bad;
SoundFile egg;

Serial port;

mechante[] badtaupes = new mechante[8];

PImage easterEgg;
PImage imageTitle;
PImage imagetaupe;
PImage imageFond;
PImage imageEnd;

// Variables pour lancer une musique sans qu'une autre soit lancée 
boolean startStarted = false; 
boolean musicStarted = false;
boolean endStarted = false;

int finalScore = 0;

int rand(int min, int max) {
  return round(random(min, max + 1));
}
int StyleTaupe;

// Classe représentant les informations d'un joueur pour le top score
class PlayerScore {
  String name;
  int score;

  PlayerScore(String n, int s) {
    name = n;
    score = s;
  }
}

long specialEndTime = 0;

// Liste des meilleurs scores
ArrayList<PlayerScore> topScores = new ArrayList<PlayerScore>();

void setup() {
  fullScreen();
  port = new Serial(this, "COM5", 9600);
  port.bufferUntil('\n');
  imageTitle = loadImage("img/title_bcknd.png");
  imageFond = loadImage("img/fond.png");
  imageEnd = loadImage("img/ecranscore.png");
  
  badtaupes[0] = new mechante(200, 625, 150);//blancG
  badtaupes[1] = new mechante(425, 825, 150);//rougeG
  badtaupes[2] = new mechante(425, 425, 150);//bleuG
  badtaupes[3] = new mechante(650, 625, 150);//vertG
  badtaupes[4] = new mechante(1120, 625, 150);//vertD
  badtaupes[5] = new mechante(1345, 825, 150);//rougeD
  badtaupes[6] = new mechante(1345, 425, 150);//bleuD
  badtaupes[7] = new mechante(1570, 625, 150);//blancD
  
  music = new SoundFile(this, "son/musique_1mn30.wav");
  start = new SoundFile(this, "son/son_debut.wav");
  end = new SoundFile(this, "son/son_fin.wav");
  nice = new SoundFile(this, "son/taupe_gentille.wav");
  jog = new SoundFile(this, "son/taupe_Jogulin.wav");
  jul = new SoundFile(this, "son/taupe_Julian.wav");
  luc = new SoundFile(this, "son/taupe_Lucas.wav");
  bad = new SoundFile(this, "son/taupe_méchante.wav");
  noa = new SoundFile(this, "son/taupe_Noah.wav");
  tom = new SoundFile(this, "son/taupe_Tom.wav");
  egg = new SoundFile(this, "son/easterEgg.wav");
  
  // Ajoutez des scores de joueur fictifs pour l'exemple
  topScores.add(new PlayerScore("Tom", 2386));
  topScores.add(new PlayerScore("Noah", 2351));
  topScores.add(new PlayerScore("Lucas", 2238));
}

void draw() {
  switch (gameState) { // Switch pour changer entre les différents écrans de jeu 
    case TITLE: // Si jamais on est sur l'écran titre
      displayTitleScreen(); // On utilise la fonction pour afficher l'écran d'accueil 
      break;
    case GAME: // Si jamais on est sur le jeu
      background(imageFond); // On change l'image de fond 
      for (int i = 0; i < 8; i++) { // On initialise toutes les taupes 
        badtaupes[i].display();
      }
      
      if (!start.isPlaying() && !startStarted){ // Si jamais la musique start n'est pas en train de jouer et qu'elle n'a pas encore été jouée
        start.play(); // On joue la musique
        startStarted = true; // On dit qu'elle a été jouée  
      }
      
      if (!start.isPlaying()){ // Si jamais la musique start n'est pas jouée 
        if (!music.isPlaying() && !musicStarted){ // Si jamais la musique music n'est pas jouée et qu'elle n'a pas encore été jouée
          music.play(); // On joue la musique music
          musicStarted = true; // On dit qu'elle a été jouée
        }
        if (!end.isPlaying() && !music.isPlaying() && musicStarted && !endStarted && gameState != SPECIAL_END){ // Si la musique end n'est pas jouée et que la musique music n'est pas jouée et que la musique music a déjà été jouée et que la musique end n'a pas été jouée 
          end.play(); // On joue la musique end 
          endStarted = true; // On dit qu'elle a été jouée 
        }
      }
      break;
    case SPECIAL_END:
      background(easterEgg);
        if (!egg.isPlaying() && millis() - specialEndTime >= 5000) {
            gameState = END;
        }
        break;
    case END: // Si jamais on est sur l'écran de fin 
      displayEndScreen(); // On utilise la fonction pour afficher l'écran de fin
      break;
  }
}

void keyPressed() {
  if (gameState == TITLE && key == ' ') { // Si jamais on est sur l'écran titre et si la touche espace est pressée 
    gameState = GAME; // On passe l'état de jeu à jeu 
    // On réinitialise les variables qu'on utilise pour lancer le jeu 
    startStarted = false; 
    musicStarted = false;
    endStarted = false;
    finalScore = 0;
    // On envoie à l'arduino que le jeu est lancé pour lancer le jeu 
    port.write("START\n");
  } else if (gameState == END && key == ' ') { // Si on est sur l'écran de fin et qu'on appuie sur espace
    gameState = TITLE; // On retourne sur l'écran titre
  }
}

void displayTitleScreen() {
  background(imageTitle); // On affiche l'écran titre
}

void displayEndScreen() {
  background(imageEnd);
  fill(255);
  textSize(60);
  text(finalScore, width - 385, height / 2 + 140);

  // Triez la liste par ordre décroissant des scores
  Collections.sort(topScores, (a, b) -> b.score - a.score);

  // Affichez les trois meilleurs scores
  for (int i = 0; i < min(3, topScores.size()); i++) {
    PlayerScore ps = topScores.get(i);
    text(ps.name + ": " + ps.score, 290, height / 2 + 110 + i * 150);
  }
}

void hasard(mechante taupe) {
  float randimage = rand(1, 100);
  println(randimage);
  if (randimage >= 1 && randimage <= 80) {
    taupe.style = 1;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/badtaupe.png");
  } else if (randimage > 80 && randimage < 96) {
    taupe.style = 2;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/goodtaupe.png");
  } else if (randimage == 96) {
    taupe.style = 11;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/tomtaupe.png");
  } else if (randimage == 97) {
    taupe.style = 12;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/lucastaupe.png");
  } else if (randimage == 98) {
    taupe.style = 13;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/juliantaupe.png");    
  } else if (randimage == 99) {
    taupe.style = 14;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/noahtaupe.png");
  } else if (randimage == 100) {
    taupe.style = 15;
    StyleTaupe = taupe.style;
    imagetaupe = loadImage("img/jocelyntaupe.png");
  }
}

void badtaupeVisible(int index, int value) {
  badtaupes[index].visible = value;
}

void serialEvent(Serial port) {
  String serialStr = port.readStringUntil('\n');
  serialStr = trim(serialStr);
  
  if (serialStr.equals("SPECIAL_END")) {
        stopAllSounds();
        easterEgg = loadImage("img/specialEnd.png");
        egg.play();
        gameState = SPECIAL_END;
        specialEndTime = millis();
    }
  
  if (serialStr.equals("END")) { // Si jamais on reçoit END dans le serial 
    gameState = END; // On passe l'état du jeu à END
  }
  
 if (serialStr.startsWith("Score")) { // Si jamais le serial commence par Score
    String[] parts = split(serialStr, ',');
    if (parts.length > 1) {
      finalScore = int(parts[1]); // On récupère le score envoyé depuis l'arduino
    }
  }
  
  int values[] = int(split(serialStr, ','));
  if (values.length == 2) {
    print(values[0]);
    print(",");
    println(values[1]);

    for (int i = 2; i < 10; i++) {
      int index = i - 2;
      if (values[0] == i && values[1] == 1) {
        hasard(badtaupes[index]);
        badtaupeVisible(index, 1);
      } else if (values[0] == i && values[1] == 0) {
        badtaupeVisible(index, 0);
      } else if (values[0] == i && values[1] == 2) {
        badtaupeVisible(index, 0);
        score();
      } 
    }
  }
}

void stopAllSounds() {
    start.stop();
    music.stop();
    end.stop();
    nice.stop();
    jog.stop();
    jul.stop();
    luc.stop();
    bad.stop();
    tom.stop();
}

void score(){
  int multiplicateur;
  if (StyleTaupe==1){
    bad.play();
    multiplicateur = 1;
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if (StyleTaupe==2){
    nice.play();
    multiplicateur = -3;
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if(StyleTaupe==11){
    tom.play();
    multiplicateur = 5;  
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if(StyleTaupe==12){
    luc.play();
    multiplicateur = 5;  
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if(StyleTaupe==13){
    jul.play();
    multiplicateur = 5;  
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if(StyleTaupe==14){
    noa.play();
    multiplicateur = 5;  
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }else if(StyleTaupe==15){
    jog.play();
    multiplicateur = 5;  
    String data = str(multiplicateur) + "\n";
    port.write(data);
  }
}
