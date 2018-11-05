public class ResumeDTOContainer {
    private List<ComplexResume> complexResumes;  
    
    public ResumeDTOContainer(List<ResumeDTO> resumes) {
        initContainer(resumes);
    }

    private void initContainer(List<ResumeDTO> resumes){
        complexResumes = new List<ComplexResume> ();
        for(ResumeDTO resume: resumes){
            complexResumes.add(resumeDto2complexResume(resume));
        }
    }

    public List<Position__c> getPositionsOnlyWithExternalId(){
        List<Position__c> positions = new List<Position__c>();
        for(ComplexResume resume:complexResumes){
            positions.addAll(resume.positions);
        }
        return positions;
    }

    public List<Candidate__c> getCandidates(){
        List<Candidate__c> candidates = new List<Candidate__c>();
        for(ComplexResume resume:complexResumes){
            candidates.add(resume.candidate);
        }
        return candidates;
    }

    public List<FileDetails> getFileDetailsList(){
        List<FileDetails> fileDetailsList = new List<FileDetails>();
         for(ComplexResume resume:complexResumes){
            fileDetailsList.add(new FileDetails(resume.fileName, resume.fileAsString, 'I', 'AllUsers', resume.candidate.id));
        }
        return fileDetailsList;
    }

    public List<Job_Application__c> getJobApps(){
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for(ComplexResume resume:complexResumes){
            String candidateId = resume.candidate.id;
            for(Position__c position:resume.positions){
                String positionId = position.id;
                jobApps.add(new Job_Application__c(
                    PositionCandidateKey__c = candidateId+positionId,
                    Candidate__c = candidateId,
                    Position__c = positionId));
            }
        }
        return jobApps;
    }

    private ComplexResume resumeDto2complexResume(ResumeDTO resumeDto){
     ComplexResume complexResume = new ComplexResume();
     complexResume.candidate = resumeDto2candidate(resumeDto);
     complexResume.fileAsString = resumeDto.photo;
     complexResume.fileName = resumeDto.photoName;
     complexResume.positions = resumeDto2positions(resumeDto);
     return complexResume;
    }

    private List<Position__c> resumeDto2positions(ResumeDTO resume){
        List<Position__c> positions = new List<Position__c>();
        for(String externalId:resume.jobAdIds){
            positions.add(new Position__c(ExternalId__c=externalId));
        }
        return positions;
    }

    private Candidate__c resumeDto2candidate(ResumeDTO resume){
        Candidate__c candidate = new Candidate__c ();
        candidate.Additional_Info__c=resume.additionalInformation;	
        candidate.Age__c=Decimal.valueOf(resume.age);	
        candidate.City__c=resume.city;	
        candidate.Country__c=resume.country;
        candidate.Currently_Employed__c=resume.currentlyEmployed;	
        candidate.Education__c=resume.education;	
        candidate.Email__c=resume.email;		
        candidate.First_Name__c=resume.firstName;
        candidate.Last_Name__c=resume.lastName;
        candidate.Mobile__c=resume.phone;
        candidate.Salary__c=Decimal.valueOf(resume.salary);	
        candidate.State_Province__c=resume.state;
        candidate.Street_Address_1__c=resume.street;
        candidate.Years_of_Experience__c=Decimal.valueOf(resume.experienceYears);	
        candidate.Zip_Postal_Code__c=resume.zipCode;
        return candidate;
    }

    private class ComplexResume{
        public List<Position__c> positions;
        public Candidate__c candidate;
        public String fileAsString;
        public String fileName;
    }
}
