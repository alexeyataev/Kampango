//@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
@IsTest
private class UpdateRelatedSessionsFlowTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String ORGANIZATION_ACCOUNT_NAME = 'acc1';

    @TestSetup 
    private static void testSetup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount(ORGANIZATION_ACCOUNT_NAME)
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildSession();
    }

    @isTest
    static void UpdateSessionVenue_CourseMainVenueChanged_SessionVenueUpdated() {
        Course__c course = [
			SELECT Main_Venue__c
			FROM Course__c
			LIMIT 1
        ];

        Id oldMainVenue = course.Main_Venue__c;

        Session__c session = [
            SELECT Venue__c
            FROM Session__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c newVenue = venueBuilder
            .InsertRecord(true)
            .Build();

        Test.startTest();
        course.Main_Venue__c = newVenue.Id;
        update course;
        Test.stopTest();

        Session__c sessionToTest = [
            SELECT Venue__c
            FROM Session__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        Id newMainVenue = course.Main_Venue__c;

        System.assertEquals(oldMainVenue, session.Venue__c);
        System.assertEquals(newMainVenue, sessionToTest.Venue__c);
    }

    @isTest
    static void UpdateSessionPractitionerLicence_CourseMainPractitionerLicenceChanged_SessionLicenceUpdated() {
        Course__c course = [
			SELECT Main_Practitioner_Licence__c
			FROM Course__c
			LIMIT 1
        ];

        Id oldMainPractitionerLicence = course.Main_Practitioner_Licence__c;

        Session__c session = [
            SELECT Practitioner_Licence__c
            FROM Session__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        Contact practitioner = [
            SELECT Id, LastName
            FROM Contact
            WHERE LastName =:PRACTITIONER_LASTNAME
            LIMIT 1
        ];
        
        TestDataFactory.getInstance().buildLicenceToPractice(practitioner);

        Licence_To_Practice__c newLicence = [
            SELECT Id 
            FROM Licence_To_Practice__c 
            WHERE Id <> :course.Main_Practitioner_Licence__c
            LIMIT 1
        ];

        Test.startTest();
        course.Main_Practitioner_Licence__c = newLicence.Id;
        update course;
        Test.stopTest();

        Session__c sessionToTest = [
            SELECT Practitioner_Licence__c
            FROM Session__c
            WHERE Course__c = :course.Id
            LIMIT 1
        ];

        Id newMainPractitionerLicence = course.Main_Practitioner_Licence__c;

        System.assertEquals(oldMainPractitionerLicence, session.Practitioner_Licence__c);
        System.assertEquals(newMainPractitionerLicence, sessionToTest.Practitioner_Licence__c);
    }
}


