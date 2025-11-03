
@IsTest
public with sharing class ClubControllerTest {
    @TestSetup
    static void setupTestData() {

        List<Club__c> clubList = new List<Club__c>();
        for (Integer i = 0; i < 3; i++) {
            clubList.add(new Club__c(Name = 'Test Club ' + i));
        }
        insert clubList;
    }

    @IsTest
    static void testCreateClub_Success() {
        Id newClubId = ClubController.createClub('New Test Club');

        Club__c createdClub = [SELECT Id, Name FROM Club__c WHERE Id = :newClubId];
        System.assertEquals('New Test Club', createdClub.Name, 'Club name should match the input name');
    }

    @IsTest
    static void testCreateClub_NullName() {
        Boolean exceptionThrown = false;

        try {
            ClubController.createClub(null);
        } catch (Exception e) {
            exceptionThrown = true;

            System.debug('Exception message: ' + e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage(), 
                'Expected a Script-thrown exception from AuraHandledException');
        }

        System.assertEquals(true, exceptionThrown, 'An exception should have been thrown for null club name');
    }


    @IsTest
    static void testGetAllClubs() {
        // Call the getAllClubs method
        List<Club__c> clubs = ClubController.getAllClubs();

        // Assert we got at least the 3 test setup records
        System.assert(clubs.size() >= 3, 'There should be at least 3 clubs returned');
    }

    @IsTest
    static void testDeleteClub() {
        // Create a club to delete
        Club__c tempClub = new Club__c(Name = 'Delete Me');
        insert tempClub;

        // Call the delete method
        ClubController.deleteClub(tempClub.Id);

        // Query including soft-deleted records
        List<Club__c> deleted = [
            SELECT Id, IsDeleted 
            FROM Club__c 
            WHERE Id = :tempClub.Id 
            ALL ROWS
        ];

        // Assert the record is found and marked as deleted
        System.assertEquals(1, deleted.size(), 'Deleted record should still exist in Recycle Bin');
        System.assertEquals(true, deleted[0].IsDeleted, 'Record should be marked as deleted');
    }

}