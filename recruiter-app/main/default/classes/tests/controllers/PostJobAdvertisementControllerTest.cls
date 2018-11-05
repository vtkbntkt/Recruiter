@isTest
private class PostJobAdvertisementControllerTest {
    @testSetup static void methodName() {
    User recruiter = 
        TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
 }
    
    @isTest static void test_postApplicationOnSiteCorrectly(){
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Not Posted');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));        
        Integer statusCode = 200;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
               
        // When
        Test.startTest();
        controller.postApplicationOnSite();       
        Test.stopTest();
        
        //Then        
        List<Position__c> positions = [SELECT id, name, externalid__c, Posting_status__c FROM Position__c];
        System.assertEquals(1,positions.size());
        System.assertEquals(position.id,positions.get(0).id);
        System.assertEquals(position.name,positions.get(0).name);
        System.assertEquals('Posted',positions.get(0).Posting_status__c);
        System.assertEquals('ExternalId',positions.get(0).ExternalId__c);
        
    }
    
    @IsTest static void test_postApplicationOnSiteException(){      
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Not Posted');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));
        Integer statusCode = 200;
        String staticSourceName = 'jobAdvServiceImpl_test_invalid_json';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        
        //When
        Test.startTest();
        controller.postApplicationOnSite();
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains('Unexpected character'));
    }
    
    @isTest static void test_updateApplicationCorrectly(){
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Posted');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));        
        Integer statusCode = 200;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
                
        // When
        Test.startTest();
        controller.updateApplication();       
        Test.stopTest();
        
        //Then        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains(System.Label.UpdateAdvStatusSuccess));
        
    }
    
    @IsTest static void test_updateApplicationException(){      
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Not Posted');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));
        Integer statusCode = 201;
        String staticSourceName = 'postjobadvertisement_test_error_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        
        //When
        Test.startTest();       
        controller.updateApplication();
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains('Invalid data content'));       
    }
    
     @isTest static void test_removeApplicationFromSiteCorrectly(){
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Posted', ExternalId__c = 'ExternalId');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));        
        Integer statusCode = 200;
        String staticSourceName = 'jobAdvServiceImpl_test_valid_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode,staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
               
        // When
        Test.startTest();
        controller.removeApplicationFromSite();       
        Test.stopTest();
        
        //Then        
        List<Position__c> positions = [SELECT id, name, externalid__c, Posting_status__c FROM Position__c];
        System.assertEquals(1,positions.size());
        System.assertEquals(position.id,positions.get(0).id);
        System.assertEquals(position.name,positions.get(0).name);
        System.assertEquals('Not Posted',positions.get(0).Posting_status__c);
        System.assertEquals(null,positions.get(0).ExternalId__c);       
    }
    
    @IsTest static void test_removeApplicationFromSiteException(){      
        //Given
        Position__c position = new Position__c(Name = 'Developer', Posting_status__c = 'Not Posted');
        insert position;
        PostJobAdvertisementController controller = 
            new PostJobAdvertisementController (new ApexPages.StandardController(position));
        Integer statusCode = 201;
        String staticSourceName = 'postjobadvertisement_test_error_body';
        Test.setMock(HttpCalloutMock.class, prepareMultiMock(statusCode, staticSourceName));
        JobAdvServiceImpl service = new JobAdvServiceImpl();
        
        //When
        Test.startTest();       
        controller.removeApplicationFromSite();       
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains('Invalid data content'));       
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