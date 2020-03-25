@SuppressWarnings('PMD.MethodNamingConventions')

@isTest
public with sharing class UpdateBookingContactsEmailTest {
    private static final String CONTACT_EMAIL_PREFIX = '.donotcontact';
    private static final String PRIMARY_CONTACT_EMAIL = 'test1@test.com';
    private static final String PARTNER_CONTACT_EMAIL = 'test2@test.com';

    @TestSetup
    static void setupData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc2')
                    .buildBranchAccount()
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost('Dina', PRIMARY_CONTACT_EMAIL)
                    .buildPartnertHost('Tim', PARTNER_CONTACT_EMAIL)
                    .buildRoom()
                    .buildBooking('Enquiry');
    }

    @isTest
    static void CreateBooking_SetValueDoNotContactToTrue_ReturnContactEmailWithPrefix() {

        Test.startTest();
            Booking__c bookingInstanceForUpdate = [SELECT Do_Not_Contact__c FROM Booking__c LIMIT 1];
            bookingInstanceForUpdate.Do_Not_Contact__c = true;
            update bookingInstanceForUpdate;
        Test.stopTest();

        Booking__c bookingInstance = [SELECT Primary_Contact_Email__c,Email_Partner__c FROM Booking__c LIMIT 1];

        System.assertEquals(bookingInstance.Primary_Contact_Email__c, PRIMARY_CONTACT_EMAIL + CONTACT_EMAIL_PREFIX, 'expecting email test1@test.com.donotcontact');
        System.assertEquals(bookingInstance.Email_Partner__c, PARTNER_CONTACT_EMAIL + CONTACT_EMAIL_PREFIX, 'expecting email test2@test.com.donotcontact');
    }

}
