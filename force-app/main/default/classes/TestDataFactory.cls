public without sharing class TestDataFactory {
    public static List<Venue__c> venues;
    public static List<Account> accounts;
    public static List<Contact> contacts;
    public static List<Room__c> rooms;
    public static List<Licence_To_Practice__c> licenceToPractices;
    public static List<Course__c> courses;
    public static List<Session__c> sessions;
    public static List<Estimated_Costs__c> estimatedCosts;

    public static List<Venue__c> createVenues(){
        venues = new List<Venue__c>();

        venues.add(
            new Venue__c(
                Name = 'TestVenue',
                Street_Address__c = '123 Secret Street',
                Town__c = 'Baltimore',
                Postcode__c = '20755',
                Type__c = 'Commercial',
                Subtype__c = 'Primary'
            )
        );
        insert venues;
        return venues;
    }

    public static List<Account> createAccountBranch(){
        accounts = new List<Account>();

        Id branchAccountRecodrType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId();

        accounts.add(
            new Account(
                RecordtypeId = branchAccountRecodrType,
                Name = 'TestBranch'
            )
        );
        insert accounts;
        return accounts;
    }

    public static List<Contact> createContactPractitioner(){
        contacts = new List<Contact>();

        Id practitionerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Practitioner').getRecordTypeId();
        //0
        contacts.add(
            new Contact(
                RecordTypeId = practitionerRecordTypeId,
                LastName = 'Practitioner',
                AccountId = accounts[0].Id
            )
        );
        //1
        contacts.add(
            new Contact(
                RecordTypeId = practitionerRecordTypeId,
                LastName = 'Practitioner2',
                AccountId =  accounts[0].Id
            )
        );
        insert contacts;
        return contacts;
    }

    public static List<Room__c> createRooms(){
        rooms = new List<Room__c>();

        rooms.add(
            new Room__c(
                Venue__c = venues[0].Id
            )
        );
        insert rooms;
        return rooms;
    }

    public static List<Licence_To_Practice__c> createLicenceToPractices(){
        licenceToPractices = new List<Licence_To_Practice__c>();

        licenceToPractices.add(
            new Licence_To_Practice__c(
                Contact__c = contacts[0].Id,
                Start_Date__c = Date.Today(),
                Status__c = 'Full',
                Licence__c = 'Postnatal Practitioner'
            )
        );
        insert licenceToPractices;
        return licenceToPractices;
    }

    public static List<Course__c> createCourses() {
        courses = new List<Course__c>();
        //0
        courses.add(new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 100,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = accounts[0].Id,
            Main_Practitioner_Licence__c = licenceToPractices[0].Id
        ));
        //1
        courses.add(new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 100,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = accounts[0].Id,
            Main_Practitioner_Licence__c = licenceToPractices[0].Id
        ));
        //2
        courses.add(new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 78,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = accounts[0].Id,
            Main_Practitioner_Licence__c = licenceToPractices[0].Id
        ));
        //3
        courses.add(new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 34,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = accounts[0].Id,
            Main_Practitioner_Licence__c = licenceToPractices[0].Id
        ));
        //4
        courses.add(new Course__c(
            Type__c = 'Antenatal',
            Sub_Type__c = 'One to One',
            Fee__c = 345,
            Status__c = 'Draft',
            Number_of_places__c = 3,
            Branch__c = accounts[0].Id,
            Main_Practitioner_Licence__c = licenceToPractices[0].Id
        ));
        insert courses;
        return courses;
    }

    public static  List<Session__c> createSessions(){
        sessions = new List<Session__c>();

        sessions.add(
            //0
            new Session__c(
                Name = 'testSession1',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[0].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //1
        sessions.add(
            new Session__c(
                Name = 'testSession2',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[0].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //2
        sessions.add(
            new Session__c(
                Name = 'testSession3',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[1].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //3
        sessions.add(
            new Session__c(
                Name = 'testSession4',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[1].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //4
        sessions.add(
            new Session__c(
                Name = 'testSession5',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[2].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //5
        sessions.add(
            new Session__c(
                Name = 'testSession5',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[2].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //6
        sessions.add(
            new Session__c(
                Name = 'testSession6',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[3].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //7
        sessions.add(
            new Session__c(
                Name = 'testSession7',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[3].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //8
        sessions.add(
            new Session__c(
                Name = 'testSession8',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[4].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //9
        sessions.add(
            new Session__c(
                Name = 'testSession9',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[4].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        //10
        sessions.add(
            new Session__c(
                Name = 'testSession10',
                Type__c = 'Standard',
                Date__c = Date.today() + 5,
                Start__c = Time.newInstance(18, 30, 0, 0),
                End__c = Time.newInstance(18, 30, 2, 20),
                Specific_Attendee_Type__c = 'Women only',
                Practitioner_Licence__c = licenceToPractices[0].Id,
                Venue__c = venues[0].Id,
                Course__c = courses[4].Id,
                Room__c = rooms[0].Id,
                Status__c = 'Confirmed'
            ));
        insert sessions;
        return sessions;
    }

    public static List<Estimated_Costs__c> createEstimatedCosts(){
        estimatedCosts = new List<Estimated_Costs__c>();

        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Practitioner Fee',
                Course__c = courses[0].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Travel',
                Course__c = courses[0].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Venue',
                Course__c = courses[0].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Practitioner Fee',
                Course__c = courses[1].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Travel',
                Course__c = courses[1].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Venue',
                Course__c = courses[1].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Practitioner Fee',
                Course__c = courses[2].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Travel',
                Course__c = courses[2].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Venue',
                Course__c = courses[2].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Practitioner Fee',
                Course__c = courses[3].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Travel',
                Course__c = courses[3].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Venue',
                Course__c = courses[3].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Practitioner Fee',
                Course__c = courses[4].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Travel',
                Course__c = courses[4].Id,
                Amount__c = 1)
        );
        estimatedCosts.add(
            new Estimated_Costs__c(
                Type__c = 'Venue',
                Course__c = courses[4].Id,
                Amount__c = 1)
        );
        insert estimatedCosts;

        return estimatedCosts;
    }

}