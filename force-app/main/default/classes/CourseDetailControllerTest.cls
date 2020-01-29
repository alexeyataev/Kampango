@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #39 - https://confluence.nct.org.uk:8443/x/EoSO
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
            .buildLicenceToPractice()
            .buildCourseWithTypeAndSubType('Antenatal','NCT Waterbirth workshop')
            .buildCourseWithTypeAndSubType('Postnatal','NCT Baby Massage course')
            .buildSession();

        Integer coursesToCreate = 6;
        Integer sessionsToCreate = 12;

        testDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);
    }

    @IsTest
    private static void retrieveRelatedSessions_passValidCourseId_sessionsRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Postnatal'].Id;
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.size() > 0);
        System.assert(sessions.size() != 20);
    }

    @IsTest
    private static void retrieveRelatedSessions_passInvalidCourseId_sessionsNotRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Postnatal'].Id;
        courseId = courseId.left(10) + '11111111';
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.isEmpty());
    }
}