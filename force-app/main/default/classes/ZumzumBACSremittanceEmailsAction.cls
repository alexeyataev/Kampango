public without sharing class ZumzumBACSremittanceEmailsAction {
    @invocableMethod(label='Send Remittance Email')
    public static List<Response> sendRemittanceEmails(List<Request> requests) {
        List<Response> result = new List<Response>();
        Id paymentRunId = requests[0].paymentRunId;
        Id templateId = requests[0].emailTemplateId;
        String orgWideAddress = requests[0].orgWideEmailAddress;
        try {
            Id orgWideAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideAddress].Id;
            ZumzumBACSremittanceEmailsBatch batch = new ZumzumBACSremittanceEmailsBatch(paymentRunId, templateId, orgWideAddressId);
            Id jobId = Database.executeBatch(batch, 50);
            result.add(new Response(true, jobId));
        } catch (Exception e) {
            result.add(new Response(false, e.getMessage()));
        }
        return result;
    }
    
    
    public class Request {
        @invocableVariable(
            label='Payment Run Id'
            required=true
        )
        public String paymentRunId;
        
        @invocableVariable(
            label = 'Email Template'
            required = true
        )
        public String emailTemplateId;
        
        @invocableVariable(
            label = 'Org Wide Address'
            required = true
        )
        public String orgWideEmailAddress;
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