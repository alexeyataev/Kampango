@isTest
public class DupOutCodeHandlerTest {

    static testMethod Void outcodeDuplicateCap(){
        Boolean result = false;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account acc = new Account(Name ='Test-Trigger', RecordTypeId = recordTypeId);
        insert acc;
        //list<Account> branchtest = [Select Id from Account where Name = 'Test-Trigger'];
       
        PostCode_Allocation__c firstPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c = acc.id );
        insert firstPA;
        
        
        
        try{
            PostCode_Allocation__c secPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c = acc.id);
            insert secPA;
            
        }
        catch(DmlException ex){ 
            
            result = true;
        }

      	System.assert(result);

    }
    static testMethod Void outcodeDuplicateEnq(){
    	Boolean result = false;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account acc = new Account(Name ='Test-Trigger', RecordTypeId = recordTypeId);
        insert acc;
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc.id);
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc.Id);
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }
    static testMethod Void outcodeDuplicateBranch(){
    	Boolean result = false;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account acc = new Account(Name ='Test-Trigger', RecordTypeId = recordTypeId);
        insert acc;
        Account acc1 = new Account(Name ='Test-Trigger1', RecordTypeId = recordTypeId);
        insert acc1;
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc.id);
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc1.id);
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }
    /*static testMethod Void outcodeDuplicatePostcode(){
    	Boolean result = false;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account acc = new Account(Name ='Test-Trigger', RecordTypeId = recordTypeId);
        insert acc;
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc.id);
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'TestPost',PSA_Roles__c = 'Enquiry PSA',Branch__c =acc.id);
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }*/
}
