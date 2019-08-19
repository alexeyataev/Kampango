@isTest
public without sharing class TestDataFactory {
    public static Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
    public static Account account = [SELECT Id FROM Account LIMIT 1];
    public static Room__c room = [SELECT Id FROM Room__c LIMIT 1];
    public static Licence_To_Practice__c licenceToPractice = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
    public static Contact practitioner = [SELECT Id, LastName FROM Contact WHERE RecordType.Name = 'Practitioner' LIMIT 1];
    public static List<Course__c> courses = new List<Course__c>();
    public static List<Session__c> sessions = new List<Session__c>();

    public static void buildCoursesWithSessions(Integer numberOfCourses, Integer numberOfSessions) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();

        for(Integer i = 0; i < numberOfCourses; i++){
            courses.add(courseBuilder
                .WithAccount(account)
                .withPractitioner(practitioner)
                .WithLicenceToPractice(licenceToPractice)
                .InsertRecord(true)
                .Build());
        }

        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            estimatedCostsBuilder
                .WithCourse(courses[i])
                .WithType('Travel')
                .InsertRecord(true)
                .Build();
            estimatedCostsBuilder
                .WithCourse(courses[i])
                .WithType('Venue')
                .InsertRecord(true)
                .Build();
            estimatedCostsBuilder
                .WithCourse(courses[i])
                .WithType('Practitioner Fee')
                .InsertRecord(true)
                .Build();
        }

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();

        for(Integer i = 0; i < numberOfSessions; i++) {
            sessions.add(sessionBuilder
                .WithCourse(courses[i / 2])
                .WithVenue(venue)
                .WithRoom(room)
                .withStatus('Provisional')
                .InsertRecord(true)
                .Build());
        }
    }
}