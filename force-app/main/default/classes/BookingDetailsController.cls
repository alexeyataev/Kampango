public without sharing class BookingDetailsController {

    public Course__c courseRecord {get; set;}

    public List<Booking__c> getBookings() {

        return [
            SELECT Name, Birth_Due_Date__c, First_Baby__c 
            FROM Booking__c 
            WHERE Course__c = :courseRecord.Id 
                AND Status__c = 'Confirmed'
            WITH SECURITY_ENFORCED
        ];
    }
}
