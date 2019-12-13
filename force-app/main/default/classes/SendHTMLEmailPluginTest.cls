@isTest
public with sharing class SendHTMLEmailPluginTest {

    private static final String OWA_VALUE = 'nctcourses@nct.org.uk';
    private static final String CONTACT_EMAIL = 'john.black@example.com';
    private static final String TEMPLATE_NAME = 'test';
    private static final String TEMPLATE_DEV_NAME = 'temp';

    @testSetup
    public static void setup() {
        Id folderId = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
        EmailTemplate template = new EmailTemplate(
        	DeveloperName = TEMPLATE_DEV_NAME,
            FolderId = folderId,
            TemplateType= 'custom', 
            Name = TEMPLATE_NAME,
            IsActive = true
        );
        insert template;
        
        
        Id orgTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs ( thisUser ) {
            TestAccountBuilder aBuilder = new TestAccountBuilder();
            Account a = aBuilder.withName('a')
                .withRecordType('Organization')
                .withType('Supplier')
                .withAccountNumber('123')
                .withBillingEmail('aa@bb.cc')
                .insertRecord(true)
                .build();
            TestContactBuilder contactBuilder = new TestContactBuilder();
            Contact recipient = contactBuilder.withRecordType('Client')
                .withAccount(a)
                .withFirstName('Test')
                .withLastName('Black')
                .withEmail(CONTACT_EMAIL)
                .insertRecord(true)
                .build();
        }
    }

    @isTest
    public static void noErrorOrgWideEmail () {
        List<OrgWideEmailAddress> orgEmailObject = [
            SELECT Id, Address 
            FROM OrgWideEmailAddress
            WHERE Address = :OWA_VALUE
            LIMIT 1
        ];

        if (SendHTMLEmailPlugin.emailsFeatureEnabled() && !orgEmailObject.isEmpty()) {
            String orgWideEmailId = orgEmailObject[0].Id;
            Contact recipient = [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Email = :CONTACT_EMAIL 
                LIMIT 1
            ];
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME 
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            testReq.templateId = templateId;
            testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            testReq.ccEmailAddresses = new List<String>{'aaa@bbb.ccc', 'aaaa@bbbb.cccc'};
                testReq.bccEmailAddresses = new List<String>{'aba@bab.cbc', 'abaa@babb.cbcc'};
                    testReq.priority = 'High';
            testReq.saveAsActivity = true;
            testReq.replyEmailAddress = 'no-reply@example.com';
            testReq.orgWideEmailAddressId = orgWideEmailId;
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            try {
                List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
                System.assertEquals(true, testResponseList[0].isSuccess, 'Email with Organization-wide address set was not sent');
            } catch (EmailException e) {
                System.assert(false, 'Org-Wide address is not verified. Please refer to step #70 in "Manual Tasks" from Confluence (Set up Organization-Wide Email Address)');
            }
        }
    }
    
    @isTest
    public static void noErrorSenderDisplayName () {
        if (SendHTMLEmailPlugin.emailsFeatureEnabled()) {
            Contact recipient = [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Email = :CONTACT_EMAIL 
                LIMIT 1
            ];
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME 
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
            
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
            System.assertEquals(true, testResponseList[0].isSuccess, 'Email with Sender Display Name set was not sent');
        }
    }
    
    @isTest
    public static void errorIfNoRecipient () {
		if (SendHTMLEmailPlugin.emailsFeatureEnabled()) {
            Contact recipient = [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Email = :CONTACT_EMAIL 
                LIMIT 1
            ];
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME 
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            testReq.templateId = templateId;
            //testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(false, testResponseList[0].isSuccess, 'Email without a recipient can not be sent');
        }
    }
	
    @isTest
    public static void errorIfNoTemplate () {
		if (SendHTMLEmailPlugin.emailsFeatureEnabled()) {
            Contact recipient = [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Email = :CONTACT_EMAIL 
                LIMIT 1
            ];
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME 
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
            
            SendHTMLEmailPlugin.Request testReq = new SendHTMLEmailPlugin.Request();
            //testReq.templateId = templateId;
            testReq.targetObjectId = recipient.Id;
            testReq.mergeObjectId = recipient.AccountId;
            
            List<SendHTMLEmailPlugin.Request> reqList = new List<SendHTMLEmailPlugin.Request>();
            reqList.add(testReq);
            
            List<SendHTMLEmailPlugin.Response> testResponseList = SendHTMLEmailPlugin.invoke(reqList);
            System.assertEquals(false, testResponseList[0].isSuccess, 'Email without a template can not be sent');
        }
    }
}