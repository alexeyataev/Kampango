/**
 * Created by User on 07.10.2019.
 */
public with sharing class CourseLeaderTemplateComponentController {
    public static Id sessionId {
        get;
        set {
            sessionId = value;
            getSessionInfo(value);
        }
    }
    public static Session__c sessionInfo { get; set; }
    public static Venue__c venueInfo { get; set; }
    public static String sessionStartTime { get; set; }
    public static String sessionEndTime { get; set; }
    public static String sessionDate { get; set; }
    public static Course__c courseInfo { get; set; }
    public static Id courseId;

    public static void getSessionInfo(Id sessionId) {
        List<Session__c> confirmedSessionList = [
                SELECT Id, Name, Type__c, Start__c, End__c, Practitioner__r.FirstName, Venue__c, Day_of_Week__c, Date__c, Course__c
                FROM Session__c
                WHERE Id = :sessionId
                LIMIT 1
        ];

        sessionInfo = confirmedSessionList[0];
        courseId = sessionInfo.Course__c;
        sessionDate = sessionInfo.Date__c.format();
        String sessionStartHour = sessionInfo.Start__c.hour() < 9 ? '0' + String.valueOf(sessionInfo.Start__c.hour()) : String.valueOf(sessionInfo.Start__c.hour());
        String sessionEndHour = sessionInfo.End__c.hour() < 9 ? '0' + String.valueOf(sessionInfo.End__c.hour()) : String.valueOf(sessionInfo.End__c.hour());
        String sessionStartMinute = sessionInfo.Start__c.minute() < 9 ? '0' + String.valueOf(sessionInfo.Start__c.minute()) : String.valueOf(sessionInfo.Start__c.minute());
        String sessionEndMinute = sessionInfo.End__c.minute() < 9 ? '0' + String.valueOf(sessionInfo.End__c.minute()) : String.valueOf(sessionInfo.End__c.minute());
        sessionStartTime = sessionStartHour + ':' + sessionStartMinute;
        sessionEndTime = sessionEndHour + ':' + sessionEndMinute;

        List<Venue__c> venueOfSession = [
                SELECT Id, Name, Map_Url__c, Town__c, Street_Address__c, Type__c
                FROM Venue__c
                WHERE Id = :sessionInfo.Venue__c
                LIMIT 1
        ];
        venueInfo = venueOfSession[0];

        List<Course__c> coursesList = [
                SELECT Id, Name, Sub_Type__c, Branch__r.Capacity_PSA__r.Name, Branch__r.Capacity_PSA_Email__c, Branch__r.Capacity_PSA_Phone__c,
                        Branch__r.Enquiries_PSA__r.Name, Branch__r.Enquiries_PSA_Email__c, Branch__r.Enquiries_PSA_Phone__c
                FROM Course__c
                WHERE Id = :sessionInfo.Course__c
                LIMIT 1
        ];
        courseInfo = coursesList[0];

        List<Booking__c> bookings = [
                SELECT Id, Name, Primary_Contact__c, Primary_Contact_Email__c, First_Name_Partner__c, Course__c, First_Name__c
                FROM Booking__c
                WHERE Course__c = :courseId
        ];
    }

    public static String getHostClientNames(Id venueId) {
        Venue_Contact__c venueContact = [
                SELECT Venue__c, Contact__c
                FROM Venue_Contact__c
                WHERE Venue__c = :venueId
        ];

        return null;
    }

}