@IsTest
public with sharing class BookingPaymentDetailsControllerTest {
    private static final String BOOKING_STATUS_CONFIRMED = 'Confirmed';

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
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildBooking('Reserved');
    }

    @IsTest
    public static void changeBookingStatus_bookingStatus_bookingStatusIsConfirmed() {
        Booking__c bookingRecord = [SELECT Id, Status__c FROM Booking__c LIMIT 1];
        
        System.runAs(TestHelper.assignPermissionSetToUser('Override_Booking_Validation', 'Enquiry PSA')) {
            bookingRecord.Status__c = BOOKING_STATUS_CONFIRMED;
            update bookingRecord;
        }

        Test.startTest();
            BookingPaymentDetailsController bookingPaymentDetailsControllerInstance = new BookingPaymentDetailsController();
            bookingPaymentDetailsControllerInstance.setBookingIdParam(bookingRecord.Id);
        Test.stopTest();

        System.assertEquals(bookingPaymentDetailsControllerInstance.bookingList.size(), 1);
        System.assertEquals(bookingPaymentDetailsControllerInstance.bookingList.get(0).Status__c, BOOKING_STATUS_CONFIRMED);
        
    }
}