import org.jgrapht.UndirectedGraph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.DepthFirstIterator;
import org.jgrapht.traverse.GraphIterator;
import java.util.Iterator;
import java.util.*;
import java.io.BufferedWriter;
import java.io.FileWriter;

UndirectedGraph<String, Wire> graph;
Set<Wire> all = new HashSet<Wire>();
Set<Wire> defaultEdges = new HashSet<Wire>();
Wire[] edgeList;
Wire[] edges;
Wire[] branch;
int v = 1; // graph_*
HashMap<String,Module> modules;
HashMap<String,ArrayList<Module>> solutions = new HashMap<String,ArrayList<Module>>(); 
ArrayList<Module> chunks;
int optimalWireNum;
// ********** set container file here ***************
String containerFile = "twitterBird.jpg";

Container container;
int grid = 4; //1mm = 4pixels, 1cell = 1mm




void setup()
{
    container = new Container();
    size(container.width, container.height);
    image(container.containerImg, 0, 0);
    filter(GRAY);
    filter(THRESHOLD, 0.5);
    container.effectiveArea();

    // ********** Module Library ***************
    modules = new HashMap<String,Module>(); 
    addModule(modules, "Power", "Power", 21, 21);
    addModule(modules, "Button", "Button", 27, 21);
    addModule(modules, "Cloud", "Cloud", 66, 27);
    addModule(modules, "LED", "LED", 20, 21);
    addModule(modules, "Wire","Wire", 14, 21);

    // ********** set fixed modules *************** 
    modules.get("Power").setXY(true,130,390); // Power module is fixed
    modules.get("Button").setXY(true,380,290); // Button module is fixed
    modules.get("LED").setXY(true,510,200);  // LED module is fixed



    graph = new SimpleGraph<String, Wire>(Wire.class);
    // *********** Add Vertexs Here ***********
    graph.addVertex("Power");
    graph.addVertex("Button");
    graph.addVertex("Cloud");
    graph.addVertex("LED");
    // *********** Add Edges Here ***********
    graph.addEdge("Power", "Button", new Wire<String>("Power","Button", ""));
    graph.addEdge("Button", "Cloud", new Wire<String>("Button","Cloud", ""));
    graph.addEdge("Cloud", "LED", new Wire<String>("Cloud","LED", ""));
    
    defaultEdges = graph.edgeSet();
    optimalWireNum = defaultEdges.size();
    for(int k = 0; k <= defaultEdges.size(); k++) // graph traversal
    {
      edgeList = defaultEdges.toArray(new Wire[defaultEdges.size()]);
      branch = new Wire[k];
      combine(edgeList, k, 0, branch, 0, edgeList);
    }




} //setup end


void draw()
{
  if(solutions.size() > 0){
    for(Module chunk : solutions.get(optimalWireNum)){
      chunk.drawModule();
    }
  }
  else{println("the modules cannot be placed in this container");}
} // draw end

void exportGraph()
{
    try
    {
      DOTExporter exporter = new DOTExporter(
        new VertexNameProvider(){public String getVertexName(Object object){return object.toString();}},
        null, null);
      File ff = new File(dataPath("/tmp/graph_" + v + ".dot"));
      v++;
      if(!ff.exists())
        ff.createNewFile();
      exporter.export(new PrintWriter(new BufferedWriter(new FileWriter(ff, false))), graph);
    }
    catch(Exception e)
    {
      e.printStackTrace();
    }
}


void resetEdges(Wire[] eList)
{
  for(int n = 0; n < eList.length; n++)
  {
    String s = graph.getEdgeSource(eList[n]); // get source vertex of e
    String t = graph.getEdgeTarget(eList[n]); // get target vertex of e
    graph.addEdge(s,t);
  }
}


void combine(Wire[] arr, int k, int startId, Wire[] branch, int numElem, Wire[] eList)
{
    if (numElem == k)
    {
      resetEdges(eList);

      for(int n = 0; n < branch.length; n++)
      {
        String s = graph.getEdgeSource(branch[n]);
        String t = graph.getEdgeTarget(branch[n]);
        graph.removeEdge(s,t);
        Wire<String> e = new Wire<String>(s,t, "removed");
        graph.addEdge(s,t, e);
        println("Wire between "+ e.getSource() + " and " + e.getTarget() + " is " + e.toString());
      }
      
      exportGraph();

      // ************** physical placement ***************
      edges = graph.edgeSet().toArray(new Wire[graph.edgeSet().size()]);
      int wireNum = graph.edgeSet().size();
      int wireWidth = modules.get("Wire").width;
      int wireHeight = modules.get("Wire").height;
      chunks = new ArrayList<Module>(); 
      Module s,t;
      Wire current = null;
      Wire next = null;

      for(int e = 0; e < edges.length; e++){
        current = edges[e];
        if(e < edges.length - 1){next = edges[e + 1];}  

        // ******* 1.If current edge & next edge are unlabeled *********
        if(current.toString().equals("")){ 
          if(next != null && next.toString().equals("")){
            s = modules.get(graph.getEdgeSource(current));
            t = modules.get(graph.getEdgeTarget(current));
            if(e == 0){
              if(s.fixed){ // add wire right
                if(areaDetect(s.placeX + s.width, s.placeY, wireWidth, wireHeight)){
                  s.width += wireWidth;
                }
                else break;
              }
              else if(!s.fixed){
                s.width += wireWidth;
                chunks.add(s);
              }
            }
            if(t.fixed){ // add wire left
              if(areaDetect(t.placeX - wireWidth, t.placeY, t.width + 2 * wireWidth, wireHeight)){
                t.width += 2 * wireWidth;
                t.placeX -= wireWidth;
              }
              else break;
            }
            else{
              t.width += 2 * wireWidth;
              chunks.add(t);
            }
             
          }
        }       

        // ******* 2.if current edge is unlabeled & next edge is labeled *********
        else if(current.toString().equals("")){ 
          if(next != null && next.toString().equals("")){
            s = modules.get(graph.getEdgeSource(current));
            t = modules.get(graph.getEdgeTarget(current));
            if(e == 0){
              if(s.fixed){ // add wire right
                if(areaDetect(s.placeX + s.width, s.placeY, wireWidth, wireHeight)){
                  s.width += wireWidth;
                }
                else break;
              }
              else if(!s.fixed){
                s.width += wireWidth;
                chunks.add(s);
              }
            }
            if(t.fixed){ // add wire left
              if(areaDetect(t.placeX - wireWidth, t.placeY, wireWidth, wireHeight)){
                t.width += wireWidth;
                t.placeX -= wireWidth;
              }
              else break;
            }
            else{
              t.width += wireWidth;
              chunks.add(t);
            }
             
          }
        }

        // ******* 3.if current edge is labeled & next edge is unlabeled *********
        else if(current.toString().equals("removed")){ 
          if(next != null && next.toString().equals("")){
            s = modules.get(graph.getEdgeSource(current));
            t = modules.get(graph.getEdgeTarget(current));
            
            if(e == 0){
              if(!s.fixed){
                chunks.add(s);
              }
            }

            if(s.fixed && t.fixed){
              if(s.placeY != t.placeY){ break; }
              else{
                if((t.placeX - s.placeX) != s.width){ break; }
                else{
                  if(areaDetect(t.placeX + t.width, t.placeY, wireWidth, wireHeight)){
                    t.width += wireWidth;
                  }
                  else break;
                }
              }
            }
            else if(s.fixed){
              t.fixed = true;
              if(areaDetect(s.placeX + s.width, s.placeY, t.width + wireWidth, t.height)){
                t.width += wireWidth;
                t.placeX = (s.placeX + s.width);
                t.placeY = s.placeY;
              }
              else break;
            }
            else if(t.fixed){
              if(areaDetect(t.placeX - chunks.get(chunks.size()-1).width, t.placeY, chunks.get(chunks.size()-1).width, t.height)){
                t.width += wireWidth;
                chunks.get(chunks.size()-1).fixed = true;
                chunks.get(chunks.size()-1).placeX = (t.placeX - chunks.get(chunks.size()-1).width);
                chunks.get(chunks.size()-1).placeY = t.placeY;
              }
              else break;
            }
            else{
              chunks.get(chunks.size()-1).width += (t.width + wireWidth);
              chunks.get(chunks.size()-1).name = chunks.get(chunks.size()-1).name.concat("&" + t.name);
            }
          }
        }

        // ******* 4.if current edge is labeled & next edge is unlabeled *********
        else if(current.toString().equals("removed")){  
          if(next != null && next.toString().equals("removed")){
            s = modules.get(graph.getEdgeSource(current));
            t = modules.get(graph.getEdgeTarget(current));
            if(e == 0){
              if(!s.fixed){
                chunks.add(s);
              }
            }

            if(s.fixed && t.fixed){
              if(s.placeY != t.placeY){ break; }
              else{
                if((t.placeX - s.placeX) != s.width){ break; }
                else{
                  if(areaDetect(t.placeX + t.width, t.placeY, wireWidth, wireHeight)){
                    t.width += wireWidth;
                  }
                  else break;
                }
              }
            }
            else if(s.fixed){
              t.fixed = true;
              if(areaDetect(s.placeX + s.width, s.placeY, t.width, t.height)){
                t.placeX = (s.placeX + s.width);
                t.placeY = s.placeY;
              }
              else break;
            }
            else if(t.fixed){
              if(areaDetect(t.placeX - chunks.get(chunks.size()-1).width, t.placeY, chunks.get(chunks.size()-1).width, t.height)){
                chunks.get(chunks.size()-1).fixed = true;
                chunks.get(chunks.size()-1).placeX = (t.placeX - chunks.get(chunks.size()-1).width);
                chunks.get(chunks.size()-1).placeY = t.placeY;
              }
              else break;
            }
            else{
              chunks.get(chunks.size()-1).width += t.width;
              chunks.get(chunks.size()-1).name = chunks.get(chunks.size()-1).name.concat("&" + t.name);
            }
          }

        }

      }

      if(placeChunks(chunks)){addChunks(solutions,"" + wireNum, chunks);} // if all chuncks can be placed in the container, save the solution

      if(wireNum < optimalWireNum){optimalWireNum = wireNum;}
             

      resetEdges(eList);
      return;
    }

    for (int i = startId; i < arr.length; ++i)
    {
      branch[numElem++] = arr[i];
      combine(arr, k, ++startId, branch, numElem, eList);
      --numElem;
    }
}

class Wire<V> extends DefaultEdge
{
  V s;
  V t;
  String label;

  Wire(V s, V t, String label)
  {
    this.s = s;
    this.t = t;
    this.label = label;
  }

  V getSource()
  {
    return s;
  }

  V getTarget()
  {
    return t;
  }

  public String toString()
  {
    return label;
  }

};

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
  String name;
  int order;
  int placeX = 0 ; int placeY = 0;
  int grayscale = int(random(50,100)); // set a random grayscale
  boolean fixed = false;
  

  // Constructor
  Module(String name, int width, int height){
    this.name = name;
    this.width = width;
    this.height = height;
  }
  
  // Methods
  String getName(){
    return name;
  }

  void setXY(boolean fixed, int placeX, int placeY){
    this.fixed = fixed;
    this.placeX = placeX;
    this.placeY = placeY;
  }

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
  
  void drawModule(){
    color gray = color(this.grayscale); 
    fill(gray,200);
    noStroke();
    rect(this.placeX , this.placeY , this.width*grid, this.height*grid); // place the mudule into the container
  }  // drawModule method end
} // class Module end

void addModule(HashMap<String,Module> map, String key, String name, int width, int height){
  map.put( key, new Module(name, width, height) );
}

void addChunks(HashMap<String,ArrayList<Module>> map, String key, ArrayList<Module> solution){
  map.put( key, solution);
}

boolean areaDetect(int x, int y, int w, int h){
  boolean available = true;
  for(int i = 0; i <= w; i++){
    for(int j = 0; j <= h; j++){
      available = true;
      color p = get(x + grid*i +2, y + grid*j +2); // avoid the grid lines and get color of the cell
      if(p != color(0,0,0)){
        available = false;
        break;       
      }
    }
    if (!available){
      break;
    } 
  }
  return available;
}

boolean placeChunks(ArrayList<Module> chunks){
    for (Module c : chunks){ // go through each module
      if(!c.fixed){
        if(!c.place()){
          c.rotate();
          if(!c.place()){break;}
        }
      }
      
    }
    return false;
}
