@isTest
private class CourseSearchUtilityTest {
    
    private static void setupTestData() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildBranchAccount()
                       .buildOrganizationAccount('acc5')
                       .buildPractitioner('Test')
                       .buildVenue()
                       .buildRoom()
                       .buildLicenceToPractice()
                       .buildCoursesWithSessions(2, 2);
    }

    @isTest
    static void courseSearchById() {
        setupTestData();

        Course__c course = [
            SELECT Id
            FROM Course__c
            LIMIT 1
        ];
 
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Id);
        Test.stopTest();
       
        CourseFinderModel model = (CourseFinderModel)System.JSON.deserialize(response.responseBody.toString(), CourseFinderModel.class );
        System.assertEquals(200, response.statusCode);
        System.assertEquals(course.Id, model.Id);                             
    }

    @isTest
    static void courseSearchByIdIfNoCourse() {
        setupTestData();

        Course__c course = [
            SELECT Id 
            FROM Course__c 
            LIMIT 1
        ];
        delete course;
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Id);
        Test.stopTest();

        System.assertEquals(404, response.statusCode);                             
    }

    @isTest
    static void courseSearchByBranchId() {
        setupTestData();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByBranch(account.Id);
        Test.stopTest();
        List<Object> responseObjects = (List<Object>)JSON.deserializeUntyped(response.responseBody.toString());

        System.assertEquals(200, response.statusCode);
        System.assertEquals(2, responseObjects.size());                             
    }

    @isTest
    static void courseSearchByBranchIdIfNoBranchCourses() {
        setupTestData();
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
    
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
        ];
            
        List<Course__c> courses = [
            SELECT Id
            FROM Course__c
            WHERE Branch__c = :account.Id
        ];

        delete courses;

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCoursesByBranch(account.Id);
        Test.stopTest();

        System.assertEquals(404, response.statusCode);                             
    }	 	 	 

    @isTest
    static void courseSearchByLocationParams(){
        Map<String, String> params = null;
        CourseSearchUtility.getCoursesByDateDistance(params);

        params = new Map<String, String>{'location' => ''};
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('location', '50.a,-0.1');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('location', '50.5,-0.1');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', '');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', 'b');
        CourseSearchUtility.getCoursesByDateDistance(params);

        params.put('radius', '50');
        RestResponse response = CourseSearchUtility.getCoursesByDateDistance(params);

        System.assertEquals(404, response.statusCode);
    }

    private static void addLocationToVenue(){
        List<Venue__c> venues = [
            SELECT Id, Location__c
            FROM
            Venue__c
        ];

        System.assertEquals(1, venues.size());
        Location loc = Location.newInstance(50.501, -0.101);
        venues[0].Location__latitude__s = loc.latitude;
        venues[0].Location__longitude__s = loc.longitude;
        update venues;
    }

    @isTest
    static void courseSearchByLocation(){
        setupTestData();
        addLocationToVenue();

        Map<String, String> params = new Map<String, String>{
            'location' => '50.5,-0.1',
            'radius' => '50'
        };
        RestResponse response = CourseSearchUtility.getCoursesByDateDistance(params);

        System.assertEquals(200, response.statusCode);
    }

    @isTest
    static void courseSearchByLocationInternal(){
        setupTestData();
        addLocationToVenue();

        Location loc = Location.newInstance(50.501, -0.101);
        List<Course__c> courses = CourseSearchUtility.getCoursesByDateDistance(loc, 50, false);
        System.assertEquals(1, courses.size());
    }
}
