/**
*   @author:  Mahanth Garlapati
*   @description: This class provides the utilities for membership functionality
*
*    19/11/2018 MG Initial Implementation
*    29/11/2018 MG W001166 - Added Method isPractitioner()
*    14/12/2018 MG W001144 - Added new Method that takes 3 parameters getMembershipType()
**/

public without sharing class MembershipUtilties {

 
    /**
    *   @contactType : This is contact type and can be Individual,Joint, Volunteer, Practitioner
    *   returns valid Memberships as map.
    *   @targetCustomer : This is a target customer and should have Parent, (Parent, Companion), Volunteer/Practitioner,
    *   Parent on benefits, Staff only --> Updated on 29/11/2018 added by ujwal
    *    
    **/
    public static Map<String, List<sObject>> getMembershipTypeMap(String contactType, String targetCustomer){

        return getMembershipTypeMap(contactType,targetCustomer,false);  
    }

    public static Map<String, List<sObject>> getMembershipTypeMap(Boolean twoMems, String targetCustomer, Boolean etSpecific){
        if (twoMems){
            return MembershipUtilties.getMembershipTypeMap('Joint',targetCustomer,etSpecific);
        }else{
            return MembershipUtilties.getMembershipTypeMap('Individual',targetCustomer,etSpecific);
        }
    }

    /**
    *  This method takes the contact is Practitioner or not.    
    *  @etspecific : This takes the boolean value based on ET journey or not 
    *  @contactType : This is contact type and can be Individual,Joint, Volunteer, Practitioner
    *  returns valid Memberships as map.
    *  @targetCustomer : This is a target customer and should have Parent, (Parent, Companion), Volunteer/Practitioner,
    *  Parent on benefits, Staff only 
    *  and returns the list of all Membership Types except Volunteer and Practitioner type.
    *  Story:  W001144 
    */
    public static Map<String, List<sObject>> getMembershipTypeMap(String contactType, String targetCustomer, Boolean etSpecific){

        
        Map<String, List<Membership_Type__mdt>> membershipTypeMap = new Map<String, List<Membership_Type__mdt>>();

        List<String> targetCustomerList = new List<String>();
        
        if(etSpecific == true && targetCustomer == 'Staff Only'){
            targetCustomerList.add('Staff Only');
        }
        else if (targetCustomer != 'Practitioner' && targetCustomer != 'Volunteer' && targetCustomer != 'Volunteer/Practitioner'){
            if(etSpecific == true)
            {
                targetCustomerList.add('Staff Only');
            }            
            targetCustomerList.add('Parent on benefits');
            targetCustomerList.add('Parent');
            targetCustomerList.add('Parent, Companion');
        }else{
            targetCustomerList.add('Volunteer/Practitioner');
            targetCustomerList.add(targetCustomer);
        }
        
        List<Membership_Type__mdt>   membershipTypeList = [
                                                            SELECT 
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
                                                                Contact_Type__c = :contactType
                                                            AND
                                                                Target_Customer__c IN : targetCustomerList
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
                                                    Practitioner_Role__r
                                                WHERE
                                                    Is_Active__c = True
                                            )
                                        FROM
                                            Contact
                                        WHERE
                                            LastName = :lastName AND
                                            Email = :email 
                                    ];

            if(contactList.size()>0 && contactList[0].Practitioner_Role__r != null && contactList[0].Practitioner_Role__r.size() > 0){
                
                    return true;
              
            }
            

        return false;
    }

    /**
    *  This Method returns the Date value for the Next Donation Date 
    *  @todaysDate : This value should be the todays Date
    *  Story: W-001355
    */
    public static Date getNextDonationDate(Date todaysDate){
        if (todaysDate.addDays(10) < Date.newInstance(todaysDate.year(), todaysDate.month()+1, 03)){
                return Date.newInstance(todaysDate.year(), todaysDate.month()+1, 03);
            }else{
                return Date.newInstance(todaysDate.year(), todaysDate.month()+2, 03);
            }
    }

    
    public static Map<String,Decimal> getGeoCodes(String postCode){
        Map<String,Decimal> geoCodes;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
 
        request.setEndpoint('https://geocoder.api.here.com/6.2/geocode.json?app_id=7j1reaxRvR9EH3MyZbgs&app_code=_rUgjj_n8Z9v3yofciRVUg&searchtext='+EncodingUtil.urlEncode(postCode, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept','application/json');
        request.setTimeout(60000);
        System.debug('request=========>'+request);
          
        //make the http callout
        HttpResponse response = http.send(request);
        //parse JSON to extract co-ordinates
        System.Debug('Response body'+response.getBody());
        //---------------------
        if(response.getstatusCode() == 200 && response.getbody() != null){
            System.debug(json.deserializeUntyped(response.getBody()));
        }
        //-----------------------
        JSONParser responseParser = JSON.createParser(response.getBody());
        //initialize co-ordinates
        decimal latitude = null;
        decimal longitude = null;
        while(responseParser.nextToken() != null) {
            if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) &&(responseParser.getText()== 'location')) {
                responseParser.nextToken();
                while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                    String locationText = responseParser.getText();
                    responseParser.nextToken();
                    if (locationText == 'latitude'){
                        latitude = responseParser.getDecimalValue();    
                    }else if (locationText == 'longitude'){
                        longitude = responseParser.getDecimalValue();
                    }
                }
            }
        }
        
        geoCodes = new Map<String,Decimal>();
        geoCodes.put('latitude',latitude);
        geoCodes.put('longitude',longitude);
        
        return geoCodes; 
        
            
    }

    /**
    *  This method displays the nearest branches and all branches in alphabetical order.
    *  @postcode : This is the postcode value.
    *  and returns the list of nearest branches and also list of all branches in alphabetical order.
    *  @MahanthG developed on 31/12/18 
    */
    public static Map<String, List<sObject>> getBranches(String postcode){ 

        Map<String,Decimal> geoCodes = getGeoCodes(postcode);

        Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
        
        decimal lat = geoCodes.get('latitude');
        decimal lon = geoCodes.get('longitude');
        
        if(lat != null && lon != null){
            String q = 'SELECT Id, Name, BillingAddress FROM Account WHERE RecordType.Name = \'Branch\' AND DISTANCE(BillingAddress, GEOLOCATION('+lat+', '+lon+'), \'mi\') < 200 '+ 
                       'ORDER BY DISTANCE(BillingAddress, GEOLOCATION('+lat+', '+lon+'), \'mi\') LIMIT 10';
                                        
           
            List<Account> nearestBranches = Database.query(q);
            
            
            for(Account topTenBranches : nearestBranches){
                System.debug('Branch Name : ' + topTenBranches.Name);
                
            }
            accountMap.put('All NearestBranches', nearestBranches);
            System.debug('Nearest Branches : '+accountMap.get('NearestBranches'));
           
        }
       

        List<Account> listOfAllBranches = new List<Account>();

        listOfAllBranches = [
                                SELECT
                                    Id,
                                    Name
                                FROM
                                    Account
                                WHERE
                                    RecordType.Name = 'Branch'
                                AND 
                                    (
                                            Name != null 
                                        OR 
                                            Name != ''
                                    )
                                ORDER BY
                                    Name
                            ];
        for(Account allBranches : listOfAllBranches){
            System.debug('Branch Name : '+allBranches.Name);
        }
        accountMap.put('Alphabetical list below:', listOfAllBranches);
        System.debug('List of all Branches : '+accountmap.get('Alphabetical list below:'));
        

        return accountMap;
    }

}