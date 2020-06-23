@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class EncryptDecryptBookingValidationCodeTest {
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'BOOKING_EncryptValidationCode_TDTM',
        'className' => 'BOOKING_EncryptValidationCode_TDTM',
        'objectAPIName' => 'Booking__c',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };
    @TestSetup 
    private static void SetupTestData() {
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory.buildOrganizationAccount('acc2')
        .buildBranchAccount()
        .createEnquiryPSA()
        .buildBranchAccountWithEnquiryPSA()
        .buildPractitioner('John')
        .buildVenue()
        .buildLicenceToPractice()
        .buildCourse()
        .buildParentHost('Dina', 'test1@test.com')
        .buildPartnertHost('Tim', 'test2@test.com')
        .buildRoom()
        .buildBooking('Enquiry');
    }
    @IsTest
    static void DecryptValidationCodeSuccess_GuestUserTriesToDecrypt_ValidationCodeDecrypted() {
        List<User> uGuest = [SELECT Id FROM User WHERE Profile.Name = 'Parent Community Profile'];
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData;
        Test.startTest();
        Booking__c bookingEncrypted = [SELECT Id, Name, Validation_Code__c, Encrypted_Validation_Code__c FROM Booking__c LIMIT 1];
        System.runAs(uGuest[0]) {
            bookingValidationData = DecryptBookingValidationCodeHandler.decrypt(new List<String>{bookingEncrypted.Encrypted_Validation_Code__c});
        }
        Test.stopTest();
        System.assertEquals(bookingValidationData[0].bookingName, bookingEncrypted.Name);
        System.assertEquals(bookingValidationData[0].bookingValidationCode, bookingEncrypted.Validation_Code__c);
    }
    @IsTest
    static void DecryptValidationCodeFailure_InternalUserTriesToDecrypt_ValidationCodeNotDecrypted() {
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData;
        Test.startTest();
        Booking__c bookingEncrypted = [SELECT Id, Name, Validation_Code__c, Encrypted_Validation_Code__c FROM Booking__c LIMIT 1];
        bookingValidationData = DecryptBookingValidationCodeHandler.decrypt(new List<String>{bookingEncrypted.Encrypted_Validation_Code__c});
        Test.stopTest();
        System.assertEquals(bookingValidationData[0], null);
    }
}