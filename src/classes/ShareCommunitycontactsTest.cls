@istest
private class ShareCommunitycontactsTest{
    
    public static testmethod void shareCommunityContact(){
        profile branchProfile = [select id from profile where name='Branch Coordinator'];
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        system.debug('Account inserted');
        Contact con = new Contact(Prefered_First_Name__c='test_4', LastName ='testCon4',AccountId = ac.Id);
        insert con;  
        system.debug('Contact inserted');
        system.debug('profiles-id : '+branchProfile.id);
        // NOTE : since we have duplicate username validation on User Object we need to 
        // change username on every run of this class. 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = branchProfile.id, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester4@noemail.com');
        insert user;
        system.debug('user insertered : '+user.Username);
    }
    
    
}