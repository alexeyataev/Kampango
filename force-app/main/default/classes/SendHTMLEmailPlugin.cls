public with sharing class SendHTMLEmailPlugin {

    @InvocableMethod(label='Send HTML Email Template')
    public static List<Response> invoke(List<Request> requests){
        
        Map<String,String> result = new Map<String,String>();
        
        String targetObjId = requests[0].targetObjectId;
        String mergeObjId = requests[0].mergeObjectId;
        String templateId = requests[0].templateId;
        String senderAddress = requests[0].replyEmailAddress;
        String priority = requests[0].priority;
        Boolean saveAsActivity = requests[0].saveAsActivity;
        String senderDisplay = requests[0].senderDisplayName;
        List<String> ccEmails = requests[0].ccEmailAddresses;
        List<String> bccEmails = requests[0].bccEmailAddresses;
        String orgWideAddress = requests[0].orgWideEmailAddress;
        
        List<Response> responseList = new List<Response>();
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
        
        Boolean hasRecipient = (targetObjId != null || bccEmails != null || ccEmails != null);
        if (emailsFeatureEnabled() && hasRecipient) {

            setEmailCapacity(targetObjId, ccEmails, bccEmails);

            message.setTargetObjectId(targetObjId);
            message.setTemplateId(templateId);
            message.setWhatId(mergeObjId);
    
            List<String> priorities = new List<String> {'Highest', 'High', 'Low', 'Lowest'};
            if (priorities.contains(priority)) {
                message.setEmailPriority(priority);
            }
            
            // Save as activity is true by default
            Boolean isSaveAsActivityNotSet = (saveAsActivity == null || !saveAsActivity);
            if (isSaveAsActivityNotSet) {
                message.setSaveAsActivity(false);
            }
            
            // Set sender address (cannot be used both)
            Boolean isOrgWideSet = (orgWideAddress != null && String.isNotBlank(orgWideAddress));
            if (isOrgWideSet) {
                Id orgWideAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideAddress].Id;
                message.setOrgWideEmailAddressId(orgWideAddressId);
            } else if (senderDisplay != null) {
                message.setSenderDisplayName(senderDisplay);
            }
            message.setReplyTo(senderAddress);
            message.setCcAddresses(ccEmails);
            message.setBccAddresses(bccEmails);

            system.debug('Email invocations before send: ' + Limits.getEmailInvocations());   
            system.debug(message);
            
            Response response;
            String error;
            try {
                Messaging.SendEmailResult[] emailResponse = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                System.debug('emailResponse is: ' + emailResponse);
                response = createResponseAfterSending(emailResponse);
            } catch (EmailException e){
                error = e.getMessage();
                if (error.contains('UNVERIFIED_SENDER_ADDRESS')) {
                    throw e;
                } else {
                    System.debug ('exception occured: ' + e.getMessage());
                    response = createErrorResponse(error);
                }
            }
            responseList.add(response);

            system.debug('Email invocations after send: ' + Limits.getEmailInvocations());
        } else {
            Response response = createErrorResponse('Messaging is not supported or recipient is not assigned');
            responseList.add(response);
        }

        return responseList;
    }

    private static void setEmailCapacity(String targetObjId, List<String> ccEmails, List<String> bccEmails) {
        Integer emailCount = 0;
        if (targetObjId != null) {
            emailCount++;
        }
        
        if (ccEmails != null){
            for(String s : ccEmails){
                emailCount++;
            }
        }
        if (bccEmails != null) {
            for(String s : bccEmails){
                emailCount++;
            }
        }
        system.debug('Email count : ' + emailCount);
        Messaging.reserveSingleEmailCapacity(emailCount);
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
            response = createErrorResponse(errorReport);
        } else {
            response = new Response();
            response.isSuccess = true;
        }
        return response;
    }

    private static Response createErrorResponse(String errors) {
        Response response = new Response();
        response.isSuccess = false;
        response.errors = errors;
        return response;
    }
    
    public static Boolean emailsFeatureEnabled() {
        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (System.NoAccessException e) {
            return false;
        }
        return true;
    }
    
    public class Request {
        
        @invocableVariable(
            label='Template Target Record Id' 
            description='If you are passing in a template Id, you need to also pass in the Id of context record. It can be a Contact, Lead, or User. It will determine which data gets merged into the template'
        	required=true
        )
        public String targetObjectId;
        
        @invocableVariable
        public String mergeObjectId;
        
        @invocableVariable
        public String templateId;
        
        @invocableVariable
        public String replyEmailAddress;
        
        @invocableVariable
        public String priority;
        
        @invocableVariable
        public Boolean saveAsActivity;
        
        @invocableVariable
        public String senderDisplayName;
        
        @invocableVariable
        public List<String> ccEmailAddresses;
        
        @invocableVariable
        public List<String> bccEmailAddresses;

        @invocableVariable
        public String orgWideEmailAddress;
    }
    
    public class Response {
        @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;

    }
    
    public class FlowEmailActionException extends Exception {}
}