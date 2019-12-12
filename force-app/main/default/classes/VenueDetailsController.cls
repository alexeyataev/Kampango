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
            //this.address = venue.Street_Address__c + ', ' + venue.Town__c + ', ' + venue.Postcode__c;

            for (Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Venue__c.fieldSets.CourseSummaryVenueFields.getFields()) {

                //this.address = String.isBlank(this.address) ? '' : this.address + ', ';
                
                if (String.isBlank(this.address)) {
                    this.address = '';
                } else {
                    this.address += ', ';
                }
                this.address += venue.get(fieldSetMember.getFieldPath());
            }

            this.emergencyContactIds = getContactIds(venue.id);

        }
    }

    public Course__c getCourseMainVenue() {
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


    public static List<Id> getContactIds(Id venueId) {

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

    
    /*public Map<Id,List<Id>> getEmergencyContactIds() {

        //Set<Id> result = new Set<Id>();
        Map<Id,List<Id>> result = new Map<Id,List<Id>>();
        

        for (Venue_Contact__c venueCont : [
                SELECT Contact__c, Venue__c
                FROM Venue_Contact__c
                WHERE Venue__c
                        IN (
                                SELECT Venue__c
                                FROM Session__c
                                WHERE Course__c = :courseRecord.Id
                        )
                AND Type__c = 'Emergency'
                WITH SECURITY_ENFORCED
        ]) {
            //result.add(venueCont.Contact__c);
            if (result.containsKey(venueCont.Venue__c)) {
                result.get(venueCont.Venue__c).add(venueCont.Contact__c);
            } else {
                List<Id> conts = new List<Id>();
                conts.add(venueCont.Contact__c);
                result.put(venueCont.Venue__c, conts);
            }

        }

        //return new List<Id>(result);
        return result;
    }*/
}

