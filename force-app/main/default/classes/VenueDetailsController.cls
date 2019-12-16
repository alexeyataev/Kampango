public without sharing class VenueDetailsController {

    public Course__c courseRecord {get; set;}

    public class VenueResult {
        public String name {get; set;}
        public Boolean isMainVenue {get; set;}
        public String address {get; set;}
        public List<Id> emergencyContactIds {get; set;}
        
        public VenueResult(Venue__c venue, Course__c courseRecord) {
            this.name = venue.Name;
            this.isMainVenue = (venue.Id == courseRecord.Main_venue__c);

            for (Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Venue__c.fieldSets.CourseSummaryVenueFields.getFields()) {
                if (String.isBlank(this.address)) {
                    this.address = '';
                } else {
                    this.address += ', ';
                }

                if (venue.get(fieldSetMember.getFieldPath()) != null) {
                    this.address += venue.get(fieldSetMember.getFieldPath());
                }
            }

            this.emergencyContactIds = getContactIds(venue.id);

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


    private static List<Id> getContactIds(Id venueId) {

        Set<Id> result = new Set<Id>();

        for (Venue_Contact__c venueCont : [
                SELECT Contact__c
                FROM Venue_Contact__c
                WHERE Venue__c = :venueId
                AND Type__c = 'Emergency'
                WITH SECURITY_ENFORCED
        ]) {
            result.add(venueCont.Contact__c);
        }

        return new List<Id>(result);
    }
}

