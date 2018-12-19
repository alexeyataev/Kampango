public with sharing class ErrorMessageInVfController {

    public ErrorMessageInVfController(ApexPages.StandardController controller) {

    }

    public boolean displayPopup {get; set;}
    public void closePopup()
    {       
        displayPopup = false;   
    }    
    public void showPopup()
    {       
        displayPopup = true;
        save();   
    }   
    public void save(){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved successfully!'));
    }

}