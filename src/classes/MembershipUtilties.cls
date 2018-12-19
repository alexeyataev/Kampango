/**
*   @author:  Mahanth Garlapati
*   @description: This class provides the utilities for membership functionality
*
*    19/11/2018 MG Initial Implementation
*    29/11/2018 MG W001166 - Added Method isPractitioner()
**/

public with sharing class MembershipUtilties {

 
    /**
    *   @contactType : This is contact type and can be Individual,Joint, Volunteer, Practitioner
    *   returns valid Memberships as map.
    *   @targetCustomer : This is a target customer and should have Parent, (Parent, Companion), Volunteer/Practitioner,
    *   Parent on benefits, Staff only --> Updated on 29/11/2018 added by ujwal
    *    
    **/
    public static Map<String, List<sObject>> getMembershipTypeMap(String contactType, String targetCustomer){

        Map<String, List<Membership_Type__mdt>> membershipTypeMap = new Map<String, List<Membership_Type__mdt>>();

        List<Membership_Type__mdt> membershipTypeList = [
                                                            SELECT 
                                                                Id, 
                                                                MasterLabel, 
                                                                Eligible_for_Gift_Aid__c, 
                                                                Installment_Amount__c, 
                                                                No_of_Installments__c,
                                                                Payment_Type__c, 
                                                                Payment_Method__c, 
                                                                Recursive__c, 
                                                                Total_Amount__c, 
                                                                Contact_Type__c,
                                                                Target_Customer__c, 
                                                                Membership__c 
                                                            FROM 
                                                                Membership_Type__mdt 
                                                            WHERE 
                                                                ET_Specific__c = false AND Contact_Type__c = :contactType AND Target_Customer__c = :targetCustomer
                                                        ];

        for (Membership_Type__mdt membershipType : membershipTypeList ){
            if (membershipTypeMap.get(membershipType.Membership__c) == null){
                List<Membership_Type__mdt> tempMembershipTypeList = new List<Membership_Type__mdt>();
                tempMembershipTypeList.add(membershipType);
                membershipTypeMap.put(membershipType.Membership__c,tempMembershipTypeList);
            }else{
                membershipTypeMap.get(membershipType.Membership__c).add(membershipType);
            }

        }
        return membershipTypeMap;   
    }

    //This method takes payment type value as parameters and returns mem
    public List<Membership_Type__mdt> paymentTypeMethod(String payType){

        List<Membership_Type__mdt> paymentType = [
                                                    SELECT 
                                                        MasterLabel, 
                                                        Eligible_for_Gift_Aid__c, 
                                                        Installment_Amount__c, 
                                                        No_of_Installments__c, 
                                                        Payment_Method__c, 
                                                        Recursive__c, 
                                                        Total_Amount__c 
                                                    FROM 
                                                        Membership_Type__mdt 
                                                    WHERE 
                                                        Payment_Method__c =: payType
                                                 ];

        return paymentType; 
    }
    
    /**
    *  This method validates the contact is Practitioner or not.    
    *  @firstName : This is the FirstName of the contact 
    *  @lastName  : This should the LastName of the contact
    *  @email     : This should be email value of the contact
    *  and returns the boolean value if contact has valid practitioner license. 
    *  Story:  W001166 
    */
    public static Boolean isPractitioner(String firstName, String lastName, String email){


        

        List<Contact> contactList  = [
                                        SELECT
                                            Id,
                                            Prefered_First_Name__c,
                                            LastName,
                                            Email,
                                            (
                                                SELECT
                                                    Id
                                                FROM
                                                    Practitioner_Licence__r
                                                WHERE
                                                    Is_Active__c = True
                                            )
                                        FROM
                                            Contact
                                        WHERE
                                            Prefered_First_Name__c = :firstName AND 
                                            LastName = :lastName AND
                                            Email = :email
                                    ];

            if(contactList.size()>0 && contactList[0].Practitioner_Licence__r != null && contactList[0].Practitioner_Licence__r.size() > 0){
                System.debug('Practitioner License is : '+contactList[0].Practitioner_Licence__r.size());
        		//if (contactList[0] != null ){//&& contactList[0].Practitioner_Licence__r != null && contactList[0].Practitioner_Licence__r.size() > 0){
                    return true;
                //}
            }
            

        return false;
    }

}