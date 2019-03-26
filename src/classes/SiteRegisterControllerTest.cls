/**
 * Class containing tests for SiteRegisterController
 */
@IsTest public with sharing class SiteRegisterControllerTest {
    @IsTest static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }
    @IsTest static void testGuestRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        Profile p = [SELECT Id FROM Profile WHERE Name='Guest License User'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
            
            controller.username = 'test@force.com';
            controller.email = 'test@force.com';
            controller.communityNickname = 'test';
            // registerUser will always return null when the page isn't accessed as a guest user
            System.assert(controller.registerUser() == null);    
            
            controller.password = 'abcd1234';
            controller.confirmPassword = 'abcd123';
            System.assert(controller.registerUser() == null);  
        }
    }
}