@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #37 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public with sharing class ConfirmationEmailControllerTest {

    @TestSetup
    static void makeData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc3')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildCoursesWithChoseNumberAndStatusSessions(1, 2, 2);
    }

    @IsTest
    static void CheckConfirmedSessions_SetTwoConfirmedSession_RetunedTwoSessions() {
        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals (
            confirmationEmailControllerInstance.sessionListWrapper.size(),
            2,
            'Shoud be returned 2 session with status Confirmed'
        );
    }

    @isTest
    static void CheckSessionDaysTemplateFormat_SetTwoConfirmedSession_RetunedTwoSessions() {
        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals (
            confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays,
            '(sessions 1,2)',
            'Shoud be returned (sessions 1,2) text template'
        );
    }

}