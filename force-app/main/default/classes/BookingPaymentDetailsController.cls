public with sharing class BookingPaymentDetailsController {
    public String bookingId { get; }
    public List<Booking__c> bookingList { get; set; }

    public void setBookingId(String bookingId) {
        refreshBookingList(bookingId);
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #33 - https://confluence.nct.org.uk:8443/x/EoSO
    private void refreshBookingList(Id bookingId) {
        bookingList = [
            SELECT Confirmed_Date__c, Course_Sub_Type__c, Status__c, Booking_Journey_Payable_Amount__c, Fee_Override__c
            FROM Booking__c
            WHERE Id = :bookingId 
            WITH SECURITY_ENFORCED
        ];
    }
}