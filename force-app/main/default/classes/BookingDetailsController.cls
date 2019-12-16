public without sharing class BookingDetailsController {

    public Course__c courseRecord {get; set;}
    public String bookingFieldSetName {get; set;}

    public class BookingResult {
        public Booking__c booking {get; set;}
        public List<Id> primaryContactIds {get; set;}
        public List<Id> partnerContactIds {get; set;}
        
        public BookingResult(Booking__c booking) {
            this.booking = booking;
            this.primaryContactIds = new List<Id> {booking.Primary_Contact__c};
            this.partnerContactIds = new List<Id> {booking.Partner_Contact__c};
        }
    }

    public List<BookingResult> getBookings() {

        List<BookingResult> result = new List<BookingResult>();

        String query = 'SELECT ';

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Booking__c.fieldSets.getMap().get(bookingFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Primary_Contact__c, Partner_Contact__c, Id FROM Booking__c WHERE Course__c = \'' + courseRecord.Id + '\' AND Status__c = \'Confirmed\' WITH SECURITY_ENFORCED';
        
        for (Booking__c booking : Database.query(query)) {
            result.add(new BookingResult(booking));
        }
        return result;
    }
}
