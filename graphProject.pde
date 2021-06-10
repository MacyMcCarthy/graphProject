import java.util.*;
import static java.lang.Math.round;


Table table;
String[] genreNames = {"Party", "RPG", "Sandbox", "Pokemon", "Puzzle", "Action Adventure", "Shooter", "Platformer"};
color[] colors = {#e87dc6, #b78acf, #7a78cc, #83c9c9, #3eb875, #afd160, #c49647, #de8273};
Genre[] genres = new Genre[genreNames.length];
int allGames;
int allHours = 0;
int mode = 0; // 0 = no choice, 1 = ratios, 2 = relative ratios
PFont font;
int hitboxes[][] = {{50, 35, 120, 30}, {170, 35, 120, 30}};
PImage[] images;
int maxHours;

void setup(){
  size(1250, 800);
  background(#ffffff);
  stroke(#000000);
  fill(#000000);
  
  PImage party = loadImage("party.png");
  PImage rpg = loadImage("rpg.png");
  PImage sandbox = loadImage("sandbox.png");
  PImage pokemon = loadImage("pokemon.png");
  PImage puzzle = loadImage("puzzle.png");
  PImage actionAdventure = loadImage("action adventure.png");
  PImage shooter = loadImage("shooter.png");
  PImage platformer = loadImage("platformer.png");
  
  images = new PImage[]{party, rpg, sandbox, pokemon, puzzle, actionAdventure, shooter, platformer};
  
  
  font = createFont("bahnschrift.ttf", 1);

  
  //loads spreadsheet
  table = loadTable("spreadsheet.csv", "header");
  
  //creates genre lists
  for(int i = 0; i < genreNames.length; i++){
    genres[i] = new Genre(genreNames[i]);
  }
 
  //separates games into objects
  for(TableRow row : table.rows()){
    String name = row.getString("game");
    String genre = row.getString("genre");
    int hours = row.getInt("hours");
    allHours+= hours;
    allGames++;
    
    
    // makes game object inside genre object that matches
    for(int i = 0; i < genres.length; i++){ 
     if(genre.equals(genres[i].getGenre())){
        genres[i].addGame(new Game(name, hours));
        break;
     } 
    }
 }
 
 calculations(allHours, genres);
 
}

void calculations(int allHours, Genre[] genres){ //calculates what percentage each genre accounts for

  for(int i = 0; i < genres.length; i++){
    genres[i].setRatio(float(genres[i].getHours())/float(allHours)); //determines what percentage of time each genre takes up
  }
  Genre max = genres[0]; //genre that takes up the most hours
  for(int i = 1; i < genres.length-1; i++){
    if(genres[i].getHours() > max.getHours()){
      max = genres[i];
      maxHours = genres[i].getHours();
    }
    
  }
  
  for(int i = 0; i < genres.length; i++){ //sets the ratios relative to the most hours played
    if(max != genres[i]){
     genres[i].setRelativeRatio(float(genres[i].getHours())/float(max.getHours()));
    }
  }
  
  
  
}



void draw(){
  clear();
  background(#ffffff);
  baseBoard();
  drawDotted(mode);
  placeHeader();
  drawButton(mode, hitboxes);
  ArrayList<int[]> barBoxes = makeLines();
  drawBoxes(barBoxes);
  displayHud(barBoxes);
}

void displayHud(ArrayList<int[]> boxes){
  boolean inBox;
  
  for(int i = 0; i < boxes.size(); i++){
    inBox = inBox(boxes.get(i));
    if(inBox){
      drawHud(i);
    }
  }
}

boolean inBox(int[] box){ //detects if the cursor is inside a button when clicked
  if((mouseX > box[0] && mouseX < box[0]+ box[2]) && ( mouseY < box[1] && mouseY > box[1]+ box[3])) return true;
  return false;
}


void drawHud(int i){ //being called recursively from displayHud. Sorts out some calculations and finds the location to put everything
  String genre = genres[i].getGenre();
  if(genre.equals("Action Adventure")){genre = "Action Ad.";}
  int hours = genres[i].getHours();
  String top3s = "";
  int percentage;
  if(mode == 1) percentage = int(round(genres[i].getRatio()*100));
  else{percentage = int(round(genres[i].getRelativeRatio()*100));}
  
  Game[] top3 = genres[i].getTop3(); //gets the top 3 games from a specific genre.
  for(Game game: top3){
   top3s+=game.getGame()+": " + game.getHours() + " Hours\n";
  }
  
  stroke(#9fa4e0);
  strokeWeight(15);
  fill(#ffffff);
  int w = 350; int h = 200;
  int modx = 1; int mody = 1;
  if(mouseX+w > width){
    modx = -1;
  }
  if(mouseY+h > height){
    mody = -1;
  }
  
  rect(mouseX, mouseY, w*modx, h*mody);
  strokeWeight(5);
  fill(#9fa4e0);
  textSize(20);
  String textFin = genre + "- " + " Hours: " + hours + " | " + percentage + "%";
  
  //determines where to place the text
  if(modx == -1 && mody == 1){
    image(images[i], mouseX-75, mouseY+5);
    text(textFin, mouseX-w+12, mouseY+30);
    text(top3s, mouseX-w+12, mouseY+95);
  }
  else if(modx == -1 && mody == -1){
    image(images[i], mouseX-75, mouseY-h+5);
    text(textFin, mouseX-w+12, mouseY-h+30);
    text(top3s, mouseX-w+12, mouseY-90);
  }
  else if(modx == 1 && mody == 1){
    image(images[i], mouseX+5, mouseY+5);
    text(textFin, mouseX+80, mouseY+30);
    text(top3s, mouseX+9, mouseY+95);
  }
  else if(modx == 1 && mody == -1){
    image(images[i], mouseX+5, mouseY-h+5);
    text(textFin, mouseX+80, mouseY-h+30);
    text(top3s, mouseX+9, mouseY-90);
  }
  
  
}


void drawBoxes(ArrayList<int[]> barBoxes){
 if(mode != 0){
   strokeWeight(2);
   for(int i = 0; i < genres.length; i++){
     fill(colors[i]);
     rect(barBoxes.get(i)[0], barBoxes.get(i)[1], barBoxes.get(i)[2], barBoxes.get(i)[3]);
   }
 }
}

ArrayList<int[]> makeLines(){ 
  int barLen = width/genres.length*7/8;
  int over = 63;
  int fullHeight = height-50 - 125;
  ArrayList<int[]> boxes = new ArrayList<int[]>();
  
  switch(mode){
    case 0:
      break;
    case 1:
      
      for(int i = 0; i < genres.length; i++){ //setting the size of the rectangle bars
        int[] box = {over+barLen/8, height-50, barLen*7/8, int(-fullHeight*genres[i].getRatio())};
        boxes.add(box);
        over+=barLen;     
        
      }
      break;
      
      case 2:
      for(int i = 0; i < genres.length; i++){
        int[] box = {over+barLen/8, height-50, barLen*7/8, int(-fullHeight*genres[i].getRelativeRatio())};
        boxes.add(box);   
        over+=barLen; 
      }
      break;
  }
  return(boxes);
}

void drawDotted(int mode){
  stroke(#9fa4e0);
  strokeCap(ROUND);
  strokeWeight(5);
  for(int i = 75; i < width-100; i+=50){
    line(i, 125, i+25, 125);
  }  
  fill(#000000);
  textSize(20);
  if(mode == 1) text(allHours + " Hours", 75, 120);
  if(mode == 2) text(maxHours + " Hours", 75, 120);
}


void mouseClicked(){ //changes the presentation mode
  
  if((mouseX > hitboxes[0][0] && mouseX < hitboxes[0][0]+hitboxes[0][2]) && (mouseY > hitboxes[0][1] && mouseY < hitboxes[0][1]+hitboxes[0][3])){
    mode = 1;
  }
  else if((mouseX > hitboxes[1][0] && mouseX < hitboxes[1][0]+hitboxes[0][2]) && (mouseY > hitboxes[1][1] && mouseY < hitboxes[1][1]+hitboxes[1][3])){
    mode = 2;
  } 
}

void drawButton(int mode, int[][] hitboxes){
  color col1 = (#515257);
  color col2 = (#515257);
  switch(mode){
   case 0:
     fill(#000000);
     textSize(45);
     text("SELECT A MODE.\nTotal Shows hours based on total percentage\nRelative shows hours relative to the largest amount", 75, 300);
     break;
   case 1:
     col1 = (#408577);
     col2 = (#b36a68);
     break;
     
   case 2:
     col2 = (#408577);
     col1 = (#b36a68);
     break;
  }
  
  fill(col1);
  rect(hitboxes[0][0], hitboxes[0][1], hitboxes[0][2], hitboxes[0][3]);
  fill(col2);
  rect(hitboxes[1][0], hitboxes[1][1], hitboxes[1][2], hitboxes[1][3]);
  
  textSize(30);
  fill(#ffffff);
  text("Total", 75, 60);
  text("Relative", 180, 60);
  
  
}

void baseBoard(){
  stroke(#9fa4e0);
  strokeWeight(7);
  noFill();
  rect(25, 25, width-50, height-50, 5);
  strokeWeight(3);
  line(25, 75, width-25, 75);
  strokeWeight(3);
  rect(50, 100, width-100, height-150, 5);
  fill(#ffffff);
  rect(890, 25, 310, 75, 5);
 //size(1250, 800);
}

void placeHeader(){
 textFont(font);
 textSize(15);
 fill(#000000);
 String header = "Macy McCarthy";
 header+= "\nTotal Games sampled: " + allGames;
 header += "\nTotal Hours Played:  " + allHours;
 text(header, width-350, 45);
 
 text("H\nO\nU\nR\nS\n \nP\nL\nA\nY\nE\nD\n", 32, 115);
 text("GAMES SORTED BY GENRE", width-300, height-29);
 
}



//CLASSES

//classs for each game containing its name and the hours played.
class Game{
  String game;
  int hours;
  
  Game(String game, int hours){
   this.game = game;
   this. hours = hours;
  }
  
  //Getters and toString
  String getGame(){return(game);}
  int getHours(){return(hours);}
 
  String toString(){return(game+ " " + hours);}
}

// Class for genre-- each genre stores all the game in the genre
class Genre{
  String genre;
  int count = 0;
  int hours = 0;
  int cap = 0;
  float ratio = 0.0;
  float relativeRatio = 1.0;
  ArrayList<Game> inGenre = new ArrayList<Game>();
  
 Genre(String genre){
   this.genre = genre;
 }
 
 void addGame(Game game){
   if(inGenre.size() == 0){ //adds a game to empty arraylist
     inGenre.add(game); 
     cap++;
   }
   else{ //compares value of arraylist with current game to append in correct location
     boolean added = false;
     for(int i = 0; i < cap; i++){
       if(game.getHours() >= inGenre.get(i).getHours()){
         inGenre.add(i, game);
         cap++;
         added = true;
         break;
         
       }
     }
     if(added == false){ //if the game doesn't have more hours than any other game, it goes on the end
       inGenre.add(game);
       cap++;
       
     }
   count++;
   } 
   hours+= game.getHours();
 }
 
 //getters setters and toString
 String getGenre(){return(genre);}
 int getHours(){return(hours);}
 float getRatio(){return(ratio);}
 float getRelativeRatio(){return(relativeRatio);}
 
 Game[] getTop3(){
   if(inGenre.size() < 3){
     Game[] top3 = new Game[inGenre.size()];
     for(int i = 0; i < inGenre.size(); i++){
       top3[i] = inGenre.get(i);
     }
     return(top3);
   }
   else{
     Game[] top3 = new Game[3];
     for(int i = 0; i < 3; i++){
       top3[i] = inGenre.get(i);
     }
     return(top3);
   }
   
 }
 
 void setRatio(float ratio){
   this.ratio = ratio;
 }
 void setRelativeRatio(float relativeRatio){
  this.relativeRatio = relativeRatio; 
 }
 
 String toString(){
   String str = "(" + genre + ": \n";
   for(int i = 0; i < inGenre.size(); i++){
     str+=(inGenre.get(i).toString() + ", \n");
   }
   str+=(")\nhours total: " + hours + "\nratio: " + ratio + "\nrelative ratio: " + relativeRatio + "\n\n\n");
   return(str); 
 }
}
