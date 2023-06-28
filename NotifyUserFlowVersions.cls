public with sharing class NotifyUserFlowVersions {
    public static Map<Id,String> userEmailMap = new Map<Id,String>();
    public static void notifyuser(){
        for(User u : [SELECT Id, Email FROM User]){
            if(u.Email !=Null || !(String.isEmpty(u.Email)))
                userEmailMap.put(u.Id,u.Email);
        }
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
        System.debug(res.getBody());
        if(res.getStatusCode() == 200){
            resultMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            for(Object obj : (List<Object>)resultMap.get('records')){
                FlowresultMap = (Map<String,Object>)obj;
                mapFlowByOwnerId.put(FlowresultMap.get('MasterLabel'),FlowresultMap.get('CreatedById'));//store the label by owner id
            }
        }
        System.debug(mapFlowByOwnerId);
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
        Map<string,Integer> countVersionMap = new Map<string,Integer>();
        Integer versionCount=0;
        String firstLabel;
        String secondLabel;
        for(Integer i=0;i<versionlist.size();i++){
            firstLabel = versionlist[i].Label;
            if(i == versionlist.size()) secondLabel = versionList[i].Label;
            else if(i>0&&i<versionlist.size()-1) secondLabel = versionList[i+1].Label;
            else secondLabel = versionList[i].label;
            System.debug('first'+firstLabel);
            System.debug('secondLabel'+secondLabel);
            System.debug('count::: '+versionCount);
            if(firstLabel != secondLabel){
                System.debug('ccc '+versionCount);
                countVersionMap.put(firstLabel,versionCount);
            }
            if(firstLabel == secondLabel){
                versionCount++;
            }
            else if(firstLabel != secondLabel) {
                versionCount=+1;
            }
            System.debug('count::: after '+versionCount);
        }
        System.debug('map'+countVersionMap);
        sendemailtoOwner(countVersionMap,mapFlowByOwnerId);
    }
    public static void sendemailtoOwner(Map<String,Integer> versionCountMap,Map<Object,Object> mapbyownerId){
        for(String str : versionCountMap.KeySet()){
            System.debug('count:::'+versionCountMap.get(str));
            if(versionCountMap.get(str) > 20){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toaddresses = new String[]{userEmailMap.get((Id)mapbyownerId.get(str))};
                message.subject = 'Flow version limit about to reach';
                message.plainTextBody = 'Hi '+[SELECT Id,Name FROM User where Id =: (Id)mapbyownerId.get(str)].Name+' Your flow named '+str+' has reached '+versionCountMap.get(str)+' versions\n'+'If you want to delete older versions please reply with a number less than 20';
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    }
}
