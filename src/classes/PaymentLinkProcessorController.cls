/**
*   @author: Mahanth Garlapati
*   @description: This class redirects to the Stripe payment
**/

public without sharing class PaymentLinkProcessorController {
    
    public Boolean paymentLinkFound {public get; public set;}
    public String paymentLink {public get; public set;}
       
    public PaymentLinkProcessorController(){
        
        paymentLinkFound = false;       
        String encryptedLinkId = ApexPages.currentPage().getParameters().get('paymentId'); 
         if (!Schema.sObjectType.Payment_Link__c.fields.Payment_Link__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
         } 
        List<Payment_Link__c> paymentLinkList = [ 
                                                    SELECT 
                                                        Payment_Link__c,
                                                        Id,
                                                        Link_Status__c 
                                                    FROM 
                                                        Payment_Link__c 
                                                    WHERE 
                                                        Link_Status__c='Active' 
                                                    AND 
                                                        Id=:encryptedLinkId 
                                                ];
        
        if (paymentLinkList != null && paymentLinkList.size() > 0){
            paymentLink = paymentLinkList[0].Payment_Link__c;
            paymentLinkFound=true;
        } 
    }       
    
    public PageReference redirect() {
    
        if(paymentLinkFound){
            Set<String> whiteListedDomains = new Set<String>();
            whiteListedDomains.add(New URL(paymentLink).getHost());
            if(!whiteListedDomains.contains(New URL(paymentLink).getHost())){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            }
            PageReference pageRef = new PageReference(paymentLink);
            System.debug('Page Reference : '+pageRef);
            return pageRef;
        } else {
            return null;
        }    
    }
    
}