@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class IndividualBookingJourneyHelper {

    @InvocableMethod(label='Update Individual')
    global static List<Individual> updateIndividual(List<Individual> individual){
        if(individual != null && !individual.isEmpty()){
            try{
                update individual;
            } catch(DmlException ex){
                System.debug(
                    Label.ContactUpdateException + ' ' +
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage()
                );
            }
            
        }
        return individual;
    }

}
//NOPMD
//Incident #16 - https://confluence.nct.org.uk:8443/x/EoSO
