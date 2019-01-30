@isTest
public class DupOutCodeTest {
	
    static testMethod Void outcodeDuplicate(){
        Boolean result = false;
        PostCode_Allocation__c firstPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c =Label.DupOutCodeTestID);
        insert firstPA;
        
        PostCode_Allocation__c firstPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =Label.DupOutCodeTestID);
        insert firstPA1;
        
        try{
            PostCode_Allocation__c secPA = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Capacity PSA',Branch__c =Label.DupOutCodeTestID);
            insert secPA;
            PostCode_Allocation__c secPA1 = new PostCode_Allocation__c(Name = 'Test',PSA_Roles__c = 'Enquiry PSA',Branch__c =Label.DupOutCodeTestID);
            insert secPA1;
        }
        catch(DmlException ex){ 
            
            result = true;
        }

      	System.assert(result);

    }

}
