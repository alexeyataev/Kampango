@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
public class CourseFinderModelOrdered extends CourseFinderModel {
    public Integer Rank {get; set;}
    public Integer Order {get; set;}
    
    public CourseFinderModelOrdered(Course__c course){
        super(course);
    }
}