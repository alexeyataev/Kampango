// @SuppressWarnings('PMD.MethodNamingConventions')
//Incident #75 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class AssignCasetoQueueTest {

    @IsTest
    private static void AssignCasetoQueue_CaseInserted_CaseAssignedToAdministrationQueue(){
        Case caseToInsert = new Case(OwnerId = UserInfo.getUserId());
        Test.startTest();
        insert caseToInsert;
        Test.stopTest();

        QueuesObject queue  = [SELECT QueueId FROM QueuesObject WHERE QueueId IN (SELECT Id FROM Group WHERE DeveloperName = 'Course_Booking_Manual_Administration')];
        Case caseToTest = [SELECT OwnerId FROM Case WHERE Id = :caseToInsert.Id];
        System.assertEquals(UserInfo.getUserId(), caseToInsert.OwnerId);
        System.assertEquals(queue.QueueId, caseToTest.OwnerId);
    }
}
