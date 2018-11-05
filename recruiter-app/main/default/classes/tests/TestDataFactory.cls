@isTest
public class TestDataFactory {
    /*

Try use map to transfer data into params
Bulkification
*/
    
    public static UserRole getRole(String roleName,Boolean beInserted){
        UserRole role = new UserRole(Name = roleName); 
        if(beInserted){
            insert role;
        }
        return role;
    }
    
    public static User getRandomUser(String roleName,String profileName, String firstName, String lastName, Boolean beInserted){
        UserRole role = getRole(roleName, true);       
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        User user = new User(firstname = firstName,
                             lastName = lastName,
                             email = uniqueName + '@test' + orgId + '.org',
                             Username = uniqueName + '@test' + orgId + '.org',
                             EmailEncodingKey = 'ISO-8859-1',
                             Alias = uniqueName.substring(18, 23),
                             TimeZoneSidKey = 'America/Los_Angeles',
                             LocaleSidKey = 'en_US',
                             LanguageLocaleKey = 'en_US',
                             ProfileId = profile.id,
                             UserRoleId = role.id);      
        if(beInserted){
            insert user;
        }
        return user;
    }
    
    public static Job_Application__c getRandomJobApp(String stage, boolean beInserted){       
        Job_Application__c jobApp = new Job_Application__c(
            Candidate__c = getRandomCandidate(true).id,
            Position__c = getRandomPosition(true).id,
            Stage__c = stage,
            OwnerId = UserInfo.getUserId()); 
        if(beInserted){
            insert jobApp;
        }
        return jobApp;       
    }
    public static Job_Application__c getRandomJobApp(String stage, boolean beInserted, Id candidateId, Id positionId){       
        Job_Application__c jobApp = new Job_Application__c(
            Candidate__c = candidateId,
            Position__c = positionId,
            Stage__c = stage,
            OwnerId = UserInfo.getUserId()); 
        if(beInserted){
            insert jobApp;
        }
        return jobApp;       
    }
    
    public static List<Job_Application__c> getJobApps(Integer rejectedNum, Integer acceptedNum){
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        Id candidateId = getRandomCandidate(true).id;
        Id positionId = getRandomPosition(true).id;
        for (Integer i=0;i<rejectedNum;i++){
            jobApps.add(getRandomJobApp('Closed - Rejected', false, candidateId, positionId));
        }
        for (Integer j=0;j<acceptedNum;j++){
            jobApps.add(getRandomJobApp('Offer Extended', false, candidateId, positionId));
        }
        
        return jobApps;
    }
    
    public static Map<Id,Job_Application__c> jobAppListToMap(List<Job_Application__c> jobApps){
        Map<Id,Job_Application__c> jobAppMap = new Map<Id,Job_Application__c>();
        for (Job_Application__c jobApp:jobApps){
            jobAppMap.put(jobApp.id, jobApp);
        }
        return jobAppMap;
    }
    
    public static List<JobApplicationTriggerHelper.WrappedJobApp> wrapJobApps(List<Job_Application__c> jobApps){
        List<JobApplicationTriggerHelper.WrappedJobApp> wrappedJobApps 
            = new List<JobApplicationTriggerHelper.WrappedJobApp>();        
        for(Job_Application__c jobApp:jobApps){
            if(jobApp.Stage__c=='Closed - Rejected'){
                wrappedJobApps.add(new JobApplicationTriggerHelper.WrappedJobApp(jobApp,JobApplicationTriggerHelper.Status.REJECTED));
            }
            else if(jobApp.Stage__c=='Offer Extended'){
                wrappedJobApps.add(new JobApplicationTriggerHelper.WrappedJobApp(jobApp,JobApplicationTriggerHelper.Status.OFFER_EXTENDED));  
            }
        }
        
        return wrappedJobApps;
    }
    
    public static Candidate__c getRandomCandidate(boolean beInserted){
        Candidate__c candidate = new Candidate__c(
            First_Name__c = generateRandomString(6),
            Email__c = generateRandomString(6)+'@gmail.com'
        );     
        if(beInserted){
            insert candidate;  
        }   
        return candidate;
    }

    public static List<Candidate__c> getRandomCandidates(Integer candidateNum, Boolean beInserted){
        List<Candidate__c> candidates = new List<Candidate__c>();
        for(Integer i=0;i<candidateNum;i++){
            candidates.add(getRandomCandidate(false));
        }
        if(beInserted){
            insert candidates;
        }
        return candidates;
    }

    public static List<FileDetails> getFileDetailsList(List<Candidate__c> candidates){
        List<FileDetails> fileDetailsList = new List<FileDetails>();
        for(Candidate__c candidate:candidates){
            fileDetailsList.add(new FileDetails(candidate.First_Name__c, Blob.valueOf(candidate.First_Name__c),'I','AllUsers', candidate.id));
        }
        return fileDetailsList;
    } 
    
    public static Position__c getRandomPosition(boolean beInserted){
        Position__c position = new Position__c(Name = generateRandomString(6));          
        if(beInserted){
            insert position;  
        }   
        return position;
    }
    
    public static Position__c getRandomPosition(boolean beInserted, Id ownerId){
        Position__c position = new Position__c(Name = generateRandomString(6), OwnerId = ownerId);          
        if(beInserted){
            insert position;  
        }   
        return position;
    }
    
    public static list<Position__c> getPositions(Id ownerId, Integer posNum){
        List<Position__c> posns = new List<Position__c>();
        for (Integer i=0; i<posNum;i++){
            posns.add(getRandomPosition(false, ownerId));
        }
        return posns;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static List<ResumeDTO> getResumesDto(Integer startIndex, 
                                                Integer recordNumber, 
                                                String zipCode, 
                                                String city, 
                                                String state, 
                                                List<String> jobAdvIds, 
                                                String photoContent){
        List<ResumeDTO> resumes = new List<ResumeDTO>();                                            
        String photo = photoContent;
        if(photo==null){
           photo =  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGP6DwABBQECz6AuzQAAAABJRU5ErkJggg==';
        }
        for(Integer i=startIndex;i<startIndex+recordNumber;i++){
            resumes.add(getResumeDto(i+''+'email@gmail.com', zipCode, city, state,jobAdvIds,photo));

        } 
        return resumes;                                           

    }
    
    public static ResumeDTO getResumeDto(String email, String zipCode, String city, String state, List<String> jobAdvIds, String photoContent){
        ResumeDTO resume = new ResumeDTO();
        resume.zipCode = zipCode;
        resume.age = '18';
        resume.additionalInformation = 'Some additional information';
        resume.city = city;
        resume.state = state;
        resume.country = 'United States';
        resume.currentlyEmployed = false;
        resume.education = 'MA/MS/MBA';
        resume.experienceYears = '15';
        resume.firstName = 'Mark';
        resume.lastName = 'Twen';
        resume.phone = '0502695589';
        resume.email = email;
        resume.street = 'Washington #88';
        resume.salary = '2500';
        resume.photo = photoContent;
        resume.photoName = 'Some photo.gif';
        resume.jobAdIds = jobAdvIds;
        return resume;
    } 
}