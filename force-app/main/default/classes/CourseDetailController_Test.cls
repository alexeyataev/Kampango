@IsTest
public with sharing class CourseDetailController_Test {
    
    @TestSetup
    private static void createTestData(){
        Account branch = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Branch'
        );
        insert branch;
        Contact practitioner = new Contact(
            RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Practitioner').getRecordTypeId(),
            LastName = 'Test'
        );
        insert practitioner;
        List<Course__c> courses = new List<Course__c>{
            new Course__c(
                Status__c = 'Draft',
                Branch__c = branch.Id,
                //Practitioner__c = practitioner.Id,
                Number_of_places__c = 15,
                Type__c = 'Postnatal',
                Sub_Type__c = 'Baby Massage'
            ),
            new Course__c(
                Status__c = 'Draft',
                Branch__c = branch.Id,
                //Practitioner__c = practitioner.Id,
                Number_of_places__c = 10,
                Type__c = 'Antenatal',
                Sub_Type__c = 'NCT Essentials Antenatal'
            )
        };
        insert courses;
        List<Session__c> sessions = new List<Session__c>{
            new Session__c(
                Course__c = courses[0].Id,
                Type__c = 'Standard',
                Date__c = System.today(),
                End__c = Time.newInstance(11, 0, 0, 0),
                Start__c = Time.newInstance(10, 0, 0, 0),
                Status__c = 'Provisional',
                Attendee_Type__c = 'Women Only'
            ),
            new Session__c(
                Course__c = courses[0].Id,
                Type__c = 'Standard',
                Date__c = System.today(),
                End__c = Time.newInstance(12, 0, 0, 0),
                Start__c = Time.newInstance(11, 0, 0, 0),
                Status__c = 'Provisional',
                Attendee_Type__c = 'Women Only'
            ),
            new Session__c(
                Course__c = courses[1].Id,
                Type__c = 'Standard',
                Date__c = System.today(),
                End__c = Time.newInstance(11, 0, 0, 0),
                Start__c = Time.newInstance(10, 0, 0, 0),
                Status__c = 'Provisional',
                Attendee_Type__c = 'Women Only'
            )
        };
        insert sessions;
    }

    @IsTest
    private static void testSessionRetrieval(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Postnatal'].Id;
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        System.assertEquals(2, sessions.size());
    }

}
