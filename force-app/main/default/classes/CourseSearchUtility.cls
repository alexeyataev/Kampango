public without sharing class CourseSearchUtility {

    private static List<String> howHeard = getHowHeardValues();
    
    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #1 - https://confluence.nct.org.uk:8443/x/EoSO
    public static Course__c getCourseById(String courseName, Boolean isFromWebSite){
        Course__c result = null;
        
        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Branch__r.Enquiries_PSA_Phone__c, Start_Date__c, End_Date__c, Branch__r.Branch_Number__c,
                    Main_Venue__r.Name, Main_Venue__r.Town__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c,
                    (
                        SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                        FROM Sessions__r
                    )
            FROM Course__c
            WHERE Name =: courseName
            AND Status__c != 'Cancelling'
            AND Status__c != 'Cancelled'
            AND Status__c != 'Draft'
            AND Start_Date__c > TODAY
            AND (Remaining_Places__c > 0 OR Overbooking_allowed__c = true)
            WITH SECURITY_ENFORCED
        ];
        
        Boolean isCourseHidden = inCourses.isEmpty() || (isFromWebSite && inCourses[0].Hide_From_Course_Finder__c);
        if(!isCourseHidden) {
            result = inCourses[0];
        } 

        return result;
    }
    
    public static RestResponse getCourseById(String courseName){
        RestResponse response = new RestResponse();
        Course__c course = getCourseById(courseName, true);
        if (course != null) {
            CourseFinderModel model = new CourseFinderModel(course);
            model.HowHeardTexts = howHeard;
            response.statusCode = HttpStatusCode.OK;
            response.responseBody = Blob.valueOf(replaseModelFilds(JSON.serializePretty(model)));
        } else {
            response.statusCode = HttpStatusCode.NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }       
        return response;
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #1 - https://confluence.nct.org.uk:8443/x/EoSO
    public static List<Course__c> getCoursesByBranch(String branchId, Boolean isFromWebSite){

        List<Course__c> inCourses = [
            SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Branch__r.Enquiries_PSA_Phone__c, Start_Date__c, End_Date__c,
                    Main_Venue__r.Name, Main_Venue__r.Town__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__r.Branch_Number__c,
            (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                    FROM Sessions__r
            )
            FROM Course__c
            WHERE Branch__r.Branch_Number__c =: branchId
            AND Status__c != 'Cancelling'
            AND Status__c != 'Cancelled'
            AND Status__c != 'Draft'
            AND Start_Date__c > TODAY
            AND (Remaining_Places__c > 0 OR (Remaining_Places__c <= 0 AND Overbooking_allowed__c = true))
            WITH SECURITY_ENFORCED
        ];
        
        List<Course__c> courses = new List<Course__c>();

        if(!inCourses.isEmpty()) {
            for (Course__c course : inCourses) {
                Boolean isCourseHidden = isFromWebSite && inCourses[0].Hide_From_Course_Finder__c;
                if(!isCourseHidden) {
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
            CoursesBranchModel branchModel = new CoursesBranchModel();
            branchModel.Courses = models;
            response.statusCode = HttpStatusCode.OK;
            response.responseBody = Blob.valueOf(replaseModelFilds(JSON.serializePretty(branchModel)));
        } else {
            response.statusCode = HttpStatusCode.NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPInoResultsFound);
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

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #1 - https://confluence.nct.org.uk:8443/x/EoSO
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
                    Branch__r.Name, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Branch__r.Enquiries_PSA_Phone__c, Start_Date__c, End_Date__c,
                    Main_Venue__r.Name, Main_Venue__r.Town__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__r.Branch_Number__c,
                (
                    SELECT Name, Contact_Hours__c, Day_of_Week__c, Date__c, Start__c, End__c, Type__c, Specific_Attendee_Type__c
                    FROM Sessions__r
                )
                FROM Course__c
                WHERE Distance(Course__c.Main_Venue__r.Location__c, :location, 'mi') < :radius
                AND Status__c != 'Cancelling'
                AND Status__c != 'Cancelled'
                AND Status__c != 'Draft'
                AND Start_Date__c > TODAY
                AND (Remaining_Places__c > 0 OR (Remaining_Places__c <= 0 AND Overbooking_allowed__c = true))
                AND ((Type__c = 'Antenatal' AND End_Date__c < :birthDueDate) OR (Type__c = 'Postnatal' AND Start_Date__c > :birthDueDate))
                WITH SECURITY_ENFORCED
            ];
        } else {
            inCourses = [
               SELECT Name, Sub_Type__c, PSA_Area__c, Type__c, Couples_Allowed__c, Women_Only__c, Number_of_places__c,
                    Branch__r.Name, Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c,
                    Fee__c, Remaining_Places__c, Branch__r.Enquiries_PSA_Phone__c, Start_Date__c, End_Date__c,
                    Main_Venue__r.Name, Main_Venue__r.Town__c, Hide_From_Course_Finder__c, Main_Venue__r.Postcode__c,
                    Main_Venue__r.County__c, Main_Venue__r.Location__c, Branch__r.Branch_Number__c,
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
                Boolean isCourseHidden = isFromWebSite && inCourses[0].Hide_From_Course_Finder__c;
                if(!isCourseHidden) {
                    courses.add(course);
                }
            }
        }
        return courses;
    }
    

    public static RestResponse getCoursesByDateDistance(Map <String, String> params){
        RestResponse response = new RestResponse();
        if (params == null){
            return createResponse(HttpStatusCode.NOT_FOUND, Label.CourseAPInoResultsFound);
        }

        Location location;
        Date birthDueDate;
        Integer radius;
        try {
            birthDueDate = validateBirthDueDate(params.get('birth'));
            location = validateLocation(params.get('location'));
            radius = validateRadius(params.get('radius'));
        } catch (RadiusTypeException rte){
            return createResponse(HttpStatusCode.SERVER_ERROR, Label.CourseAPIradiusIsNotValid);
        } catch (DateTypeException dte){
            return createResponse(HttpStatusCode.NOT_FOUND, Label.CourseAPInoResultsFound);
        } catch (LocationTypeException lte) {
            return createResponse(HttpStatusCode.NOT_FOUND, Label.CourseAPInoResultsFound);
        }
        
        List<Course__c> courses = getCoursesByDateDistance(location, radius, birthDueDate, true);        
        Boolean isCoursesHasData = (courses != null && !courses.isEmpty());
        if (isCoursesHasData) {
            List<CourseFinderModelOrdered> models = new List<CourseFinderModelOrdered>();
            Integer i = 0;
            Integer lowestRankIncluded = 1;
            for (Course__c course : courses) {
                CourseFinderModelOrdered model = new CourseFinderModelOrdered(course, birthDueDate);
                i++;

                model.HowHeardTexts = howHeard;

                if (model.Rank <= 5) { // filtering by rank
                models.add(model);
                    if (lowestRankIncluded < model.Rank){
                        lowestRankIncluded = model.Rank;
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
            sortedModel.LowestRankIncluded = lowestRankIncluded;
            sortedModel.SuggestedLowestRank = getSuggestedLowestRank(radius, lowestRankIncluded);
            sortedModel.viewPort = new ViewPort(params.get('viewports')).getViewport();
            
            response.statusCode = HttpStatusCode.OK;
            response.responseBody = Blob.valueOf(replaseModelFilds(JSON.serializePretty(sortedModel)));
        } else {
            response.statusCode = HttpStatusCode.NOT_FOUND;
            response.responseBody = Blob.valueOf(System.Label.CourseAPIcourseNotExists);
        }        
        return response;
    }

    private static Integer getSuggestedLowestRank(Integer radius, Integer lowestRankIncluded){
        Integer result;

        final Integer RANK_3 = 3;
        final Integer RANK_4 = 4;
        final Integer RANK_5 = 5;

        final Integer RANK_3_MAX_RADIUS = 10;
        final Integer RANK_4_MAX_RADIUS = 20;
        
        if (radius <= RANK_3_MAX_RADIUS) {
            result = RANK_3;
        } else if (radius <= RANK_4_MAX_RADIUS) {
            result = RANK_4;
        } else {
            result = RANK_5;
        }
        
        if (result > lowestRankIncluded) {
            result = lowestRankIncluded;
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
                throw new LocationTypeException(e);
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
                throw new RadiusTypeException();
            }
        } catch (Exception e){
            throw new RadiusTypeException(e);
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
            throw new DateTypeException(e);
        }

        return result;
    }


    private static Date getDefaultBirthDueDate(){
        final Integer DIFFERENCE_FROM_TODAY = 30;
        return Date.today() + DIFFERENCE_FROM_TODAY;
    }

    private static String replaseModelFilds(String model) {
        return model.replace('Session_Date', 'Date').replace('Session_End', 'End');
    }
   
    private static RestResponse createResponse(Integer statusCode, String label){
        RestResponse response = new RestResponse();
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(label);
        return response;
    }

    public virtual class CustomTypeException extends Exception {} 

    public class DateTypeException extends CustomTypeException {}

    public class LocationTypeException extends CustomTypeException {}

    public class RadiusTypeException extends CustomTypeException {}
}
//NOPMD
//Incident #18 - https://confluence.nct.org.uk:8443/x/EoSO