/*ContactUtilities Class: Used to check the Duplicate Contacts.
    **
    * Author        : Ujwal Theja
    * Created Date  : 07-12-2018
    * (c) Copyright by CSS Corp.
    **
*/


public without sharing class ContactUtilities {
    
    /* This method validates the contact is existing or not 
     **
	 * email:- Get the list of contacts based on the email id
	 **
	*/
    public static boolean isContactExisting(String email){
        		List<Contact> contactlist;
        
        contactlist = [SELECT 
                       Id, Email 
                       FROM 
                       Contact 
                       WHERE 
                       Email = :email and Email != null and Email != '']; 
        if (!Schema.sObjectType.Contact.fields.Email.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
                                  	 
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
        
       list<AccountContactRelation> accntContRelList;
        accntContRelList = [SELECT Id,
                                Roles 
                                FROM 
                                AccountContactRelation 
                                where 
                                Contact.id=:contId ]; //OR Contact.Email = :email
        if (!Schema.sObjectType.AccountContactRelation.fields.Roles.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
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
    public static boolean isStaff(Id contId){
        List<Contact> con;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
        System.debug('recordTypeId: '+recordTypeId);
        
        con = [SELECT
              		 Id,
               		 Name
                  FROM
                  	 Contact
                  WHERE 
                  	id = :contId 
               AND
               		RecordTypeId = :recordTypeId];

        if (!Schema.sObjectType.Contact.fields.Id.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }       	
        if(con.size()>0){
            
            return true;
        }
        else{
            
            return false;
        }
    }
    /* This methiod is used to fetch the targetCustomer based on the contact and user
	 **
	 * It returns String value of targetCustomer.
	 **
    */
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
    
    /* This method validates the membership is existing or not 
     **
	 * contId:- Get the list of membership based on the contId
	 **
	*/
    public static boolean isMembershipExists(Id contId, String email){
        
        list<npe03__Recurring_Donation__c> recDonList;
        recDonList =[Select 
                             Id,
                             Name,
                             npe03__Contact__c                   
                         From
                             npe03__Recurring_Donation__c
                         WHERE
                             (
                                 npe03__Contact__c != null 
                                 AND
                                 npe03__Contact__c = :contId
                             )
                         OR
                             (
                                 npe03__Contact__c != null
                                 AND
                                 (npe03__Contact__r.Email = :email AND npe03__Contact__r.Email != NULL AND npe03__Contact__r.Email != '')
                             )                      
                        ];
        if (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.npe03__Contact__c.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
         }
        if(recDonList.size()>0){
            System.debug('Recurring Donations List size: '+recDonList);
            return true;
        }
        else{
            System.debug('Recurring Donation List is Empty: False');
            return false;
        }
                
    }
    
    /*public PageReference doRedirect(Id contId){

    PageReference pageRef = new PageReference('/apex/MembershipStatus?id='+contId);
    pageRef.setRedirect(true);
    return pageRef;

    }*/

}