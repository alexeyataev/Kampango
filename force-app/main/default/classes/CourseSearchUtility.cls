public without sharing class CourseSearchUtility {

    private static List<String> howHeard = getHowHeardValues();

    public static CourseFinderModel getCourseByReference(String courseId, Boolean isFromWebsite) {
        if (isFromWebsite == true) {
            //Description__c, Session_Type__c, PostcodeArea, Notes__c
            List<Course__c> courses = [
                SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,  
                    Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, 
                    Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                    Main_Venue__r.County__c, Main_Venue__r.Map_Link__c, Branch__c,
                    (
                        SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c 
                        FROM Sessions__r
                    )
                FROM Course__c
                WHERE Id = :courseId
                ];

            if(!courses.isEmpty()) {
                CourseFinderModel courseFinderModel  =  new CourseFinderModel(courses[0]);                   					
                courseFinderModel.HowHeardTexts = howHeard;
                return courseFinderModel;
            } else {
                return null;
            }

        } else {
            return null;
        }
    } 

    public static List<CourseFinderModel> getCourseByBranch(String branchId) { 
        //Description__c, Session_Type__c, PostcodeArea, Notes__c
        List<Course__c> courses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,   
                Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, 
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Main_Venue__r.Map_Link__c, Branch__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            WHERE Branch__c = :branchId
            ];

        List<CourseFinderModel> courseFinderModels = new List<CourseFinderModel>();

        if(!courses.isEmpty()) {
            for (Course__c course : courses) {
                CourseFinderModel courseFinderModel  =  new CourseFinderModel(course);                   					
                courseFinderModel.HowHeardTexts = howHeard;
                courseFinderModels.add(courseFinderModel); 
            } 
        }
        return courseFinderModels;                 					
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
