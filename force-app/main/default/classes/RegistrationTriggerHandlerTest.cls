@IsTest
public class RegistrationTriggerHandlerTest {

    @TestSetup
    static void setupData(){
        Club__c c = new Club__c(Name = 'Test Club');
        insert c;

        List<Event__c> events = new List<Event__c>{
            new Event__c(
                Name = 'Event 1', 
                Registered_Participants__c = 0,
                Club__c = c.Id,
                Max_Partcipants__c = 20
                ),
            new Event__c(
                Name = 'Event 2', 
                Registered_Participants__c = 0,
                Club__c = c.Id,
                Max_Partcipants__c = 30
                )
        };
        insert events;

        // Create Participants
        List<Participant__c> participants = new List<Participant__c>{
            new Participant__c(Name = 'P1', Team_Members_Count__c = 2),
            new Participant__c(Name = 'P2', Team_Members_Count__c = 3),
            new Participant__c(Name = 'P3', Team_Members_Count__c = 1)
        };
        insert participants;

    }

    @IsTest
    static void testAfterInsertUpdateEventCount() {
        Event__c evt=[SELECT Id FROM Event__c LIMIT 1];
        List<Participant__c> participants = [SELECT Id, Team_Members_Count__c FROM Participant__c];
        
        List<Registration__c> regs=new List<Registration__c>();

        for(Participant__c part:participants){
            regs.add(new Registration__c(
                Event__c=evt.Id,
                Participant__c=part.Id
            ));
        }

        Test.startTest();
        insert regs;  
        Test.stopTest(); 

        evt = [SELECT Registered_Participants__c FROM Event__c WHERE Id = :evt.Id];
        //after the registrations are inserted, the event data is updated hence needs to be fetched again

        
        System.assertEquals(
            6, 
            evt.Registered_Participants__c,
            'Event count should increase by the participant’s Team_Members_Count__c value'
        );
    }

    @IsTest
    static void testAfterDeleteUpdateEventCount() {
        Event__c evt=[SELECT Id FROM Event__c WHERE Name='Event 2'];

        Participant__c part = [SELECT Id, Team_Members_Count__c FROM Participant__c WHERE Name = 'P2'];
        
        Registration__c reg = new Registration__c(Event__c = evt.Id, Participant__c = part.Id);

          
        Test.startTest();
        insert reg;
        delete reg;
        Test.stopTest();

        evt = [SELECT Registered_Participants__c FROM Event__c WHERE Id = :evt.Id];
        System.assertEquals(0, evt.Registered_Participants__c,
            'Event count should decrease correctly after deleting one registration');
    }
}