public with sharing class RandomUserService {

    @future
    public static void assignRandomTeamNameAsync(Id registrationId) {
        try {

            String randomName = generateRandomTeamName();

            Registration__c reg = [SELECT Id, Name FROM Registration__c WHERE Id = :registrationId LIMIT 1];
            reg.Name = ' Team '+ randomName ;
            update reg;

            System.debug('Team name updated asynchronously: ' + reg.Name);

        } catch (Exception e) {
            System.debug('Error assigning team name: ' + e.getMessage());
        }
    }
    private static String generateRandomTeamName() {
        List<String> adjectives = new List<String>{'Swift', 'Brave', 'Dynamic', 'Mighty', 'Bold', 'Fearless', 'Agile', 'Thunder', 'Crimson', 'Lunar'};
        List<String> nouns = new List<String>{'Eagles', 'Titans', 'Warriors', 'Falcons', 'Panthers', 'Sharks', 'Dragons', 'Lions', 'Wolves', 'Hawks'};

        
        Integer adjIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), adjectives.size());
        Integer nounIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), nouns.size());

        return adjectives[adjIndex] + ' ' + nouns[nounIndex];
    }

}
