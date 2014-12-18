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
    graph.addVertex("Aluminum");
    graph.addVertex("Boron");
    graph.addVertex("Carbon");
    graph.addVertex("Durian");
    // *********** Add Edges Here ***********
    graph.addEdge("Aluminum", "Boron");
    graph.addEdge("Boron", "Carbon");
    graph.addEdge("Carbon", "Durian");
    
    edges = graph.edgeSet();

  for(int k = 0; k <= edges.size(); k++)
  {
    edgeList = edges.toArray(new DefaultEdge[edges.size()]);
    branch = new DefaultEdge[k];
    combine(edgeList, k, 0, branch, 0, edgeList);
  }
}


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


void resetEdges(DefaultEdge[] eList)
{
  for(int n = 0; n < eList.length; n++)
  {
    DefaultEdge e = eList[n];
    String s = graph.getEdgeSource(e); // get source vertex of e
    String t = graph.getEdgeTarget(e); // get target vertex of e
    graph.addEdge(s,t);
  }
}


void combine(DefaultEdge[] arr, int k, int startId, DefaultEdge[] branch, int numElem, DefaultEdge[] eList)
{
    if (numElem == k)
    {
      resetEdges(eList);

      for(int n = 0; n < branch.length; n++)
      {
        DefaultEdge e = branch[n];
        String s = graph.getEdgeSource(e);
        String t = graph.getEdgeTarget(e);
        graph.removeEdge(s,t);
      }
      
      exportGraph();
      return;
    }

    for (int i = startId; i < arr.length; ++i)
    {
      branch[numElem++] = arr[i];
      combine(arr, k, ++startId, branch, numElem, eList);
      --numElem;
    }
}

