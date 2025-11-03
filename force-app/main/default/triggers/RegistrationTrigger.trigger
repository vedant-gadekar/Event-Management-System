trigger RegistrationTrigger on Registration__c (after insert,after delete) {
    if(Trigger.isAfter && Trigger.isInsert) {

        for (Registration__c reg : Trigger.new) {
            EventRegistrationEmailService.sendRegistrationEmailAsync(reg.Id);
        }
        
        RegistrationTriggerHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        System.debug('RegistrationTrigger: after delete fired for ' + Trigger.old.size() + ' records');

        RegistrationTriggerHandler.afterDelete(Trigger.old);
    }

}
