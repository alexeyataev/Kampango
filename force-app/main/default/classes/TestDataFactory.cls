@isTest
public without sharing class TestDataFactory {
    public static List<Venue__c> venues = [SELECT Id FROM Venue__c LIMIT 5];
    public static List<Account> accounts = [SELECT Id FROM Account LIMIT 5];
    public static List<Room__c> rooms = [SELECT Id FROM Room__c LIMIT 5];
    public static List<Licence_To_Practice__c> licenceToPractices = [SELECT Id FROM Licence_To_Practice__c LIMIT 5];
    public static List<Course__c> courses;
    public static Course__c course0;
    public static Course__c course1;
    public static Course__c course2;
    public static Course__c course3;

    public static void createCourses() {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course0 = courseBuilder
            .WithAccount(accounts[0])
            .WithLicenceToPractice(licenceToPractices[0])
            .InsertRecord(true)
            .Build();
        course1 = courseBuilder
            .WithAccount(accounts[0])
            .WithLicenceToPractice(licenceToPractices[0])
            .InsertRecord(true)
            .Build();
        course2 = courseBuilder
            .WithAccount(accounts[0])
            .WithLicenceToPractice(licenceToPractices[0])
            .InsertRecord(true)
            .Build();
        course3 = courseBuilder
            .WithAccount(accounts[0])
            .WithLicenceToPractice(licenceToPractices[0])
            .InsertRecord(true)
            .Build();
    }

    public static void createSessions(){
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        sessionBuilder
            .WithCourse(course0)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course0)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course1)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course1)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course2)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course2)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course3)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
        sessionBuilder
            .WithCourse(course3)
            .WithVenue(venues[0])
            .WithPractitionerLicence(licenceToPractices[0])
            .WithRoom(rooms[0])
            .InsertRecord(true)
            .Build();
    }

    public static void createEstimatedCosts(){
        TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
        estimatedCostsBuilder
            .WithCourse(course0)
            .WithType('Travel')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course0)
            .WithType('Venue')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course0)
            .WithType('Practitioner Fee')
            .InsertRecord(true)
            .Build();

        estimatedCostsBuilder
            .WithCourse(course1)
            .WithType('Travel')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course1)
            .WithType('Venue')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course1)
            .WithType('Practitioner Fee')
            .InsertRecord(true)
            .Build();

        estimatedCostsBuilder
            .WithCourse(course2)
            .WithType('Travel')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course2)
            .WithType('Venue')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course2)
            .WithType('Practitioner Fee')
            .InsertRecord(true)
            .Build();

        estimatedCostsBuilder
            .WithCourse(course3)
            .WithType('Travel')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course3)
            .WithType('Venue')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course3)
            .WithType('Practitioner Fee')
            .InsertRecord(true)
            .Build();
    }

}