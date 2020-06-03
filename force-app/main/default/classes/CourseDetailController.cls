@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #53 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class CourseDetailController {
    @AuraEnabled(cacheable=true)
    public static List<Session__c> retrieveRelatedSessions(String courseId) {
        List<Session__c> sessions;
        sessions = [
            SELECT  Additional_Information_with_Venue__c,
                    Contact_Hours__c,
                    Date__c,
                    Delivery_Type__c,
                    End__c,
                    Location_County__c,
                    Location_Home_Information__c,
                    Location_Id__c,
                    Location_Name__c,
                    Location_Postcode__c,
                    Location_Street__c,
                    Location_Town__c,
                    Start__c,
                    Status__c,
                    Type__c
            FROM Session__c
            WHERE Course__c = :courseId
            AND (Status__c = 'Confirmed' OR Type__c = 'Reunion')
            WITH SECURITY_ENFORCED
            ORDER BY Date__c, Start__c
        ];

        return sessions;
    }

    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getCourseDetailsInformation(String bookingId) {
        return [
            SELECT  Booking__c.Name,
                    Booking__c.Final_Fee__c,
                    Booking__c.First_Name__c,
                    Booking__c.Last_Name__c,
                    Booking__c.PSA_Office__c,
                    Booking__c.Reservation_Expiry_Date__c,
                    Booking__c.Course__c,
                    Booking__c.Course__r.Name,
                    Booking__c.Course__r.Additional_Offer_Information__c,
                    Booking__c.Course__r.Branch__r.Name,
                    Booking__c.Course__r.End_Date__c,
                    Booking__c.Course__r.Main_Venue_Name__c,
                    Booking__c.Course__r.PSA_Area__c,
                    Booking__c.Course__r.Start_Date__c,
                    Booking__c.Course__r.Title__c
             FROM Booking__c
             WHERE Id = :bookingId
        ];
    }

}