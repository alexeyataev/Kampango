/*Community Parent Signup Page Controller: Controls the ParentCommunitySelfReg page.
    **
    * Author        : Ujwal Theja
    * Created Date  : 16-08-2018
    * (c) Copyright by CSS Corp.
    **
*/
public with sharing class ParentCommunitySelfRegController {
    
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
    
    
    
    public List<SelectOption> getPreferenceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Post','Post'));
        options.add(new SelectOption('Email','Email'));
        options.add(new SelectOption('SMS Text','SMS Text'));
        options.add(new SelectOption('Telephone','Telephone'));
       
        return options;
    }
    
    public ParentCommunitySelfRegController() {
        String expid = ApexPages.currentPage().getParameters().get('expid');            
        //if (expId != null) {
            //Site.setExperienceId(expId); 
        //}    
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
                    preference = str;
                    start = false;
                } else {               
                    preference = preference + ';' + str;
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
        u.Contact_Preference__c = preference;
       
        u.PostalCode = postalCode;
        
        u.Phone = phone;
        
        
        if(u.PostalCode == '' || u.PostalCode!=null){
            if(u.PostalCode.length()>=6){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid postalcode'));
               
            }
        }
        String userId;
        System.debug('Test'+userName);
        /**try {
            userId = Site.createExternalUser(u, accountId, password);
            
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                
                 
            }
            list<User> us =[select username from  user where username =:email];
        
        	if(email == us[0].username){
            System.debug('username'+us[0].username);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Email already exist on the system'));
        	} 
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }**/
        
        //if (userId != null) { 
            
            /**if (password != null && password.length() > 1) {
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
                
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }**/
        //}
        return null;
    }
   
}