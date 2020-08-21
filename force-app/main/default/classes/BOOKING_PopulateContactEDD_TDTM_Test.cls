@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #114 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class BOOKING_PopulateContactEDD_TDTM_Test {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_LASTNAME_TWO = 'Brown';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'BOOKING_PopulateContactEDD_TDTM',
        'className' => 'BOOKING_PopulateContactEDD_TDTM',
        'objectAPIName' => 'Booking__c',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void SetupTestData() {
    TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME_TWO, HOST_EMAIL_ADDRESS)
                    .buildBooking('Enquiry');

        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    public static void bookingBirthDueDateChanged_relatedContactsExpectedDueDateUpdated() {

        List<Booking__c> bookings = [
            SELECT Birth_Due_Date__c, Partner_Contact__c, Primary_Contact__c
            FROM Booking__c 
        ];

        List<Contact> contacts = [
            SELECT Expected_Due_Date__c
            FROM Contact
            WHERE Id IN (:bookings[0].Partner_Contact__c, :bookings[0].Primary_Contact__c)
        ];
        
        Test.startTest();
        for (Booking__c booking : bookings) {
            booking.Birth_Due_Date__c = booking.Birth_Due_Date__c.addDays(2);           
        }
        update bookings;      
        Test.stopTest();

        List<Contact> contactsToTest = [
            SELECT Expected_Due_Date__c
            FROM Contact
            WHERE Id IN :contacts
        ];
        
        for (Contact contact : contactsToTest) {
            System.assertEquals(bookings[0].Birth_Due_Date__c, contact.Expected_Due_Date__c, 'Expected Due Date should be the same as Birth Due Date');
        }
    }
}
