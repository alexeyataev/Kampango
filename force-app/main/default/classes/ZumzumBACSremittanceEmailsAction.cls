public class ZumzumBACSremittanceEmailsAction {
	@invocableMethod(label='Send Remittance Email')
    public static List<Response> sendRemittanceEmails(List<Request> requests) {
        List<Response> result = new List<Response>();
        Id paymentRunId = requests[0].paymentRunId;
        Id templateId = requests[0].emailTemplateId;
        String orgWideAddress = requests[0].orgWideEmailAddress;
        
        Id orgWideAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideAddress].Id;
        try {
            ZumzumBACSremittanceEmailsBatch batch = new ZumzumBACSremittanceEmailsBatch(paymentRunId, templateId, orgWideAddressId);
            Database.executeBatch(batch, 50);
        	result.add(new Response(true));
        } catch (Exception e) {
            result.add(new Response(false, e.getMessage()));
        }
        return result;
    }
    
    private static Response createResponseAfterSending(Messaging.SendEmailResult[] emailResponse) {
        Boolean success = emailResponse[0].isSuccess();
        Messaging.SendEmailError[] curErrors = emailResponse[0].getErrors();
        Response response;
        if (!success) {
            String errorReport = '';
            for (Messaging.SendEmailError curError : curErrors) {
                errorReport = errorReport + curError.getMessage() + '/n';
            }
            response = new Response(false, errorReport);
        } else {
            response = new Response(true);
        }
        return response;
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