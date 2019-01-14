public with sharing class Attachmentsample {

    public Attachmentsample(ApexPages.StandardController controller) {

    }
    Public Attachment myfile;
    Public Attachment getmyfile()
    {
        myfile = new Attachment();
        return myfile;
    }
   
    Public Pagereference savedoc()
    {
        String accid = System.currentPagereference().getParameters().get('id');

        Attachment a = new Attachment(parentId = accid, name=myfile.name, body = myfile.body);
         
         /* insert the attachment */
     try{
         insert a;
     }
     catch(DMLException e){
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
       return null;
     }
     
     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
        return NULL;
    }   

}
