public with sharing class NotifyUserFlowVersions {
    public static Map<Id,String> userEmailMap = new Map<Id,String>();
    public static void notifyuser(){
        for(User u : [SELECT Id, Email FROM User]){
            if(u.Email !=Null || !(String.isEmpty(u.Email)))
            userEmailMap.put(u.Id,u.Email);
        }
        System.debug(userEmailMap);
        Map<String,Object> resultMap = new Map<String,Object>();//to store the results from api callout
        Map<String,Object> FlowresultMap = new Map<String,Object>();//to store the records from api callout
        List<Domain> domains = [SELECT Id, Domain FROM Domain];//fetch the domains in the present org
        Map<Object,Object> mapFlowByOwnerId = new Map<Object,Object>();
        http h = new http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('https://'+(String)domains[0].Domain.remove('-sites')+'/services/data/v57.0/tooling/query/?q=Select+id,CreatedById,MasterLabel+FROM+Flow');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            resultMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> newlist = (List<Object>)resultMap.get('records');//deserialize to get records from results
            for(Object obj : newlist){
                FlowresultMap = (Map<String,Object>)obj;
                mapFlowByOwnerId.put(FlowresultMap.get('MasterLabel'),FlowresultMap.get('CreatedById'));//store the label by owner id
            }
            System.debug(mapFlowByOwnerId);
        }
        Set<String> flowLabelSet = new set<String>();
        for(Object obj : mapFlowByOwnerId.KeySet()){
            flowLabelSet.add((String)obj);//seperate all the labels of flow
        }
        System.debug(flowLabelSet);
        List<Id> durableIds = new List<Id>();
        for(FlowDefinitionView i:[SELECT Id,DurableId FROM FlowDefinitionView WHERE Label=:flowLabelSet]){
            durableIds.add(i.DurableId);
        }
        System.debug(durableIds);
        List<FlowVersionView> versionlist = new List<FlowVersionView>();
        versionlist = [SELECT Id, DurableId, FlowDefinitionViewId, Label, Status FROM FlowVersionView WHERE FlowDefinitionViewId =:durableIds];
        System.debug(versionlist);
        Integer versionCount=0;
        String firstLabel;
        String secondLabel;
        for(Integer i=0;i<versionlist.size();i++){
            firstLabel = versionlist[i].Label;
			if(i == versionlist.size()) secondLabel = versionList[i].Label;
			else if(i>0&&i<versionlist.size()-1) secondLabel = versionList[i+1].Label;
            else secondLabel = versionList[i].label;
            if(firstLabel == secondLabel){
                versionCount++;
            }
            else if(firstLabel != secondLabel) versionCount=+1;
            if(versionCount >=12){
				              
            }
        }
    }
}