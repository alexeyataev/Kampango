@IsTest
public with sharing class BookingPaymentDetailsControllerTest {
    private static final String BOOKING_STATUS_CONFIRMED = 'Confirmed';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';

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
        Booking__c bookingRecord = [
            SELECT Id, Status__c 
            FROM Booking__c 
            LIMIT 1
        ];

        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            bookingRecord.Status__c = BOOKING_STATUS_CONFIRMED;
            update bookingRecord;
        }

        Test.startTest();
            BookingPaymentDetailsController bookingPaymentDetailsControllerInstance = new BookingPaymentDetailsController();
            bookingPaymentDetailsControllerInstance.setBookingId(bookingRecord.Id);
        Test.stopTest();

        System.assertEquals(1, bookingPaymentDetailsControllerInstance.bookingList.size());
        System.assertEquals(bookingRecord.Id, bookingPaymentDetailsControllerInstance.bookingList.get(0).Id);
        System.assertEquals(BOOKING_STATUS_CONFIRMED, bookingPaymentDetailsControllerInstance.bookingList.get(0).Status__c);

    }
}