public without sharing class CreateGiftAidDeclarationHelper {
    @InvocableMethod
    public static void createGiftAidDeclaration(List<List<gaid__Gift_Aid_Declaration__c>> giftAidDeclarationList) {
        if(!giftAidDeclarationList.isEmpty() || !giftAidDeclarationList[0].isEmpty()) { 
            try {

                for(gaid__Gift_Aid_Declaration__c gad : giftAidDeclarationList[0]) {
                    gad.gaid__Acquisition_Method__c = String.valueOf(gad.gaid__Acquisition_Method__c);
                }

            insert giftAidDeclarationList[0];

            } catch(DMLException ex) {
                throw new CreateGiftAidDeclarationException();
            }
        }

    }

    public class CreateGiftAidDeclarationException extends Exception {}
}