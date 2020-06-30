@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #42 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public class IndividualBookingJourneyHelperTest {

    @TestSetup
    static void createTestData(){
        TestIndividualBuilder individualBuilder = new TestIndividualBuilder();
        Individual record = individualBuilder.withLastName('TestIndividual')
            .insertRecord(true)
            .build();
    }

    @IsTest
    static void updateIndividual_validIndividual_recordUpdated(){
        List<Individual> record = [
            SELECT Id, Has_Opted_In_Email__c, Has_Opted_In_Post__c,
            Has_Opted_In_SMS__c, Has_Opted_In_Telephone__c
            FROM Individual
            LIMIT 1
        ];
        record[0].Has_Opted_In_Email__c = false;
        record[0].Has_Opted_In_Post__c = false;
        record[0].Has_Opted_In_SMS__c = false;
        record[0].Has_Opted_In_Telephone__c = false;
        Test.startTest();
        record = IndividualBookingJourneyHelper.updateIndividual(record);
        Test.stopTest();
        System.assertEquals(false, record[0].Has_Opted_In_Email__c);
        System.assertEquals(false, record[0].Has_Opted_In_Post__c);
        System.assertEquals(false, record[0].Has_Opted_In_SMS__c);
        System.assertEquals(false, record[0].Has_Opted_In_Telephone__c);
    }

    @IsTest
    static void updateIndividual_emptyList_noUpdate(){
        DateTime timeStamp = System.now();
        Test.startTest();
        IndividualBookingJourneyHelper.updateIndividual(new List<Individual>());
        Test.stopTest();
        List<Individual> updatedRecords = [
            SELECT Id
            FROM Individual
            WHERE LastModifiedDate > :timeStamp
        ];
        System.assert(updatedRecords.isEmpty());
    }
}