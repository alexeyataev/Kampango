public without sharing class BookingDetailsController {

    public Course__c courseRecord {get; set;}
    public String bookingFieldSetName {get; set;}
    @TestVisible
    public Map<Id, Contact> bookingContacts {get; set;}
    public String bookingContactFieldSetName{get; set;}

    public List<Booking__c> getBookings() {

        String query = 'SELECT ';

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Booking__c.fieldSets.getMap().get(bookingFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Primary_Contact__c, Partner_Contact__c, Id FROM Booking__c WHERE Course__c = \'' + courseRecord.Id + '\' AND Status__c = \'Confirmed\' WITH SECURITY_ENFORCED';
        
        List<Booking__c> bookings = Database.query(query);
        
        setBookingContacts(bookings);

        return bookings;
    }

    private void setBookingContacts(List<Booking__c> bookings) {
        Set<Id> bookingContactIds = new Set<Id>();
        
        for(Booking__c booking : bookings){
            bookingContactIds.add(booking.Primary_Contact__c);
            if(booking.Partner_Contact__c != null){
                bookingContactIds.add(booking.Partner_Contact__c);
            }
        }

        String query = 'SELECT ';

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Contact.fieldSets.getMap().get(bookingContactFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Contact WHERE Id IN :bookingContactIds WITH SECURITY_ENFORCED';

        bookingContacts = new Map<Id, Contact>((List<Contact>)Database.query(query));
    }
}
