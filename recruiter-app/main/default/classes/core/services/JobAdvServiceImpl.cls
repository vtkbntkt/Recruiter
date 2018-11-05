public class JobAdvServiceImpl implements IjobAdvService{
    
    public void postJobAdvWithPositionUpdate(Position__c position){ 
        String requestBody = 
            Utils.positions2jobAdsWithIdAsJsonString(new List<Position__c>{position});
        HttpResponse response =  JobAdvCalloutService.manipulateRecords(requestBody, HttpConstants.METHOD_POST);
        if (response.getStatusCode()!=HttpConstants.STATUS_CODE_OK){
            throw new JobAdvServiceException(response.getBody()); 
        } 
        try{
            List<Position__c> receivedPositions = Utils.jobAdsWithIdAsJson2positions(response.getBody());
            position.ExternalId__c = receivedPositions.get(0).ExternalId__c;
            position.Posting_status__c='Posted';
            update position;           
        }
        catch(JsonException exc){
            throw new JobAdvServiceException(exc.getMessage(),exc);
        }
        catch(DmlException exc){
            throw new JobAdvServiceException(exc.getMessage(),exc);
        }
    }
    
    
    
    public void updateJobAdv(Position__c position){       
        String requestBody = 
            Utils.positions2jobAdsWithIdAsJsonString(new List<Position__c>{position});
        HttpResponse response =  JobAdvCalloutService.manipulateRecords(requestBody, HttpConstants.METHOD_PUT);
        if (response.getStatusCode()!=HttpConstants.STATUS_CODE_OK){
            throw new JobAdvServiceException(response.getBody()); 
        }               
    }
    
    @future(callout=true)
    public static void closeJobAdvertisement(List<Id> positionIds){
        List<Position__c> positions = [SELECT Job_Description__c, Education__c, id, Location__c, Salary_Range__c, Skills_Required__c, Name, 
                    Hiring_Manager__r.Name, Hiring_Manager__r.Phone, Hiring_Manager__r.Email, ExternalId__c, Status__c
                    FROM Position__c WHERE id IN :positionIds];
        String requestBody = Utils.positions2jobAdsWithIdAsJsonString(positions);
        HttpResponse response =  JobAdvCalloutService.manipulateRecords(requestBody, HttpConstants.METHOD_PUT);
        if (response.getStatusCode()==HttpConstants.STATUS_CODE_OK){
            updateField(positions, 'Posting_status__c', 'Archived');
            update positions;                     
        } 
        else{
           throw new JobAdvServiceException(response.getBody()); 
        }
    }

    
    
    private static void updateField(List<Position__c> positions, String field, String value){
        for(Position__c position:positions){
            position.put(field,value);
        }
    } 
    
    public void removeJobAdv(Position__c position){
        String requestBody = 
            Utils.positions2jobAdsWithIdAsJsonString(new List<Position__c>{position});
        HttpResponse response =  JobAdvCalloutService.manipulateRecords(requestBody,HttpConstants.METHOD_DELETE);
        if (response.getStatusCode()!=HttpConstants.STATUS_CODE_OK){
            throw new JobAdvServiceException(response.getBody()); 
        } 
        position.Posting_status__c = 'Not Posted';
        position.ExternalId__c = null;
        try{
            update position;
        }
        catch(DmlException exc){
           throw new JobAdvServiceException(exc.getMessage(),exc); 
        }       
    }
    
    public class JobAdvServiceException extends Exception{}
    
}