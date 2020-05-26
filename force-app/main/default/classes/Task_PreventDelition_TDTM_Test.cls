//@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #75 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class Task_PreventDelition_TDTM_Test {

    private static final String ACCOUNT_NAME = 'Test Account';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'Task_PreventDelition_TDTM',
        'className' => 'Task_PreventDelition_TDTM',
        'objectAPIName' => 'Task',
        'triggerActions' => 'BeforeDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };
    
    @TestSetup
    private static void SetupTestData(){
        Account account = new Account(Name = ACCOUNT_NAME);
        insert account;
        Task task = new task(WhatId = account.Id, Status = 'Completed', Subject = 'Text Body');
        insert task;
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void DeleteTask_DeletionBlocked(){
        Account account = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        Task task = [SELECT Id FROM Task WHERE WhatId = :account.Id LIMIT 1];
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