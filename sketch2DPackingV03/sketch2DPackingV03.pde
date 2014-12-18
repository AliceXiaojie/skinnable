// ********** set container file here ***************
String containerFile = "twitterBird.jpg";

Container container;
int grid = 4; //1mm = 4pixels, 1cell = 1mm
ArrayList<Module> modules; // collect all modules
ArrayList<Module> group; // collect continuous unpre-placed modules
ArrayList<Module> waitingList; // 
boolean available;


void setup(){
  container = new Container();
  size(container.width, container.height); 
  modules = new ArrayList<Module>();
  // ********** add modules here ***************
  modules.add(new Module(21,21));  // Power 
  modules.add(new Module(27,21));  // Button 
  modules.add(new Module(66,27));  // Cloud
  modules.add(new Module(20,21));  // LED
  // ********** set order ***************
  for(int i = 0; i < modules.size(); i++){
    Module module = modules.get(i);
    module.order = i;
  }
  // ********** pre-place modules ***************
  modules.get(0).placed = true; // Power module is pre-placed
  modules.get(1).placed = true; // Button module is pre-placed
  modules.get(3).placed = true; // LED module is pre-placed

} // setup end

void draw(){

  image(container.containerImg, 0, 0);
  filter(GRAY);
  filter(THRESHOLD, 0.5);
  container.effectiveArea();


  boolean allPlaced = false;
  boolean wList = false;
  boolean noNext = false;
  boolean startPlacing = false;
  group = new ArrayList<Module>();
  waitingList = new ArrayList<Module>();


    for (int i = 0; i < modules.size(); i++){ // go through each module
      startPlacing = false;
      idleNum = 0;
      Module current = modules.get(i);
      Module next = null;
      if(i < (modules.size() - 1)){
        next = modules.get(i+1);
        noNext = false;        
      }
      else noNext = true;
      

      if(!current.placed){
        group.add(current);
        idleNum += 1;
        if(noNext||(!noNext && next.placed)){
          startPlacing = true;
        }
      }

      if(startPlacing){// place modules in the group. if modules can't be placed, add them all to waitingList
        int groupWidth = 0;
        int maxHeight = 0;
        int detectX = 0;
        int detectY = 0;
        int groupStartOrder = group.get(0).order;
        int groupEndOrder = group.get(group.size()-1).order;

        for(int j=0; j < group.size(); j++){ // get the amount of width and height of this group
          Module m = group.get(j);
          groupWidth += m.width;
          if(m.height > maxHeight){
            maxHeight = m.height;
          }
        }
        if(group.get(0).order == 0){ // ********** First Situation: if this group includes the first module 
          
          detectX = modules.get(groupEndOrder+1).placeX - groupWidth * grid;
          detectY = modules.get(groupEndOrder+1).placeY;
          //detect this area
          boolean  collision = false;     
          for(int k = 0; k <= groupWidth; k++){
             for(int l = 0; l <= maxHeight; l++){
               collision = false;
               color p = get(detectX + grid * k + 2, detectY + grid * l + 2); // avoid the grid lines and get color of the cell
               if(p != color(0,0,0)){
                 collision = true;
                 break;
               } 
                 
             } //loop l ends
            if(collision == true){
               break; 
            }
            
          } //loop k ends
          if(collision == false){ // this area is available to place this group
            color gray = color(127); 
            fill(gray,200);
            noStroke();
            rect(detectX , detectY , groupWidth * grid, maxHeight * grid);  
          }
        } // First Situation End *************

        else if(group.get(group.size()-1).order == modules.size()-1){ // *********** Second Situation: if this group includes the final module         
          detectX = modules.get(groupStartOrder - 1).placeX + modules.get(groupStartOrder - 1).width * grid;
          detectY = modules.get(groupStartOrder - 1).placeY;
          for(i=0; i < groupWidth; i++){
            // ******* //detect the area
          }
        } // Second Situation End *********

        else{ // ********** Third Situation: this group doesn't include the first module nor the final module
          if(modules.get(groupStartOrder - 1).placeY == modules.get(groupEndOrder+1).placeY){
            if(modules.get(groupStartOrder - 1).placeX - modules.get(groupStartOrder - 1).placeX == groupWidth * grid){
            // it's possible to place modules without wires
            // ******* //detect the area

            }
          }
          else{
          // can't be placed without wires
          //*******//
          } 
        } // Third Situation End *****************

        group.clear(); // Removes all of the elements from this list.

      } // group placing end

    } // for end



  // place all the left modules
  if(wList){
    int q = waitingList.size();
    for (int i = 0; i<q; i++){ // go through each module
      Module m = waitingList.get(i);
      available = m.place(); 
      if(available){
        m.draw(); // place the mudule into the container 
      }
      else if(!available){
        m.rotate();
        available = m.place();
        if(available){
          m.draw(); // place the rotated mudule into the container
          // available = true; 
        }
        else if(!available) println("can't place Module"+ (i+1));
      }   
    } 
  }
  
  
} // draw end

class Container{
  // Attributor
  PImage containerImg;
  int width;
  int height;
  int num_X, num_Y;
  boolean img_loaded = false;
  int left, bottom, top, right;

  // Constructor
  Container(){
    containerImg = new PImage();
    containerImg = loadImage(containerFile);
    width = containerImg.width;
    height = containerImg.height;
  }

  // Methods
  void effectiveArea() {

    left = containerImg.width;
    right = 0;
    bottom = containerImg.height;
    top = 0;
    
    // ********* edge detection ********
    for (int x = 0; x < containerImg.width; x++) {
      for (int y = 0; y < containerImg.height; y++) {
        color c = containerImg.get(x, y);
        color new_zero = color(0, 0, 0);
        if (c <= color(220, 220, 220)) {
          containerImg.set(x, y, new_zero);
        } // set the area
        if (c == color(0, 0, 0)) {
          if (left > x) {
              left = x;
          }
          right = x;
          if (bottom > y) {
              bottom = y;
          }
          if (top < y) {
            top = y;
          }
        }
      }

    }

    num_X = int((right-left)/grid);
    num_Y = int((top - bottom)/grid);
    // ****** set grids **********  
    line(left, bottom, left, top); // left edge of grids
    stroke(255, 0, 0);
    line(left, bottom , right, bottom); // top edge of grids
    stroke(255, 0, 0);  
    for (int x = left; x <= right; x+=grid) {
      for (int y = bottom; y <= top; y+=grid) {
        line(left, y, right, y);
        stroke(255, 0, 0);
      }    
      line(x, top, x, bottom);
      stroke(255, 0, 0);
    } 


    // ******* effective area **********
    int i = left, j = bottom;
    int tainted=0;
    for (int n = 0; n <= num_X; n++) {
      for (int m = 0; m <= num_Y; m++) {
        for (i = left + grid*n; i <= left + grid * (n +1 ) - 1; i++) {
          for (j = bottom + grid * m; j <= bottom + grid * (m + 1) - 1; j++) {
            color c = containerImg.get(i, j);
            if (c == color(255, 255, 255)) {
              color gray = color(127, 127, 127);
              fill(gray,200);
              rect(left + grid * n, bottom + grid * m, grid, grid);
              tainted=1;
              break;
            }
            
          }
          if(tainted == 1){
            tainted = 0;
            break;
          }

        }
      }
    }

  } // method effectiveArea end
  
} // class Container end

class Module{
  // Attributor
  int width, height;
  int order;
  int placeX = 0 ; int placeY = 0;
  int grayscale = int(random(50,100)); // set a random grayscale
  boolean placed = false;
  

  // Constructor
  Module(int width, int height){
    this.width = width;
    this.height = height;
  }
  
  // Methods
  boolean place(){
    boolean collision = false;
    boolean breakn = false;
    boolean available = false;
    int x,y;
    
    for(int n=0; n<=container.num_X; n++){
      for(int m=0; m<=container.num_Y; m++){
            breakn = false;
            collision = false;
            color c = container.containerImg.get(container.left+grid*n+2,container.bottom+grid*m+2); // avoid the grid lines and get color of the cell
            if(c == color(0,0,0)){
              x = container.left+grid*n;
              y = container.bottom+grid*m;
              
              for(int i = 0; i <= this.width; i++){
                 for(int j = 0; j <= this.height; j++){
                   color p = get(x + grid*i +2, y + grid*j +2); // avoid the grid lines and get color of the cell
                   if(p != color(0,0,0)){
                     collision = true;
                     break;
                   } 
                     
                 } //loop j ends
                if(collision == true){
                   break; 
                }
                
              } //loop i ends
              
              if(collision == false){
                this.placeX = x;
                this.placeY = y;
                breakn = true;
                available = true;
                break;   
              }
              else available = false;
            }
            

      } //loop m ends
      if(breakn == true){
        break;
      }
    } //loop n ends
    if(available) {return true;}
    else return false;
  } // place method end

  void rotate(){
    int t;
    t = width;
    width = height;
    height = t;
  } // rotate method end
  
  void draw(){
    color gray = color(this.grayscale); 
    fill(gray,200);
    noStroke();
    rect(this.placeX , this.placeY , this.width*grid, this.height*grid); // place the mudule into the container
  }  // draw method end
} // class Module end

