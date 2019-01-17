public with sharing class BookingApprovedHandler {
	
    public static void sendSingleMail(String courseid, String cemail, String name){
	
     String[] toAddresses = new String[] {cemail};
    // grab the email template
    EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where name ='Booking Enquiry Case new Confirmation'];

    // grab the contact fields we need. This assumes we are emailing a contact.
   
    // process the merge fields
    String subject = emailTemplate.Subject;
   

    String htmlBody = emailTemplate.HtmlValue;
    
    htmlBody = htmlBody.replace('{!courseid}', courseid);
    

    String plainBody = emailTemplate.Body;
    

        //build the email message
    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
	
    email.setToAddresses(toAddresses);
    
    email.setSenderDisplayName(cemail);
    email.setTargetObjectId(UserInfo.getUserId());
   
    email.setSaveAsActivity(false);
    

    email.setSubject(subject);
    email.setHtmlBody(htmlBody);
    email.setPlainTextBody(plainBody);

    Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
}
}