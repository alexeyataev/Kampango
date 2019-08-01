public with sharing class TestDataFactory {

    public static Venue__c createVenue(){
        Venue__c venue = new Venue__c(
            Name = 'TestVenue',
            Street_Address__c = '123 Secret Street',
            Town__c = 'Baltimore',
            Postcode__c = '20755',
            Type__c = 'Commercial',
            Subtype__c = 'Primary'
        );
        return venue;
    }

    public static Id getPractitionerRecordTypeId() {
        return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Practitioner').getRecordTypeId();
    }

}