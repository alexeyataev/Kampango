@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #133 - https://confluence.nct.org.uk:8443/x/EoSO

@IsTest
public with sharing class Estimated_Costs_Rollups_TDTM_Test {

    private static final String PRACTITIONER_LASTNAME = 'Smith';

    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String> {
        'triggerHandlerName' => 'Estimated_Costs_Rollups_TDTM',
        'className' => 'Estimated_Costs_Rollups_TDTM',
        'objectAPIName' => 'Estimated_Costs__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void testSetup() {
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession();
    }

    @IsTest
    public static void EstimatedCostsCheckInserting_CreatedTwoEstimatedCostsRecords_CostsShouldBeEquals() {

        List<Course__c> courses = [
            SELECT Count_of_Estimated_Travel_Costs__c, Count_of_Estimated_Venue_Costs__c
            FROM Course__c
        ];

        System.assertEquals(1, courses[0].Count_of_Estimated_Travel_Costs__c, 'Should be equals 1');
        System.assertEquals(1, courses[0].Count_of_Estimated_Venue_Costs__c, 'Should be equals 1');
    }

    @IsTest
    public static void EstimatedCostsCheckUpdating_CreatedTwoEstimatedCostsRecordAndUpdate_CostsShouldBeEquals() {

        List<Course__c> coursesBeforeUpdate = [
            SELECT Estimated_Travel_Costs__c, Estimated_Venue_Costs__c
            FROM Course__c
        ];

        Estimated_Costs__c estimatedCostsTypeTravel = [
            SELECT Amount__c
            FROM Estimated_Costs__c
            WHERE Course__c = :coursesBeforeUpdate[0].Id AND Type__c = 'Travel'
        ];

        Estimated_Costs__c estimatedCostsTypeVenue = [
            SELECT Amount__c
            FROM Estimated_Costs__c
            WHERE Course__c = :coursesBeforeUpdate[0].Id AND Type__c = 'Venue'
        ];

        System.assertEquals(coursesBeforeUpdate[0].Estimated_Travel_Costs__c, estimatedCostsTypeTravel.Amount__c, 'Should be equals');
        System.assertEquals(coursesBeforeUpdate[0].Estimated_Venue_Costs__c, estimatedCostsTypeVenue.Amount__c, 'Should be equals');

        estimatedCostsTypeTravel.Amount__c = 200;
        estimatedCostsTypeVenue.Amount__c = 200;

        Test.startTest();
            update new List<Estimated_Costs__c> { estimatedCostsTypeTravel, estimatedCostsTypeVenue };
        Test.stopTest();

        List<Course__c> coursesAfterUpdate = [
            SELECT Estimated_Travel_Costs__c, Estimated_Venue_Costs__c
            FROM Course__c
        ];

        System.assertEquals(coursesAfterUpdate[0].Estimated_Travel_Costs__c, estimatedCostsTypeTravel.Amount__c, 'Should be equals');
        System.assertEquals(coursesAfterUpdate[0].Estimated_Venue_Costs__c, estimatedCostsTypeVenue.Amount__c, 'Should be equals');
    }

}
