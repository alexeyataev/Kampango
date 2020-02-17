@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #37 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public with sharing class ConfirmationEmailControllerTest {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String SESSION_CONFIRMED_STATUS = 'Confirmed';

    private static final String SESSION_REUNION_TYPE = 'Reunion';
    private static final String SESSION_STANDARD_TYPE = 'Standard';
    private static final String SESSION_BREASTFEEDING_TYPE = 'Breastfeeding';

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
                    .buildBooking('Enquiry');
    }

    private static void coursesWithChosenNumberAndStatusSessionsDataBuilder(Integer numberOfCourses, Integer numberOfProvisionSession, Integer numberOfConfirmedSession) {
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
        sessionWithTypeAndStatusDataBuilder(SESSION_STANDARD_TYPE, SESSION_PROVISIONAL_STATUS);

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
        sessionWithTypeAndStatusDataBuilder(SESSION_BREASTFEEDING_TYPE, SESSION_PROVISIONAL_STATUS);

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
        sessionWithTypeAndStatusDataBuilder(SESSION_REUNION_TYPE, SESSION_PROVISIONAL_STATUS);

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
        sessionWithTypeAndStatusDataBuilder(SESSION_REUNION_TYPE, SESSION_CONFIRMED_STATUS);

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
        coursesWithChosenNumberAndStatusSessionsDataBuilder(1, 2, 2);

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2)');
    }

    @IsTest
    static void checkVenueWithSessionDaysFormat_venueWithTreeSession_StringWithThreeSession() {
        coursesWithChosenNumberAndStatusSessionsDataBuilder(1, 2, 3);

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];
        
        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2 & 3)');
    }
}