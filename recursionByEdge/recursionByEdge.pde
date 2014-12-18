import org.jgrapht.UndirectedGraph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.DepthFirstIterator;
import org.jgrapht.traverse.GraphIterator;
import java.util.Iterator;
import java.util.*;
import java.io.BufferedWriter;
import java.io.FileWriter;

UndirectedGraph<String, DefaultEdge> graph;
Set<DefaultEdge> all = new HashSet<DefaultEdge>();
int v = 1; // graph_*
void setup()
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

void combine(DefaultEdge[] arr, int k, int startId, DefaultEdge[] branch, int numElem, DefaultEdge[] eList){
        
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

