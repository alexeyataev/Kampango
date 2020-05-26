@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #93 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class ChatterPost_PreventDelition_TDTM_Test {

    private static final String ACCOUNT_NAME = 'Test Account';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'ChatterPost_PreventDelition_TDTM',
        'className' => 'ChatterPost_PreventDelition_TDTM',
        'objectAPIName' => 'FeedItem',
        'triggerActions' => 'BeforeDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };
    
    @TestSetup
    private static void SetupTestData(){
        Account account = new Account(Name = ACCOUNT_NAME);
        insert account;
        FeedItem chatterPost = new FeedItem(ParentId = account.Id, Type = 'TextPost', Body = 'Text Body');
        insert chatterPost;
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void DeleteChatterPost_DeletionBlocked(){
        Account account = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        FeedItem chatterPost = [SELECT Id FROM FeedItem WHERE ParentId = :account.Id LIMIT 1];
        Boolean hasError = false;
        
        Test.startTest();
        try{
            delete chatterPost;
        }catch(Exception e){
            hasError = true;
        }
        Test.stopTest();

        System.assert(hasError);
    }
}

