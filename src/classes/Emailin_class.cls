/* Create a button to be placed in Course object */

public class Emailin_class { 
    
    public String subject{set;get;}
    public String email_body{set;get;}
    public String toaddress{set;get;}
    public string ccaddress{set;get;}
    
    
    public ApexPages.StandardController stdCntrlr {get;set;}
    
    public Emailin_class(ApexPages.StandardController controller) {
        stdCntrlr = controller;
        toaddress='';
        course__c userCourse = (course__c)controller.getRecord();
        list<Booking__c>  emailrecords=[select id,name,First_Contact__r.Email,Second_Contact__r.Email from Booking__c where Course__c=:userCourse.id];
        System.debug('emailrecords  :'+emailrecords);
        
        for(Booking__c b : emailrecords){
            //System.debug('Booking-Name :'+b.Name);
            //System.debug('Booking-b.First_Contact__r.Email :'+b.First_Contact__r.Email);
            //System.debug('Booking-b.Second_Contact__r.Email :'+b.Second_Contact__r.Email);
            if(b.First_Contact__r.Email!=null){
                toaddress=toaddress+b.First_Contact__r.Email+';';
            }
            if(b.Second_Contact__r.Email!=null){
                toaddress=toaddress+b.Second_Contact__r.Email+';';
            }
        }
        
        System.debug('Final toaddress =========> :'+toaddress);
    }
    
    
    public pagereference send(){
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        course__c courseObj = (course__c)stdCntrlr.getRecord();
        ccaddress = courseObj.practitioner__r.Email;
        System.debug('toAddress :'+toAddress);
        if(null != toAddress && !''.equals(toAddress)) {
            String[] toAddrArray = toAddress.contains(';') ?  toAddress.split(';') : new String[]{toAddress};
                System.debug('toAddrArray :'+toAddrArray);
            try{    
                
                for (String toId : toAddrArray){
                    String[] toIDArray= new String[1];
                    toIDArray[0] = toId;
                    email.setToAddresses(toIDArray);
                    email.setSubject(subject);
                    email.setplaintextbody(email_body);
                    System.debug('ccaddress :'+ccaddress);
                    // contional operator : (condition ? true : false)
                    if(null != ccaddress && !''.equals(ccaddress)) {
                        String[] ccArray = ccaddress.contains(';') ?  ccaddress.split(';') : new String[]{ccaddress};
                            email.setCcAddresses(ccArray);
                        System.debug('ccArray: '+ccArray);
                    }
                    System.debug('SingleEmailMessage : =========> : '+email);
                    messaging.sendEmail(new messaging.singleEmailmessage[]{email});
                }
            }catch(EmailException emailEx){
                System.debug('EmailException-Email sent failed' +emailEx.getMessage());
                ApexPages.Message msg=new ApexPages.Message(ApexPages.Severity.ERROR,'Email address is invalid, Please correct before sending..');
                ApexPages.addMessage(msg);
                return null;
            }catch(Exception e){
                System.debug('Exception-Email sent failed' +e.getMessage());
                return null;
            }
        }
        PageReference coursePage = new ApexPages.StandardController(courseObj).view();
        /*ApexPages.Message msg=new ApexPages.Message(ApexPages.Severity.INFO,'Email Sent Successfully..');
			ApexPages.addMessage(msg);*/
        coursePage.setRedirect(true);
        return coursePage;
    }
}