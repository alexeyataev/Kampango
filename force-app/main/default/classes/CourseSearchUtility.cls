public without sharing class CourseSearchUtility {

    private static List<String> howHeard = getHowHeardValues();

    public static Course__c getCourseById(String courseName, Boolean isFromWebSite){
        Course__c result = null;

        String paramToSearch = 'Name = \'' + courseName + '\'';

        List<Course__c> inCourses = getCourses(paramToSearch);
        
        if(!inCourses.isEmpty()) {
            if(isFromWebSite == true) {
                if (inCourses[0].Hide_From_Course_Finder__c != true ) {
                    result = inCourses[0];
                }
            } else {
                result = inCourses[0];
            }
        } 

        return result;
    }
    
    public static RestResponse getCourseById(String courseName){
        RestResponse response = new RestResponse();
        Course__c course = getCourseById(courseName, true);
        if (course != null) {
            CourseFinderModel model = new CourseFinderModel(course);
            model.HowHeardTexts = howHeard;
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_OK;
            response.responseBody = Blob.valueOf(JSON.serializePretty(model));
        } else {
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }       
        return response;
    }
    
    public static List<Course__c> getCoursesByBranch(String branchId, Boolean isFromWebSite){

        String paramToSearch = 'Branch__c = \'' + branchId + '\'';

        List<Course__c> inCourses = getCourses(paramToSearch);
        
        List<Course__c> courses = new List<Course__c>();

        if(!inCourses.isEmpty()) {
            for (Course__c course : inCourses) {
                if(isFromWebSite == true) {
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
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_OK;
            response.responseBody = Blob.valueOf(JSON.serializePretty(models));
        } else {
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
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

    public static List<Course__c> getCourses(String param) {
        List<Course__c> courses = new List<Course__c>();

        String query = 'SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c, '  
            + 'Branch__r.Name, Branch__r.Branch_Key__c, Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, '
            + 'Branch__r.Enquiries_PSA_Phone__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c, '  
            + 'Main_Venue__r.Name, Main_Venue__r.Town__c, Main_Venue__r.Postcode__c, ' 
            + 'Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, ' 
             + '( ' 
                + 'SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c ' 
                + 'FROM Sessions__r ' 
            + ') ' 
            + 'FROM Course__c ' 
            + 'WHERE ' 
            + param
            + ' AND Status__c != \'Cancelling\''
            + ' AND Status__c != \'Cancelled\''
            + ' AND Start_Date__c > TODAY'
            + ' WITH SECURITY_ENFORCED';

        courses = Database.query(query);

        return courses;
    }

    public static List<Course__c> getCoursesByDateDistance(Location location, Integer radius, Boolean isFromWebSite){
        final Integer DEFAULT_RADIUS = 100; // from Intrabiz API
        if (location == null){
            return null;
        }
        
        if (radius == null || radius <= 0) {
            radius = DEFAULT_RADIUS; 
        }

        //  getCourses() were not used, as it was not found how to manage this geoQuery
        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,  
                Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                Main_Venue__r.County__c, Main_Venue__r.Location__c, Main_Venue__r.Map_Link__c, Hide_From_Course_Finder__c, 
                Main_Venue__r.Postcode__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c 
                    FROM Sessions__r
                )
            FROM Course__c
            WHERE Distance(Course__c.Main_Venue__r.Location__c, :location, 'mi') < :radius
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> courses = new List<Course__c>();

        if(!inCourses.isEmpty()) {
            for (Course__c course : inCourses) {
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
    
    public static RestResponse getCoursesByDateDistance(Map <String, String> params){
        RestResponse response = new RestResponse();
        if (params == null){
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
            return response;
        }

        Location location = validateLocation(params.get('location'));
        Integer radius = validateRadius(params.get('radius'));
        
        List<Course__c> courses = getCoursesByDateDistance(location, radius, true);        
        
        if (courses != null && !courses.isEmpty()) {
            List<CourseFinderModelOrdered> models = new List<CourseFinderModelOrdered>();
            Integer i = 0;
            for (Course__c course : courses) {
                CourseFinderModelOrdered model = new CourseFinderModelOrdered(course);
                i++;
                model.Rank = 1;
                model.Order = i;
                model.HowHeardTexts = howHeard;
                models.add(model);
            }
            
            CoursesDateDistanceModel sortedModel = new CoursesDateDistanceModel();
            sortedModel.Courses = models;
            sortedModel.LowestRankIncluded = 5;
            sortedModel.SuggestedLowestRank = 5;
            sortedModel.viewPort = new ViewPort(params.get('viewports')).getViewport();
            
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_OK;
            response.responseBody = Blob.valueOf(JSON.serializePretty(sortedModel));
        } else {
            response.statusCode = CourseApiConstants.HTTP_RESPONSE_NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }        
        return response;
    }
    
    private static Location validateLocation(String strLocation){
        Location result;
        if (String.isEmpty(strLocation)){
            return null;
        }
            
        List<String> latLong = strLocation.split(',');
        
        if (latLong.size() == 2){
            try {
                Double latitude = Double.valueOf(latLong[0]);
                Double longitude = Double.valueOf(latLong[1]);
                result = Location.newInstance(latitude, longitude);
            } catch (Exception e){
                result = null;
            }
        }
        
        return result;
    }
    
    private static Integer validateRadius(String strRadius){
        Integer result;
        if (String.isEmpty(strRadius)){
            return null;
        }
        
        try {
            result = Integer.valueOf(strRadius);
        } catch (Exception e){
            result = null;
        }
        
        return result;
    }
}