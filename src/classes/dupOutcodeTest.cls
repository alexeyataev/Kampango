@isTest
public class DupOutCodeTest {
	
    static testMethod Void outcodeDuplicate(){
        Boolean result = false;
        PostCode_Allocation__c firstPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA;
        
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c ='0010E00000MmsfLQAR');
            insert secPA;
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c ='0010E00000MmsfLQAR');
            insert secPA1;
        }
        catch(DmlException ex){ 
            
            result = true;
        }

      	System.assert(result);

    }

}
