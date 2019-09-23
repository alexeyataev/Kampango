public without sharing class CourseSearchUtility {

    private static List<String> howHeard = getHowHeardValues();

    public static Course__c getCourseById(String courseId, Boolean isFromWebSite){
        Course__c result = null;
        
        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,  
                Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, 
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Branch__c, Hide_From_Course_Finder__c,Main_Venue__r.Location__c, 
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            WHERE Id = :courseId
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> courses = new List<Course__c>();
        for (Course__c course : inCourses) {
            if (course.Remaining_Places__c == 0) {
                continue; 
            }
            if(isFromWebSite == true){
                if (course.Hide_From_Course_Finder__c != true) {
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
            model.HowHeardTexts = howHeard;
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(model));
        } else {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf('{ "Error" : course does not exist }');
        }       
        return response;
    }
    
    public static List<Course__c> getCoursesByBranch(String branchId, Boolean isFromWebSite){
        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,   
                Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, 
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, 
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            WHERE Branch__c = :branchId
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> courses = new List<Course__c>();

        if(!inCourses.isEmpty()) {
            for (Course__c course : inCourses) {
                if (course.Remaining_Places__c == 0) {
                    continue; 
                }
                if(isFromWebSite == true){
                    if (course.Hide_From_Course_Finder__c != true) {
                        courses.add(course);
                    }
                } else {
                    courses.add(course);
                }
            } 
        }
        return courses;
    }
    
    public static RestResponse getCoursesByBranch(String branchId) {
        RestResponse response = new RestResponse();
        List<Course__c> courses = getCoursesByBranch(branchId, true);
        
        if (!courses.isEmpty()) {
            List<CourseFinderModel> models = new List<CourseFinderModel>();
            for (Course__c course : courses) {
                CourseFinderModel model = new CourseFinderModel(course);
                model.HowHeardTexts = howHeard;
                models.add(model);
            }
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(models));
        } else {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf('{ "Error" : branch does not exist }');
        }        
        return response;
    }

    private static List<String> getHowHeardValues() {
        List<String> howHeardValues= new List<String>();
        Schema.DescribeFieldResult fieldResult = Booking__c.How_Heard__c.getDescribe();
        for (Schema.PicklistEntry value : fieldResult.getPicklistValues()) {
            howHeardValues.add(value.getLabel());
        }     
        return howHeardValues;
    }
}
