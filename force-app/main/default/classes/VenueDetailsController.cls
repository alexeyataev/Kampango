public without sharing class VenueDetailsController {

    public Course__c courseRecord {get; set;}


    public class VenueResult {
        public String name {get; set;}
        public Boolean isMainVenue {get; set;}
        public String address {get; set;}

        public VenueResult(Venue__c venue, Course__c courseRecord) {
            this.name = venue.Name;
            this.isMainVenue = (venue.Id == courseRecord.Main_venue__c);
            this.address = venue.Street_Address__c + ', ' + venue.Town__c + ', ' + venue.Postcode__c;
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
                IN (SELECT Venue__c 
                    FROM Session__c 
                    WHERE Course__c = :courseRecord.Id)
            WITH SECURITY_ENFORCED
        ]) {
            result.add(new VenueResult(venue, courseRecord));            
        }

        return result;

        /*return [
            SELECT Name, Street_Address__c, Postcode__c 
            FROM Venue__c 
            WHERE Id 
                IN (SELECT Venue__c 
                    FROM Session__c 
                    WHERE Course__c = :courseRecord.Id)
            WITH SECURITY_ENFORCED
        ];*/
    }
}

