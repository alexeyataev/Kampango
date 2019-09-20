@isTest
public without sharing class CourseApiTest {

    private static String URI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/courses';
    private static String methodGet = 'GET';

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
    static void searchCourseById() {
        Course__c course = [
            SELECT Id
            FROM Course__c
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = URI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('course', course.Id);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CourseApi.getCourseStaff();
        Test.stopTest();

        CourseFinderModel model = (CourseFinderModel)System.JSON.deserialize(res.responseBody.toString(), CourseFinderModel.class );

        System.assertEquals(200, res.statusCode);
        System.assertEquals(course.Id, model.Id);      
    }

    @isTest
    static void searchCourseByBranch() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account account = [
            SELECT Id 
            FROM Account
            WHERE RecordTypeId = :recordTypeId 
            LIMIT 1
            ];

        RestRequest req = new RestRequest();
        req.requestURI = URI;
        req.httpMethod = methodGet;
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('branch', account.Id);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CourseApi.getCourseStaff();
        Test.stopTest();

        List<Object> responseObjects = (List<Object>)JSON.deserializeUntyped(res.responseBody.toString());

        System.assertEquals(200, res.statusCode);
        System.assertEquals(2, responseObjects.size());     
    }
}
