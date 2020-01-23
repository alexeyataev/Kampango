@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #37 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public with sharing class ConfirmationEmailControllerTest {

    private static void sessionWithTypeAndStatusDataBuilder(String sessionType, String sessionStatus) {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildSessionWithTypeAndStatus(sessionType, sessionStatus)
                    .buildBooking('Reserved');
    }

    private static void cursesWithChoseNumberAndStatusSessionsDataBuilder(Integer numberOfCourses, Integer numberOfProvisionSession, Integer numberOfConfirmedSession) {
       TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc3')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildCoursesWithChoseNumberAndStatusSessions(numberOfCourses, numberOfProvisionSession, numberOfConfirmedSession);

    }

    @IsTest
    static void checkSession_sessionStatusIsProvisionalAndTypeIsStandard_ListIsEmpty() {
        sessionWithTypeAndStatusDataBuilder('Standard', 'Provisional');

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.sessionListWrapper.size(), 0);
        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.size(), 0);
    }

    @IsTest
    static void checkSession_sessionStatusIsProvisionalAndTypeIsBreasrfeeding_ListIsEmpty() {
        sessionWithTypeAndStatusDataBuilder('Breastfeeding', 'Provisional');

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.sessionListWrapper.size(), 0);
        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.size(), 0);
    } 

    @IsTest
    static void checkSession_sessionStatusIsProvisionalAndTypeIsReunion_ListIsEmpty() {
        sessionWithTypeAndStatusDataBuilder('Reunion', 'Provisional');

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.sessionListWrapper.size(), 0);
        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.size(), 0);
    }

    @IsTest
    static void checkSession_sessionStatusIsConfirmedAndTypeIsReunion_ListHasOneSession() {
        sessionWithTypeAndStatusDataBuilder('Reunion', 'Confirmed');

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];
        
        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.sessionListWrapper.size(), 1);
        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.size(), 1);
    }
    
    @IsTest
    static void checkVenueWithSessionDaysFormat_venueWithTwoSession_StringWithTwoSession() {
        cursesWithChoseNumberAndStatusSessionsDataBuilder(1, 2, 2);

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2)');
    }

    @IsTest
    static void checkVenueWithSessionDaysFormat_venueWithTreeSession_StringWithThreeSession() {
        cursesWithChoseNumberAndStatusSessionsDataBuilder(1, 2, 3);

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];
        
        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2 & 3)');
    }
}