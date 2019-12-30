@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #37 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public with sharing class ConfirmationEmailControllerTest {

    @IsTest
    static void checkSession_sessionStatusIsProvisionalAndTypeIsStandard_ListIsEmpty() {
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
                    .buildSessionWithTypeAndStatus('Standard', 'Provisional')
                    .buildBooking('Reserved');

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
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc2')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildSessionWithTypeAndStatus('Breastfeeding', 'Provisional')
                    .buildBooking('Reserved');

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
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc3')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildSessionWithTypeAndStatus('Reunion', 'Provisional')
                    .buildBooking('Reserved');

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
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc3')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
                    .buildBooking('Reserved');

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

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];

        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2)');
    }

    @IsTest
    static void checkVenueWithSessionDaysFormat_venueWithTreeSession_StringWithThreeSession() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc3')
                    .buildBranchAccount()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildCoursesWithChoseNumberAndStatusSessions(1, 2, 3);

        Course__c course = [SELECT Name FROM Course__c LIMIT 1];
        
        Test.startTest();
            ConfirmationEmailController confirmationEmailControllerInstance = new ConfirmationEmailController();
            confirmationEmailControllerInstance.setCourse(course);
        Test.stopTest();

        System.assertEquals(confirmationEmailControllerInstance.locationListWrapper.get(0).sessionDays, '(sessions 1,2 & 3)');
    }
}