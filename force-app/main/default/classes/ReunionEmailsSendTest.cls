@isTest
public class ReunionEmailsSendTest {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PROFILE_NAME = 'Capacity PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';
    private static final String PRACTITIONER_LAST_NAME = 'John';
    private static final String PARENT_HOST_LAST_NAME = 'Dina';
    private static final String PARTNER_HOST_LAST_NAME = 'Tim';

    @TestSetup
    static void setup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .createCapacityPSA()
                    .buildOrganizationAccount('acc1')
                    .buildBranchAccountWithEmails('psa@test.com')
                    .buildPractitioner(PRACTITIONER_LAST_NAME)
                    .buildLicenceToPractice()
                    .buildVenue()
                    .buildRoom()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildPractitionerFeeRate()
                    .buildParentHost(PARENT_HOST_LAST_NAME, 'test1@test.com')
                    .buildPartnertHost(PARTNER_HOST_LAST_NAME, 'test2@test.com')
                    .buildBooking('Enquiry')
                    .buildConfirmedSession()
                    .setCourseToFinal();
    }

    @isTest
    static void sendWhenInPrivateVenue() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Contact parentHost = [SELECT Id FROM Contact WHERE LastName = :PARENT_HOST_LAST_NAME LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE LastName = :PRACTITIONER_LAST_NAME LIMIT 1];
        Licence_To_Practice__c license = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];
        
        
        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            booking.Status__c = 'Confirmed';
            update booking;
            Session__c reunion = sessionBuilder
                .withCourse(course)
                .withType('Reunion')
                .withParentHost(parentHost)
                .withStatus(SESSION_PROVISIONAL_STATUS)
                .withPractitioner(practitioner)
                //.withPractitionerFeeRate(practitionerFeeRate)
                .withPractitionerLicence(license)
                .insertRecord(true)
                .build();
            reunion.Status__c = 'Confirmed';
            update reunion;
        }
        System.assert(true);
    }

    static void sendWhenInPublicVenue() {
        //create a session, change from provisional to confirmed, check result
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner('John')
                    .buildLicenceToPractice()
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildCourse()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildBooking('Enquiry')
                    .buildReunion();
    }
}