public with sharing class EventController {

    @AuraEnabled
    public static Event__c createEvent(String eventName, Id clubId, Integer maxParticipants) {
        if (String.isBlank(eventName)) {
            throw new AuraHandledException('Event name cannot be empty.');
        }

        Event__c newEvent = new Event__c(
            Name = eventName,
            Club__c = clubId,
            Max_Partcipants__c = maxParticipants,
            Registered_Participants__c = 0
        );
        
        insert newEvent;
        return newEvent;
    }


    // read all Events
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getAllEvents() {
        try{
            return [
            SELECT Id, Name, Club__r.Name, Max_Partcipants__c, Registered_Participants__c
            FROM Event__c
            ORDER BY CreatedDate DESC
            ];
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   

    // read events by Club
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getEventsByClub(Id clubId) {
        return [
            SELECT Id, Name, Max_Partcipants__c,Registered_Participants__c
            FROM Event__c
            WHERE Club__c = :clubId
            ORDER BY CreatedDate DESC
        ];
    }

    // delete Event
    @AuraEnabled
    public static void deleteEvent(Id eventId) {
        delete [SELECT Id FROM Event__c WHERE Id = :eventId LIMIT 1];
    }

    

}