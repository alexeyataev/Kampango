/*ContactUtilities Class: Used to check the Duplicate Contacts.
    **
    * Author        : Ujwal Theja
    * Created Date  : 07-12-2018
    * (c) Copyright by CSS Corp.
    **
*/


public with sharing class ContactUtilities {
    
    /* This method validates the contact is existing or not 
     **
	 * email:- Get the list of contacts based on the email id
	 **
	*/
    public static boolean isContactExisting(String email){
        		list<Contact> contactlist = [SELECT 
                                     	Id, Email 
                                     FROM 
                                     	Contact 
                                     WHERE 
                                     	Email = :email and Email != null and Email != '']; 
                                  	 
        if(contactList.size()>0){
            System.debug('Contact List size: '+contactlist);
            return true;
        }
        else{
            return false;
        }
     	
    }
    
    /* This method used to validate the Volunteer is existing or not
	 **
     * contId :- Contact id is used to check whether the contact had assigned as volunteer or not
	 **
	*/
    public static boolean isVolunteerExisting(Id contId){//, String email
        
        list<AccountContactRelation> accntContRelList = [SELECT Id,
                                                         		Roles 
                                                         FROM 
                                                         		AccountContactRelation 
                                                         where 
                                                         	Contact.id=:contId ]; //OR Contact.Email = :email
        
        if(accntContRelList.size()>0 && (accntContRelList[0].Roles =='Volunteer' || accntContRelList[0].Roles =='Branch Coordinator' ||accntContRelList[0].Roles =='Branch Treasurer' || accntContRelList[0].Roles =='Regional Coordinator')){
            System.debug('Contact List size: '+accntContRelList);
            return true;
        }
        else{
            return false;
        }
    }
    
    /* This methiod is used to validate whether user is a Staff or not
	 **
	 * It returns boolean value.
	 **
    */
    public static boolean isStaff(Id userId){
        
        
        list<User> us = [Select Id ,Profile.Name from User where id = :userId];
        if(us.size()>0 && us[0].Profile.Name != null && us[0].Profile.Name == 'Office Staff'){
            System.debug('Profile Name: '+us[0].Profile.Name);
            return true;
        }
        else{
            return false;
        }
    }
    
    public static String targetCustomer(Boolean isStaff,Boolean isVolunteer,Boolean isPractitioner,String twomems){
        String targetCustomer;
        if(isStaff == true){
            targetCustomer = 'Staff Only';
        }
        else if(isVolunteer == true || isPractitioner == true){
            targetCustomer = 'Volunteer/Practitioner';
        }
        else{
            if(twomems == 'true'){
                targetCustomer = 'Parent, Companion';
            }
            else{
                targetCustomer = 'Parent';
            }
            
        }
        return targetCustomer;
    }
}