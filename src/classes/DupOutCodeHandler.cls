public with sharing class DupOutCodeHandler {
	
    public void onBeforeInsertUpdate(List<PostCode_Allocation__c>  pcalist){
        
        //BypassRules__c profileCustomSetting = BypassRules__c.getInstance(UserInfo.getUserId());
        //Boolean DisableTriggers =  profileCustomSetting.Disable_Triggers__c;
        list<PostCode_Allocation__c> outcodelist = [SELECT Id, Name,Branch__c, PSA_Roles__c FROM PostCode_Allocation__c];
        //if(DisableTriggers == false){
            
            for(PostCode_Allocation__c pa: PCAList){
            
                for(PostCode_Allocation__c palist: outcodelist){
                    if(((palist.Branch__c!=pa.Branch__c)&&(palist.Name==pa.Name))){
                        pa.addError('Branch should not be assigned to more than one postcode');
                        //System.debug('Branch should be assigned to more than one postcode-> As per onshore');
                    }
                    
                    else if((palist.Branch__c==pa.Branch__c)&&(palist.Name==pa.Name) && (palist.PSA_Roles__c==pa.PSA_Roles__c)){
                        
                        pa.addError('Postcode should not be assigned to more than one Enquiry and Capacity PSA');
                    	
                    }
                    else{ //if(((palist.Branch__c==pa.Branch__c)&&(palist.Name!=pa.Name))){
                        //pa.addError('Postcode should not be assigned to more than one Branch');
                        System.debug('Postcode should be assigned to more than one Branch-> As per onshore');
                    }
                }
            }
        //}
    }
}
