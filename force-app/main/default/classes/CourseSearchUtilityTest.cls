@isTest
private class CourseSearchUtilityTest {
    
    @TestSetup
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
}
