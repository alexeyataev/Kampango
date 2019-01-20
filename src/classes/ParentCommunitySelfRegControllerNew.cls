/*Community Parent Signup Page Controller: Controls the ParentCommunitySelfReg page.
    **
    * Author        : Ujwal Theja
    * Created Date  : 16-08-2018
    * (c) Copyright by CSS Corp.
    **
*/
public class ParentCommunitySelfRegControllerNew {
    
    public boolean displayPopup {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    Public String phone{set;get;}
    
    public List<String> selectedPreferences {
        get{
            if(selectedPreferences == NULL){
                
                selectedPreferences = new List<String>();
            }
            return selectedPreferences;
        }
        set;}
   
    public String postalCode {get; set;}
    
    public List<selectOption> getPreferenceOptions() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('Mail','Mail'));
        options.add(new selectOption('Post','Post'));
        options.add(new selectOption('Email','Email'));
        options.add(new selectOption('Phone','Phone'));
        options.add(new selectOption('Message','Message'));
        return options;
    }
    
    public ParentCommunitySelfRegControllerNew() {
        String expid = ApexPages.currentPage().getParameters().get('expid');            
        if (expId != null) {
            Site.setExperienceId(expId); 
        }    
    }
    
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
     
    public PageReference registerUser() {
        displayPopup = true;
        
        
           // it's okay if password is null - we'll send the user a random password in that case
    
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.
        
        String preference = '';
        Boolean start = true;
        if(!selectedPreferences.isEmpty()) {           
            for(String str : selectedPreferences) {
                if(start) {
                    Preference = str;
                    start = false;
                } else {               
                    Preference = Preference + ';' + str;
                }
            }
        }
       
        
        String userName = email;
        
        String comNickname = lastName+' '+firstName;
        
        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = comNickname;
        u.ProfileId = profileId;
        u.Contact_Preference__c = Preference;
        
        u.PostalCode = postalCode;
        
        u.Phone = phone;
        
       
        String userId;
        System.debug('Test'+userName);
        try {
            userId = Site.createExternalUser(u, accountId, password);
            
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                 
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
        
        if (userId != null) { 
            
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
                
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
   
}