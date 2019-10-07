@SuppressWarnings('PMD.MethodNamingConventions')
public class ViewPort {
    private Double north {get; private set;}
    private Double south {get; private set;}
    private Double east {get; private set;}
    private Double west {get; private set;}
    private Boolean isValid {get; private set;}
    
    public List<List<Double>> getViewPort(){
        List<List<Double>> result = new List<List<Double>>();
        result.add(new List<Double>{0, 0});
        result.add(new List<Double>{0, 0});
                    
        if (isValid){
            result[0][0] = north;
            result[0][1] = west;
            result[1][0] = south;
            result[1][1] = east;
            
        } else {
            result = null;
        }
        
        return result;
    }
    
    public ViewPort(String viewPorts){
        isValid = false;
        if (String.isEmpty(viewPorts)){
        	return;
        }
        
        List<String> vertexes = viewPorts.split('[,|]');
        if (vertexes.size() != 4) {
            return;
        }
        
        try {
            north = Double.valueOf(vertexes[0]);
            west = Double.valueOf(vertexes[1]);
            south = Double.valueOf(vertexes[2]);
            east = Double.valueOf(vertexes[3]);
        } catch (TypeException tEx){
            return;
        }
        
        isValid = true;
    }
}