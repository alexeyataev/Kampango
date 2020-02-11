@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #44 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class VenueDetailsControllerTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                .buildBranchAccount()
                .buildPractitioner(PRACTITIONER_LASTNAME)
                .buildPractitionerFeeRate()
                .buildVenue()
                .buildRoom()
                .buildLicenceToPractice()
                .buildCourse()
                .buildEstimatedCosts()
                .buildSession()
                .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
                .buildVenueContact();
    }

    @IsTest
    public static void getVenues_oneVenueCreated_componentShowsOneVenue() {

        Course__c course = [
                SELECT Id
                FROM Course__c
                LIMIT 1
        ];

        List<Venue__c> venues = [
                SELECT Name, Street_Address__c, Town__c, Postcode__c
                FROM Venue__c
                WHERE Id
                        IN (
                                SELECT Venue__c
                                FROM Session__c
                                WHERE Course__c = :course.Id
                        )
        ];

        VenueDetailsController.venueContactFieldSetName = 'CourseSummaryEmergencyContactFields';
        VenueDetailsController venueDetailsController = new VenueDetailsController();
        venueDetailsController.courseRecord = course;

        Test.startTest();

        List<VenueDetailsController.VenueResult> venuesToTest = venueDetailsController.getVenues();

        Test.stopTest();

        System.assertEquals(venuesToTest[0].venue.Id, venues[0].Id);
    }

    @IsTest
    public static void getVenues_componentLoadsOneVenue_correctEmergencyContactLoaded() {

        Course__c course = [
                SELECT Id
                FROM Course__c
                LIMIT 1
        ];

        List<Venue__c> venues = [
                SELECT Name, Street_Address__c, Town__c, Postcode__c
                FROM Venue__c
                WHERE Id
                        IN (
                                SELECT Venue__c
                                FROM Session__c
                                WHERE Course__c = :course.Id
                        )
        ];

        Set<Id> result = new Set<Id>();

        for (Venue_Contact__c venueCont : [
                SELECT Contact__c
                FROM Venue_Contact__c
                WHERE Venue__c = :venues[0].Id
                AND Type__c = 'Emergency'
                WITH SECURITY_ENFORCED
        ]) {
            result.add(venueCont.Contact__c);
        }

        List<Id> contactIds = new List<Id>(result);

        VenueDetailsController.venueContactFieldSetName = 'CourseSummaryEmergencyContactFields';
        VenueDetailsController venueDetailsController = new VenueDetailsController();
        venueDetailsController.courseRecord = course; 

        Test.startTest();

        List<VenueDetailsController.VenueResult> venuesToTest = venueDetailsController.getVenues();

        Test.stopTest();
        
        System.assertEquals(venuesToTest[0].emergencyContacts[0].Id, contactIds[0]);

    }
}
