@SuppressWarnings('PMD.ApexSOQLInjection')
//Incident #50 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class VenueDetailsController {

    public Course__c courseRecord {get; set;}
    public static String venueContactFieldSetName {get; set;}

    public class VenueResult {
        public Venue__c venue {get; set;}
        public Boolean isMainVenue {get; set;}
        public String address {get; set;}
        public List<Contact> emergencyContacts {get; set;}
        
        public VenueResult(Venue__c venue, Course__c courseRecord) {
            this.venue = venue;
            this.isMainVenue = (venue.Id == courseRecord.Main_venue__c);
        
            for (Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Venue__c.fieldSets.CourseSummaryVenueAddressFields.getFields()) {
                if (String.isBlank(this.address)) {
                    this.address = '';
                } else {
                    this.address += ', ';
                }

                if (venue.get(fieldSetMember.getFieldPath()) != null) {
                    this.address += venue.get(fieldSetMember.getFieldPath());
                }
            }

           this.emergencyContacts = getContacts(venue.id);

        }
    }

    private Course__c getCourseMainVenue() {
        return [
                SELECT Main_venue__c
                FROM Course__c
                WHERE Id = :courseRecord.Id
        ];
    } 
    

    public List<VenueResult> getVenues() {

        List<VenueResult> result = new List<VenueResult>();

        courseRecord = getCourseMainVenue();

        for (Venue__c venue : [
                SELECT Name, Street_Address__c, Town__c, Postcode__c
                FROM Venue__c
                WHERE Id
                        IN (
                                SELECT Venue__c
                                FROM Session__c
                                WHERE Course__c = :courseRecord.Id
                        )
                WITH SECURITY_ENFORCED
        ]) {
            result.add(new VenueResult(venue, courseRecord));
        }

        return result;
    }

    private static List<Contact> getContacts(Id venueId) {

        Set<Id> contactIds = new Set<Id>();

        for (Venue_Contact__c venueCont : [
                SELECT Contact__c
                FROM Venue_Contact__c
                WHERE Venue__c = :venueId
                AND Type__c IN ('Emergency', 'Alternate Emergency')
                WITH SECURITY_ENFORCED
        ]) {
            contactIds.add(venueCont.Contact__c);
        }

        String query = 'SELECT ';

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Contact.fieldSets.getMap().get(venueContactFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Contact WHERE Id IN :contactIds WITH SECURITY_ENFORCED';

        return (List<Contact>)Database.query(query);
    }
}

