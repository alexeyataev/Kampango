@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #94 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class Task_PreventDeletion_TDTM_Test {


    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'Task_PreventDeletion_TDTM',
        'className' => 'Task_PreventDeletion_TDTM',
        'objectAPIName' => 'Task',
        'triggerActions' => 'BeforeDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };
    
    @TestSetup
    private static void SetupTestData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildBranchAccount();
        Account account = [SELECT Id FROM Account LIMIT 1];
        Task task = new task(WhatId = account.Id, Status = 'Completed', Subject = 'Text Body');
        insert task;
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void DeleteTask_DeletionBlocked(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        Boolean hasError = false;
        
        Test.startTest();
        try{
            delete task;
        }catch(Exception e){
            hasError = true;
        }
        Test.stopTest();

        System.assert(hasError);
    }
}