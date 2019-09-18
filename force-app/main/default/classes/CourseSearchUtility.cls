public class CourseSearchUtility {
    public static Course__c getCourseById(String courseId, Boolean isFromWebSite){
        Course__c result = null;
        
        // ToDo use Database.query instead to do filtering inside of SOQL query itself.
        List<Course__c> inCourses = [
        	SELECT Id, Name, Hide_From_Course_Finder__c
            FROM Course__c
            WHERE Id = :courseId
        ];
        
        List<Course__c> courses = new List<Course__c>();
        for (Course__c course : inCourses){
            if(isFromWebSite == true){
                if (course.Hide_From_Course_Finder__c == true){
                    // do not add
                } else {
                    courses.add(course);
                }
            } else {
                courses.add(course);
            }
        }
        
        if (!courses.isEmpty() && courses.size() == 1){
            result = courses[0];
        }
        
        return result;
    }
    
    public static RestResponse getCourseById(String courseId){
        RestResponse response = new RestResponse();
        Course__c course = getCourseById(courseId, true);
        
        if (course != null) {
            CourseFinderModel model = new CourseFinderModel(course);
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(model));
        } else {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf('{ "Error" : course does not exist }');
        }
        
        return response;
    }
    
    public static List<Course__c> getCoursesByBranchId(String branchId, Boolean isFromWebSite){
        return null;
    }
    
    public static RestResponse getCoursesByBranchId(String branchId){
        return null;
    }
    
    public static List<Course__c> GetCoursesByDateDistance(/*ToDo: parameters to be defined, */ Boolean isFromWebSite){
        return null;
    }
    
    public static RestResponse GetCoursesByDateDistance(/*ToDo: parameters to be defined, */ ){
        return null;
    }
}