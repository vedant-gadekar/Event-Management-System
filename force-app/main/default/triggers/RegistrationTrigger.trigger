trigger RegistrationTrigger on Registration__c (after insert,after delete) {
    if(Trigger.isAfter && Trigger.isInsert) {

        List<Id> regIds = new List<Id>();
        for (Registration__c reg : Trigger.new) {
            regIds.add(reg.Id);
        }

        // Call async method only once for all new records thus avoiding the governor limit
        if (!regIds.isEmpty()) {
            EventRegistrationEmailService.sendRegistrationEmailAsync(regIds);
        }

        
        RegistrationTriggerHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        System.debug('RegistrationTrigger: after delete fired for ' + Trigger.old.size() + ' records');

        RegistrationTriggerHandler.afterDelete(Trigger.old);
    }

}
