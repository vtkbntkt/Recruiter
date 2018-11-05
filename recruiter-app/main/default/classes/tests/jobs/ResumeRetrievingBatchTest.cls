@isTest 
private class ResumeRetrievingBatchTest {

    @isTest static void test_startCorrectly(){
        //Given
        String zipCodeName = '0000';
        String state = 'NY';
        String city = 'New York';
        String positionExternalId = '8754YutrferTTwer89';
        Zip_Code__c zipCode = new Zip_Code__c(name=zipCodeName, 	State__c=state, City__c=city);
        insert zipCode;
        Position__c position = new Position__c (name='Test', ExternalId__c=positionExternalId);
        insert position;
          //Prepare fake responses.
          //Page number must be 1. No more than one executeBatch can be called from within a test method.  
          //Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
        Integer pageNumber = 1;
        Integer pageSize = 100;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.testDataSet.put('recordNumber', pageNumber);
        resumeCallout.testDataSet.put('bodyForGetRecords',getBodyMap(pageSize,pageNumber,zipCodeName,city, state, new List<String>{positionExternalId}));
          //Init real ResumeRetrievingJobManager with fake callout and real job app service
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, new JobAppServiceImpl(new FileServiceImpl()));

        //When
        Test.startTest();
        ResumeRetrievingBatch batch = new ResumeRetrievingBatch(manager,'2018-10-10');
        Id batchId = Database.executeBatch(batch,1);
        Test.stopTest();

        //Then
        System.assertEquals(1,Limits.getEmailInvocations());
        List<Candidate__c> candidates = [SELECT id FROM Candidate__c];
        System.assertEquals(pageSize*pageNumber, candidates.size());
        
        Map<Id, Candidate__c> candidatesMap = new Map<Id, Candidate__c>(candidates);
        List<Id> candidateIds = new List<ID>(candidatesMap.keySet());
        List<ContentDocumentLink> contentDocLinks = 
            [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId IN :candidateIds];
        System.assertEquals(pageSize*pageNumber, contentDocLinks.size());

        List<Job_Application__c> jobApps = [SELECT id FROM Job_Application__c];
        System.assertEquals(pageSize*pageNumber, jobApps.size());
    }

    @isTest static void test_start_getRecordNumberError(){
        //Given
        String zipCodeName = '0000';
        String state = 'NY';
        String city = 'New York';
        String positionExternalId = '8754YutrferTTwer89';
        Zip_Code__c zipCode = new Zip_Code__c(name=zipCodeName, State__c=state, City__c=city);
        insert zipCode;
        Position__c position = new Position__c (name='Test', ExternalId__c=positionExternalId);
        insert position;
          //Prepare fake responses.
          //Page number must be 1. No more than one executeBatch can be called from within a test method.  
          //Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
        Integer pageNumber = 1;
        Integer pageSize = 1;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.testDataSet.put('getRecordNumberExc', new ResumeRetrievingJobManager.ResumeRetrievingJobManagerException());
        resumeCallout.testDataSet.put('bodyForGetRecords',getBodyMap(pageSize,pageNumber,zipCodeName,city, state, new List<String>{positionExternalId}));
          //Init real ResumeRetrievingJobManager with fake callout and real job app service
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, new JobAppServiceImpl(new FileServiceImpl()));

        //When
        Test.startTest();
        ResumeRetrievingBatch batch = new ResumeRetrievingBatch(manager,'2018-10-10');
        Id batchId = Database.executeBatch(batch,1);
        Test.stopTest();

        //Then
        System.assertEquals(1,Limits.getEmailInvocations());
        List<Candidate__c> candidates = [SELECT id FROM Candidate__c];
        System.assert(candidates.isEmpty());
    }

      @isTest static void test_start_getRecordsError(){
        //Given
        String zipCodeName = '0000';
        String state = 'NY';
        String city = 'New York';
        String positionExternalId = '8754YutrferTTwer89';
        Zip_Code__c zipCode = new Zip_Code__c(name=zipCodeName, State__c=state, City__c=city);
        insert zipCode;
        Position__c position = new Position__c (name='Test', ExternalId__c=positionExternalId);
        insert position;
          //Prepare fake responses.
          //Page number must be 1. No more than one executeBatch can be called from within a test method.  
          //Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
        Integer pageNumber = 1;
        Integer pageSize = 1;
        ResumeCalloutServiceMock resumeCallout = new ResumeCalloutServiceMock();
        resumeCallout.testDataSet.put('recordNumber', pageNumber);
        resumeCallout.testDataSet.put('getRecordsExc',new ResumeRetrievingJobManager.ResumeRetrievingJobManagerException());
          //Init real ResumeRetrievingJobManager with fake callout and real job app service
        ResumeRetrievingJobManager manager = new ResumeRetrievingJobManager(resumeCallout, new JobAppServiceImpl(new FileServiceImpl()));

        //When
        Test.startTest();
        ResumeRetrievingBatch batch = new ResumeRetrievingBatch(manager,'2018-10-10');
        Id batchId = Database.executeBatch(batch,1);
        Test.stopTest();

        //Then
        System.assertEquals(1,Limits.getEmailInvocations());
        List<Candidate__c> candidates = [SELECT id FROM Candidate__c];
        System.assert(candidates.isEmpty());
    }

    private static Map<Integer,String> getBodyMap(Integer pageSize, 
                                                  Integer pageNumber, 
                                                  String zipCode, 
                                                  String city, 
                                                  String state, 
                                                  List<String> jobAdvIds){
        Map<Integer,String> resumeDtoJsonMap = new Map<Integer,String>();
        for(Integer i=0; i<pageNumber;i++){
            List<ResumeDTO> resumes = 
            TestDataFactory.getResumesDto(i*pageSize, pageSize, zipCode, city, state, jobAdvIds, null);
            resumeDtoJsonMap.put(i+1,Json.serialize(resumes));
        }
        return resumeDtoJsonMap;
    }


    private class ResumeCalloutServiceMock implements IcalloutService{
        public Map<String,Object> testDataSet;

        public ResumeCalloutServiceMock(){
            testDataSet = new Map<String,Object>();
        }

        public HttpResponse getRecords(Map<String,String> params){
            if(testDataSet.containsKey('getRecordsExc')){
                throw (Exception) testDataSet.get('getRecordsExc');
            }
            Map<Integer,String> bodyMap = (Map<Integer,String>)testDataSet.get('bodyForGetRecords');
            String body = bodyMap.get(Integer.valueOf(params.get('pageNumber')));
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }

        public HttpResponse getRecordNumber(Map<String,String> params){
            if(testDataSet.containsKey('getRecordNumberExc')){
                throw (Exception) testDataSet.get('getRecordNumberExc');
            }
            String recordNum = String.valueOf(testDataSet.get('recordNumber'));
            HttpResponse response = new HttpResponse();
            response.setBody(recordNum);
            response.setStatusCode(200);
            return response;
        }
    }
}
