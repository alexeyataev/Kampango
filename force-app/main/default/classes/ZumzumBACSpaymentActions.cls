public with sharing class ZumzumBACSpaymentActions {
    @invocableMethod(label='Link Purchase Invoices')
    public static List<Response> linkPurchaseInvoices(List<Request> requests) {
        List<Response> result = new List<Response>();
        String paymentRunId = requests[0].recordId;
        
        Set<Id> linkedPIids = new Set<Id>();
        List<Payment_Run_Line_Item__c> existingPrliList = [
            SELECT Id, Purchase_Invoice__c
            FROM Payment_Run_Line_Item__c
            WITH SECURITY_ENFORCED
        ];
        for (Payment_Run_Line_Item__c prli : existingPrliList) {
            linkedPIids.add(prli.Purchase_Invoice__c);
        }

        List<Payment_Run_Line_Item__c> prliList = new List<Payment_Run_Line_Item__c>();
        for (Zumzum__Purchase_Invoice__c pi : [
            SELECT Id 
            FROM Zumzum__Purchase_Invoice__c 
            WHERE Id NOT IN :linkedPIids
              AND Zumzum__Status__c <> 'Paid'
              AND Zumzum__Total_Unpaid_Amount__c > 0
                    AND Zumzum__Account__r.Zumzum__Bank_Account_Name__c <> ''
                    AND Zumzum__Account__r.Zumzum__Bank_Account_No__c <> ''
                    AND Zumzum__Account__r.Zumzum__Bank_Sort_Code__c <> ''
        ]) {
            Payment_Run_Line_Item__c prli = new Payment_Run_Line_Item__c();
            prli.Payment_Run__c = paymentRunId;
            prli.Purchase_Invoice__c = pi.Id;
            prliList.add(prli);
        }
        if (prliList.isEmpty()) {
            result.add(new Response(
                false, 
                'There is no Purchase Invoices matching the action criteria'
            ));
        } else {
            if (Payment_Run_Line_Item__c.sObjectType.getDescribe().isCreateable()) {
                insert prliList;
                result.add(new Response(true));
            } else {
                result.add(new Response(
                    false, 
                    'The user has no access rights to create Payment Run Line Items'
                ));
            }
        }
        return result;
    }
    
    public class Request {
        @invocableVariable(
            label='Payment Run Id'
            required=true
        )
        public String recordId;
    }
    
    public class Response {
        @invocableVariable
        public Boolean isSuccess;
        @invocableVariable
        public String message;
        
        public Response(Boolean isSuccess) {
            this(isSuccess, null);
        }
        
        public Response(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}