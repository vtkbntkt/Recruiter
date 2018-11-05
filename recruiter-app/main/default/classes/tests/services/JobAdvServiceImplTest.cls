@isTest
private class JobAdvServiceImplTest {
    
    @testSetup static void methodName() {
    User recruiter = 
        TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
 }

    
    @IsTest static void test_postJobAdvCorrectly(){       
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        //StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :staticSourceName LIMIT 1];
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        
        Position__c position = new Position__c(Name='Manager');
        insert position;
        
        // When
        Test.startTest();
        service.postJobAdvWithPositionUpdate(position);       
        Test.stopTest();
        
        //Then        
        List<Position__c> positions = [SELECT id, name, externalid__c, Posting_status__c FROM Position__c];
        System.assertEquals(1,positions.size());
        System.assertEquals(position.id,positions.get(0).id);
        System.assertEquals(position.name,positions.get(0).name);
        System.assertEquals('Posted',positions.get(0).Posting_status__c);
        System.assertEquals('ExternalId',positions.get(0).ExternalId__c);        
    }
   
    @IsTest static void test_postJobAdvStatusCodeError(){      
        //Given
        Integer statusCode = 400; 
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        
        Test.startTest();
        try{
            System.debug('***HERE***');
            // When
            service.postJobAdvWithPositionUpdate(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
    @IsTest static void test_postJobAdvJsonException(){      
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_invalid_json';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        
        Test.startTest();
        try{
            // When
            service.postJobAdvWithPositionUpdate(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
     @IsTest static void test_postJobAdvDmlException(){      
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        position.Approver_1__c = position.id;       
        Test.startTest();
        try{
            // When
            service.postJobAdvWithPositionUpdate(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
    @IsTest static void test_updateJobAdvCorrectly(){      
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();        
        Position__c position = TestDataFactory.getRandomPosition(false);
        insert position;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        // When
        Test.startTest();
        service.updateJobAdv(position);       
        Test.stopTest();
        
        //Then                 
    }
    
    @IsTest static void test_updateJobAdvStatusCodeError(){      
        //Given
        Integer statusCode = 201;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        
        Test.startTest();
        try{
            // When
            service.updateJobAdv(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
    @IsTest static void test_deleteJobAdvCorrectly(){      
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        
        Position__c position = new Position__c(Name='Manager');
        insert position;
        
        // When
        Test.startTest();
        service.removeJobAdv(position);       
        Test.stopTest();
        
        //Then        
        List<Position__c> positions = [SELECT id, name, externalid__c, Posting_status__c FROM Position__c];
        System.assertEquals(1,positions.size());
        System.assertEquals(position.id,positions.get(0).id);
        System.assertEquals(position.name,positions.get(0).name);
        System.assertEquals('Not Posted',positions.get(0).Posting_status__c);
        System.assertEquals(null, positions.get(0).ExternalId__c);        
    }
    
    @IsTest static void test_deleteJobAdvStatusCodeError(){      
        //Given
        Integer statusCode = 201;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        
        Test.startTest();
        try{
            // When
            service.removeJobAdv(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
     @IsTest static void test_deleteJobAdvDmlException(){      
        //Given
        Integer statusCode = HttpConstants.STATUS_CODE_OK;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        Position__c position = TestDataFactory.getRandomPosition(true);
        position.Approver_1__c = position.id;       
        Test.startTest();
        try{
            // When
            service.removeJobAdv(position); 
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){ 
            // Then
            System.assert(exc instanceOf JobAdvServiceImpl.JobAdvServiceException);           
        }
        Test.stopTest();
    }
    
    @IsTest static void test_closeJobAdvertisementCorrectly(){
         //Given      
        Position__c position = new Position__c(Name = 'Dev2', Posting_status__c = 'Posted', Status__c='Open'); 
        insert position;
        Map<Id,Position__c> positionMap = new Map<Id,Position__c>([SELECT name,Posting_status__c, Status__c FROM Position__c ]);
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(200,'jobAdvServiceImpl_test_valid_body'));

        // When
        Test.startTest();
        JobAdvServiceImpl.closeJobAdvertisement(new List<Id>(positionMap.keySet()));       
        Test.stopTest();
        
        //Then        
        List<Position__c> positions = [SELECT name FROM Position__c WHERE Posting_status__c = 'Archived'];
        System.assertEquals(1, positions.size());
        System.assertEquals('Dev2', positions.get(0).name);     
    }
    
    @IsTest static void test_closeJobAdvertisementErrorStatusCode(){
         //Given      
        Position__c position = new Position__c(Name = 'Dev2', Posting_status__c = 'Posted', Status__c='Open'); 
        insert position;
        Map<Id,Position__c> positionMap = new Map<Id,Position__c>([SELECT name,Posting_status__c, Status__c FROM Position__c ]);
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(201,'jobAdvServiceImpl_test_valid_body'));

        // When      
        try{
            Test.startTest();
            JobAdvServiceImpl.closeJobAdvertisement(new List<Id>(positionMap.keySet())); 
            Test.stopTest(); 
            System.assert(false,'Expected exception');         
        }   
        catch(Exception exc){
            //Then           
            System.assert(exc instanceof JobAdvServiceImpl.JobAdvServiceException);
        }
             
        List<Position__c> positions = [SELECT name FROM Position__c WHERE Posting_status__c = 'Archived'];
        System.assertEquals(0, positions.size());
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