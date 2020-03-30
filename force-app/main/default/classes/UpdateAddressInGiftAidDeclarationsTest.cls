@SuppressWarnings('PMD.MethodNamingConventions')

@isTest
public with sharing class UpdateAddressInGiftAidDeclarationsTest {

    private static final String PRIMARY_CONTACT_NAME = 'Dina';
    private static final String PRIMARY_CONTACT_EMAIL = 'test1@test.com';

    @TestSetup
    static void setupData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc2')
                    .buildParentHost(PRIMARY_CONTACT_NAME, PRIMARY_CONTACT_EMAIL)
                    .buildGiftAidDeclaration();
    }

    @isTest
    static void UpdateGiftAidAdress_ChangedAddresInContact_GiftAidAddressEqualsContactAddress() {

        gaid__Gift_Aid_Declaration__c gadInstanceBeforeUpdate = [SELECT gaid__Housename_or_number__c, gaid__Postalcode__c FROM gaid__Gift_Aid_Declaration__c];
        Contact contactInstanceBeforeUpdate = [SELECT MailingStreet, MailingPostalCode FROM Contact LIMIT 1];

        System.assertEquals(gadInstanceBeforeUpdate.gaid__Housename_or_number__c,
                            contactInstanceBeforeUpdate.MailingStreet,
                            'Gift Aid HousenameOrNumber equals Contact MailingStreet');

        System.assertEquals(gadInstanceBeforeUpdate.gaid__Postalcode__c, 
                            contactInstanceBeforeUpdate.MailingPostalCode, 
                            'Gift Aid Postalcode equals Contact mailingPostalCode');

        Test.startTest();
            contactInstanceBeforeUpdate.MailingStreet = '63 Street';
            contactInstanceBeforeUpdate.MailingPostalCode = 'AAA BBB';
            update contactInstanceBeforeUpdate;
        Test.stopTest();

        gaid__Gift_Aid_Declaration__c gadInstanceAfterUpdate = [SELECT gaid__Housename_or_number__c, gaid__Postalcode__c FROM gaid__Gift_Aid_Declaration__c];
        Contact contactInstanceAfterUpdate = [SELECT MailingStreet, MailingPostalCode FROM Contact LIMIT 1];

        System.assertEquals(gadInstanceAfterUpdate.gaid__Housename_or_number__c,
                            contactInstanceAfterUpdate.MailingStreet,
                            'Gift Aid HousenameOrNumber should equal Contact MailingStreet');

        System.assertEquals(gadInstanceAfterUpdate.gaid__Postalcode__c,
                            contactInstanceAfterUpdate.MailingPostalCode,
                            'Gift Aid Postalcode should equal Contact mailingPostalCode');

    }
}
