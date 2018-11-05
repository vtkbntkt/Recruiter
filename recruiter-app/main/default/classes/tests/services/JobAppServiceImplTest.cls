@isTest
private class JobAppServiceImplTest {
    
    @isTest static void test_updateJobAppByExternalResumeDTO_Correctly(){
        //Given
        Position__c position = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg');
        insert position;
        ResumeDTO resume = getResumeDto();
        resume.jobAdIds = new List<String>{position.ExternalId__c};

        //When
        Test.startTest();
        new JobAppServiceImpl(new FileServiceMock()).updateJobAppByExternalResumeDTO(new List<ResumeDTO>{resume});
        Test.stopTest();

        //Then
        List<Candidate__c> candidates = [SELECT email__c, PhotoFileId__c FROM Candidate__c];
        System.assertEquals(1, candidates.size());
        System.assertEquals(resume.email, candidates.get(0).email__c);
        System.assertEquals(candidates.get(0).id, candidates.get(0).PhotoFileId__c);
        List<Job_Application__C> jobApps = 
        [SELECT id FROM Job_Application__c WHERE Candidate__c=:candidates.get(0).id AND Position__c = :position.id];
        System.assertEquals(1, jobApps.size());
    }

    @isTest static void test_updateJobAppByExternalResumeDTO_Correctly_ExistingCandidate_ExistingJobApp(){
        //Given
        Candidate__c existingCandidate = new Candidate__c(First_name__c='Jo', email__c = 'milo@mail.com');
        insert existingCandidate;
        Position__c firstPosition = new Position__c(Name = 'first posn', ExternalId__c = 'idfromexternalorg1');
        insert firstPosition;
        String positionCandidateKey = existingCandidate.id+''+firstPosition.id;
        Job_Application__c existingJobApp = new Job_Application__c(Candidate__c = existingCandidate.id, 
        Position__c=firstPosition.id, 
        PositionCandidateKey__c = positionCandidateKey);
        insert existingJobApp;
        Position__c secondPosition = new Position__c(Name = 'second posn', ExternalId__c = 'idfromexternalorg2');
        insert secondPosition;
        ResumeDTO resume = getResumeDto();
        resume.jobAdIds = new List<String>{firstPosition.ExternalId__c};
        resume.jobAdIds.add(secondPosition.ExternalId__c);

        //When
        Test.startTest();
        new JobAppServiceImpl(new FileServiceMock()).updateJobAppByExternalResumeDTO(new List<ResumeDTO>{resume});
        Test.stopTest();

        //Then
        // Check if the candidate data was updated (lastname, photofield) and not corrupted (email, firstname)
        List<Candidate__c> candidates = [SELECT email__c, PhotoFileId__c, First_name__c, Last_name__c  FROM Candidate__c];
        System.assertEquals(1, candidates.size());
        System.assertEquals(resume.email, candidates.get(0).email__c);
        System.assertEquals(candidates.get(0).id, candidates.get(0).PhotoFileId__c);
        System.assertEquals(resume.firstName, candidates.get(0).First_name__c);
        System.assertEquals(resume.lastName, candidates.get(0).Last_name__c);
        // Check if existing jobapp list wasn't corrupted (old record should exist, checking by id)
        System.assert(![SELECT id FROM Job_Application__c WHERE id= :existingJobApp.id].isEmpty());
        // Check if new job app were added
        List<Job_Application__C> newJobApps = 
        [SELECT Candidate__c,  Position__c FROM Job_Application__c WHERE id!=:existingJobApp.id];
        System.assertEquals(1, newJobApps.size());
        System.assertEquals(existingCandidate.id, newJobApps.get(0).Candidate__c);
        System.assertEquals(secondPosition.id, newJobApps.get(0).Position__c); 
    }

     @isTest static void test_updateJobAppByExternalResumeDTO_Correctly_Bulk(){
        //Given
        Position__c position1 = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg1');
        Position__c position2 = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg2');
        insert position1;
        insert position2;
        Integer recordNum = 10;
        List<ResumeDTO> resumeDtoList = new List<ResumeDTO>();
        for (Integer i = 0; i<recordNum; i++){
            ResumeDTO resume = getResumeDto();
            resume.jobAdIds = new List<String>{position1.ExternalId__c};
            resume.jobAdIds.add(position2.ExternalId__c);
            resume.email = resume.email+''+i;
            resumeDtoList.add(resume);
        }

        //When
        Test.startTest();
        new JobAppServiceImpl(new FileServiceMock()).updateJobAppByExternalResumeDTO(resumeDtoList);
        Test.stopTest();

        //Then
        List<Candidate__c> candidates = [SELECT email__c, PhotoFileId__c FROM Candidate__c];
        System.assertEquals(recordNum, candidates.size());

        List<Job_Application__C> jobApps = [SELECT id FROM Job_Application__c];
        System.assertEquals(recordNum*2, jobApps.size());
    }

    @isTest static void test_updateJobAppByExternalResumeDTO_DMLExc(){
        //Given
        Position__c position = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg');
        insert position;
        ResumeDTO resume = getResumeDto();
        resume.jobAdIds = new List<String>{position.ExternalId__c};
        delete position;

        //When
        Test.startTest();
        try{
            new JobAppServiceImpl(new FileServiceMock()).updateJobAppByExternalResumeDTO(new List<ResumeDTO>{resume});
            System.assert(false, 'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf JobAppServiceException);
        }
        Test.stopTest();
    }

     @isTest static void test_updateJobAppByExternalResumeDTO_SaveFileExc(){
        //Given
        Position__c position = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg');
        insert position;
        ResumeDTO resume = getResumeDto();
        resume.jobAdIds = new List<String>{position.ExternalId__c};
        FileServiceMock fileService = new FileServiceMock();
        fileService.testDataSet.put('save_file_exc',new SaveFileException());

        //When
        Test.startTest();
        try{
            new JobAppServiceImpl(fileService).updateJobAppByExternalResumeDTO(new List<ResumeDTO>{resume});
            System.assert(false, 'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf JobAppServiceException);
        }
        Test.stopTest();
    }
    @isTest static void test_updateJobAppByExternalResumeDTO_clearFileExc(){
        //Given
        Position__c position = new Position__c(Name = 'SF developer', ExternalId__c = 'idfromexternalorg');
        insert position;
        ResumeDTO resume = getResumeDto();
        resume.jobAdIds = new List<String>{position.ExternalId__c};
        FileServiceMock fileService = new FileServiceMock();
        fileService.testDataSet.put('clear_file_exc',new ClearFileException());

        //When
        Test.startTest();
        try{
            new JobAppServiceImpl(fileService).updateJobAppByExternalResumeDTO(new List<ResumeDTO>{resume});
            System.assert(false, 'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf JobAppServiceException);
        }
        Test.stopTest();
    }

    private static ResumeDTO getResumeDto(){
        ResumeDTO resume = new ResumeDTO();
        resume.age = '18';
        resume.additionalInformation = 'info';
        resume.city = 'NY';
        resume.country = 'US';
        resume.currentlyEmployed = false;
        resume.education = 'high';
        resume.experienceYears = '15';
        resume.firstName = 'Jo';
        resume.lastName = 'Emo';
        resume.phone = '0502209489';
        resume.email = 'milo@mail.com';
        resume.street = 'Washington #88';
        resume.salary = '2500';
        resume.photo = 'DDDRRE';
        resume.photoName = 'myFace.gif';
        return resume;
    }

    private class FileServiceMock implements IfileService{
        public Map<String, Object> testDataSet;

        public FileServiceMock(){
            testDataSet = new Map<String,Object>();
        }

        public void saveFiles(List<FileDetails> fileDetails){
            if(testDataSet.containsKey('save_file_exc')){
               throw (SaveFileException)testDataSet.get('save_file_exc');
           }
           for(FileDetails item:filedetails){
               item.contentVersionId = item.relatedEntityId;
           }
        }

        public void removeFilesByContentVersionIds(List <Id> contentVersionIds){
            if(testDataSet.containsKey('clear_file_exc')){
               throw (ClearFileException)testDataSet.get('clear_file_exc');
           }
        }
    } 
}
