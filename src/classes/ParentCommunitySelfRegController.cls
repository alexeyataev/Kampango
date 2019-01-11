/*Community Parent Signup Page Controller: Controls the ParentCommunitySelfReg page.
    **
    * Author        : Ujwal Theja
    * Created Date  : 16-08-2018
    * (c) Copyright by CSS Corp.
    **
*/
public class ParentCommunitySelfRegController {
    
    public boolean displayPopup {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    //public String userName {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    Public String phone{set;get;}
    //public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    public List<String> selectedPreferences {
        get{
            if(selectedPreferences == NULL){
                
                selectedPreferences = new List<String>();
            }
            return selectedPreferences;
        }
        set;}
    //public String street {get; set;}
    //public string address {get; set;}
    //public String city {get; set;}
    //public String state {get; set;}
    public String postalCode {get; set;}
    //public String country {get; set;}
    //public String SelectedCountries {get; set;}
    /*public List<String> SelectedCountries{
        get{
            if(SelectedCountries == NULL){
                SelectedCountries = new List<String>();
            }
            return SelectedCountries;
        }
        set;
    }*/
    
    /*public List<SelectOption> getPreferredCountries(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('UK','UK'));
        options.add(new SelectOption('United Kingdom','United Kingdom'));
        options.add(new SelectOption('GB','GB'));
        return options;
    }*/
    public List<SelectOption> getPreferenceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        /*options.add(new SelectOption('Mail','Mail'));*/
        options.add(new SelectOption('Post','Post'));
        options.add(new SelectOption('Email','Email'));
        options.add(new SelectOption('SMS Text','SMS Text'));
        options.add(new SelectOption('Telephone','Telephone'));
        /*options.add(new SelectOption('Phone','Phone'));*/
         /*options.add(new SelectOption('Message','Message'));*/
        return options;
    }
    
    public ParentCommunitySelfRegController() {
        String expid = ApexPages.currentPage().getParameters().get('expid');            
        if (expId != null) {
            Site.setExperienceId(expId); 
        }    
    }
    
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    //public void closePopup()
    //{       
     //   displayPopup = false;   
    //}   
    public PageReference registerUser() {
        displayPopup = true;
        /*if(email == '' || email != null ){
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);
            if (!MyMatcher.matches()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid email address'));
               
            }
        }*/

        
        /*if(password == '' || password != NULL){
          
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Password'));
             //password.addError('Please enter password');
        }*/
        
        /*if(phone == '' || phone != null){
            if(!phone.isNumeric()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid phone number'));
            }
            if(phone.length()>=12){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter valid phone number'));
            }
        }*/
        
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
        /*String countries = '';
        Boolean start1 = true;
        if(!SelectedCountries.isEmpty()) {           
            for(String str : selectedCountries) {
                if(start1) {
                    countries = str;
                    start1 = false;
                } else {               
                    countries = countries + ';' + str;
                }
            }
        }*/
        
        String userName = email;
        //String str = street +''+ address;
        String comNickname = lastName+' '+firstName;
        
        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = comNickname;
        u.ProfileId = profileId;
        u.Contact_Preference__c = preference;
        //u.Street = str;
        //u.City = city;
        //u.State = state;
        u.PostalCode = postalCode;
        //u.Country = SelectedCountries;
        u.Phone = phone;
        
        
        if(u.PostalCode == '' || u.PostalCode!=null){
            if(u.PostalCode.length()>=6){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter valid postalcode'));
                //u.PostalCode.addError('Please enter a valid postalcode');
            }
        }
        String userId;
        System.debug('Test'+userName);
        try {
            userId = Site.createExternalUser(u, accountId, password);
            
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                 
            }
            list<User> us =[select username from  user where username =:email];
        
        	if(email == us[0].username){
            System.debug('username'+us[0].username);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Email already exist on the system'));
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