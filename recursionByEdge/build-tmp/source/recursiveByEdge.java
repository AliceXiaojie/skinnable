import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.jgrapht.UndirectedGraph; 
import org.jgrapht.graph.DefaultEdge; 
import org.jgrapht.graph.SimpleGraph; 
import org.jgrapht.traverse.DepthFirstIterator; 
import org.jgrapht.traverse.GraphIterator; 
import java.util.Iterator; 
import java.util.*; 
import java.io.BufferedWriter; 
import java.io.FileWriter; 

import com.mxgraph.layout.orthogonal.*; 
import com.mxgraph.model.*; 
import com.mxgraph.analysis.*; 
import com.jgraph.components.labels.*; 
import com.jgraph.navigation.*; 
import com.jgraph.layout.tree.*; 
import org.jgrapht.graph.*; 
import org.jgrapht.demo.*; 
import com.jgraph.layout.simple.*; 
import com.mxgraph.util.png.*; 
import com.mxgraph.swing.*; 
import com.mxgraph.swing.handler.*; 
import com.mxgraph.layout.hierarchical.*; 
import com.mxgraph.generatorfunction.*; 
import org.jgraph.*; 
import com.mxgraph.layout.orthogonal.model.*; 
import org.jgraph.plaf.*; 
import org.jgrapht.traverse.*; 
import com.mxgraph.util.svg.*; 
import org.jgraph.plaf.basic.*; 
import com.mxgraph.view.*; 
import com.jgraph.layout.organic.*; 
import com.mxgraph.sharing.*; 
import com.mxgraph.layout.hierarchical.model.*; 
import com.mxgraph.shape.*; 
import org.jgrapht.alg.*; 
import com.jgraph.layout.hierarchical.model.*; 
import com.jgraph.util.*; 
import com.mxgraph.costfunction.*; 
import com.jgraph.algebra.cost.*; 
import com.mxgraph.util.*; 
import org.jgrapht.event.*; 
import org.jgrapht.experimental.alg.color.*; 
import org.jgrapht.experimental.alg.*; 
import org.jgrapht.alg.interfaces.*; 
import org.jgrapht.alg.cycle.*; 
import com.mxgraph.layout.hierarchical.stage.*; 
import com.mxgraph.canvas.*; 
import com.jgraph.io.svg.*; 
import org.jgraph.graph.*; 
import org.jgrapht.generate.*; 
import com.jgraph.algebra.*; 
import com.mxgraph.io.*; 
import org.jgrapht.*; 
import com.mxgraph.reader.*; 
import com.jgraph.layout.routing.*; 
import org.jgraph.util.*; 
import org.jgrapht.experimental.permutation.*; 
import org.jgrapht.experimental.dag.*; 
import org.jgrapht.util.*; 
import com.mxgraph.swing.view.*; 
import com.jgraph.layout.graph.*; 
import org.jgraph.event.*; 
import org.jgrapht.alg.util.*; 
import org.jgrapht.ext.*; 
import org.jgrapht.experimental.equivalence.*; 
import org.jgrapht.experimental.*; 
import com.mxgraph.io.graphml.*; 
import com.mxgraph.swing.util.*; 
import com.jgraph.layout.hierarchical.*; 
import org.jgrapht.experimental.isomorphism.*; 
import com.jgraph.layout.*; 
import com.mxgraph.layout.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class recursiveByEdge extends PApplet {











UndirectedGraph<String, DefaultEdge> graph;
Set<DefaultEdge> all = new HashSet<DefaultEdge>();
int v = 1; // graph_*
public void setup()
{

  Set<DefaultEdge> edges = new HashSet<DefaultEdge>();
  DefaultEdge[] edgeList;
  DefaultEdge[] branch;
    graph = new SimpleGraph<String, DefaultEdge>(DefaultEdge.class);
    // *********** Add Vertexs Here ***********
    graph.addVertex("A");
    graph.addVertex("B");
    graph.addVertex("C");
    graph.addVertex("D");
    // *********** Add Edges Here ***********
    graph.addEdge("A", "B");
    graph.addEdge("B", "C");
    graph.addEdge("C", "D");
    
    edges = graph.edgeSet();

  for(int k = 0; k <= edges.size(); k++){

      for(DefaultEdge e : edges){ // reset all edges
        String s = graph.getEdgeSource(e); // get source vertex of e
        String t = graph.getEdgeTarget(e); // get target vertex of e
        graph.addEdge(s,t);
      }

      edgeList = edges.toArray(new DefaultEdge[edges.size()]);
      branch = new DefaultEdge[k];

      combine(edgeList, k, 0, branch, 0, edgeList);
  } // for end

} // setup end

public void combine(DefaultEdge[] arr, int k, int startId, DefaultEdge[] branch, int numElem, DefaultEdge[] eList){
        
        if (numElem == k)
        {
            for(int n = 0; n < eList.length; n++){ // reset all edges
              DefaultEdge e = eList[n];
              String s = graph.getEdgeSource(e); // get source vertex of e
              String t = graph.getEdgeTarget(e); // get target vertex of e
              graph.addEdge(s,t);
              // println(s + "   ->   " + t);
            }

            for(int n = 0; n < branch.length; n++){
              DefaultEdge e = branch[n];
               String s = graph.getEdgeSource(e);
               String t = graph.getEdgeTarget(e);
               // println(s + "   ->   " + t);
              graph.removeEdge(s,t);
            }

            try
            {
              DOTExporter exporter = new DOTExporter();
              File ff = new File(dataPath("/tmp/graph_" + v + ".dot"));
              v++;
              if(!ff.exists())
              {
                  ff.createNewFile();
              }
              FileWriter fw = new FileWriter(ff, true);
              BufferedWriter bw = new BufferedWriter(fw);
              PrintWriter pw = new PrintWriter(bw);
              //PrintWriter f = new PrintWriter(new BufferedWriter(new FileWriter(ff, true)));
              exporter.export(pw, graph);
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
            for(int n = 0; n < eList.length; n++){ // reset all edges
              DefaultEdge e = eList[n];
              String s = graph.getEdgeSource(e); // get source vertex of e
              String t = graph.getEdgeTarget(e); // get target vertex of e
              graph.addEdge(s,t);
              // println(s + "   ->   " + t);
            }
            return;

        }

        for (int i = startId; i < arr.length; ++i)
        {
            branch[numElem++] = arr[i];
            combine(arr, k, ++startId, branch, numElem, eList);
            --numElem;
        }
    }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "recursiveByEdge" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
