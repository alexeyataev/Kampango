@isTest
public with sharing class SendHTMLEmailPluginTest {

    @testSetup
    public static void setup() {
        Id folderId = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
        EmailTemplate template = new EmailTemplate(
        	DeveloperName = 'temp',
            FolderId = folderId,
            TemplateType= 'custom', 
            Name = 'test',
            IsActive = true
        );
        insert template;
        
        
        Id orgTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs ( thisUser ) {
            Account a = new Account(
                Name = 'A', 
                RecordTypeId = orgTypeId, 
                Type = 'Supplier', 
                AccountNumber = '123',
                Billing_Email__c = 'aa@bb.cc'
            );
            insert a;
            TestContactBuilder contactBuilder = new TestContactBuilder();
            Contact recipient = contactBuilder.withRecordType('Client')
                .withAccount(a)
                .withFirstName('Test')
                .withLastName('Black')
                .withEmail('john.black@example.com')
                .insertRecord(true)
                .build();
        }
    }

    @isTest
    public static void noErrorOrgWideEmail () {
        List<OrgWideEmailAddress> orgEmailObject = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        if (emailsFeatureEnabled() && !orgEmailObject.isEmpty()) {
            String orgWideEmail = orgEmailObject[0].Address;
            Contact recipient = [SELECT Id, AccountId FROM Contact LIMIT 1];
            Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            testReq.templateId = templateId;
            testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            testReq.ccEmailAddresses = new List<String>{'aaa@bbb.ccc', 'aaaa@bbbb.cccc'};
                testReq.bccEmailAddresses = new List<String>{'aba@bab.cbc', 'abaa@babb.cbcc'};
                    testReq.priority = 'High';
            testReq.saveAsActivity = true;
            testReq.replyEmailAddress = 'no-reply@example.com';
            testReq.orgWideEmailAddress = orgWideEmail;
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(true, testResponseList[0].isSuccess);
        }
    }
    
    @isTest
    public static void noErrorSenderDisplayName () {
        List<OrgWideEmailAddress> orgEmailObject = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        if (emailsFeatureEnabled() && !orgEmailObject.isEmpty()) {
            String orgWideEmail = orgEmailObject[0].Address;
            Contact recipient = [SELECT Id, AccountId FROM Contact LIMIT 1];
            Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            testReq.templateId = templateId;
            testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            testReq.ccEmailAddresses = new List<String>{'aaa@bbb.ccc', 'aaaa@bbbb.cccc'};
                testReq.bccEmailAddresses = new List<String>{'aba@bab.cbc', 'abaa@babb.cbcc'};
                    testReq.priority = 'High';
            testReq.saveAsActivity = true;
            testReq.replyEmailAddress = 'no-reply@example.com';
            testReq.senderDisplayName = 'senderTestName';
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(true, testResponseList[0].isSuccess);
        }
    }
    
    @isTest
    public static void errorIfNoRecepient () {
		if (emailsFeatureEnabled()) {
            Contact recipient = [SELECT Id, AccountId FROM Contact LIMIT 1];
            Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            testReq.templateId = templateId;
            //testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(false, testResponseList[0].isSuccess);
        }
    }
	
    @isTest
    public static void errorIfNoTemplate () {
		if (emailsFeatureEnabled()) {
            Contact recipient = [SELECT Id, AccountId FROM Contact LIMIT 1];
            Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            //testReq.templateId = templateId;
            testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(false, testResponseList[0].isSuccess);
        }
    }
    
    private static Boolean emailsFeatureEnabled() {
        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (System.NoAccessException e) {
            return false;
        }
        return true;
    }
}