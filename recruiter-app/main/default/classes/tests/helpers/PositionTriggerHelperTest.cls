@isTest
private class PositionTriggerHelperTest {
    private static final Id QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Unclaimed Positions Queue'].get(0).id;
    
    @testSetup static void methodName() {
    User recruiter = 
        TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
 }
    
    @isTest static void test_process_UpdatePositionOwnerCorrectly(){
        //Given
        User user = TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
        List<Position__c> posns = getPosns('Manager');
        
        //When
        Test.startTest();
        PositionTriggerHelper.processOwnerSetting(posns);
        Test.stopTest();
        
        //Then
        System.assertEquals(QUEUE_ID,posns.get(0).OwnerId); 
    }
    
    @isTest static void test_process_BulkUpdatePositionOwnerCorrectly(){
        //Given
        Integer notrecruiterNum = 99;
        Integer recruiterNum = 101;
        User notRecruiter = TestDataFactory.getRandomUser('NotRecruiter','System Administrator', 'Anton', 'Bezuh', true);
        User recruiter = TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Evgen', 'Mora', true);
        List<Position__c> posns = TestDataFactory.getPositions(notRecruiter.id,notrecruiterNum);
        posns.addAll(TestDataFactory.getPositions(recruiter.id,recruiterNum));
        
        //When
        Test.startTest();
        PositionTriggerHelper.processOwnerSetting(posns);
        Test.stopTest();
        
        //Then
        Integer changedPosNum =0;
        Integer notChangedNum =0;
        for(Position__c pos:posns){         
            if(pos.OwnerId==recruiter.id){
                notChangedNum++;
            }
            else if(pos.OwnerId==QUEUE_ID){
                changedPosNum++;
            }
        }       
        System.assertEquals(notrecruiterNum,changedPosNum);
        System.assertEquals(recruiterNum,notChangedNum);
        
    }
    
    @isTest static void test_process_NoNeedToUpdatePositionOwner(){
        //Given
        List<Position__c> posns = getPosns('Recruiter');
        Id ownerIdOld = posns.get(0).OwnerId;
        
        //When
        Test.startTest();
        PositionTriggerHelper.processOwnerSetting(posns);
        Test.stopTest();
        
        //Then
        System.assertEquals(ownerIdOld,posns.get(0).OwnerId);  
        
    }
    
    @isTest static void test_process_NoRelevantQueue(){
        //Given
        List<Position__c> posns = getPosns('Recruiter');
        PositionTriggerHelper.testFlag = PositionTriggerHelper.Flag.NO_QUEUE;
        
        Test.startTest();
        try{
            // When
            PositionTriggerHelper.processOwnerSetting(posns);
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){
            // Then
            System.assert(exc instanceOf PositionTriggerHelper.NoRelevantQueueException);           
        } 
        Test.stopTest();
    }
    
    @isTest static void test_process_NoRecruiters(){
        //Given
        List<Position__c> posns = getPosns('Recruiter');
        PositionTriggerHelper.testFlag = PositionTriggerHelper.Flag.NO_RECRUITS;
        
        Test.startTest();
        try{
            // When
            PositionTriggerHelper.processOwnerSetting(posns);
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){
            // Then
            System.assert(exc instanceOf PositionTriggerHelper.NoRecruitersQueueException);           
        } 
        Test.stopTest();
        
    }
    
    @isTest static void test_processEmailSending(){
        //Given
        User user = TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
        List<Position__c> posns = TestDataFactory.getPositions(user.id,200);
        //List<AggregateResult> users = [SELECT Email FROM User WHERE UserRoleId IN (SELECT ID FROM UserRole WHERE Name='Recruiter') Group By Email];
        //Integer emailsToSendNum = users.size();
        
        //When  
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)){ 
        PositionTriggerHelper.processEmailSending(posns);    
        }
               
        //Then      
        System.assertEquals(1,Limits.getEmailInvocations()); 
        Test.stopTest();
    }
    
    @isTest static void test_processJobAdvArchivingCorrectlyWithNotRelevantRecords(){
        //Given       
        List<Position__c> oldList = new List<Position__c>();
        oldList.add(new Position__c(Name = 'Dev1', Posting_status__c = 'Not Posted', Status__c='Open'));//not relevant posting status
        oldList.add(new Position__c(Name = 'Dev2', Posting_status__c = 'Posted', Status__c='Open')); 
        oldList.add(new Position__c(Name = 'Dev3', Posting_status__c = 'Posted', Status__c='Closed')); // not relevant  - status has not been changed
        insert oldList;
        
        List<Position__c> newList = [SELECT Name,Posting_status__c,Status__c FROM Position__c ];
        for(Position__c position:newList){
            position.Status__c='Closed';
        }
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(200,'jobAdvServiceImpl_test_valid_body'));
        
        //When  
        Test.startTest();
        PositionTriggerHelper.processJobAdvArchiving(new Map<Id,Position__c>(oldList), new Map<Id,Position__c>(newList));
        Test.stopTest();
        
               
        //Then      
        List<Position__c> positions = [SELECT name FROM Position__c WHERE Posting_status__c = 'Archived'];
        System.assertEquals(1, positions.size());
        System.assertEquals('Dev2', positions.get(0).name);
    }
    
    @isTest static void test_processJobAdvArchivingBulk(){
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
        PositionTriggerHelper.processJobAdvArchiving(new Map<Id,Position__c>(oldList), new Map<Id,Position__c>(newList));
        Test.stopTest();
                       
        //Then      
        List<Position__c> positions = [SELECT name FROM Position__c WHERE Posting_status__c = 'Archived'];
        System.assertEquals(positionNum, positions.size());
        
    }
    
    
    
    
    
    
    
    private static List<Position__c> getPosns(String roleName){
        List<Position__c> posns = new List<Position__c>();
        User user = TestDataFactory.getRandomUser(roleName,'System Administrator', 'Anton', 'Bezuh', true);
        Position__c posn = TestDataFactory.getRandomPosition(false, user.id);       
        posns.add(posn);        
        return posns;
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