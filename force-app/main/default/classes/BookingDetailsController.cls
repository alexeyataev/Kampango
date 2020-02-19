@SuppressWarnings('PMD.ApexSOQLInjection')
//Incident #47 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class BookingDetailsController {

    public Course__c courseRecord {get; set;}
    public String bookingFieldSetName {get; set;}
    public Map<Id, Contact> bookingContacts {get; set;}
    public String bookingContactFieldSetName{get; set;}
    private static final String CONFIRMED_STATUS = 'Confirmed';

    public List<Booking__c> getBookings() {

        String query = 'SELECT ';
        Id courseId = courseRecord.Id;

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Booking__c.fieldSets.getMap().get(bookingFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Primary_Contact__c, Partner_Contact__c, Info_for_Practitioner__c, Id FROM Booking__c WHERE Course__c = :courseId AND Status__c = :CONFIRMED_STATUS AND Do_Not_Contact__c = false WITH SECURITY_ENFORCED';
        
        List<Booking__c> bookings = (List<Booking__c>)Database.query(query);
        
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
