trigger RegistrationTrigger on Registration__c (after insert) {
    if(Trigger.isAfter) {

        for (Registration__c reg : Trigger.new) {
            EventRegistrationEmailService.sendRegistrationEmailAsync(reg.Id);
        }
        
        RegistrationTriggerHandler.afterInsert(Trigger.new);
    }
    
}
