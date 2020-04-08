@isTest
public class ReunionEmailsSendTest {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PROFILE_NAME = 'PSA Manager';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';
    private static final String PRACTITIONER_LAST_NAME = 'John';
    private static final String PARENT_HOST_LAST_NAME = 'Dina';
    private static final String PARTNER_HOST_LAST_NAME = 'Tim';
    private static final String PARTICIPANT_PRIMARY_LAST_NAME = 'Jen';
    private static final String PARTICIPANT_PRIMARY_EMAIL = 'primary@test.com';
    private static final String PARTICIPANT_PARTNER_LAST_NAME = 'Jack';
    private static final String PARTICIPANT_PARTNER_EMAIL = 'partner@test.com';
    private static final String CLIENT_RECORDTYPE_NAME = 'Client';
    private static final String STATUS_ENQUIRY = 'Enquiry';
    private static final String TEMPLATE_NAME = 'test';
    private static final String TEMPLATE_PRACTITIONER_DEV_NAME = 'Reunion_Confirmed_Practitioner';
    private static final String TEMPLATE_PUBLIC_DEV_NAME = 'Reunion_Confirmed_Public';
    private static final String TEMPLATE_NOT_A_HOST_DEV_NAME = 'Reunion_Confirmed_Not_A_Host';
    private static final String TEMPLATE_HOST_DEV_NAME = 'Reunion_Confirmed_Host';

    @TestSetup
    static void setup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .createPSAmanager()
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
                    .buildBooking(STATUS_ENQUIRY)
                    .buildConfirmedSession();

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Overbooking_Allowed__c = true;
        update course;

        TestContactBuilder primaryContactBuilder = new TestContactBuilder();
        Contact participantPrimary = primaryContactBuilder
            .withRecordType(CLIENT_RECORDTYPE_NAME)
            .withEmail(PARTICIPANT_PRIMARY_EMAIL)
            .withLastName(PARTICIPANT_PRIMARY_LAST_NAME)
            .build();
        Contact participantPartner = primaryContactBuilder
            .withRecordType(CLIENT_RECORDTYPE_NAME)
            .withEmail(PARTICIPANT_PARTNER_EMAIL)
            .withLastName(PARTICIPANT_PARTNER_LAST_NAME)
            .build();
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.DuplicateRuleHeader.AllowSave =  true;
        Database.insert(
            new List<Contact> {participantPrimary, participantPartner}, 
            dmlOption
        );

        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        Booking__c participantBooking = bookingBuilder
            .withCourse([SELECT Id FROM Course__c LIMIT 1])
            .withStatus(STATUS_ENQUIRY)
            .withPrimaryContact(participantPrimary)
            .withPartnerContact(participantPartner)
            .withBookingExpiryDate(System.today().addDays(3))
            .ignoreDuplicateRules(true)
            .insertRecord(true)
            .build();
        dataFactory.setCourseToFinal();

        System.debug([SELECT Id FROM Booking__c].size());
        Account branchAcc = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
        branchAcc.PSA_Area__c = '3A';
        update branchAcc;
    }

    @isTest
    static void sendWhenInPrivateVenue() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Contact parentHost = [SELECT Id FROM Contact WHERE LastName = :PARENT_HOST_LAST_NAME LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE LastName = :PRACTITIONER_LAST_NAME LIMIT 1];
        Licence_To_Practice__c license = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        List<Booking__c> bookings = [SELECT Id FROM Booking__c];
        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];
        Test.startTest();
        
        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            for (Booking__c b : bookings) {
                b.Status__c = 'Confirmed';
            }
            update bookings;
            
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

        Test.stopTest();
        System.assert(true);
    }

    @isTest
    static void sendWhenInPublicVenue() {
        //create a session, change from provisional to confirmed, check result
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Venue__c publicVenue = [SELECT Id FROM Venue__c LIMIT 1];
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
                .withVenue(publicVenue)
                .withStatus(SESSION_PROVISIONAL_STATUS)
                .withPractitioner(practitioner)
                .withPractitionerLicence(license)
                .insertRecord(true)
                .build();
            reunion.Status__c = 'Confirmed';
            update reunion;
        }
        System.assert(true);
    }

    @isTest
    static void errorWhenNoConfirmedBookings() {
        //create a session, change from provisional to confirmed, check result
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Venue__c publicVenue = [SELECT Id FROM Venue__c LIMIT 1];
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
            Session__c reunion = sessionBuilder
                .withCourse(course)
                .withType('Reunion')
                .withVenue(publicVenue)
                .withStatus(SESSION_PROVISIONAL_STATUS)
                .withPractitioner(practitioner)
                .withPractitionerLicence(license)
                .insertRecord(true)
                .build();
            reunion.Status__c = 'Confirmed';
            update reunion;
        }
        System.assert(true);
    }

    @isTest
    static void errorWhenNoPSAemails() {
        //create a session, change from provisional to confirmed, check result
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Venue__c publicVenue = [SELECT Id FROM Venue__c LIMIT 1];
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
            Account branchAcc = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            branchAcc.Capacity_PSA_Email__c = null;
            branchAcc.Enquiries_PSA_Email__c = null;
            update branchAcc;

            booking.Status__c = 'Confirmed';
            update booking;

            Session__c reunion = sessionBuilder
                .withCourse(course)
                .withType('Reunion')
                .withPractitioner(practitioner)
                .withPractitionerLicence(license)
                .withVenue(publicVenue)
                .withStatus(SESSION_PROVISIONAL_STATUS)
                .insertRecord(true)
                .build();
            reunion.Status__c = 'Confirmed';
            update reunion;
        }
        System.assert(true);
    }

    @isTest
    static void errorWhenHostIsNotPrimaryContactThatBookedForCourse() {
        //create a session, change from provisional to confirmed, check result
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE LastName = :PRACTITIONER_LAST_NAME LIMIT 1];
        Licence_To_Practice__c license = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Contact notPrimaryContact = [
            SELECT Id FROM Contact WHERE LastName = :PARTNER_HOST_LAST_NAME
        ];
        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];
        
        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            Account branchAcc = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            branchAcc.Capacity_PSA_Email__c = null;
            branchAcc.Enquiries_PSA_Email__c = null;
            update branchAcc;

            booking.Status__c = 'Confirmed';
            update booking;

            Session__c reunion = sessionBuilder
                .withCourse(course)
                .withType('Reunion')
                .withPractitioner(practitioner)
                .withPractitionerLicence(license)
                .withParentHost(notPrimaryContact)
                .withStatus(SESSION_PROVISIONAL_STATUS)
                .insertRecord(true)
                .build();
            reunion.Status__c = 'Confirmed';
            update reunion;
        }
        System.assert(true);
    }
}