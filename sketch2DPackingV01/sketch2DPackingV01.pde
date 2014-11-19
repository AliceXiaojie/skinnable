// ********** set container file here ***************
String containerFile = "irregular.jpg";

Container c1;
int grid = 15; //1mm = 4pixels, 1cell = 5mm
ArrayList<Module> modules;
boolean available;


void setup(){
  c1 = new Container();
  size(c1.width, c1.height); 
  modules = new ArrayList<Module>();
  // ********** add modules here ***************
  modules.add(new Module(6,4));  // 6grids height * 4grids width
  modules.add(new Module(5,3));
  modules.add(new Module(7,1));
  modules.add(new Module(2,3));  
} // setup end

void draw(){

  image(c1.containerImg, 0, 0);
  filter(GRAY);
  filter(THRESHOLD, 0.5);
  c1.effectiveArea();
  // modules set by user
  color g = color(127);
  fill(g,200);
  noStroke();
  rect(63,38,30,45);
  
  
  int n = modules.size();
  for (int i = 0; i<n; i++){ // go through each module
    Module m = modules.get(i);
    available = m.place(); 
    if(available){
      m.draw(); // place the mudule into the container 
    }
    else if(!available){
      m.rotate();
      available = m.place();
      if(available){
        m.draw(); // place the rotated mudule into the container
        available = true; 
      }
      else if(!available) println("can't place Module"+ (i+1));
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
  int placeX=0 ; int placeY=0;
  int r = int(random(50,100)); // set a random grayscale
  

  // Constructor
  Module(int height, int width){
    this.height = height;
    this.width = width;
  }
  
  // Methods
  boolean place(){
    boolean collision = false;
    boolean breakn = false;
    boolean available = false;
    int x,y;
    
    for(int n=0; n<=c1.num_X; n++){
      for(int m=0; m<=c1.num_Y; m++){
            breakn = false;
            collision = false;
            color c = c1.containerImg.get(c1.left+grid*n+2,c1.bottom+grid*m+2); // avoid the grid lines and get color of the cell
            if(c == color(0,0,0)){
              x = c1.left+grid*n;
              y = c1.bottom+grid*m;
              
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
    color gray = color(this.r); 
    fill(gray,200);
    noStroke();
    rect(this.placeX , this.placeY , this.width*grid, this.height*grid); // place the mudule into the container
  }  // draw method end
} // class Module end

