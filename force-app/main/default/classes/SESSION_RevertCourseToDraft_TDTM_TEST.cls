@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    @TestSetup
    private static void setupTestData() {
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId();
        Account account = new Account(
            RecordtypeId = branchRecordTypeId,
            Name = 'TestBranch'
        );
        insert account;

        Id practitionerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Practitioner').getRecordTypeId();
        Contact practitioner = new Contact(RecordTypeId = practitionerRecordTypeId, LastName = 'Practitioner', AccountId = account.id );
        insert practitioner;

        Venue__c venue = new Venue__c(
            Name = 'TestVenue',
            Street_Address__c = '123 Secret Street',
            Town__c = 'Baltimore',
            Postcode__c = '20755',
            Type__c = 'Commercial',
            Subtype__c = 'Primary'
        );
        insert venue;

        Room__c room = new Room__c(
            Venue__c = venue.Id
        );
        insert room;

        Licence_To_Practice__c licenceToPractice = new Licence_To_Practice__c(
            Contact__c = practitioner.Id,
            Start_Date__c = Date.Today(),
            Status__c = 'Full',
            Licence__c = 'Postnatal Practitioner'
        );
        insert licenceToPractice;

        Course__c course = new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 100,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = account.Id,
            Main_Practitioner_Licence__c = licenceToPractice.Id
        );
        insert course;

        Session__c session = new Session__c(
            Name = 'testSession',
            Type__c = 'Standard',
            Date__c = Date.today() + 5,
            Start__c = Time.newInstance(18, 30, 0, 0),
            End__c = Time.newInstance(18, 30, 2, 20),
            Attendee_Type__c = 'Women only',
            Practitioner_Licence__c = licenceToPractice.Id,
            Venue__c = venue.Id,
            Course__c = course.Id,
            Room__c = room.Id,
            Status__c = 'Confirmed'
        );

        insert session;

        List<Estimated_Costs__c> estimatedCosts = new List<Estimated_Costs__c>();
        estimatedCosts.add(new Estimated_Costs__c(Type__c = 'Practitioner Fee', Course__c = course.Id, Amount__c = 1));
        estimatedCosts.add(new Estimated_Costs__c(Type__c = 'Travel', Course__c = course.Id, Amount__c = 1));
        estimatedCosts.add(new Estimated_Costs__c(Type__c = 'Venue', Course__c = course.Id, Amount__c = 1));
        insert estimatedCosts;
    }


    @isTest
    static void revertDraftAfterInsert() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];

        Session__c session2 = new Session__c(
            Name = 'testSession2',
            Type__c = 'Standard',
            Date__c = Date.today() + 5,
            Start__c = Time.newInstance(18, 30, 0, 0),
            End__c = Time.newInstance(18, 30, 2, 20),
            Attendee_Type__c = 'Women only',
            Practitioner_Licence__c = practitionerLicence.Id,
            Venue__c = venue.Id,
            Course__c = course.Id,
            Room__c = room.Id,
            Status__c = 'Confirmed'
        );
        insert session2;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }

    @isTest
    static void revertDraftAfterDateUpdate() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.Date__c = Date.today();
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }


    @isTest
    static void revertDraftAfterStartTimeUpdate() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.Start__c = Time.newInstance(19, 00, 0, 0);
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }

    @isTest
    static void revertDraftAfterEndTimeUpdate() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.End__c = Time.newInstance(02, 00, 0, 0);
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }

    @isTest
    static void revertDraftAfterLunchBreakMinutesUpdate() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.Lunch_Break_Minutes__c = 15;
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);

    }

    @isTest
    static void revertDraftAfterPractitionerLicenceUpdate() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId();
        Account account = new Account(
            RecordtypeId = branchRecordTypeId,
            Name = 'TestBranch'
        );
        insert account;

        Id practitionerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Practitioner').getRecordTypeId();
        Contact practitioner2 = new Contact(RecordTypeId = practitionerRecordTypeId, LastName = 'Practitioner2', AccountId = account.id );
        insert practitioner2;

        Licence_To_Practice__c licenceToPractice2 = new Licence_To_Practice__c(
            Contact__c = practitioner2.Id,
            Start_Date__c = Date.Today(),
            Status__c = 'Full',
            Licence__c = 'Postnatal Practitioner'
        );
        insert licenceToPractice2;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.Practitioner_Licence__c = licenceToPractice2.Id;
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }

    @isTest
    static void revertDraftAfterVenueUpdate() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Venue__c venue = new Venue__c(
            Name = 'TestVenue2',
            Street_Address__c = '123 Secret Street',
            Town__c = 'London',
            Postcode__c = '20745',
            Type__c = 'Commercial',
            Subtype__c = 'Primary'
        );
        insert venue;

        Room__c room = new Room__c(
            Venue__c = venue.Id
        );
        insert room;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id];
        session.Venue__c = venue.Id;
        session.Room__c = room.Id;
        update session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }

    @isTest
    static void revertDraftAfterSessionDeletion() {
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = 'Final';
        update course;

        Session__c session = [SELECT Id FROM Session__c WHERE Course__c =:course.Id];
        delete session;

        test.stopTest();

        System.assertEquals('Draft', [SELECT Status__c FROM Course__c WHERE Id = :course.Id].Status__c);
    }
}