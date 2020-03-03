@IsTest
public with sharing class CreateGiftAidDeclarationHelperTest {

    @TestSetup
    static void makeData() {
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Lola Household'
        );

        insert account;

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Lola')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
    }

    @IsTest
    static void createGiftAidDeclaration_insertGiftAidDeclarationListWithOneRecord_returnOneRecord() {

        Contact cont = [SELECT Id FROM Contact LIMIT 1];

        List<gaid__Gift_Aid_Declaration__c> gadList = new List<gaid__Gift_Aid_Declaration__c>();

        gaid__Gift_Aid_Declaration__c gadInstance = new gaid__Gift_Aid_Declaration__c();
        gadInstance.Method__c = 'GiftAid';
        gadInstance.gaid__Acquisition_Method__c = 'Digital';
        gadInstance.gaid__Contact__c = cont.Id;

        gadList.add(gadInstance);

        Test.startTest();
            CreateGiftAidDeclarationHelper.CreateGiftAidDeclaration(new List<List<gaid__Gift_Aid_Declaration__c>>{gadList});
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM gaid__Gift_Aid_Declaration__c].size(), 'Return 1 record');

    }

    @IsTest
    static void createGiftAidDeclaration_insertEmptyGiftAidDeclarationList_returnEmptyList() {

        Contact cont = [SELECT Id FROM Contact LIMIT 1];

        List<gaid__Gift_Aid_Declaration__c> gadList = new List<gaid__Gift_Aid_Declaration__c>();

        gaid__Gift_Aid_Declaration__c gadInstance = new gaid__Gift_Aid_Declaration__c();

        Test.startTest();
            CreateGiftAidDeclarationHelper.CreateGiftAidDeclaration(new List<List<gaid__Gift_Aid_Declaration__c>>{gadList});
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM gaid__Gift_Aid_Declaration__c].size(), 'Return empty list');

    }

}
