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
            LastName = 'Test',
            AccountId = branch.Id
        );
        insert practitioner;
        Licence_To_Practice__c license = new Licence_To_Practice__c(
            Contact__c = practitioner.Id,
            Licence__c = 'Signature Antenatal Teacher',
            Start_Date__c = System.today(),
            Status__c = 'Full'
        );
        insert license;
        List<Course__c> courses = new List<Course__c>{
            new Course__c(
                Status__c = 'Draft',
                Branch__c = branch.Id,
                PSA_Branch__c = 'Bridport',
                PSA_Office__c = '1C',
                Practitioner__c = practitioner.Id,
                Number_of_places__c = 15,
                Type__c = 'Postnatal',
                Sub_Type__c = 'Baby Massage',
                Main_Practitioner_Licence__c = license.Id
            ),
            new Course__c(
                Status__c = 'Draft',
                Branch__c = branch.Id,
                PSA_Branch__c = 'Bridport',
                PSA_Office__c = '1C',
                Practitioner__c = practitioner.Id,
                Number_of_places__c = 10,
                Type__c = 'Antenatal',
                Sub_Type__c = 'NCT Essentials Antenatal',
                Main_Practitioner_Licence__c = license.Id
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
