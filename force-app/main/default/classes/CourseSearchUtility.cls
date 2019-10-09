public without sharing class CourseSearchUtility {

    private static List<String> howHeard = getHowHeardValues();

    public static Course__c getCourseById(String courseName, Boolean isFromWebSite){
        Course__c result = null;

        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                    Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Start_Date__c, End_Date__c,
                    (
                        SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                        FROM Sessions__r
                    )
            FROM Course__c
            WHERE Name =: courseName
            AND Status__c != 'Cancelling'
            AND Status__c != 'Cancelled'
            AND Start_Date__c > TODAY
            AND (Remaining_Places__c > 0 OR (Remaining_Places__c <= 0 AND Overbooking_allowed__c = true))
            WITH SECURITY_ENFORCED
        ];
        
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
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(model));
        } else {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }       
        return response;
    }
    
    public static List<Course__c> getCoursesByBranch(String branchId, Boolean isFromWebSite){

        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                    Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Start_Date__c, End_Date__c,
            (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                    FROM Sessions__r
            )
            FROM Course__c
            WHERE Branch__c =: branchId
            AND Status__c != 'Cancelling'
            AND Status__c != 'Cancelled'
            AND Start_Date__c > TODAY
            AND (Remaining_Places__c > 0 OR (Remaining_Places__c <= 0 AND Overbooking_allowed__c = true))
            WITH SECURITY_ENFORCED
        ];
        
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
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(models));
        } else {
            response.statusCode = 404;
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

    public static List<Course__c> getCoursesByDateDistance(Location location, Integer radius, Date birthDueDate, Boolean isFromWebSite){
        final Integer DEFAULT_RADIUS = 100; // from Intrabiz API
        if (location == null){
            return null;
        }
        
        if (radius == null || radius <= 0) {
            radius = DEFAULT_RADIUS; 
        }

        List<Course__c> inCourses;

        if (isFromWebSite) {
            inCourses = [
                SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                    Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c, 
                    Start_Date__c, End_Date__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                    FROM Sessions__r
                )
                FROM Course__c
                WHERE Distance(Course__c.Main_Venue__r.Location__c, :location, 'mi') < :radius
                AND Status__c != 'Cancelling'
                AND Status__c != 'Cancelled'
                AND Start_Date__c > TODAY
                AND (Remaining_Places__c > 0 OR (Remaining_Places__c <= 0 AND Overbooking_allowed__c = true))
                AND ((Type__c = 'Antenatal' AND End_Date__c < :birthDueDate) OR (Type__c = 'Postnatal' AND Start_Date__c > :birthDueDate))
                WITH SECURITY_ENFORCED
            ];
        } else {
            inCourses = [
                SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Branch_Key__c, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Main_Practitioner__r.Name, Branch__r.Enquiries_PSA_Phone__c,
                    Main_Practitioner__r.Email, Main_Practitioner__r.Phone, Main_Venue__r.Name, Main_Venue__r.Town__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Start_Date__c, End_Date__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                    FROM Sessions__r
                )
                FROM Course__c
                WHERE Distance(Main_Venue__r.Location__c, :location, 'mi') < :radius
                AND Status__c != 'Cancelled'
                WITH SECURITY_ENFORCED
            ];
        }

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
            return getWrongResponse();
        }

        Location location;
        try {
            location = validateLocation(params.get('location'));
        } catch (TypeException te){
            return getWrongResponse();
        }
        
        Date birthDueDate;
        try {
            birthDueDate = validateBirthDueDate(params.get('birth'));
        } catch (TypeException te){
            return getWrongResponse();
        } 

        Integer radius;
        try {
            radius = validateRadius(params.get('radius'));
        } catch (TypeException te){
            return getWrongRadiusResponse();
        }
        
        List<Course__c> courses = getCoursesByDateDistance(location, radius, birthDueDate, true);        
        
        if (courses != null && !courses.isEmpty()) {
            List<CourseFinderModelOrdered> models = new List<CourseFinderModelOrdered>();
            Integer i = 0;
            Integer LowestRankIncluded = 1;
            for (Course__c course : courses) {
                CourseFinderModelOrdered model = new CourseFinderModelOrdered(course, birthDueDate);
                i++;

                model.HowHeardTexts = howHeard;

                if (model.Rank <= 5) { // filtering by rank
                models.add(model);
                    if (LowestRankIncluded > model.Rank){
                        LowestRankIncluded = model.Rank;
                    }
                }

            }
            
            // Sort models according rank, group rank and date;
            models.sort();
            // update Orders accorting to the sorting order;
            i = 0;
            for (CourseFinderModelOrdered model : models){
                i++;
                model.Order = i;
            }
            
            CoursesDateDistanceModel sortedModel = new CoursesDateDistanceModel();
            sortedModel.Courses = models;
            sortedModel.LowestRankIncluded = LowestRankIncluded;
            sortedModel.SuggestedLowestRank = getSuggestedLowestRank(LowestRankIncluded, radius);
            sortedModel.viewPort = new ViewPort(params.get('viewports')).getViewport();
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(sortedModel));
        } else {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }        
        return response;
    }
    
    private static Integer getSuggestedLowestRank(Integer radius, Integer LowestRankIncluded){
        Integer result;
        
        if (radius <= 10) {
            result = 3;
        } else if (radius <= 20) {
            result = 4;
        } else {
            result = 5;
        }
        
        if (result > LowestRankIncluded) {
            result = LowestRankIncluded;
        }
        
        return result;
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
                throw new TypeException(e);
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
            if (result <= 0) {
                throw new TypeException();
            }
        } catch (Exception e){
            throw new TypeException(e);
        }
        
        return result;
    }

    private static Date validateBirthDueDate(String strBirthDueDate) {
        Date result;
        if (String.isEmpty(strBirthDueDate)){
            return getDefaultBirthDueDate();
        }

        try {
            result = Date.valueOf(strBirthDueDate);
        } catch (Exception e){
            throw new TypeException(e);
        }

        return result;
    }


    private static Date getDefaultBirthDueDate(){
        final Integer DIFFERENCE_FROM_TODAY = 30;
        return Date.today() + DIFFERENCE_FROM_TODAY;
    }


    
    private static RestResponse getWrongResponse(){
        RestResponse response = new RestResponse();
        response.statusCode = 404;
        response.responseBody = Blob.valueOf(Label.CourseAPIcourseNotExists);
        return response;
    }

    private static RestResponse getWrongRadiusResponse(){
        RestResponse response = new RestResponse();
        response.statusCode = HttpStatusCode.SERVER_ERROR;
        response.responseBody = Blob.valueOf(Label.CourseAPIradiusIsNotValid);
        return response;
    }
}