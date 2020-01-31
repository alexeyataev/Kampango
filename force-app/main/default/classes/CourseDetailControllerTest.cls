@IsTest
public with sharing class CourseDetailControllerTest {

    @TestSetup
    static void createTestData(){
        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc1')
            .buildPractitioner('Smith')
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice();

        Integer coursesToCreate = 4;
        Integer provisionSessionsToCreate = 5;
        Integer confirmedSessionsToCreate = 5;

        testDataFactory.buildCoursesWithChoseNumberAndStatusSessions(coursesToCreate, provisionSessionsToCreate,confirmedSessionsToCreate);
    }

    @IsTest
    private static void retrieveRelatedSessions_passValidCourseId_sessionsRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Antenatal' LIMIT 1].Id;
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.size() > 0);
    }

    @IsTest
    private static void retrieveRelatedSessions_passInvalidCourseId_sessionsNotRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Antenatal' LIMIT 1].Id;
        courseId = courseId.left(10) + '11111111';
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.isEmpty());
    }
}