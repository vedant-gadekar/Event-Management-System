public class EventRegistrationEmailService {

    @future(callout=false)
    public static void sendRegistrationEmailAsync(List<Id> registrationIds) {

        List<Registration__c> regs= [
            SELECT Id, Name,
                   Participant__r.Name,
                   Participant__r.Email__c,
                   Event__r.Name,
                   Event__r.Max_Partcipants__c,
                   Event__r.Club__r.Name
            FROM Registration__c
            WHERE Id IN :registrationIds
        ];
        if (regs.isEmpty()) {
            // Record deleted before async ran — safely exit
            System.debug('Registration record no longer exists, skipping email.');
            return;
        }

        for(Registration__c reg:regs){
            if (String.isNotBlank(reg.Participant__r.Email__c)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            string mailId=reg.Participant__r.Email__c;
            string eventName=reg.Event__r.Name;
            string clubName=reg.Event__r.Club__r.Name;
            string participantName=reg.Participant__r.Name;

            mail.setToAddresses(new String[]{mailId});
            mail.setSubject('Regisration Confirmed for ' + eventName);


            String body = 'Hello ' + participantName + ',<br/><br/>' +
                'You have successfully registered for the event <b>' + eventName + '</b>!<br/><br/>' +
                
                'Thank you for registering.<br/><br/>' +
                'Best Regards,<br/> '+ clubName;

            mail.setHtmlBody(body);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        }
        
    }
}
