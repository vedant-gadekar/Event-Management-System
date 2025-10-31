public with sharing class RegistrationController {

    //create registration
    @AuraEnabled
    public static Id createRegistration(String registrationName, Id participantId, Id eventId) {
        Registration__c reg = new Registration__c(
            Name = 'Pending Team Name...',
            Participant__c = participantId,
            Event__c = eventId
        );
        insert reg;
        System.debug('before team name updated');

        RandomUserService.assignRandomTeamNameAsync(reg.Id);
        
        return reg.Id;
    }



    // read Registrations
    @AuraEnabled(cacheable=true)
    public static List<Registration__c> getAllRegistrations() {
        return [
            SELECT Id, Name, Participant__r.Name, Event__r.Name,Participant__r.Team_Members_Count__c
            FROM Registration__c
            ORDER BY CreatedDate DESC
        ];
    }

    // READ Registrations by Event
    @AuraEnabled(cacheable=true)
    public static List<Registration__c> getRegistrationsByEvent(Id eventId) {
        return [
            SELECT Id, Name, Participant__r.Name, Event__r.Name,Participant__r.Team_Members_Count__c
            FROM Registration__c
            WHERE Event__c = :eventId
            ORDER BY CreatedDate DESC
        ];
    }

    // READ Registrations by Participant
    @AuraEnabled(cacheable=true)
    public static List<Registration__c> getRegistrationsByParticipant(Id participantId) {
        return [
            SELECT Id, Name, Participant__r.Name, Event__r.Name,Participant__r.Team_Members_Count__c
            FROM Registration__c
            WHERE Participant__c = :participantId
            ORDER BY CreatedDate DESC
        ];
    }

    // UPDATE Registration
    @AuraEnabled
    public static void updateRegistration(Id registrationId, String registrationName) {
        Registration__c reg = [SELECT Id FROM Registration__c WHERE Id = :registrationId LIMIT 1];
        reg.Name = registrationName;
        update reg;
    }

    // DELETE Registration
    @AuraEnabled
    public static void deleteRegistration(Id registrationId) {
        delete [SELECT Id FROM Registration__c WHERE Id = :registrationId LIMIT 1];
    }

}