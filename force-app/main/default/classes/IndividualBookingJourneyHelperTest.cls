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
    static void updateIndividualValidIndividualRecordUpdated(){
        List<Individual> record = [
            SELECT Id, Email__c, Post__c,
                SMS__c, Telephone__c
            FROM Individual
            LIMIT 1
        ];
        record[0].Email__c = false;
        record[0].Post__c = false;
        record[0].SMS__c = false;
        record[0].Telephone__c = false;
        Test.startTest();
        record = IndividualBookingJourneyHelper.updateIndividual(record);
        Test.stopTest();
        System.assertEquals(false, record[0].Email__c);
        System.assertEquals(false, record[0].Post__c);
        System.assertEquals(false, record[0].SMS__c);
        System.assertEquals(false, record[0].Telephone__c);
    }

    @IsTest
    static void updateIndividualEmptyListNoUpdate(){
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
