public with sharing class Utils {

    public static String getDeliveryMethod(List<Session__c> sessions) {
        String deliveryMethod ;
        for (Session__c session : sessions) {
            deliveryMethod = deliveryMethod != null ? session.Type__c != 'Reunion' && deliveryMethod != session.Delivery_Type__c ? 'Hybrid' : deliveryMethod : session.Delivery_Type__c;
        }
        
        return deliveryMethod;
    }
    
}
