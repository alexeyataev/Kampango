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
              AND Zumzum__Status__c = 'Posted'
              AND Zumzum__Total_Unpaid_Amount__c > 0
        ]) {
            Payment_Run_Line_Item__c prli = new Payment_Run_Line_Item__c();
            prli.Payment_Run__c = paymentRunId;
            prli.Purchase_Invoice__c = pi.Id;
            prliList.add(prli);
        }
        if (prliList.isEmpty()) {
            result.add(new Response(false, 'There is no Purchase Invoices matching the action criteria'));
        } else {
            try {
                System.debug(prliList);
                System.debug(prliList.size());
                insert prliList;
                result.add(new Response(true));
            } catch (DmlException e) {
                result.add(new Response(false, e.getMessage()));
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