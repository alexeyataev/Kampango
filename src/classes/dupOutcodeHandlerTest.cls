@isTest
public class dupOutcodeHandlerTest {

    static testMethod Void outcodeDuplicateCap(){
        Boolean result = false;
        //Id branch =[SELECT Id FROM Account where Name= 'Bournemouth 2'];
        PostCode_Allocation__c firstPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA;
        
        
        
        try{
            PostCode_Allocation__c secPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c ='0010E00000MmsfLQAR');
            insert secPA;
            
        }
        catch(DmlException ex){ 
            
            result = true;
        }

      	System.assert(result);

    }
    static testMethod Void outcodeDuplicateEnq(){
    	Boolean result = false;
        
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }
    static testMethod Void outcodeDuplicateBranch(){
    	Boolean result = false;
        
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsWOQAZ');
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }
    static testMethod Void outcodeDuplicatePostcode(){
    	Boolean result = false;
        
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'TestPost',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
            insert secPA1;
        }
        catch(DmlException ex){
            result = true;
        }
        System.assert(result);
    }
}