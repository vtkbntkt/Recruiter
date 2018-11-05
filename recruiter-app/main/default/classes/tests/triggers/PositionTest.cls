@isTest
private class PositionTest {
    private static final Id QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Unclaimed Positions Queue'].get(0).id;
    
    @testSetup static void methodName() {
    User recruiter = 
        TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
 }
    
    @isTest static void test_PositionTrigger(){
        //Given
        Integer notrecruiterNum = 2;
        Integer recruiterNum = 3;
        User notRecruiter = TestDataFactory.getRandomUser('NotRecruiter','System Administrator', 'Anton', 'Bezuh', true);
        User recruiter = TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Evgen', 'Mora', true);
        List<Position__c> posns = TestDataFactory.getPositions(notRecruiter.id,notrecruiterNum);
        posns.addAll(TestDataFactory.getPositions(recruiter.id,recruiterNum));
        
        //When
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)){
            insert posns;
        }
        Test.stopTest();
        
        //Then        
        System.assertEquals(notrecruiterNum,[SELECT COUNT() FROM Position__c WHERE OwnerId=:QUEUE_ID]);
        System.assertEquals(recruiterNum,[SELECT COUNT() FROM Position__c WHERE OwnerId=:recruiter.id]);
    }
    
    @isTest static void test_processEmailSending(){
        User user = TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
        List<Position__c> posns = TestDataFactory.getPositions(user.id,200);
        //List<AggregateResult> users = [SELECT Email FROM User WHERE UserRoleId IN (SELECT ID FROM UserRole WHERE Name='Recruiter') Group By Email];
        //Integer emailsToSendNum = users.size();
        
        //When    
        Test.startTest();   
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)){
            insert posns;
        }
        
        //Then      
        System.assertEquals(1,Limits.getEmailInvocations());
        Test.stopTest();
    }
    
    @isTest static void test_processJobAdvArchiving(){
        //Given       
        List<Position__c> oldList = new List<Position__c>();
        Integer positionNum = 200;
        for(Integer i=0;i<positionNum;i++ ){
            Position__c position = TestDataFactory.getRandomPosition(false);
            position.Posting_status__c = 'Posted';
            position.Status__c='Open';
            oldList.add(position);   
        }
        insert oldList;
        
        List<Position__c> newList = [SELECT Name,Posting_status__c,Status__c FROM Position__c ];
        for(Position__c position:newList){
            position.Status__c='Closed';
        }
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(200,'jobAdvServiceImpl_test_valid_body'));
        
        //When  
        Test.startTest();
        update newList;
        Test.stopTest();
        
        //Then      
        List<Position__c> positions = [SELECT name FROM Position__c WHERE Posting_status__c = 'Archived'];
        System.assertEquals(positionNum, positions.size());
    }
    
    private static MultiStaticResourceCalloutMock prepareMultiMock(Integer statusCode, String staticSourceName){
        JobAdvServiceCredentials__c credentials = getCredentials();
        insert credentials;   
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(credentials.BaseUri__c, 'getTokenBody');
        multimock.setStaticResource('https://www.orga.com/services/apexrest/JobAdv', staticSourceName);       
        multimock.setStatusCode(statusCode);
        multimock.setHeader('Content-Type', 'application/json'); 
        return multimock;        
    }
    
    
    
    private static JobAdvServiceCredentials__c getCredentials(){
        return new JobAdvServiceCredentials__c(
            Grant__c ='password', 
            ClientId__c = '12345',
            ClientSecret__c = '12345',
            Username__c ='user',
            securityToken__c='12345',
            Password__c ='123456',
            BaseUri__c='http://www.test.com');
    }
    
    
}