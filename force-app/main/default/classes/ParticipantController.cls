public with sharing class ParticipantController {

    // CREATE Participant
    @AuraEnabled
    public static Id createParticipant(String participantName,String email,Integer teamMemberCount)  {
        Participant__c participant = new Participant__c(
            Name = participantName,
            Email__c=email,
            Team_Members_Count__c=teamMemberCount
        );
        System.debug('Particapnt added'+participantName+' '+ email);
        insert participant;
        return participant.Id;
    }

    // READ All Participants
    @AuraEnabled(cacheable=true)
    public static List<Participant__c> getAllParticipants() {
        return [
            SELECT Id, Name,Email__c, CreatedById
            FROM Participant__c
            ORDER BY Name ASC
        ];
    }

    // DELETE Participant
    @AuraEnabled
    public static void deleteParticipant(Id participantId) {
        delete [SELECT Id FROM Participant__c WHERE Id = :participantId LIMIT 1];
    }
    

}