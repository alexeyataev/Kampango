public without sharing class AutocreatedRegHandlerPayment implements Auth.RegistrationHandler{
    public Profile p =[SELECT Id FROM profile WHERE name='Standard User'];
    public User createUser(Id portalId, Auth.UserData data){
        User u = new User();
        u.username = data.username + '@salesforce.com';
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.username;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = data.attributeMap.get('language');
        u.localesidkey = data.locale;
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        return u;
    }
    
    public void updateUser(Id userId, Id portalId, Auth.UserData data){
    	if(Schema.sObjectType.User.fields.email.isupdateable()){
	               
            User u = new User(id=userId);
            u.username = data.username + '@salesforce.com';
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName;
            String alias = data.username;
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.languagelocalekey = data.attributeMap.get('language');
            u.localesidkey = data.locale;
            update(u);
            }
        }
    }