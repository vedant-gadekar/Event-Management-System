public class RegistrationTriggerHandler {

    public static void afterInsert(List<Registration__c> newRegs) {

        List<Id> regIds = new List<Id>();
        for (Registration__c reg : newRegs) {
            regIds.add(reg.Id);
        }

        if (!regIds.isEmpty()) {
            updateRegisteredCountAsync(regIds);
        }
    }

    @future(callout=false)
    public static void updateRegisteredCountAsync(List<Id> registrationIds) {
        // Query the registrations with related data
        List<Registration__c> regs = [
            SELECT Id, Event__c, Participant__r.Team_Members_Count__c
            FROM Registration__c
            WHERE Id IN :registrationIds
        ];

        System.debug('update registered count async called');

        // Map of Event → total team members added
        Map<Id, Decimal> eventToAddCount = new Map<Id, Decimal>();

        for (Registration__c reg : regs) {
            Decimal count = (reg.Participant__r.Team_Members_Count__c != null) ? reg.Participant__r.Team_Members_Count__c : 1;

            if (!eventToAddCount.containsKey(reg.Event__c)) {
                eventToAddCount.put(reg.Event__c, count);
            } else {
                eventToAddCount.put(reg.Event__c, eventToAddCount.get(reg.Event__c) + count);
            }
        }

        // Query and update events
        List<Event__c> eventsToUpdate = [
            SELECT Id, Registered_Participants__c 
            FROM Event__c 
            WHERE Id IN :eventToAddCount.keySet()
        ];

        for (Event__c evt : eventsToUpdate) {
            Decimal existing = (evt.Registered_Participants__c != null) ? evt.Registered_Participants__c : 0;
            evt.Registered_Participants__c = existing + eventToAddCount.get(evt.Id);
        }

        update eventsToUpdate;
    }
}
