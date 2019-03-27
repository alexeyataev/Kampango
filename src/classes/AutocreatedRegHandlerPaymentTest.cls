@isTest
private class AutocreatedRegHandlerPaymentTest {
static testMethod void testCreateAndUpdateUser() {
    AutocreatedRegHandlerPayment handler = new AutocreatedRegHandlerPayment();
    Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'testusertesterss@example.org', null, 'testuserlongsss', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
    User u = handler.createUser(null, sampleData);
    System.assertEquals('testuserlongsss@salesforce.com', u.userName);
    System.assertEquals('testusertesterss@example.org', u.email);
    System.assertEquals('testLast', u.lastName);
    System.assertEquals('testFirst', u.firstName);
    System.assertEquals('testuser', u.alias);
    insert(u);
    String uid = u.id;
    
    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
        'testNewFirst testNewLast', 'testnewusertestrts@example.org', null, 'testnewuserlongsss', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
    handler.updateUser(uid, null, sampleData);
    
    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
    System.assertEquals('testnewuserlongsss@salesforce.com', updatedUser.userName);
    System.assertEquals('testnewusertestrts@example.org', updatedUser.email);
    System.assertEquals('testNewLast', updatedUser.lastName);
    System.assertEquals('testNewFirst', updatedUser.firstName);
    System.assertEquals('testnewu', updatedUser.alias);
}
}