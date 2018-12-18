public class BookingApprovedHandler {
	
    public static void sendSingleMail(String courseid, String cemail, String name){
	
     String[] toAddresses = new String[] {cemail};
    // grab the email template
    EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where name ='Booking Enquiry Case new Confirmation'];

    // grab the contact fields we need. This assumes we are emailing a contact.
   // Contact c = [Select Id, FirstName FROM Contact WHERE Id=: contactId];
	//list<string> em = new list<string>;
    //em.add(address);
    // process the merge fields
    String subject = emailTemplate.Subject;
    //subject = subject.replace('{!Contact.FirstName}', c.FirstName);

    String htmlBody = emailTemplate.HtmlValue;
    //htmlBody = htmlBody.replace('{!Contact.FirstName}', c.FirstName);
    //htmlBody = htmlBody.replace('{!name}', lastname);
    htmlBody = htmlBody.replace('{!courseid}', courseid);
    //htmlBody = htmlBody.replace('{!enddate}', enddate);
    //htmlBody = htmlBody.replace('{!startdate}', startdate);

    String plainBody = emailTemplate.Body;
    //plainBody = plainBody.replace('{!Contact.FirstName}', c.FirstName);
    //plainBody = plainBody.replace('{!name}', lastname);

        //build the email message
    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
	//email.setToAddresses(address);
     //email.setCcAddresses(address)
	//email.setInReplyTo(address);
    //email.setReplyTo(address);
    email.setToAddresses(toAddresses);
    //email.ccaddresses(em[0]);
    email.setSenderDisplayName(cemail);
    email.setTargetObjectId(UserInfo.getUserId());
    //email.setTargetObjectId(id1);
    email.setSaveAsActivity(false);
    

    email.setSubject(subject);
    email.setHtmlBody(htmlBody);
    email.setPlainTextBody(plainBody);

    Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
}
}