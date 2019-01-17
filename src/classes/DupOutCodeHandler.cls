public with sharing class DupOutCodeHandler {
	
    public void onBeforeInsertUpdate(List<PostCode_Allocation__c>  pcalist){
        
       
        list<PostCode_Allocation__c> outcodelist = [SELECT Id, Name,Branch__c, PSA_Roles__c FROM PostCode_Allocation__c];
        
            
            for(PostCode_Allocation__c pa: PCAList){
            
                for(PostCode_Allocation__c palist: outcodelist){
                    if(((palist.Branch__c!=pa.Branch__c)&&(palist.Name==pa.Name))){
                        pa.addError('Branch should not be assigned to more than one postcode');
                        
                    }
                    
                    else if((palist.Branch__c==pa.Branch__c)&&(palist.Name==pa.Name) && (palist.PSA_Roles__c==pa.PSA_Roles__c)){
                        
                        pa.addError('Postcode should not be assigned to more than one Enquiry and Capacity PSA');
                    	
                    }
                    else{ 
                        System.debug('Postcode should be assigned to more than one Branch-> As per onshore');
                    }
                }
            }
        
    }
}
