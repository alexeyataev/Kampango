@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #108 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class SendHTMLEmailPlugin {

    @InvocableMethod(label='Send HTML Email Template')
    public static List<Response> invoke(List<Request> requests){
        
        Map<String,String> result = new Map<String,String>();
        
        String targetObjId = requests[0].targetObjectId;
        String mergeObjId = requests[0].mergeObjectId;
        String templateDeveloperName = requests[0].templateDeveloperName;
        String templateId = requests[0].templateId;
        String senderAddress = requests[0].replyEmailAddress;
        String priority = requests[0].priority;
        Boolean saveAsActivity = requests[0].saveAsActivity;
        String senderDisplay = requests[0].senderDisplayName;
        List<String> ccEmails = requests[0].ccEmailAddresses;
        List<String> bccEmails = requests[0].bccEmailAddresses;
        List<String> attachments = requests[0].attachmentsIds;
        List<String> toAddresses = requests[0].emailAddresses;
        String orgWideAddress = requests[0].orgWideEmailAddress;
        String emailBody = requests[0].emailBodyToSend;
        String subject = requests[0].emailSubject;
        
        List<Response> responseList = new List<Response>();
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();

        Boolean hasRecipient = (targetObjId != null || bccEmails != null || ccEmails != null || toAddresses != null);
        if (TestEmailUtility.emailsFeatureEnabled() && hasRecipient) {

            setEmailCapacity(targetObjId, ccEmails, bccEmails);

            if (String.isNotBlank(targetObjId)) {
                message.setTargetObjectId(targetObjId);
            }

            if (toAddresses != null) {
                message.setToAddresses(toAddresses);                
            }

            if(String.isBlank(templateId) && String.isNotBlank(templateDeveloperName)) {
                List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateDeveloperName WITH SECURITY_ENFORCED LIMIT 1];
                templateId = emailTemplateList.isEmpty() ? templateId : emailTemplateList[0].Id;
            } 

            if (String.isNotBlank(templateId)) {
                message.setTemplateId(templateId);
            } else {
                message.setSubject(subject);
                message.setHtmlBody(emailBody);
            }

            message.setWhatId(mergeObjId);
    
            List<String> priorities = new List<String> {'Highest', 'High', 'Low', 'Lowest'};
            if (priorities.contains(priority)) {
                message.setEmailPriority(priority);
            }
            
            Boolean isSaveAsActivityNotSet = (saveAsActivity == null || !saveAsActivity);
            if (isSaveAsActivityNotSet) {
                message.setSaveAsActivity(false);
            }

            if (String.isNotBlank(orgWideAddress)) {
                Id orgWideAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideAddress].Id;
                message.setOrgWideEmailAddressId(orgWideAddressId);
            } else if (senderDisplay != null) {
                message.setSenderDisplayName(senderDisplay);
            }
            message.setReplyTo(senderAddress);
            message.setCcAddresses(ccEmails);
            message.setBccAddresses(bccEmails);

            if (attachments != null) {
                List<String> contentVersionIds = new List<String>();
                for (ContentVersion contVersion : [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :attachments]) {
                    contentVersionIds.add(contVersion.Id);
                }
                message.setEntityAttachments(contentVersionIds);
            }

            Response response;
            String error;
            try {
                Messaging.SendEmailResult[] emailResponse = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                response = createResponseAfterSending(emailResponse);
            } catch (EmailException e){
                error = e.getMessage();
                if (error.contains('UNVERIFIED_SENDER_ADDRESS')) {
                    throw e;
                } else {
                    response = createErrorResponse(error);
                }
            }
            responseList.add(response);
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
    
    public class Request {
        @invocableVariable(
            label='Template Target Record Id' 
            description='If you are passing in a template Id, you need to also pass in the Id of context record. It can be a Contact, Lead, or User. It will determine which data gets merged into the template'
        	required=false
        )
        public String targetObjectId;
        
        @invocableVariable
        public String mergeObjectId;
        
        @invocableVariable
        public String templateDeveloperName;

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
        public List<String> emailAddresses;
        
        @invocableVariable
        public List<String> ccEmailAddresses;
        
        @invocableVariable
        public List<String> bccEmailAddresses;

        @invocableVariable
        public List<String> attachmentsIds;

        @invocableVariable
        public String orgWideEmailAddress;
        
        @invocableVariable
        public String emailBodyToSend;

        @invocableVariable
        public String emailSubject;
    }
    
    public class Response {
        @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;
    }
    
    public class FlowEmailActionException extends Exception {}
}