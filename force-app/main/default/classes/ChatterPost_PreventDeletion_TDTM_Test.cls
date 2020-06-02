@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #93 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class ChatterPost_PreventDeletion_TDTM_Test {

    private static final String ACCOUNT_NAME = 'Test Account';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'ChatterPost_PreventDeletion_TDTM',
        'className' => 'ChatterPost_PreventDeletion_TDTM',
        'objectAPIName' => 'FeedItem',
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
        FeedItem chatterPost = new FeedItem(ParentId = account.Id, Type = 'TextPost', Body = 'Text Body');
        insert chatterPost;
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void DeleteChatterPost_DeletionBlocked(){
        FeedItem chatterPost = [SELECT Id FROM FeedItem LIMIT 1];
        String errorMessage;
        
        Test.startTest();
        try{
            delete chatterPost;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, errorMessage.contains(System.label.Delete_Chatter_Post_Error_Text));
    }
}
