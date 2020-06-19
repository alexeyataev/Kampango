public without sharing class BookingPaymentDetailsController {
    public String bookingId { get; }
    public Booking__c booking { get; set; }

    public void setBookingId(String bookingId) {
        refreshBooking(bookingId);
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #33 - https://confluence.nct.org.uk:8443/x/EoSO
    private void refreshBooking(Id bookingId) {
        booking = [
            SELECT Confirmed_Date__c, Course_Sub_Type__c, Status__c, Booking_Journey_Payable_Amount__c, Fee_Override__c, Next_Collection_Date__c
            FROM Booking__c
            WHERE Id = :bookingId 
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
}