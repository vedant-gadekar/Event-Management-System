
@IsTest
public class EventControllerTest {

    private static Club__c createTestClub() {
        Club__c c = new Club__c(Name = 'Test Club');
        insert c;
        return c;
    }

    @IsTest
    static void testCreateEvent_Success() {
        Club__c testClub = createTestClub();

        Test.startTest();
        Event__c evt = EventController.createEvent('Tech Expo', testClub.Id, 100);
        Test.stopTest();

        // Fetch the event to verify it was inserted
        Event__c insertedEvt = [SELECT Id, Name, Club__c, Max_Partcipants__c, Registered_Participants__c 
                                FROM Event__c WHERE Id = :evt.Id LIMIT 1];

        System.assertNotEquals(null, insertedEvt.Id, 'Event should have been inserted');
        System.assertEquals('Tech Expo', insertedEvt.Name, 'Event name mismatch');
        System.assertEquals(testClub.Id, insertedEvt.Club__c, 'Event should be linked to the correct club');
        System.assertEquals(100, insertedEvt.Max_Partcipants__c, 'Max participants mismatch');
        System.assertEquals(0, insertedEvt.Registered_Participants__c, 'Registered participants should start at 0');
    }

    @IsTest
    static void testCreateEvent_BlankName() {
        Boolean exceptionThrown = false;

        try {
            Club__c c = createTestClub();
            EventController.createEvent('', c.Id, 50);
        } catch (Exception e) {
            exceptionThrown = true;
            // AuraHandledException appears as 'Script-thrown exception' in tests
            System.assertEquals('Script-thrown exception', e.getMessage(), 
                'Expected AuraHandledException for blank event name');
        }

        System.assertEquals(true, exceptionThrown, 'Exception should have been thrown for blank name');
    }

    @IsTest
    static void testGetAllEvents() {
        Club__c c = createTestClub();
        EventController.createEvent('Hackathon', c.Id, 200);
        EventController.createEvent('Seminar', c.Id, 50);

        Test.startTest();
        List<Event__c> allEvents = EventController.getAllEvents();
        Test.stopTest();

        System.assert(allEvents.size() >= 2, 'Expected at least 2 events');
    }

    @IsTest
    static void testGetEventsByClub() {
        Club__c clubA = createTestClub();
        Club__c clubB = new Club__c(Name = 'Another Club');
        insert clubB;

        EventController.createEvent('Club A Event', clubA.Id, 100);
        EventController.createEvent('Club B Event', clubB.Id, 150);

        Test.startTest();
        List<Event__c> clubAEvents = EventController.getEventsByClub(clubA.Id);
        Test.stopTest();

        System.assertEquals(1, clubAEvents.size(), 'Should return only events for Club A');
        System.assertEquals('Club A Event', clubAEvents[0].Name);
    }

    @IsTest
    static void testDeleteEvent() {
        Club__c c = createTestClub();
        Event__c evt = EventController.createEvent('Delete Me', c.Id, 10);

        Test.startTest();
        EventController.deleteEvent(evt.Id);
        Test.stopTest();

        // Verify deletion
        List<Event__c> deleted = [SELECT Id FROM Event__c WHERE Id = :evt.Id ALL ROWS];
        System.assertEquals(true, deleted.isEmpty(), 'Event should have been deleted');
    }
}
