@IsTest
public class BookingFlowUpdateNctNumberTest {

    private static final Id RECORD_TYPE_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Household Account Test';

    public static String createPrimaryContact(){
        Account account = new Account (
            RecordTypeId = RECORD_TYPE_ID,
            Name = ACCOUNT_NAME
        );
        insert account;
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Dina')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        return primaryContact.Id;
    }

     public static String createPartnerContact(){
        Account account = new Account(
            RecordTypeId = RECORD_TYPE_ID,
            Name = ACCOUNT_NAME
        );

        insert account;
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        return partnerContact.Id;
    }

    @IsTest
    public static void checkNctNumber_SetNctNumberAndUpdate_NctNumberNotBeEmpty() {
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        
        List<Contact> primaryContact = [
            SELECT Id, NCT_Number__c
            FROM Contact
            WHERE Id = :primaryId
        ];

        primaryContact[0].NCT_Number__c = '111111';

        Test.startTest();
        BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{primaryContact});
        Test.stopTest();

        System.assertEquals('111111', [SELECT Name, NCT_Number__c FROM Contact][0].NCT_Number__c);
    }

    @IsTest
    public static void checkNctNumber_SetNctNumberAndUpdateForPartnerAndPrimaryContact_NctNumbersNotBeEmpty() {
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        String partnerId = BookingJourneyHelperTest.createPartnerContact();
        
        Set<Id> contactIds = new Set<Id> {
            primaryId,
            partnerId
        };
        
        List<Contact> contactList = [
            SELECT Id, NCT_Number__c
            FROM Contact
            WHERE Id in :contactIds
        ];

        contactList[0].NCT_Number__c = '111111';
        contactList[1].NCT_Number__c = '222222';

        Test.startTest();
        BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{contactList});
        Test.stopTest();

        System.debug([SELECT Name, NCT_Number__c FROM Contact]);
        
        System.assertEquals('111111', [SELECT Name, NCT_Number__c FROM Contact][0].NCT_Number__c);
        System.assertEquals('222222', [SELECT Name, NCT_Number__c FROM Contact][1].NCT_Number__c);

        
    }
}