public with sharing class BookingPaymentDetailsController {
    public String bookingIdParam { get;}
    public List<Booking__c> bookingList { get; set; }
    
    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #33 - https://confluence.nct.org.uk:8443/x/EoSO
    public void setBookingIdParam(String bookingId) {
        bookingList =  [
            SELECT Course_Fee__c,
                   Confirmed_Date__c,
                   Course_Sub_Type__c,
                   Fee_Override__c,
                   Status__c
            FROM Booking__c
            WHERE Id = :bookingId 
            WITH SECURITY_ENFORCED
        ];
    }
}