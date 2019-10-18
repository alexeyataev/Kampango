public with sharing class SendHTMLEmailPlugin {

    @InvocableMethod(label='Send HTML Email Template')
    public static List<Response> invoke(List<Request> requests){
        
        Map<String,String> result = new Map<String,String>();
        
        String targetObjId = requests[0].targetObjectId;
        String mergeObjId = requests[0].mergeObjectId;
        String templateId = requests[0].templateId;
        List<String> toEmails = requests[0].toEmails;
        String toEmail = requests[0].toEmail;
        String senderAddress = requests[0].replyEmailAddress;
        String priority = requests[0].priority;
        Boolean saveAsActivity = requests[0].saveAsActivity;
        String senderDisplay = requests[0].senderDisplayName;
        List<String> ccEmails = requests[0].ccEmailAddresses;
        List<String> bccEmails = requests[0].bccEmailAddresses;
        String orgWide = requests[0].orgWideEmailAddressId;
        
        Integer emailCount = 0;
        if(targetObjId != null) {
            emailCount++;
        }
        if(ccEmails != null){
            for(String s : ccEmails){
                emailCount++;
            }
        }
        if(bccEmails != null) {
            for(String s : bccEmails){
                emailCount++;
            }
        }
        system.debug('Email count : ' + emailCount);
        Messaging.reserveSingleEmailCapacity(emailCount);
        
        List<Response> responseList = new List<Response>();
        
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
        if (targetObjId != null || toEmail != null || toEmails != null || bccEmails != null || ccEmails != null){
            // Set the target object Id
            if (targetObjId != null){
                message.setTargetObjectId(targetObjId);
            }
            
            if (templateId != null) {
                message.setTemplateId(templateId);
            } else {
                System.debug('incorrect input in template and target object');
            }
            message.setWhatId(mergeObjId);

            // Set to emails
            if(toEmails != null){
                message.setToAddresses(toEmails);
                //message.setTreatTargetObjectAsRecipient(false);
            } else if (toEmail != null) {
                message.setToAddresses(new List<String> { toEmail });
                //message.setTreatTargetObjectAsRecipient(false);
            }
    
      		// Set Priority            
            if(priority!= null && (priority == 'Highest' || priority =='High' || priority =='Low' || priority == 'Lowest')){
                message.setEmailPriority(priority);
            }
            
            // Save as activity?
            if(saveAsActivity != null && saveAsActivity && targetObjId != null && message.isTreatTargetObjectAsRecipient()) {
                message.setSaveAsActivity(true);
            } else {
                message.setSaveAsActivity(false);
            }
            
            // Set sender address
            if(senderAddress != null){
                message.setReplyTo(senderAddress);
            }
    
            if(orgWide != null){
                Id orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: orgWide].Id;
                message.SetorgWideEmailAddressId(orgWideEmail);
            }
            
            // Set sender display name
            if(senderDisplay != null){
                message.setSenderDisplayName(senderDisplay);
            }
            
            // Set cc email
            if(ccEmails != null){
                message.setCcAddresses(ccEmails);
            }
            
            // Set bcc email
            if(bccEmails != null){
                message.setBccAddresses(bccEmails);
            }
            system.debug('Email invocations before send: ' + Limits.getEmailInvocations());   
            system.debug(message);
            
            
            Messaging.SendEmailResult[] emailResponse;
            Boolean completed;
            String error;
            // Send the email you have created.
            try {
                emailResponse = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                System.debug('emailResponse is: ' + emailResponse);
                completed = true;
            } catch (FlowEmailActionException e){
                System.debug ('exception occured: ' + e.getMessage());
                completed = false;
                error = e.getMessage();
            } catch (System.EmailException e){
                System.debug ('exception occured: ' + e.getMessage());
                completed = false;
                error = e.getMessage();
            }
           
            //report back the results
            Response response = new Response();
            if (completed) {
                if (emailResponse[0].isSuccess() != true) {
                    Messaging.SendEmailError[] curErrors = emailResponse[0].getErrors();
                    String errorReport = '';
                    for(Messaging.SendEmailError curError : curErrors ) {
                        errorReport = errorReport + curError.getMessage() + '/n';
                    }
                    response.errors = errorReport;
                    response.isSuccess = false;
                } else {
                    response.isSuccess = true;
                }
            } else {
                response.errors = error;
                response.isSuccess = false;
            }
           
            
            responseList.add(response);
        } else {
            Response response = new Response();
            response.isSuccess = false;
            response.errors = 'Recipient is not assigned';
            responseList.add(response);
        }

        
        system.debug('Email invocations after send: ' + Limits.getEmailInvocations());
        return responseList;
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
        public List<String> toEmails;
        
        @invocableVariable
        public String toEmail;
        
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
        public String orgWideEmailAddressId;
    }
    
    public class Response {
        @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;

    }
    
    public class FlowEmailActionException extends Exception {}
}