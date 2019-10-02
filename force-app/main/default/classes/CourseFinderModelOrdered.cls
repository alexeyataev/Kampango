@SuppressWarnings('PMD.VariableNamingConventions')
//Incident #10 - https://confluence.nct.org.uk:8443/x/EoSO
public class CourseFinderModelOrdered extends CourseFinderModel {
    public Integer Rank {get; set;}
    public Integer Order {get; set;}
    public transient Integer groupRank {get; set;}
    public transient Date birthDueDate {get; set;}
    
    public CourseFinderModelOrdered(Course__c course, Date birthDueDate){
        super(course);
        this.birthDueDate = birthDueDate;
        calculateRank();
        calculateGroupRank();
    }

    private void calculateRank(){
        Rank = 1;
    }

    private void calculateGroupRank(){
        groupRank = 2;
    }
}