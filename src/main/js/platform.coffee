###
file: comzotoh.cloudapi.platform.coffee
###

`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`


class ConfigurationParameter extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database Configuration Parameter information ###

    constructor: (n, @value) ->
        super()
        @immediate=true
        @dynamic=true
        @setName(n)

    getSource: () -> @source

    setSource: (src) -> @source = src ? ''

    getDynamic: () -> @dynamic

    setDynamic: (b) -> @dynamic = true is b

    getValue: () -> @value

    setValue: (v) -> @value =v

    setImmediate: (b) -> @immediate = true is b

    isImmediate: () -> @immediate

    setModifiable: (b) -> @modifiable = true is b

    isModifiable: () -> @modifiable

    setDataType: (t) -> @data = t ? ''

    getDataType: () -> @data

ConfigurationParameter.ALL= 1
ConfigurationParameter.SYSTEM= 2
ConfigurationParameter.ENGINE= 4
ConfigurationParameter.USER= 8

#}

class Database extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database information ###

    constructor: (@dbid) -> super()

    equals: (other) -> @getProviderDatabaseId() is other?.getProviderDatabaseId()

    toString: () -> @getProviderDatabaseId()

    getHostName: () -> @host

    getProviderDataCenterId: () -> @zone

    setProviderDataCenterId: (id) -> @zone = id ? ''

    getConfiguration: () ->

    getProviderDatabaseId: () -> @dbid

    setProviderDatabaseId: (n) -> @dbid = n ? ''

    getAdminUser: () -> @admin

    setAdminUser: (n) -> @admin = n ? ''

    getAllocatedStorageInGb: () -> @gbSize

    setAllocatedStorageInGb: (n) -> if n? and not isNaN(n) then @gbSize=n

    getEngine: () -> @engine

    setEngine: (e) -> if e? then @engine= e

    getHostPort: () -> @hostPort

    setHostPort: (n) -> if n? and not isNaN(n) then @hostPort= n

    setHostName: (n) -> @host = n ? ''

    getRecoveryPointTimestamp: () -> @ckptTS

    setRecoveryPointTimestamp: (ts) -> if ts? then @ckptTS= ts

    getProductSize: () ->

    setProductSize: (s) ->

    getSnapshotRetentionInDays: () -> @retentionDays

    setSnapshotRetentionInDays: (n) -> if n? and not isNaN(n) then @retentionDays=n

    setConfiguration: (s) ->

    getMaintenanceWindow: () -> @maintenanceWnd

    setMaintenanceWindow: (w) -> if w? then @maintenanceWnd= w

    getSnapshotWindow: () -> @snapshotWnd

    setSnapshotWindow: (w) -> if w? then @snapshotWnd= w

    setHighAvailability: (b) -> if b? then @highAvail = b

    isHighAvailability: () -> @highAvail

#}

class MessageQueueSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Platform.MessageQueueSupport interface ###

    constructor: (sqs) ->
        ### internal ###
        super(sqs)

    createQueue: (name, desc, timeoutSecs, cbs) ->
        ###
        **result**: string - JSON-Object#result</br>
        **name**: string</br>
        **desc**: string</br>
        **timeoutSecs**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['QueueName', name] ]
        if timeoutSecs? and not isNaN(timeoutSecs)
            p.push(['Attribute.1.Name', 'VisibilityTimeout'], ['Attribute.1.Value', timeoutSecs])
        me=this
        h=(data) -> me.on_create_q(data,cbs)
        @awscall('CreateQueue', p, h, cbs)

    removeQueue: (name,cbs) ->
        ###
        **return**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/DeleteQueueResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        args= @aws.ec2Arg('DeleteQueue', [], h, cbs)
        args.tags.QueueName=name
        @aws.doAjax( args)

    list: (filter, cbs) ->
        ###
        **result**: [ string, ... ]</br>
        **filter**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=if @aws.ute().vstr(filter) then [['QueueNamePrefix', filter ]] else []
        me=this
        h= (data) -> me.on_list(data,cbs)
        @awscall( 'ListQueues', p, h, cbs)

    getQueue: (name, cbs) ->
        ###
        **result**: string - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['QueueName', name] ]
        me=this
        h=(data) -> me.on_get_q(data,cbs)
        @awscall('GetQueueUrl', p, h, cbs)

    sendMessage: (queue, msg,cbs) ->
        ###
        **queue**: string</br>
        **msg**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['MessageBody', msg] ]
        me=this
        h= (data) -> me.on_send_msg(data,cbs)
        args= @aws.ec2Arg('SendMessage', p, h, cbs)
        args.tags.QueueName=queue
        @aws.doAjax( args)

    receiveMessages: (queue, maxMsgs, timeoutSecs, cbs) ->
        ###
        **queue**: string</br>
        **maxMsgs**: int</br>
        **timeoutSecs**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['AttributeName.1', 'All'] ]
        if timeoutSecs? and not isNaN(timeoutSecs) then p.push(['VisibilityTimeout', timeoutSecs])
        if maxMsgs? and not isNaN(maxMsgs) then p.push(['MaxNumberOfMessages', maxMsgs])
        me=this
        h= (data) -> cbs?.success?( me.on_rec_msgs(data,cbs) )
        args= @aws.ec2Arg('ReceiveMessage', p, h, cbs)
        args.tags.QueueName=queue
        @aws.doAjax( args)

    removeMessage: (queue, msgHdle, cbs) ->
        ###
        **queue**: string</br>
        **msgHdle**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['ReceiptHandle', msgHdle] ]
        [uu,fcn,gt,dom] = @aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/DeleteMessageResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        args= @aws.ec2Arg('DeleteMessage', p, h, cbs)
        args.tags.QueueName=queue
        @aws.doAjax( args)

    getQueueAttributes: (queue, cbs) ->
        ###
        **queue**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['AttributeName.1', 'All']]
        me=this
        h= (data) -> me.on_getq_atts(data,cbs)
        args= @aws.ec2Arg('GetQueueAttributes', p, h, cbs)
        args.tags.QueueName=queue
        @aws.doAjax( args)

    setQueueAttributes: (queue, name, value, cbs) ->
        ###
        **queue**: string</br>
        **name**: string</br>
        **value**:</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['Attribute.Name', name], ['Attribute.Value', value] ]
        [uu,fcn,gt,dom] = @aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/SetQueueAttributesResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        args= @aws.ec2Arg('SetQueueAttributes', p, h, cbs)
        args.tags.QueueName=queue
        @aws.doAjax( args)

##SKIP_GEN_DOC##

    on_getq_atts: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items= gt(data, '/GetQueueAttributesResponse/GetQueueAttributesResult/Attribute')
        ii=items.length
        rc=[]
        for i in [0...ii]
            nv= { 'Name': dom.ffcn(items[i],'Name'), 'Value': dom.ffcn( items[i],'Value') }
            rc.push(nv)
        cbs?.success?(rc)

    on_rec_msgs: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items= gt(data, '/ReceiveMessageResponse/ReceiveMessageResult/Message')
        ii=items.length
        rc=[]
        for i in [0...ii]
            mid= dom.ffcn(items[i], 'MessageId')
            hd= dom.ffcn(items[i], 'ReceiptHandle')
            md5= dom.ffcn(items[i], 'MD5OfBody')
            msg= dom.ffcn( items[i], 'Body')
            a={ 'MessageId': mid, 'ReceiptHandle':hd, 'MD5OfBody':md5, 'Body':msg, 'Attributes':[] }
            atts=gt(items[i], 'Attribute')
            nn=atts?.length || 0
            for n in [0...nn]
                nv= { 'Name': dom.ffcn(atts[n],'Name'), 'Value': dom.ffcn(atts[n],'Value') }
                a.Attributes.push(nv)
            rc.push(a)
        rc

    on_send_msg: (data, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        item= gt(data, '/SendMessageResponse/SendMessageResult')[0]
        rc= { 'MD5OfMessageBody' : dom.ffcn( item, 'MD5OfMessageBody'), 'MessageId' : dom.ffcn( item, 'MessageId') }
        cbs?.success?(rc)

    on_get_q: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        url= dom.ffcn( data, '/GetQueueUrlResponse/GetQueueUrlResult/QueueUrl')
        @aws.cb_result(url, cbs)

    on_create_q: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        url= dom.ffcn(data, '/CreateQueueResponse/CreateQueueResult/QueueUrl')
        @aws.cb_result(url, cbs)

    on_list: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items=gt(data, '/ListQueuesResponse/ListQueuesResult/QueueUrl')
        ii=items.length
        rc=[]
        for i in [0...ii]
            rc.push(fcn( items[i] ) )
        cbs?.success?(rc)

##SKIP_GEN_DOC##

#}

class DatabaseConfiguration  extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database Configuration information ###

    constructor: (@cfgId) -> super()

    setProviderConfigurationId: () -> @cfgId= id ? ''

    getProviderConfigurationId: () -> @cfgId

    setDatabaseFlavor: (f) -> @family = f ? ''

    getDatabaseFlavor: () -> @family

#}

##SKIP_GEN_DOC##

class CDNSupport #{

    constructor: () ->

    # returns: java.util.Collection
    # cbs: AjaxCBS
    list: (cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    delete: (p1, cbs) ->

    # returns: java.lang.String
    # p1: java.lang.String
    # p2: java.lang.String
    # p3: boolean
    # p4: [Ljava.lang.String;
    # cbs: AjaxCBS
    create: (p1, p2, p3, p4, cbs) ->

    # returns: boolean
    # cbs: AjaxCBS
    hasSupport: (cbs) ->

    # returns: org.dasein.cloud.platform.Distribution
    # p1: java.lang.String
    # cbs: AjaxCBS
    getDistribution: (p1, cbs) ->

    # returns: java.lang.String
    # p1: java.util.Locale
    # cbs: AjaxCBS
    getProviderTermForDistribution: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # p2: java.lang.String
    # p3: boolean
    # p4: [Ljava.lang.String;
    # cbs: AjaxCBS
    update: (p1, p2, p3, p4, cbs) ->

#}

##SKIP_GEN_DOC##

class KeyValueDatabase extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores KeyValue Database information ###

    constructor: (@dbid) -> super()

    equals: (other) -> @getProviderDatabaseId() is other?.getProviderDatabaseId()

    toString: () -> @getProviderDatabaseId()

    getProviderDatabaseId: () -> @dbid

    setProviderDatabaseId: (id) -> @dbid= id ? ''

#}

class EndpointType #{
    ###
    Enums for Notification endpoint types.</br>
        { HTTPS, HTTP, EMAIL, SMS, EMAIL_JSON, AWS_SQS }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

EndpointType.AWS_SQS = new EndpointType('sqs')
EndpointType.EMAIL_JSON = new EndpointType('email-json')
EndpointType.SMS = new EndpointType('sms')
EndpointType.EMAIL = new EndpointType('email')
EndpointType.HTTPS = new EndpointType('https')
EndpointType.HTTP = new EndpointType('http')

EndpointType.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ EndpointType.SMS, EndpointType.EMAIL_JSON, EndpointType.AWS_SQS, EndpointType.EMAIL, EndpointType.HTTPS, EndpointType.HTTP ]

EndpointType.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'sqs' then EndpointType.AWS_SQS
        when 'email-json' then EndpointType.EMAIL_JSON
        when 'sms' then EndpointType.SMS
        when 'email' then EndpointType.EMAIL
        when 'https' then EndpointType.HTTPS
        when 'http' then EndpointType.HTTP
        else null

#}

class PushNotificationSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Platform.PushNotificationSupport interface ###

    constructor: (sns) ->
        ### internal ###
        super(sns)

    hasSupport: () -> true

    confirmSubscription: (topicId, token, authToUnsub, cbs) ->
        ###
        **returns**: Subscription</br>
        **topicId**: string</br>
        **token**: string</br>
        **authToUnsub**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['TopicArn', topicId ], ['Token', token] ]
        if authToUnsub then p.push(['AuthenticateOnUnsubscribe', 'true'])
        me=this
        h=(data) -> me.on_confirm_sub(data,topicId, cbs)
        @awscall('ConfirmSubscription', p, h, cbs)

    createTopic: (name, cbs) ->
        ###
        **returns**: Topic</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['Name',name]]
        me=this
        h=(data) -> me.on_new_topic(data,name,cbs)
        @awscall('CreateTopic', p, h, cbs)

    getProviderTermForSubscription: (locale) -> 'Subscription'

    getProviderTermForTopic: (locale) -> 'Topic'

    listTopicSubscriptions: (cursor, topicId, cbs) ->
        ###
        **cursor**: string or null</br>
        **topicId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['TopicArn', topicId ] ]
        if @aws.ute().vstr(cursor) then p.push( ['NextToken', cursor] )
        me=this
        h=(data) ->
            [rc,ntk]= me.on_list_subs(data, '/ListSubscriptionsByTopicResponse/ListSubscriptionsByTopicResult')
            cbs?.success?(rc, ntk)
        @awscall('ListSubscriptionsByTopic', p, h, cbs)

    listSubscriptions: (cursor, cbs) ->
        ###
        **returns**: [ Subscription, ... ]</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p= if @aws.ute().vstr(cursor) then [['NextToken', cursor]] else []
        me=this
        h=(data) ->
            [rc,ntk] = me.on_list_subs(data, '/ListSubscriptionsResponse/ListSubscriptionsResult')
            cbs?.success?(rc, ntk)
        @awscall('ListSubscriptions', p, h, cbs)

    listTopics: (cursor, cbs) ->
        ###
        **returns**: [ Topic, ... ]</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p= if @aws.ute().vstr(cursor) then [['NextToken', cursor]] else []
        me=this
        h= (data) ->
            [rc,ntk] = me.munch_topics(data)
            cbs?.success?(rc, ntk)
        @awscall('ListTopics', p, h, cbs)

    publish: (topicId, subject, msg, cbs) ->
        ###
        **returns**: string - JSON-Object#result</br>
        **topicId**: string</br>
        **subject**: string or null</br>
        **msg**:</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['TopicArn', topicId ] , ['Message', msg] ]
        if @aws.ute().vstr(subject) then p.push(['Subject', subject])
        me=this
        h= (data) -> me.on_pub(data,cbs)
        @awscall('Publish', p, h, cbs)

    removeTopic: (topicId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **topicId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['TopicArn', topicId] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data,'/DeleteTopicResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('DeleteTopic', p, h, cbs)

    subscribe: (topicId, endpointType, dataFormat, endpoint, cbs) ->
        ###
        **returns**: Subscription</br>
        **topicId**: string</br>
        **endpointType**: EndpointType</br>
        **dataFormat**: DataFormat</br>
        **endpoint**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['Endpoint', endpoint], ['Protocol', endpointType.toString() ] , ['TopicArn', topicId] ]
        me=this
        h=(data) -> me.on_new_subsc(data,topicId,endpoint, endpointType, dataFormat,cbs)
        @awscall('Subscribe', p, h, cbs)

    unsubscribe: (subscription, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **subscription**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['SubscriptionArn', subscription] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data,'/UnsubscribeResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('Unsubscribe', p, h, cbs)

##SKIP_GEN_DOC##

    on_pub: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        n= dom.ffcn( data,'/PublishResponse/PublishResult/MessageId')
        @aws.cb_result(n, cbs)

    on_confirm_sub: (data,topic, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        n= dom.ffcn(data,'/ConfirmSubscriptionResponse/ConfirmSubscriptionResult/SubscriptionArn')
        a=new ComZotoh.CloudAPI.Platform.Subscription(n)
        @aws.cas(a)
        a.setProviderTopicId(topic)
        cbs?.success?(a)

    on_new_subsc: (data,topic,endpt, endpttype, fmt, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        n= dom.ffcn(data,'/SubscribeResponse/SubscribeResult/SubscriptionArn')
        a=new ComZotoh.CloudAPI.Platform.Subscription(n)
        @aws.cas(a)
        a.setEndpointType(endpttype)
        a.setEndpoint(endpt)
        a.setDataFormat(fmt)
        a.setProviderTopicId(topic)
        cbs?.success?(a)

    on_list_subs: (data, pfx) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items= gt(data, pfx+'/Subscriptions/member')
        ii=items.length
        ntk= dom.ffcn(data, pfx+'/NextToken')
        if uu.vstr(ntk) then uu.debug('ListSubscriptions: more to come, cursor='+ntk)
        rc=[]
        for i in [0...ii]
            sub= dom.ffcn(items[i], 'SubscriptionArn')
            a= new ComZotoh.CloudAPI.Platform.Subscription(sub)
            @aws.cas(a)
            x=dom.ffcn(items[i], 'Protocol')
            a.setEndpointType( ComZotoh.CloudAPI.Platform.EndpointType.valueOf(x))
            a.setEndpoint( dom.ffcn(items[i], 'Endpoint') )
            a.setProviderOwnerId( dom.ffcn(items[i], 'Owner') )
            a.setProviderTopicId( dom.ffcn(items[i], 'TopicArn') )
            rc.push(a)
        [rc, ntk]

    munch_topics: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items= gt(data,'/ListTopicsResponse/ListTopicsResult/Topics/member')
        ntk= dom.ffcn(data,'/ListTopicsResponse/ListTopicsResult/NextToken')
        if uu.vstr(ntk) then uu.debug('ListTopics: more to come, cursor='+ntk)
        ii=items.length
        rc=[]
        for i in [0...ii]
            a=new ComZotoh.CloudAPI.Platform.Topic()
            @aws.cas(a)
            a.setProviderTopicId( dom.ffcn(items[i], 'TopicArn') )
            rc.push(a)
        [rc,ntk]

    on_new_topic: (data,name, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        a=new ComZotoh.CloudAPI.Platform.Topic(name)
        @aws.cas(a)
        x= dom.ffcn(data,'/CreateTopicResponse/CreateTopicResult/TopicArn')
        a.setProviderTopicId(x)
        cbs?.success?(a)

##SKIP_GEN_DOC##

#}

class KeyValueItem extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Key-Value Item data ###

    constructor: (n) ->
        super(n)
        @flds=[]

    getFields: () -> @flds

    setFields: (fs) -> if fs? then @flds= fs

    add: (kvp) -> if kvp? then @flds.push(kvp)

#}

class KeyValuePair  #{
    ### POJO stores Key-Value data ###

    constructor: (@key, @value) ->

    equals: (other) -> @getKey() is other?.getKey() and @getValue() is other?.getValue()

    toString: () -> @key + '=' + @value

    getValue: () -> @value

    getKey: () -> @key

    setValue: (val) -> @value = val

    setKey: (key) -> if key? and key.length > 0 then @key=key

#}

class IPRange #{
    ### POJO stores IP range information ###

    constructor: (@cidr) ->

    getCidr: () -> @cidr

    setCidr: (s) -> @cidr= s ? ''

    setStatus: (s) -> @status = s ? ''

    getStatus: () -> @status

#}

class DBFirewall extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database related Firewall information ###

    constructor: (@fwId) ->
        super()
        @iprs=[]
        @secgrps=[]

    setProviderFirewallId: (id) -> @fwId = id ? ''

    getProviderFirewallId: () -> @fwId

    setIPRanges: (r) -> if r? then @iprs = r

    getIPRanges: () -> @iprs

    addIPRange: (r) -> if r? then @iprs.push(r)

    setNetworkFirewalls: (r) -> if r? then @secgrps = r

    getNetworkFirewalls: () -> @secgrps

    addNetworkFirewall: (r) -> if r? then @secgrps.push(r)

#}

class RelationalDatabaseSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Platform.RelationalDatabaseSupport interface ###

    constructor: (rds) ->
        ### internal ###
        super(rds)

    hasSupport: () -> true

    getProviderTermForSnapshot: (locale) -> 'DBSnapshot'

    getSnapshot: (snapId, cbs) ->
        ###
        **returns**: DatabaseSnapshot</br>
        **snapId**: string </br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBSnapshotIdentifier', snapId]]
        me=this
        h= (data) ->
            cbs?.success?( me.aws.ute().getFirst( me.munch_snaps(data)) )
        @awscall('DescribeDBSnapshots', p, h, cbs)


    listSnapshots: (cursor, dbId, cbs) ->
        ###
        **returns**: [ DBSnapshot, ...]</br>
        **cursor**: string or null</br>
        **dbId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(dbId) then p.push(['DBInstanceIdentifier', dbId])
        if @aws.ute().vstr(cursor) then p.push(['Marker', cursor])
        me=this
        h= (data) -> cbs?.success?( me.munch_snaps(data))
        @awscall('DescribeDBSnapshots', p, h, cbs)

    getDatabase: (dbId, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBInstanceIdentifier', dbId]]
        me=this
        h= (data) ->
            cbs?.success?( me.aws.ute().getFirst( me.munch_dbs(data)) )
        @awscall('DescribeDBInstances', p, h, cbs)

    getProviderTermForDatabase: (locale) -> 'Database'

    removeDatabase: (dbId, snapId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dbId**: string</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBInstanceIdentifier', dbId]]
        [uu,fcn,gt,dom]=@aws.cfns()
        if uu.vstr(snapId)
            p.push(['FinalDBSnapshotIdentifier', snapId])
        else
            p.push(['SkipFinalSnapshot', true])
        me=this
        h= (data) ->
            top=dom.getNode(data,'/DeleteDBInstanceResponse')
            me.aws.cb_boolean(is_alive(top),cbs)
        @awscall('DeleteDBInstance', p, h, cbs)

    addAccess: (fwId, params, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **fwId**: string</br>
        **params**: object - optional paramters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBSecurityGroupName', fwId]]
        [uu,cfn,gt,dom]=@aws.cfns()
        if params?
            if is_alive(params.cidr) then p.push(['CIDRIP', params.cidr ])
            else
                p.push(['EC2SecurityGroupName', params.SecGroupName ], ['EC2SecurityGroupOwnerId', params.SecGroupOwner ])
        me=this
        h=(data) ->
            top=dom.getNode(data, '/AuthorizeDBSecurityGroupIngressResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('AuthorizeDBSecurityGroupIngress', p, h, cbs)

    alterDatabase: (dbId, product, cfgId, dbFwalls, password, params, applyAsync, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **product**: DatabaseProduct</br>
        **cfgId**: string</br>
        **dbFwalls**: [ string, ... ]</br>
        **password**: string or null</br>
        **params**: object - optional parameters.</br>
        **applyAsync**: boolean</br>
        **cbs**: AjaxCBS
        ###
        p=[ ['DBInstanceIdentifier', dbId] , ['ApplyImmediately', applyAsync] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        if uu.vstr(password) then p.push(['MasterUserPassword', password])
        if uu.vstr(cfgId) then p.push(['DBParameterGroupName', cfgId])
        if product?
            z=product.getEngineVersion()
            if uu.vstr(z) then p.push(['EngineVersion', z])
            z=product.getStorageInGigabytes()
            if z? and not isNaN(z) then p.push(['AllocatedStorage', z])
            z=product.getProductSize()
            if uu.vstr(z) then p.push(['DBInstanceClass', z])
            z=product.isHighAvailability()
            if is_alive(z) then p.push(['MultiAZ', z ])
        nn=dbFwalls?.length || 0
        for n in [0...nn]
            p.push( ['DBSecurityGroups.member.'+(n+1), dbFwalls[n] ] )
        if params?
            z=params.backupRententionDays
            if z? and not isNaN(z) then p.push(['BackupRetentionPeriod', z])
            z=params.maintenanceWindow
            if z? then p.push(['PreferredMaintenanceWindow', z.toString() ])
            z=params.backupWindow
            if z? then p.push(['PreferredBackupWindow', z.toString() ])
        me=this
        h= (data) -> me.on_alter_db(data,cbs)
        @awscall('ModifyDBInstance', p, h, cbs)

    createFromScratch: (dbId, product, root, password, port, dbname, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **product**: DatabaseProduct</br>
        **root**: string</br>
        **password**: string</br>
        **port**: int or null</br>
        **dbname**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['AllocatedStorage', product.getStorageInGigabytes() ] ]
        engineVer= product.getEngineVersion()
        [uu,fcn,gt,dom]=@aws.cfns()
        p.push(['DBInstanceClass', product.getProductSize() ])
        p.push(['DBInstanceIdentifier', dbId])
        if uu.vstr(dbname) then p.push(['DBName', dbname])
        if uu.vstr(engineVer) then p.push(['EngineVersion', engineVer])
        p.push(['Engine', product.getEngine() ])
        p.push(['MasterUserPassword', password ])
        p.push(['MasterUsername', root])
        if port? and not isNaN(port) then p.push(['Port', port])
        if product.isHighAvailability() is true
            p.push(['MultiAZ', true])
        else
            zone= product.getProviderDataCenterId()
            if uu.vstr(zone) then p.push(['AvailabilityZone',zone])
        me=this
        h= (data) -> me.on_create_db(data,cbs)
        @awscall( 'CreateDBInstance', p, h, cbs)

    createFromLatest: (dbId, srcDbId, product, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **srcDbId**: string</br>
        **product**: DatabaseProduct</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['TargetDBInstanceIdentifier', dbId], ['SourceDBInstanceIdentifier', srcDbId] ]
        p.push(['UseLatestRestorableTime', true])
        [uu,fcn,gt,dom]=@aws.cfns()
        if port? and not isNaN(port) then p.push(['Port', port])
        if product?
            memSize= product.getProductSize()
            if uu.vstr(memSize) then p.push(['DBInstanceClass', memSize ])
            engine= product.getEngine()
            if uu.vstr(engine) then p.push(['Engine', engine])
            if product.isHighAvailability() is true
                p.push(['MultiAZ', true])
            else
                zone= product.getProviderDataCenterId()
                if uu.vstr(zone) then p.push(['AvailabilityZone',zone])
        me=this
        h= (data) -> me.on_create_as_last(data,cbs)
        @awscall('RestoreDBInstanceToPointInTime', p, h, cbs)

    createFromSnapshot: (dbId, snapId, product, port, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **snapId**: string</br>
        **product**: DatabaseProduct</br>
        **port**: int or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBInstanceIdentifier', dbId], ['DBSnapshotIdentifier', snapId] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        if port? and not isNaN(port) then p.push(['Port', port])
        if product?
            memSize= product.getProductSize()
            if uu.vstr(memSize) then p.push(['DBInstanceClass', memSize ])
            engine= product.getEngine()
            if uu.vstr(engine) then p.push(['Engine', engine])
            if product.isHighAvailability() is true
                p.push(['MultiAZ', true])
            else
                zone= product.getProviderDataCenterId()
                if uu.vstr(zone) then p.push(['AvailabilityZone',zone])
        me=this
        h=(data) -> me.on_create_as_snap(data,cbs)
        @awscall('RestoreDBInstanceFromDBSnapshot', p, h, cbs)

    createFromTimestamp: (dbId, srcDbId, product, timestamp, cbs) ->
        ###
        **returns**: Database</br>
        **dbId**: string</br>
        **srcDbId**: string</br>
        **product**: DatabaseProduct</br>
        **timestamp**: date</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['TargetDBInstanceIdentifier', dbId], ['SourceDBInstanceIdentifier', srcDbId] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        if port? and not isNaN(port) then p.push(['Port', port])
        ts= uu.toISO8601String(timestamp, 5)
        p.push(['RestoreTime', ts])
        if product?
            memSize= product.getProductSize()
            if uu.vstr(memSize) then p.push(['DBInstanceClass', memSize ])
            engine= product.getEngine()
            if uu.vstr(engine) then p.push(['Engine', engine])
            if product.isHighAvailability() is true
                p.push(['MultiAZ', true])
            else
                zone= product.getProviderDataCenterId()
                if uu.vstr(zone) then p.push(['AvailabilityZone',zone])
        me=this
        h= (data) -> me.on_create_as_last(data,cbs)
        @awscall('RestoreDBInstanceToPointInTime', p, h, cbs)

    getConfiguration: (cfgId, cbs) ->
        ###
        **returns**: DatabaseConfiguration</br>
        **cfgId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBParameterGroupName', cfgId ]]
        me=this
        h=(data) ->
            [rc, ntk] = me.munch_cfgns(data)
            cbs?.success?( me.aws.ute().getFirst(rc) )
        @awscall('DescribeDBParameterGroups', p, h, cbs)

    getDatabaseEngines: (cbs) ->
        ###
        **returns**: DatabaseEngine</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h=(data) -> cbs?.success?(me.munch_engines(data))
        @awscall('DescribeDBEngineVersions', [], h, cbs)

    createConfiguration: (cfgId, desc, params, cbs) ->
        ###
        **results**: boolean - JSON-Object#result</br>
        **cfgId**: string</br>
        **desc**: string</br>
        **params**: object - optional parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p =[ ['DBParameterGroupName', cfgId ] , ['Description', desc] ]
        p.push(['DBParameterGroupFamily', params.dbFamily ])
        me=this
        h=(data) -> me.on_new_cfgn(data,cbs)
        @awscall('CreateDBParameterGroup', p,h,cbs)

    isSupportsFirewallRules: () -> true

    isSupportsHighAvailability: () -> true

    isSupportsLowAvailability: () -> true

    isSupportsMaintenanceWindows: () -> true

    isSupportsSnapshots: () -> true

    listConfigurations: (cursor, cbs) ->
        ###
        **returns**: [ , ... ]</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(cursor) then p.push(['Marker', cursor])
        me=this
        h=(data) ->
            [rc,ntk]=me.munch_cfgns(data)
            cbs?.success?(rc, ntk)
        @awscall('DescribeDBParameterGroups', p, h, cbs)

    listDBFirewalls: (cursor, cbs) ->
        ###
        **returns**: [ DBFirewall, ... ]</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(cursor) then p.push(['Marker', cursor])
        me=this
        h=(data) ->
            [rc,ntk]=me.munch_dbfwalls(data)
            cbs?.success?(rc, ntk)
        @awscall('DescribeDBSecurityGroups',p,h,cbs)

    listDatabases: (cbs) ->
        ###
        **returns**: [ Database, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_dbs(data))
        @awscall('DescribeDBInstances',[], h, cbs)

    listParameters: (cursor, cfgId, filter, cbs) ->
        ###
        **returns**: [ ConfigurationParameter, ... ]</br>
        **cursor**: string or null</br>
        **cfgId**: string</br>
        **filter**: int - ConfigurationParameter:ENUM.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBParameterGroupName', cfgId]]
        if @aws.ute().vstr(cursor) then p.push(['Marker',cursor])
        z=ComZotoh.CloudAPI.Platform.ConfigurationParameter
        switch filter
            when z.SYSTEM then src='system'
            when z.ENGINE then src='engine-default'
            when z.USER then src='user'
            else src=''
        if @aws.ute().vstr(src) then p.push(['Source',src])
        me=this
        h=(data) ->
            [rc,ntk] =me.munch_params(data)
            cbs?.success?(rc, ntk)
        @awscall('DescribeDBParameters', p, h, cbs)


    removeConfiguration: (cfgId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **cfgId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBParameterGroupName', cfgId ]]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/DeleteDBParameterGroupResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('DeleteDBParameterGroup', p, h, cbs)

    removeSnapshot: (snapId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['DBSnapshotIdentifier', snapId ]]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/DeleteDBSnapshotResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('DeleteDBSnapshot', p, h, cbs)

    resetConfiguration: (cfgId, params, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **cfgId**: string</br>
        **params**: [ ConfigurationParameter,...] - options parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBParameterGroupName', cfgId]]
        b= @pack_cfgn_params(params, p)
        if not b then p.push( ['ResetAllParameters', true ] )
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data, '/ResetDBParameterGroupResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('ResetDBParameterGroup',p,h,cbs)

    restart: (dbId, blocking, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **dbId**: string</br>
        **blocking**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBInstanceIdentifier', dbId] ]
        [uu,fcn,gt,dom] = @aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data,'/RebootDBInstanceResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('RebootDBInstance', p, h, cbs)

    revokeAccess: (fwId, params, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **fwId**: string</br>
        **params**: object - optional params.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBSecurityGroupName', fwId]]
        [uu,cfn,gt,dom]=@aws.cfns()
        if params?
            if is_alive(params.cidr) then p.push(['CIDRIP', params.cidr ])
            else
                p.push(['EC2SecurityGroupName', params.SecGroupName ], ['EC2SecurityGroupOwnerId', params.SecGroupOwner ])
        me=this
        h=(data) ->
            top=dom.getNode(data, '/RevokeDBSecurityGroupIngressResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('RevokeDBSecurityGroupIngress', p, h, cbs)

    updateConfiguration: (cfgId, params, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **cfgId**: string</br>
        **params**: [ConfigurationParameter,... ] - optional params</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['DBParameterGroupName', cfgId]]
        @pack_cfgn_params(params, p)
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data, '/ModifyDBParameterGroupResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('ModifyDBParameterGroup',p,h,cbs)

    snapshot: (dbId, snapIdDesc, cbs) ->
        ###
        **returns**: DatabaseSnapshot</br>
        **dbId**: string</br>
        **snapIdDesc**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBInstanceIdentifier', dbId], ['DBSnapshotIdentifier', snapIdDesc ] ]
        me=this
        h= (data) -> me.on_new_snap(data,cbs)
        @awscall('CreateDBSnapshot', p, h, cbs)

    getDBFirewall: (name, cbs) ->
        ###
        **returns: DBFirewall</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBSecurityGroupName', name] ]
        me=this
        h=(data) ->
            [rc,ntk]=me.munch_dbfwalls(data)
            a= if rc? and rc?.length > 0 then rc[0] else null
            cbs?.success?(a)
        @awscall('DescribeDBSecurityGroups', p,h, cbs)

    removeDBFirewall: (name, cbs) ->
        ###
        **returns: boolean - JSON-Object#boolean</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBSecurityGroupName', name] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data)-> 
            top=dom.getNode(data, '/DeleteDBSecurityGroupResponse')
            me.aws.cb_boolean(is_alive(top),cbs)
        @awscall('DeleteDBSecurityGroup', p,h,cbs)

    createDBFirewall: (name, desc, cbs) ->
        ###
        **returns**: DBFirewall</br>
        **name**: string</br>
        **desc**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['DBSecurityGroupName', name], ['DBSecurityGroupDescription', desc] ]
        me=this
        h=(data)-> me.on_new_dbfwall(data,cbs)
        @awscall('CreateDBSecurityGroup', p,h,cbs)

##SKIP_GEN_DOC##

    on_new_dbfwall: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item=gt(data,'/CreateDBSecurityGroupResponse/CreateDBSecurityGroupResult/DBSecurityGroup')[0]
        a=@munch_one_dbfw(item)
        cbs?.success?(a)

    on_new_cfgn: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item=gt(data,'/CreateDBParameterGroupResponse/CreateDBParameterGroupResult/DBParameterGroup')[0]
        @aws.cb_boolean( is_alive(item), cbs)

    munch_engines: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data,'/DescribeDBEngineVersionsResponse/DescribeDBEngineVersionsResult/DBEngineVersions/DBEngineVersion')
        ii=items.length
        rc=[]
        for i in [0...ii]
            fam=dom.ffcn(items[i], 'DBParameterGroupFamily')
            e=dom.ffcn(items[i], 'Engine')
            ev=dom.ffcn(items[i], 'EngineVersion')
            a= new ComZotoh.CloudAPI.Platform.DatabaseEngine(fam,e, ev)
            @aws.cas(a)
            a.setDescription( dom.ffcn(items[i], 'DBEngineDescription') + '|' + dom.ffcn(items[i], 'DBEngineVersionDescription') )
            rc.push(a)
        rc

    on_create_as_last: (data, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item= gt(data, '/RestoreDBInstanceToPointInTimeResponse/RestoreDBInstanceToPointInTimeResult/DBInstance')[0]
        a= @on_one_db_inst(item)
        cbs?.success?(a)

    on_create_as_snap: (data, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item= gt(data, '/RestoreDBInstanceFromDBSnapshotResponse/RestoreDBInstanceFromDBSnapshotResult/DBInstance')[0]
        a= @on_one_db_inst(item)
        cbs?.success?(a)

    on_create_db: (data, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item= gt(data, '/CreateDBInstanceResponse/CreateDBInstanceResult/DBInstance')[0]
        a= @on_one_db_inst(item)
        cbs?.success?(a)

    on_alter_db: (data, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        item= gt(data, '/ModifyDBInstanceResponse/ModifyDBInstanceResult/DBInstance')[0]
        a= @on_one_db_inst(item)
        cbs?.success?(a)

    munch_cfgns: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data,'/DescribeDBParameterGroupsResponse/DescribeDBParameterGroupsResult/DBParameterGroups/DBParameterGroup')
        ntk= dom.ffcn(data, '/DescribeDBParameterGroupsResponse/DescribeDBParameterGroupsResult/Marker')
        if uu.vstr(ntk) then uu.debug('ListDBParamGroups: more to come, cursor='+ntk)
        ii=items.length
        rc=[]
        for i in [0...ii]
            gn=dom.ffcn(items[i], 'DBParameterGroupName')
            a= new ComZotoh.CloudAPI.Platform.DatabaseConfiguration(gn)
            @aws.cas(a)
            a.setDatabaseFlavor( dom.ffcn(items[i], 'DBParameterGroupFamily') )
            a.setDescription( dom.ffcn(items[i], 'Description') )
            rc.push(a)
        [rc,ntk]

    munch_one_dbfw: (item)->
        [uu,fcn,gt,dom]=@aws.cfns()
        gn=dom.ffcn(item, 'DBSecurityGroupName')
        a= new ComZotoh.CloudAPI.Platform.DBFirewall(gn)
        @aws.cas(a)
        a.setProviderOwnerId( dom.ffcn(item, 'OwnerId') )
        a.setDescription( dom.ffcn(item, 'DBSecurityGroupDescription') )
        ecgps= gt(item, 'EC2SecurityGroups/EC2SecurityGroup')
        nn=ecgps?.length || 0
        for n in [0...nn]
            gn=dom.ffcn(ecgps[n],'EC2SecurityGroupName')
            obj= new ComZotoh.CloudAPI.Network.Firewall(gn)
            @aws.cas(obj)
            obj.setProviderOwnerId( dom.ffcn(ecgps[n],'EC2SecurityGroupOwnerId') )
            obj.setCurrentState(dom.ffcn(ecgps[n],'Status'))
            a.addNetworkFirewall(obj)
        iprs= gt(item, 'IPRanges/IPRange')
        nn=iprs?.length || 0
        for n in [0...nn]
            cidr= dom.ffcn(iprs[n], 'CIDRIP')
            obj=new ComZotoh.CloudAPI.Platform.IPRange(cidr)
            obj.setStatus(dom.ffcn(iprs[n], 'Status'))
            a.addIPRange(obj)
        a

    munch_dbfwalls: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items= gt(data, '/DescribeDBSecurityGroupsResponse/DescribeDBSecurityGroupsResult/DBSecurityGroups/DBSecurityGroup')
        ntk= dom.ffcn(data, '/DescribeDBSecurityGroupsResponse/DescribeDBSecurityGroupsResult/Marker')
        if uu.vstr(ntk) then uu.debug('ListDBSecGroups: more to come, cursor='+ntk)
        ii=items.length
        rc=[]
        for i in [0...ii]
            a=@munch_one_dbfw(items[i])
            rc.push(a)
        [rc, ntk]

    munch_dbs: (data) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items= gt(data, '/DescribeDBInstancesResponse/DescribeDBInstancesResult/DBInstances/DBInstance')
        ii=items.length
        rc=[]
        for i in [0...ii]
            rc.push( @on_one_db_inst(items[i]) )
        rc

    on_one_db_inst: (item) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        name= dom.ffcn(item, 'DBName')
        a= new ComZotoh.CloudAPI.Platform.Database(name)
        @aws.cas(a)
        a.setCurrentState(dom.ffcn(item, 'DBInstanceStatus'))
        eng= dom.ffcn(item, 'Engine')
        engver= dom.ffcn(item, 'EngineVersion')
        x=new ComZotoh.CloudAPI.Platform.DatabaseEngine('',eng, engver)
        a.setEngine(x)
        host= gt(item, 'Endpoint')[0]
        a.setHostName( dom.ffcn(host,'Address') )
        x= dom.ffcn(host,'Port')
        a.setHostPort(Number(x))
        a.setProviderDatabaseId( dom.ffcn(item, 'DBInstanceIdentifier') )
        a.setProviderDataCenterId( dom.ffcn(item, 'AvailabilityZone') )
        x=uu.setISO8601(new Date(), dom.ffcn(item, 'InstanceCreateTime') )
        a.setCreationTimestamp(x)
        x= dom.ffcn(item, 'AllocatedStorage')
        a.setAllocatedStorageInGb(Number(x))
        x=dom.ffcn(item, 'DBInstanceClass')
        a.setProductSize(x)
        a.setAdminUser( dom.ffcn(item, 'MasterUsername') )
        x=dom.ffcn(item, 'BackupRetentionPeriod')
        a.setSnapshotRetentionInDays(Number(x))
        x=uu.setISO8601(new Date(), dom.ffcn(item, 'LatestRestorableTime') )
        a.setRecoveryPointTimestamp(x)
        x=dom.ffcn(item, 'PreferredBackupWindow')
        a.setSnapshotWindow( @split_time_window(x) || @split_time_window_2(x) )
        x= dom.ffcn(item, 'PreferredMaintenanceWindow')
        a.setMaintenanceWindow( @split_time_window(x) || @split_time_window_2(x) )
        a

    split_time_window_2: (s) ->
        r=/(\d{2}):(\d{2})-(\d{2}):(\d{2})/
        pr= s.match(r)
        if not ( pr? and pr.length is 5 ) then return null
        z=ComZotoh.CloudAPI
        a=new z.TimeWindow()
        a.setStartHour( Number( pr[1]) )
        a.setStartMinute( Number(pr[2]) )
        a.setEndHour( Number( pr[3]))
        a.setEndMinute( Number(pr[4]))
        a

    split_time_window: (s) ->
        r=/([a-zA-Z]+):(\d{2}):(\d{2})-([a-zA-Z]+):(\d{2}):(\d{2})/
        pr= s.match(r)
        if not ( pr? and pr.length is 7 ) then return null
        z=ComZotoh.CloudAPI
        a=new z.TimeWindow()
        a.setStartDayOfWeek( z.DayOfWeek.valueOf( pr[1] ) )
        a.setStartHour( Number( pr[2]) )
        a.setStartMinute( Number(pr[3]) )
        a.setEndDayOfWeek( z.DayOfWeek.valueOf( pr[4] ) )
        a.setEndHour( Number( pr[5]))
        a.setEndMinute( Number(pr[6]))
        a

    munch_params: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data, '/DescribeDBParametersResponse/DescribeDBParametersResult/Parameters/Parameter')
        ntk=dom.ffcn(data, '/DescribeDBParametersResponse/DescribeDBParametersResult/Marker')
        if uu.vstr(ntk) then uu.debug('ListDBParams: more to come, cursor='+ntk)
        rc=[]
        ii=items.length
        for i in [0...ii]
            v=dom.ffcn(items[i],'ParameterValue')
            nm=dom.ffcn(items[i],'ParameterName')
            a=new ComZotoh.CloudAPI.Platform.ConfigurationParameter(nm,v)
            @aws.cas(a)
            a.setModifiable('true' is dom.ffcn(items[i],'IsModifiable') )
            a.setDataType( dom.ffcn(items[i],'DataType') )
            a.setDescription(dom.ffcn(items[i],'Description'))
            a.setSource( dom.ffcn(items[i],'Source') )
            a.setDynamic('dynamic' is dom.ffcn(items[i],'ApplyType') )
            rc.push(a)
        [rc, ntk]

    pack_cfgn_params: (params, out) ->
        pfx=null
        ii= params?.length || 0
        for i in [0...ii]
            pfx= 'Parameters.member.'+(i+1)
            mtd= if params[i].isImmediate() then 'immediate' else 'pending-reboot'
            pv= params[i].getValue()
            pn= params[i].getName()
            if is_alive(pv) then out.push( [pfx+'.ParameterValue' , pv ] )
            out.push( [pfx+'.ParameterName' , pn ] )
            out.push( [pfx+'.ApplyMethod' , mtd ] )
        if pfx? then true else false

    munch_snaps: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items= gt(data,'/DescribeDBSnapshotsResponse/DescribeDBSnapshotsResult/DBSnapshots/DBSnapshot')
        ii=items.length
        rc=[]
        for i in [0...ii]
            rc.push( @munch_one_snap(items[i]) )
        rc

    munch_one_snap: (item) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        snap=dom.ffcn(item, 'DBSnapshotIdentifier')
        a= new ComZotoh.CloudAPI.Platform.DatabaseSnapshot(snap)
        @aws.cas(a)
        a.addTag('Port', dom.ffcn(item, 'Port') )
        a.addTag('Engine', dom.ffcn(item, 'Engine') )
        a.setCurrentState(dom.ffcn(item, 'Status'))
        a.addTag('AvailabilityZone', dom.ffcn(item, 'AvailabilityZone') )
        a.addTag('EngineVersion',dom.ffcn(item, 'EngineVersion'))
        a.setProviderDatabaseId( dom.ffcn(item, 'DBInstanceIdentifier') )
        x=dom.ffcn(item, 'AllocatedStorage')
        a.setStorageInGigabytes(Number(x))
        x=uu.setISO8601(new Date(), dom.ffcn(item, 'InstanceCreateTime') )
        a.setSnapshotTimestamp(x)
        a.setAdminUser( dom.ffcn(item, 'MasterUsername') )
        a

    on_new_snap: (data, cbs) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        item=gt(data, '/CreateDBSnapshotResponse/CreateDBSnapshotResult/DBSnapshot')[0]
        a= if item? then @munch_one_snap(item) else null
        cbs?.success?(a)

##SKIP_GEN_DOC##

#}

class DatabaseSnapshot extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database snapshot information ###

    constructor: (@snap) -> super()

    equals: (other) -> @getProviderSnapshotId() is other?.getProviderSnapshotId()

    toString: () -> @getProviderSnapshotId()

    getProviderSnapshotId: () -> @snap

    getSnapshotTimestamp: () -> @tstamp

    setProviderSnapshotId: (id) -> @snap = id ? ''

    setSnapshotTimestamp: (ts) -> if ts? then @tstamp= ts

    getProviderDatabaseId: () -> @dbId

    setProviderDatabaseId: (id) -> @dbId = id ? ''

    getAdminUser: () -> @admin

    setAdminUser: (u) -> @admin = u ? ''

    getStorageInGigabytes: () -> @gbSize

    setStorageInGigabytes: (n) -> if n? and not isNaN(n) then @gbSize= n

#}

class DatabaseEngine extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Database engine information ###

    constructor: (@dbGroup, @engId, @engVer) -> super()

    toString: () -> @desc

    setFamily: (f) -> @dbGroup = f ? ''

    getFamily: () -> @dbGroup

    setProviderEngineId: (id) -> @engId = id ? ''

    getProviderEngineId: () -> @engId

    setVersion: (v) -> @engVer = v ? ''

    getVersion: () -> @engVer

    isMySQL: () -> (@engId ? '').toLowerCase().indexOf('mysql') >= 0

#}

class DatabaseProduct #{
    ### POJO stores Database product information ###

    constructor: () ->

    setProviderDataCenterId: (z) -> @zone = z ? ''

    getProviderDataCenterId: () -> @zone

    setStorageInGigabytes: (n) -> if n? and not isNaN(n) then @gbSize = n

    getStorageInGigabytes: () -> @gbSize

    setProductSize: (z) -> @dbSize= z

    getProductSize: () -> @dbSize

    getEngineVersion: () -> @engineVersion

    setEngineVersion: (e) -> @engineVersion= e ? ''

    getEngine: () -> @engine

    setEngine: (e) -> @engine= e ? ''

    setHighAvailability: (b) -> @highAvail = true is b

    isHighAvailability: () -> @highAvail

#}

##SKIP_GEN_DOC##

class Distribution #{

    constructor: () ->

    # returns: boolean
    # p1: java.lang.Object
    # cbs: AjaxCBS
    equals: (p1, cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    toString: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getName: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getLocation: (cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setName: (p1, cbs) ->

    # returns: boolean
    # cbs: AjaxCBS
    isActive: (cbs) ->

    # returns: void
    # p1: boolean
    # cbs: AjaxCBS
    setActive: (p1, cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getProviderOwnerId: (cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setProviderOwnerId: (p1, cbs) ->

    # returns: [Ljava.lang.String;
    # cbs: AjaxCBS
    getAliases: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getDnsName: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getProviderDistributionId: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getLogDirectory: (cbs) ->

    # returns: java.lang.String
    # cbs: AjaxCBS
    getLogName: (cbs) ->

    # returns: boolean
    # cbs: AjaxCBS
    isDeployed: (cbs) ->

    # returns: void
    # p1: [Ljava.lang.String;
    # cbs: AjaxCBS
    setAliases: (p1, cbs) ->

    # returns: void
    # p1: boolean
    # cbs: AjaxCBS
    setDeployed: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setDnsName: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setLocation: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setProviderDistributionId: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setLogDirectory: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    setLogName: (p1, cbs) ->

#}

##SKIP_GEN_DOC##

class KeyValueDatabaseSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Platform.KeyValueDatabaseSupport interface ###

    constructor: (sdb) ->
        ### internal ###
        super(sdb)

    list: (cursor, cbs) ->
        ###
        **returns**: [ KeyValueDatabase, ... ] , cursor</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(cursor) then p.push(['NextToken', cursor])
        me=this
        h= (data) ->
            [rc, ntk] = me.munch_xml(data)
            cbs?.success?(rc, ntk)
        @awscall('ListDomains', p, h, cbs)

    query: (cursor, select, wantConsistentRead, cbs) ->
        ###
        **returns**: [ KeyValueItem, ... ] , cursor</br>
        **cursor**: string or null</br>
        **select**: query string</br>
        **wantConsistentRead**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['SelectExpression', select ] ]
        if @aws.ute().vstr(cursor) then p.push(['NextToken', cursor ])
        if wantConsistentRead then p.push(['ConsistentRead', 'true'])
        me=this
        h= (data) ->
            [rc, ntk] = me.munch_kvals(data)
            cbs?.success?( rc, ntk )
        @awscall('Select', p, h, cbs)

    hasSupport: () -> true

    getItemCount: (db, cbs) ->
        ###
        **returns**: int - JSON-Object#result</br>
        **cbs**: AjaxCBS</br>
        ###
        q= [ 'select count(*) from `', db , "`" ].join('')
        p= [ ['SelectExpression', q] ]
        me=this
        h= (data) -> me.on_item_count(data,cbs)
        @awscall('Select', p, h, cbs)

    getItemNames: (db, cbs) ->
        ###
        **returns**: [ KeyValueItem, ... ]</br>
        **db**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        q= [ 'select itemName() from `', db , "`" ].join('')
        p= [ ['SelectExpression', q] ]
        me=this
        h= (data) -> me.on_list_items(data,cbs)
        @awscall('Select', p, h, cbs)

    getKeyCount: (db, item, cbs) ->
        ###
        **returns**: int - JSON-Object#result</br>
        **db**: string</br>
        **item**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs? then cbs.success= (data) -> me.on_key_count(data,old,cbs)
        @getKeyValuePairs(db, item, false, cbs)

    addKeyValuePairs: (db, item, keyvals, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **db**: string</br>
        **item**: string</br>
        **keyvals**: [ KeyValuePair, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        @upsert_kvals(db, item, keyvals, 'false', cbs)

    createDatabase: (name, desc, cbs) ->
        ###
        **returns**: KeyValueDatabase</br>
        **name**: string</br>
        **desc**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ [ 'DomainName', name] ]
        me=this
        h= (data) ->
            x=new ComZotoh.CloudAPI.Platform.KeyValueDatabase(name)
            cbs?.success?(x)
        @awscall('CreateDomain', p, h, cbs)

    getKeyValuePairs: (db, item, wantConsistentRead, cbs) ->
        ###
        **returns**: [ KeyValuePair, ... ]</br>
        **db**: string</br>
        **item**: string</br>
        **wantConsistentRead**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ [ 'DomainName', db], ['ItemName', item] ]
        if wantConsistentRead then p.push(['ConsistentRead', 'true'])
        me=this
        h= (data) -> me.munch_atts(data,item, cbs)
        @awscall( 'GetAttributes', p, h, cbs)

    getDatabase: (name, cbs) ->
        ###
        **returns**: KeyValueDatabase</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs? then cbs.success= (data) -> me.on_get_one_db(data,name,old,cbs)
        @list('',cbs)

    getProviderTermForDatabase: (locale) -> 'Simple DB'

    isSupportsKeyValueDatabases: () -> true

    removeKeyValuePairs: (db, item, keyvals, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **db**: string</br>
        **item**: string</br>
        **keyvals**: [ KeyValuePair, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ [ 'DomainName', db], [ 'ItemName', item ] ]
        jj=keyvals?.length || 0
        u= @aws.ute()
        for j in [0...jj]
            v= keyvals[j].getValue()
            k= keyvals[j].getKey()
            a= 'Attribute.' + j
            p.push([a + ".Name", k] )
            if is_alive(v) then p.push( [a + ".Value", v] )
        if u.isDbg() and jj > 0
            u.debug( 'keyValuePairs:remove:\n' + u.jsonStr( p ))
        me=this
        h= (data) -> me.aws.cb_boolean(true,cbs)
        @awscall('DeleteAttributes', p, h, cbs)

    removeItem: (db, item, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **db**: string</br>
        **item**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        @removeKeyValuePairs(db, item, [], cbs)

    removeDatabase: (db, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **db**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ [ 'DomainName', db ] ]
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall('DeleteDomain',  p, h, cbs)

    replaceKeyValuePairs: (db, item, keyvals, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **db**: string</br>
        **item**: string</br>
        **keyvals**: [ KeyValuePair, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        @upsert_kvals(db, item, keyvals, 'true', cbs)

##SKIP_GEN_DOC##

    on_key_count: (data,old,cbs) ->
        fs= if data? then data.getFields() else []
        c= if fs? then fs.length else 0
        cbs?.success=old
        @aws.cb_result(Number(c), cbs)

    on_item_count: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        c= dom.ffcn(data, '/SelectResponse/SelectResult/Item/Attribute/Value')
        c= if uu.vstr(c) then Number(c) else Number(0)
        @aws.cb_result( c, cbs)

    on_list_items: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data,'/SelectResponse/SelectResult/Item')
        ii= items.length
        lst=[]
        for i in [0...ii]
            n= dom.ffcn(items[i], 'Name')
            lst.push( new ComZotoh.CloudAPI.Platform.KeyValueItem(n))
        cbs?.success?(lst)

    on_get_one_db: (data, name,old, cbs) ->
        ii=data.length
        rc=null
        for i in [0...ii]
            if data[i].getProviderDatabaseId() is name
                rc= data[i]
                break
        old?(rc)

    upsert_kvals: (db, item, keyvals, replaceStr, cbs) ->
        p=[ [ 'DomainName', db], [ 'ItemName', item ] ]
        jj=keyvals?.length || 0
        u= @aws.ute()
        for j in [0...jj]
            v= keyvals[j].getValue() ? ''
            k= keyvals[j].getKey()
            a= 'Attribute.' + j
            p.push([a + '.Name', k], [a + '.Value', v], [a + '.Replace', replaceStr])
        if u.isDbg() && jj > 0
            u.debug( 'keyValuePairs:upsert:\n' + u.jsonStr( p ))
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall('PutAttributes', p, h, cbs)

    munch_kvals: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/SelectResponse/SelectResult/Item')
        ntk = dom.ffcn(data,'/SelectResponse/SelectResult/NextToken')
        if uu.vstr(ntk) then uu.debug('Select.get-keyvals: more to come, cursor='+ntk)
        ii= items.length
        lst=[]
        for i in [0...ii]
            name= dom.ffcn(items[i], 'Name')
            a= new ComZotoh.CloudAPI.Platform.KeyValueItem(name)
            lst.push(a)
            atts=gt( items[i], 'Attribute')
            jj= atts?.length || 0
            for j in [0...jj]
                v= gt( atts[j], 'Value')[0]
                if v? then v= fcn( v)
                n= dom.ffcn( atts[j], 'Name')
                a.add( new ComZotoh.CloudAPI.Platform.KeyValuePair(n,v))
        if uu.isDbg()
            uu.debug( "Select.get-keyvals: number of rows returned = #{lst.length}")
        [lst,ntk]

    munch_atts: (data, name, cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/GetAttributesResponse/GetAttributesResult/Attribute')
        ii= items.length
        a= new ComZotoh.CloudAPI.Platform.KeyValueItem(name)
        for i in [0...ii]
            v= gt( items[i], 'Value')[0]
            if v? then v=fcn(v)
            n= dom.ffcn(items[i], 'Name')
            a.add( new ComZotoh.CloudAPI.Platform.KeyValuePair(n,v))
        cbs?.success?(a)

    munch_xml: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data,'/ListDomainsResponse/ListDomainsResult/DomainName')
        ntk = dom.ffcn(data,'/ListDomainsResponse/ListDomainsResult/NextToken')
        if uu.vstr(ntk) then uu.debug('ListDomains: more to come, cursor='+ntk)
        ii= items.length
        lst=[]
        for i in [0...ii]
            n= fcn( items[i])
            lst.push(new ComZotoh.CloudAPI.Platform.KeyValueDatabase(n))
        [ lst, ntk]

##SKIP_GEN_DOC##

#}

class Subscription extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Subscription information ###

    constructor: (@subId) -> super()

    toString: () -> @getProviderSubscriptionId() + '|' + @getProviderTopicId()

    getProviderSubscriptionId: () -> @subId

    setProviderSubscriptionId: (s) ->  @subId= s ? ''

    setEndpointType: (p) -> if p? then @endptType=p

    getEndpointType: () -> @endptType

    setEndpoint: (p) -> @endpt = p ? ''

    getEndpoint: () -> @endpt

    setDataFormat: (f) -> if f? then @fmt= f

    getDataFormat: () -> @fmt

    getProviderTopicId: () -> @topicId

    setProviderTopicId: (n) -> @topicId = n ? ''

#}

class Topic extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Topic information ###

    constructor: (name) -> super(name)

    toString: () -> @getName() + '|' + @getProviderTopicId()

    isActive: () -> true

    setActive: (b) ->

    getProviderTopicId: () -> @topicId

    setProviderTopicId: (n) -> @topicId = n ? ''

#}

class PlatformServices #{
    ### ComZotoh.CloudAPI.Platform.PlatformServices interface ###

    constructor: (@ec2,@sdb,@sns,@sqs, @rds) ->
        ### internal ###
        @pubsub=new ComZotoh.CloudAPI.Platform.PushNotificationSupport(@sns)
        @kvds=new ComZotoh.CloudAPI.Platform.KeyValueDatabaseSupport(@sdb)
        @queue=new ComZotoh.CloudAPI.Platform.MessageQueueSupport(@sqs)
        @rdbs=new ComZotoh.CloudAPI.Platform.RelationalDatabaseSupport(@rds)

    getCDNSupport: () -> null

    getKeyValueDatabaseSupport: () -> @kvds

    getMessageQueueSupport: () -> @queue

    getPushNotificationSupport: () -> @pubsub

    getRelationalDatabaseSupport: () -> @rdbs

    hasCDNSupport: () -> false

    hasKeyValueDatabaseSupport: () -> is_alive(@kvds)

    hasMessageQueueSupport: () -> is_alive(@queue)

    hasPushNotificationSupport: () -> is_alive(@pubsub)

    hasRelationalDatabaseSupport: () -> is_alive(@rdbs)

#}



`

if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Platform)) { ComZotoh.CloudAPI.Platform={}; }
ComZotoh.CloudAPI.Platform.ConfigurationParameter=ConfigurationParameter;
ComZotoh.CloudAPI.Platform.Database=Database;
ComZotoh.CloudAPI.Platform.MessageQueueSupport=MessageQueueSupport;
ComZotoh.CloudAPI.Platform.DatabaseConfiguration=DatabaseConfiguration;
ComZotoh.CloudAPI.Platform.CDNSupport=CDNSupport;
ComZotoh.CloudAPI.Platform.KeyValueDatabase=KeyValueDatabase;
ComZotoh.CloudAPI.Platform.KeyValuePair=KeyValuePair;
ComZotoh.CloudAPI.Platform.KeyValueItem=KeyValueItem;
ComZotoh.CloudAPI.Platform.EndpointType=EndpointType;
ComZotoh.CloudAPI.Platform.PushNotificationSupport=PushNotificationSupport;
ComZotoh.CloudAPI.Platform.DBFirewall=DBFirewall;
ComZotoh.CloudAPI.Platform.IPRange=IPRange;
ComZotoh.CloudAPI.Platform.RelationalDatabaseSupport=RelationalDatabaseSupport;
ComZotoh.CloudAPI.Platform.DatabaseSnapshot=DatabaseSnapshot;
ComZotoh.CloudAPI.Platform.DatabaseEngine=DatabaseEngine;
ComZotoh.CloudAPI.Platform.DatabaseProduct=DatabaseProduct;
ComZotoh.CloudAPI.Platform.Distribution=Distribution;
ComZotoh.CloudAPI.Platform.KeyValueDatabaseSupport=KeyValueDatabaseSupport;
ComZotoh.CloudAPI.Platform.Subscription=Subscription;
ComZotoh.CloudAPI.Platform.Topic=Topic;
ComZotoh.CloudAPI.Platform.PlatformServices=PlatformServices;


})(|GLOBAL|);



`

