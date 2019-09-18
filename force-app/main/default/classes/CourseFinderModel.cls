public class CourseFinderModel {
    public String id {get;set;}
    public String name {get; set;}
    
    public CourseFinderModel (Course__c course){
        this.id = course.Id;
        this.name = course.Name;
    }
    // public Date date {get; set;} reserved
}