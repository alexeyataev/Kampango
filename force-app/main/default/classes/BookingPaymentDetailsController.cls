public with sharing class BookingPaymentDetailsController {
    public String bookingId { get; set; }
    public List<Booking__c> bookingList { get; set; }
    
    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
        refreshBookingList();
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #33 - https://confluence.nct.org.uk:8443/x/EoSO
    private void refreshBookingList() {
        bookingList = [
            SELECT Course_Fee__c, Confirmed_Date__c, Course_Sub_Type__c, Fee_Override__c, Status__c
            FROM Booking__c
            WHERE Id = :bookingId 
            WITH SECURITY_ENFORCED
        ];
    }
}