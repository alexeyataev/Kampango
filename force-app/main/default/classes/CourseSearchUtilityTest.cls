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
            SELECT Id, Name
            FROM Course__c
            LIMIT 1
        ];
 
        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Name);
        Test.stopTest();

        CourseFinderModel model = (CourseFinderModel)System.JSON.deserialize(response.responseBody.toString(), CourseFinderModel.class );
        System.assertEquals(200, response.statusCode);
        System.assertEquals(course.Name, model.Id);                             
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
        System.assertEquals(1, responseObjects.size());                             
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
    static void courseSearchByIdIfCancelled() {
        setupTestData();

        Course__c course = [
            SELECT Id, Status__c, Branch__r.Enquiries_PSA_Phone__c, Branch__r.Enquiries_PSA__r.Name,
                   Branch__r.Enquiries_PSA_Email__c
            FROM Course__c
            LIMIT 1
        ];

        course.Status__c = 'Cancelled';
        update course;

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(course.Id);
        Test.stopTest();
       
        System.assertEquals(404, response.statusCode);
    }

    @isTest
    static void courseSearchByIdIfStarted() {
        setupTestData();

        Session__c session = [
            SELECT Id, Date__c, Course__c
            FROM Session__c
            LIMIT 1
        ];

        session.Date__c = Date.today() - 5;
        update session;

        Test.startTest();
        RestResponse response = new RestResponse();
        response = CourseSearchUtility.getCourseById(session.Course__c);
        Test.stopTest();

        System.assertEquals(404, response.statusCode);
    }
}