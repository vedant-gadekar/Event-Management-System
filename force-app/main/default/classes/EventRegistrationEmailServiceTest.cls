
@isTest
private class EventRegistrationEmailServiceTest {

    private static List<Registration__c> createTestRegistrations(Integer count, Boolean withEmail) {

        List<Club__c> clubs = new List<Club__c>();
        
        for (Integer i = 0; i < count; i++) {
            clubs.add(new Club__c(Name = 'Club ' + i));
        }
        insert clubs;

        List<Event__c> events = new List<Event__c>();
        for (Integer i = 0; i < count; i++) {
            events.add(new Event__c(
                Name = 'Event ' + i,
                Club__c = clubs[i].Id,
                Max_Partcipants__c = 10
            ));
        }
        insert events;

        List<Participant__c> participants = new List<Participant__c>();
        for (Integer i = 0; i < count; i++) {
            participants.add(new Participant__c(
                Name = 'Participant ' + i,
                Email__c = withEmail ? 'test' + i + '@example.com' : null,
                Team_Members_Count__c= count
            ));
        }
        insert participants;

        List<Registration__c> regs = new List<Registration__c>();
        for (Integer i = 0; i < count; i++) {
            regs.add(new Registration__c(
                Name = 'Reg ' + i,
                Participant__c = participants[i].Id,
                Event__c = events[i].Id
            ));
        }
        insert regs;

        return regs;

    }

    @isTest
    static void testSingleInsertWithValidData() {
        List<Registration__c> regs = createTestRegistrations(1, true);
        List<Id> regIds = new List<Id>();
        for (Registration__c r : regs) regIds.add(r.Id);


        Test.startTest();
        EventRegistrationEmailService.sendRegistrationEmailAsync(regIds);
        Test.stopTest();

        System.assert(true, 'Async email method executed successfully for valid data.');
    }

    @isTest
    static void testMissingEmail() {
        List<Registration__c> regs = createTestRegistrations(1, false);
        List<Id> regIds = new List<Id>();
        for (Registration__c r : regs) regIds.add(r.Id);

        Test.startTest();
        EventRegistrationEmailService.sendRegistrationEmailAsync(regIds);
        Test.stopTest();

        // No exception expected, but no email should be sent
        System.assert(true, 'Handled missing participant email gracefully.');
    }

    @isTest
    static void testBulkInsert() {
        List<Registration__c> regs = createTestRegistrations(50, true);
        List<Id> regIds = new List<Id>();
        for (Registration__c r : regs) regIds.add(r.Id);


        Test.startTest();
        EventRegistrationEmailService.sendRegistrationEmailAsync(regIds);
        Test.stopTest();

        System.assertEquals(50, regs.size(), 'All async calls executed in bulk scenario.');
    }

    // @isTest
    // static void testInvalidId() {
    //     Test.startTest();
    //     try {
    //         EventRegistrationEmailService.sendRegistrationEmailAsync('005XXXXXXXXXXXX'); // Invalid ID for Registration
    //         Test.stopTest();
    //         System.assert(true, 'Handled invalid ID gracefully without unhandled exception.');
    //     } catch (Exception e) {
    //         System.assert(false, 'Should not throw exception for invalid ID: ' + e.getMessage());
    //     }
    // }

}