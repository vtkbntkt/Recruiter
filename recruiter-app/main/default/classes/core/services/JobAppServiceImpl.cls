public class JobAppServiceImpl implements IjobAppService {
    private IfileService fileService;


    public JobAppServiceImpl(IfileService fileService){
        this.fileService = fileService;

    }
    
    public void updateJobAppByExternalResumeDTO(List<ResumeDTO> resumeDtoList){
        ResumeDTOContainer container = new ResumeDTOContainer(resumeDtoList);
        Savepoint savePoint = Database.setSavepoint();
        try{
            List<Position__c> positionsWithExternalIdOnly =  container.getPositionsOnlyWithExternalId();
            fillPositionActualIdByExternalId(positionsWithExternalIdOnly);
            List<Candidate__c> candidates = container.getCandidates();
            upsert candidates Email__c;
            List<FileDetails> fileDetailsList = container.getFileDetailsList();
            fileService.removeFilesByContentVersionIds(extractContentVersionIdsFromCandidates(candidates));
            fileService.saveFiles(fileDetailsList);
            fillPhotoFileIds(candidates, fileDetailsList);
            update candidates;
            List<Job_Application__c> jobApps = container.getJobApps();
            upsert jobApps PositionCandidateKey__c;
        }
        catch(DmlException dmlExc){
            Database.rollback(savePoint);
            throw new JobAppServiceException(dmlExc.getMessage(), dmlExc);
        }
        catch(ClearFileException cfExc){
            Database.rollback(savePoint);
            throw new JobAppServiceException(cfExc.getMessage(), cfExc);
        }
        catch(SaveFileException sfExc){
            Database.rollback(savePoint);
            throw new JobAppServiceException(sfExc.getMessage(), sfExc);
        }

    }

    private void fillPositionActualIdByExternalId(List<Position__c> positionsWithExternalIdOnly){
         List<Position__c> actulPositions = 
         [SELECT ExternalId__c FROM Position__c WHERE ExternalId__c IN :extractPositionExternalIds(positionsWithExternalIdOnly)];
         fillPositionIds(positionsWithExternalIdOnly, actulPositions);
    }

    private void fillPositionIds(List<Position__c> externalPositions, List<Position__c> actualPositions){
        for(Position__c externalPosition:externalPositions){
            for(Position__c actualPosition:actualPositions){
                if(externalPosition.ExternalId__c==actualPosition.ExternalId__c){
                    externalPosition.id = actualPosition.id;
                }
            }
        }
    }

    private List<String> extractPositionExternalIds(List<Position__c> positionsWithExternalIdOnly){
        List<String> ids = new List<String>();
        for(Position__c position:positionsWithExternalIdOnly){
           ids.add(position.ExternalId__c);
        }
        return ids;
    }

    private List<Id> extractContentVersionIdsFromCandidates(List<Candidate__c> candidates){
        Map<Id, Candidate__c> candidateMap = new Map<Id,Candidate__c>(candidates);
        List<Candidate__c> retrievedCandidates = [SELECT PhotoFileId__c FROM Candidate__c WHERE id IN :candidateMap.keySet()];
        List<Id> contentVersionIds = new List<Id>();
        for (Candidate__c candidate:retrievedCandidates){
            contentVersionIds.add(candidate.PhotoFileId__c);
        }
        return contentVersionIds;

    }

    private void fillPhotoFileIds(List<Candidate__c> candidates, List<FileDetails> fileDetailsList){
       Map<Id, Candidate__c> candidateMap = new Map<Id,Candidate__c>(candidates);
       for(FileDetails fileDetails:fileDetailsList){
           candidateMap.get(fileDetails.relatedEntityId).PhotoFileId__c = fileDetails.contentVersionId;
       } 

    }
}
