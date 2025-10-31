public with sharing class ClubController {

    //create club
    @AuraEnabled
    public static Id createClub(String name) {
        if (name == null) {
            throw new AuraHandledException('Club name cannot be null');
        }

        Club__c club = new Club__c(Name = name);
        insert club;
        return club.Id;
    }

    //read all clubs
    @AuraEnabled(cacheable=true)
    public static List<Club__c> getAllClubs() {
        try {
            return [
            SELECT Id, Name
            FROM Club__c
            ORDER BY Name ASC
        ];
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // delete Club
    @AuraEnabled
    public static void deleteClub(Id clubId) {
        delete [SELECT Id FROM Club__c WHERE Id = :clubId LIMIT 1];
    }
}