###
file: comzotoh.cloudapi.compute.coffee
###

`

(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

function is_num(obj) { return is_alive(obj) && isNaN(obj) === false ; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`


class Volume extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Volume information ###

    constructor: (@volId) -> super()

    equals: (other) -> @volId is other?.getProviderVolumeId()

    toString: () -> @getProviderVolumeId()

    getDeviceId: () -> @devId

    getProviderDataCenterId: () -> @zone

    setProviderDataCenterId: (id) -> @zone = id ? ''

    getProviderSnapshotId: () -> @snapId

    setProviderSnapshotId: (snap) -> @snapId= snap ? ''

    getProviderVirtualMachineId: () -> @vmId

    setProviderVirtualMachineId: (vm) -> @vmId = vm ? ''

    getProviderVolumeId: () -> @volId

    getSizeInGigabytes: () -> @gbSize

    setDeviceId: (dev) -> @devId=dev ? ''

    setProviderVolumeId: (id) -> @volId = id ? ''

    setSizeInGigabytes: (gb) -> if gb? and not isNaN(gb) then @gbSize=gb

    getAttachedTimestamp: () -> @att_tstamp

    setAttachedTimestamp: (date) -> if date? then @att_tstamp=date


#}

class MachineImage extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Machine Image information ###

    constructor: (@imgId) -> super()

    equals: (other) -> @getProviderMachineImageId() is other?.getProviderMachineImageId()

    toString: () -> @getProviderMachineImageId()

    getType: () -> @type

    getPlatform: () -> @platform

    getSoftware: () -> @software

    setPlatform: (p1) -> if p1? then @platform=p1

    setSoftware: (p1) -> @software=p1 ? ''

    getArchitecture: () -> @arch

    setArchitecture: (a) -> if a? then @arch=a

    getProviderMachineImageId: () -> @imgId

    setProviderMachineImageId: (id) -> @imgId = id ? ''

    setType: (t) -> if t? then @type=t

#}

class ScalingGroup extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores a Scaling Group information ###

    constructor: (@gid) -> super()

    getProviderLaunchConfigurationId: () -> @cfgnId

    setProviderLaunchConfigurationId: (n) -> @cfgnId = n ? ''

    getCooldown: () -> @coolDownSecs

    setCooldown: (n) -> if n? and not isNaN(n) then @coolDownSecs=n

    getMaxServers: () -> @maxServers

    setMaxServers: (n) -> if n? and not isNaN(n) then @maxServers = n

    getMinServers: () -> @minServers

    setMinServers: (n) -> if n? and not isNaN(n) then @minServers = n

    getProviderDataCenterIds: () -> @zones

    setProviderDataCenterIds: (zs) -> if zs? then @zones= zs

    getProviderScalingGroupId: () -> @gid

    setProviderScalingGroupId: (id) -> @gid = id ? ''

    setProviderServerIds: (ids) -> if ids? then @sids= ids

    getProviderServerIds: () -> @sids

    setTargetCapacity: (n) -> if n? and not isNaN(n) then @targetCap= n

    getTargetCapacity: () -> @targetCap

#}

class VirtualMachineSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.VirtualMachineSupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    clone: (vmId, intoDcId, powerOn, fwalls, cbs) ->
        ###
        NOT YET IMPLEMENTED</br>
        **returns**: VirtualMachine</br>
        **vmId**: string</br>
        **intoDcId**: string - target data center</br>
        **powerOn**: boolean</br>
        **fwalls**: [] - list of firewall names</br>
        **cbs**: AjaxCBS</br>
        ###

    hasSupport: () -> true

    boot: (vmId, cbs) ->
        ###
        Restarts a vm , when the vm is in a paused-stopped state.</br>
        **returns**: boolean - JSON-Object#result
        **vmId**: string
        **cbs**: AjaxCBS
        ###
        p=[ ['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall( 'StartInstances', p , h, cbs)

    disableAnalytics: (vmId, cbs) ->
        ###
        Disable monitoring of the vm.</br>
        **returns**: boolean - JSON-Object#result.</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall( 'UnmonitorInstances', p , h, cbs)

    enableAnalytics: (vmId, cbs) ->
        ###
        Enable monitoring of the vm.</br>
        **returns**: boolean - JSON-Object#result.</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall( 'MonitorInstances', p , h, cbs)

    getConsoleOutput: (vmId, cbs) ->
        ###
        **returns**: string - JSON-Object#result</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['InstanceId', vmId] ]
        me=this
        h= (data) -> me.aws.cb_string( me.on_get_console_out(data),cbs)
        @awscall( 'GetConsoleOutput',  p, h, cbs)

    getProduct: (prodId) ->
        ###
        **returns**: VirtualMachineProduct</br>
        **prodId**: string</br>
        ###
        ComZotoh.CloudAPI.Compute.VirtualMachineProduct.entrySet()[prodId]

    getProviderTermForServer: (locale) -> 'Instance'

    getVirtualMachine: (vmId, cbs) ->
        ###
        **returns**: VirtualMachine</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ [ 'InstanceId.1', vmId ] ]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_xml(data)) )
        @awscall( 'DescribeInstances', p, h, cbs)

    launch: (imageId, product, dc, keypair, vLanId, withAnalytics, fwalls, params, cbs) ->
        ###
        Launch a Virtual-Machine from an Machine-Image.</br>
        **returns**: VirtualMachine</br>
        **imageId**: string</br>
        **product**: VirtualMachineProduct</br>
        **dc**: string - datacenter.</br>
        **keypair**: string</br>
        **vLanId**: string</br>
        **withAnalytics**: boolean</br>
        **fwalls**: [ string, ... ]</br>
        **params**: object - extra params.</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,cfn,gt,dom]=@aws.cfns()
        b64=uu.b64()
        me=this
        p=[]
        if withAnalytics then p.push(['Monitoring.Enabled', 'true'])
        p.push(['ImageId', imageId])
        p.push(['InstanceType', product?.getProductId() ])
        p.push(['MinCount', 1])
        p.push(['MaxCount', 1])
        if uu.vstr(keypair) then p.push(['KeyName', keypair])
        if uu.vstr(vLanId)
            p.push(['SubnetId', vLanId])
            fwalls=[]
        else if uu.vstr(dc)
            p.push(['Placement.AvailabilityZone', dc])

        nn= fwalls?.length || 0
        for i in [0...nn]
            p.push(['SecurityGroup.'+(i+1), fwalls[i]])

        if params?
            s= params['UserData']
            if uu.vstr(s) then p.push(['UserData', b64.encode(s)])

        h= (data) -> me.on_launch(data,cbs)
        @awscall( 'RunInstances', p, h, cbs)

    listFirewalls: (vmId, cbs) ->
        ###
        **returns**: [ string, ... ]</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs? then cbs.success= (data) -> me.on_list_fwalls(data,cbs, old)
        @getVirtualMachine(vmId, cbs)

    listProducts: (arch) ->
        ###
        **returns**: [ VirtualMachineProduct, ... ]</br>
        **arch**: Architecture</br>
        ###
        lst=ComZotoh.CloudAPI.Compute.VirtualMachineProduct.values()
        t=arch?.toString()
        ii=lst.length
        rc=[]
        s= if 'x84_64' is t then '64bit' else if 'i386' then '32bit' else '???'
        for i in [0...ii]
            if lst[i].getDescription().indexOf(s) >= 0 then rc.push(lst[i])
        rc

    listVirtualMachines: (cbs) ->
        ###
        **returns**: [ VirtualMachine, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?(me.munch_xml(data))
        @awscall( 'DescribeInstances', [], h, cbs)

    pause: (vmId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true, cbs)
        @awscall('StopInstances', p , h, cbs)

    reboot: (vmId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data, '/RebootInstancesResponse', cbs)
        @awscall('RebootInstances', p , h, cbs)

    supportsAnalytics: () -> true

    terminate: (vmId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vmId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['InstanceId.1', vmId ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true,cbs)
        @awscall( 'TerminateInstances', p, h, cbs)

##SKIP_GEN_DOC##

    on_launch: (data, cbs) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        top = dom.getNode(data, '/RunInstancesResponse')
        resId = dom.ffcn( top, 'reservationId')
        owner = dom.ffcn( top, 'ownerId')
        items = gt(top, 'instancesSet/item')
        lst=[]
        if items? then @unpack_instances(lst, resId, owner, items)
        cbs?.success?( uu.getFirst(lst))

    on_list_fwalls: (data,cbs,old) ->
        gs= ( if data? then data.getTag('groupSet') ) ? ''
        gs= gs.split(',')
        cbs?.success=old
        @aws.cb_result(gs, cbs)

    munch_xml: (data) ->
        [uu,fcn,gt, dom]=@aws.cfns()
        items = gt(data, '/DescribeInstancesResponse/reservationSet/item')
        ii= items.length
        lst = []
        for i in [0...ii]
            resId = dom.ffcn( items[i] ,'reservationId')
            owner = dom.ffcn( items[i] , 'ownerId')
            iis= gt(items[i], 'instancesSet/item')
            if iis? then @unpack_instances(lst, resId, owner, iis)
        lst

    unpack_instances: (out, resId, ownerId, iitems) ->
        pds=ComZotoh.CloudAPI.Compute.VirtualMachineProduct.entrySet()
        jj= iitems.length
        [uu,fcn,gt,dom]=@aws.cfns()
        for j in [0...jj]
            if '#text' is dom.getNName(iitems[j]) then continue
            instanceState = gt(iitems[j],'instanceState')[0]
            stateName = uu.getNVal(instanceState,'name')
            #if ( 'shutting-down' is stateName or 'terminated' is stateName ) then continue
            iid = dom.ffcn( iitems[j],'instanceId')
            inst= new ComZotoh.CloudAPI.Compute.VirtualMachine(iid)
            @aws.cas(inst)
            inst.setCurrentState(stateName)
            inst.setProviderOwnerId(ownerId)
            groupIds = gt( iitems[j] , 'groupSet/item')
            groups = []
            kk= groupIds?.length || 0
            for k in [0...kk]
                gn = dom.ffcn( groupIds[k], 'groupName')
                if uu.vstr(gn) then groups.push(gn)
            inst.addTag('groupSet', groups.join(',') )
            inst.setProviderMachineImageId( dom.ffcn( iitems[j],'imageId') )
            inst.addTag('kernelId',dom.ffcn( iitems[j],'kernelId') )
            inst.addTag('ramdiskId',dom.ffcn( iitems[j],'ramdiskId'))
            inst.setPublicDnsAddress( uu.getNVal(iitems[j], 'dnsName') )
            inst.setPrivateDnsAddress( uu.getNVal(iitems[j], 'privateDnsName') )
            inst.addTag('keyName', dom.ffcn( iitems[j],'keyName') )
            x = uu.getNVal(iitems[j], 'architecture')
            x= ComZotoh.CloudAPI.Compute.Architecture.valueOf(x)
            inst.setArchitecture(x)
            uu.getNVal(iitems[j], 'reason')
            uu.getNVal(iitems[j], 'amiLaunchIndex')
            x = dom.ffcn( iitems[j],'instanceType')
            x= if x? then pds[x] else null
            inst.setProduct(x)
            x= uu.getNVal(iitems[j], 'launchTime')
            x= uu.setISO8601(new Date(), x)
            inst.setLastBootTimestamp(x)
            x = gt(iitems[j],'placement')[0]
            x = uu.getNVal( x,'availabilityZone')
            inst.setProviderDataCenterId(x)
            x= uu.getNVal(iitems[j], 'privateIpAddress')
            inst.setPrivateIpAddresses( if uu.vstr(x) then [x] else [] )
            x= uu.getNVal(iitems[j], 'ipAddress')
            inst.setPublicIpAddresses( if uu.vstr(x) then [x] else [] )
            x = uu.getNVal(iitems[j], 'platform')
            x=ComZotoh.CloudAPI.Compute.Platform.valueOf(x)
            inst.setPlatform(x)
            # added for VPC stuff
            inst.setProviderSubnetId( uu.getNVal(iitems[j], 'subnetId') )
            inst.setProviderVlanId( uu.getNVal(iitems[j], 'vpcId') )
            out.push(inst)
        out

    on_get_console_out: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        b64=uu.b64()
        top= dom.getNode(data, '/GetConsoleOutputResponse')
        iid = dom.ffcn( top,'instanceId')
        ts = dom.ffcn( top,'timestamp')
        os = gt( top,'output')[0]
        if os? and uu.vstr(os.textContent)
            os = b64.decode(os.textContent) ? ''
            os = os.replace(/\x1b/mg, '\n').replace(/\r/mg, '').replace(/\n+/mg, '\n')
        else
            os = ''
        os

##SKIP_GEN_DOC##


#}

class Architecture #{
    ###
    Enums for CPU architectures</br>
        { I64, I32 }
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

Architecture.I64= new Architecture('x86_64')
Architecture.I32=new Architecture('i386')

Architecture.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ Architecture.I64, Architecture.I32 ]

Architecture.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'x86_64' then Architecture.I64
        when 'i386' then Architecture.I32
        else null

#}


class VolumeSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.VolumeSupport Interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    remove: (vid, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vid**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ [ 'VolumeId', vid ] ]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data, '/DeleteVolumeResponse', cbs)
        @awscall( 'DeleteVolume', p, h, cbs)

    create: (snapId, gbSize, dc, cbs) ->
        ###
        **returns**: Volume</br>
        **snapId**: string</br>
        **gbSize**: int</br>
        **dc**: string - datacenter.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(snapId)
            p.push(['SnapshotId', snapId])
        else
            if gbSize? and (not isNaN(gbSize)) then p.push(['Size', gbSize])
        if @aws.ute().vstr(dc) then p.push(['AvailabilityZone', dc])
        me=this
        h= (data) -> cbs?.success?( me.on_create(data))
        @awscall('CreateVolume', p, h, cbs)

    hasSupport: () -> true

    attach: (vid, vmId, device, cbs) ->
        ###
        Attach a Volume to a running Virtual-Machine.</br>
        **returns**: boolean - JSON-Object#result</br>
        **vid**: string</br>
        **vmId**: string</br>
        **device**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        p=[]
        if uu.vstr(vid) then p.push(['VolumeId', vid])
        if uu.vstr(vmId) then p.push(['InstanceId', vmId])
        if uu.vstr(device) then p.push(['Device', device])
        me=this
        h= (data) -> me.on_attach(data,cbs)
        @awscall( 'AttachVolume', p, h, cbs)

    detach: (vid, cbs) ->
        ###
        Detach a Volume from a Virtual-Machine.</br>
        **returns**: boolean - JSON-Object#result</br>
        **vid**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [[ 'VolumeId', vid ]]
        me=this
        h= (data) -> me.aws.cb_boolean(true,cbs)
        @awscall('DetachVolume', p, h, cbs)

    getProviderTermForVolume: (locale) -> 'Volume'

    getVolume: (vid, cbs) ->
        ###
        **returns**: Volume</br>
        **vid**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['VolumeId.1', vid]]
        me=this
        h= (data) -> cbs?.success?(me.aws.ute().getFirst(me.munch_xml(data)))
        @awscall( 'DescribeVolumes', p, h, cbs)

    listPossibleDeviceIds: (platform) ->
        ###
        **returns**: [ string , ... ]</br>
        **platform**: ComZotoh.CloudAPI.Compute.Platform</br>
        ###
        rc=[]
        if ComZotoh.CloudAPI.Compute.Platform.WINDOWS is platform
            rc= [ 'xvdf', 'xvdg', 'xvdh', 'xvdi', 'xvdj' ]
        else if ComZotoh.CloudAPI.Compute.Platform.LINUX is platform
            rc= [ 'dev/sdf', 'dev/sdg', 'dev/sdh', 'dev/sdi', 'dev/sdj' ]
        rc

    listVolumes: (cbs) ->
        ###
        **returns**: [ Volume, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?(me.munch_xml(data))
        @awscall( 'DescribeVolumes', [], h, cbs)

##SKIP_GEN_DOC##

    on_create: (data) ->
        [uu,fcn,gt, dom]=@aws.cfns()
        top= dom.getNode(data, '/CreateVolumeResponse')
        vid= dom.ffcn( top,'volumeId')
        v= new ComZotoh.CloudAPI.Compute.Volume(vid)
        @aws.cas(v)
        v.setProviderDataCenterId( dom.ffcn( top,'availabilityZone') )
        x= dom.ffcn( top,'size')
        v.setSizeInGigabytes(Number(x))
        v.setCurrentState( dom.ffcn( top,'status') )
        v.setProviderSnapshotId( dom.ffcn( top,'snapshotId') )
        x= uu.setISO8601(new Date(), dom.ffcn(top,'createTime') )
        v.setCreationTimestamp(x)
        v

    on_attach: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        top=dom.getNode(data, '/AttachVolumeResponse')
        vid = dom.ffcn(top,'volumeId')
        a= new ComZotoh.CloudAPI.Compute.Volume(vid)
        @aws.cas(a)
        a.setProviderVirtualMachineId( dom.ffcn(top,'instanceId'))
        a.setDeviceId( dom.ffcn(top,'device'))
        a.setCurrentState( dom.ffcn( top,'status'))
        x= uu.setISO8601(new Date(), dom.ffcn(top,'attachTime') )
        a.setAttachedTimestamp(x)
        cbs?.success?(a)

    munch_xml: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/DescribeVolumesResponse/volumeSet/item')
        lst=[]
        ii=items.length
        for i in [0...ii]
            x = dom.ffcn( items[i], 'status')
            if 'deleting' is x then continue
            id = dom.ffcn(items[i],'volumeId')
            v=new ComZotoh.CloudAPI.Compute.Volume(id)
            @aws.cas(v)
            v.setCurrentState(x)
            x = dom.ffcn(items[i],'size')
            v.setSizeInGigabytes(Number(x))
            v.setProviderSnapshotId( dom.ffcn(items[i], 'snapshotId') )
            v.setProviderDataCenterId( dom.ffcn(items[i], 'availabilityZone') )
            x=uu.setISO8601(new Date(), dom.ffcn( items[i], 'createTime'))
            v.setCreationTimestamp(x)
            e= gt( items[i], 'attachmentSet/item')[0]
            if e?
                v.setProviderVirtualMachineId( dom.ffcn( e, 'instanceId') )
                v.setDeviceId( dom.ffcn( e, 'device') )
                dom.ffcn( e, 'status')
                x= uu.setISO8601(new Date(), dom.ffcn( e, 'attachTime') )
                v.setAttachedTimestamp(x)
            lst.push(v)
        lst

##SKIP_GEN_DOC##

#}


class SnapshotSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.SnapshotSupport Interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    remove: (snapId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['SnapshotId', snapId] ]
        me=this
        h=(data) -> me.aws.on_boolean_reply(data,'/DeleteSnapshotResponse',cbs)
        @awscall( 'DeleteSnapshot', p, h, cbs)

    isPublic: (snapId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['SnapshotId', snapId],  ['Attribute', 'createVolumePermission' ] ]
        me=this
        h=(data) -> me.aws.cb_boolean( me.on_ispublic(data), cbs)
        @awscall('DescribeSnapshotAttribute', p,h,cbs)

    create: (vid, desc, cbs) ->
        ###
        **returns**: Snapshot</br>
        **vid**: string</br>
        **desc**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['VolumeId', vid],  ['Description', desc || 'new snapshot' ] ]
        me=this
        h=(data) -> me.on_newsnap(data,cbs)
        @awscall( 'CreateSnapshot', p,h,cbs)

    hasSupport: () -> true

    listShares: (snapId, cbs) ->
        ###
        **returns**: [ string , ... ]</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['SnapshotId', snapId],  ['Attribute', 'createVolumePermission' ] ]
        me=this
        h=(data) -> cbs?.success?( me.on_listshares(data))
        @awscall( 'DescribeSnapshotAttribute', p,h,cbs)

    getProviderTermForSnapshot: (locale) -> 'Snapshot'

    getSnapshot: (snapId, cbs) ->
        ###
        **returns**: Snapshot</br>
        **snapId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['SnapshotId.1', snapId] ]
        me=this
        h=(data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_xml(data)))
        @awscall('DescribeSnapshots', p,h,cbs)

    listSnapshots: (cbs) ->
        ###
        **returns**: [ Snapshot, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['Filter.1.Name', 'owner-id'],['Filter.1.Value.1', @aws.ctx().getAccountNumber() ]]
        me=this
        h=(data) -> cbs?.success?( me.munch_xml(data))
        @awscall('DescribeSnapshots', p,h,cbs)

    sharePublic: (snapId, affirmative, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **snapId**: string</br>
        **affirmative**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        opType = if affirmative then 'Add' else 'Remove'
        @share_xxx(snapId, opType, 'Group', 'all', cbs)

    shareSnapshot: (snapId, acct, affirmative, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **snapId**: string</br>
        **acct**: string</br>
        **affirmative**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        opType = if affirmative then 'Add' else 'Remove'
        @share_xxx(snapId, opType, 'UserId', acct, cbs)

    supportsSnapshotSharing: () -> true

    supportsSnapshotSharingWithPublic: () -> true

##SKIP_GEN_DOC##

    share_xxx: (snapId, actionStr, type, receiver, cbs) ->
        p=[]
        p.push [ 'SnapshotId', snapId ]
        p.push ['createVolumePermission.'+actionStr+'.1.'+type, receiver]
        me=this
        h=(data) -> me.aws.on_boolean_reply(data,'/ModifySnapshotAttributeResponse',cbs)
        @awscall( 'ModifySnapshotAttribute', p, h, cbs)

    on_listshares: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data,'/DescribeSnapshotAttributeResponse/createVolumePermission/item')
        ii=items.length
        lst=[]
        for i in [0...ii]
            e=gt( items[i], 'userId')
            r=if e? and e.length > 0 then fcn(e[0]) else ''
            if uu.vstr(r) then lst.push(r)
            e=gt( items[i], 'group')
            r=if e? and e.length > 0 then fcn(e[0]) else ''
            if uu.vstr(r) then lst.push(r)
        lst

    on_ispublic: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/DescribeSnapshotAttributeResponse/createVolumePermission/item')
        ii=items.length
        for i in [0...ii]
            g=gt( items[i], 'group')
            if g? and g.length > 0
                if 'all' is fcn( g[0] ) then return true
        false

    munch_xml: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/DescribeSnapshotsResponse/snapshotSet/item')
        lst=[]
        ii=items.length
        for i in [0...ii]
            id = dom.ffcn( items[i], 'snapshotId')
            a= new ComZotoh.CloudAPI.Compute.Snapshot(id)
            @aws.cas(a)
            a.setDescription( dom.ffcn(items[i], 'description') )
            a.setVolumeId( dom.ffcn( items[i], 'volumeId') )
            a.setCurrentState( dom.ffcn(items[i], 'status') )
            x=uu.setISO8601( new Date(), dom.ffcn( items[i], 'startTime'))
            a.setSnapshotTimestamp(x)
            a.setProgress( dom.ffcn(items[i], 'progress') )
            lst.push(a)
        lst

    on_newsnap: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        top= dom.getNode(data, '/CreateSnapshotResponse')
        sid= dom.ffcn(top,'snapshotId')
        a=new ComZotoh.CloudAPI.Compute.Snapshot(sid)
        @aws.cas(a)
        a.setVolumeId( dom.ffcn(top,'volumeId') )
        a.setCurrentState( dom.ffcn(top,'status') )
        x= uu.setISO8601( new Date(), dom.ffcn(top,'startTime') )
        a.setSnapshotTimestamp(x)
        a.setProgress( dom.ffcn(top,'progress') )
        a.setProviderOwnerId( dom.ffcn(top,'ownerId') )
        x= dom.ffcn(top,'volumeSize')
        a.setSizeInGb(Number(x))
        a.setDescription( dom.ffcn(top,'description') )
        cbs?.success?(a)

##SKIP_GEN_DOC##

#}


class MachineImageSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.MachineImageSupport Interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    remove: (imageId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **imageId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['ImageId', imageId]]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data,'/DeregisterImageResponse',cbs)
        @awscall('DeregisterImage', p, h, cbs)

    transfer: (cloud, imageId, cbs) ->
        ###
        NOT YET IMPLEMENTED.</br>
        **returns**: string - JSON-Object#result - new image-id</br>
        **cloud**: string - target cloud provider.</br>
        **imageId**: string</br>
        **cbs**: AjaxCBS</br>
        ###

    downloadImage: (imageId, output, cbs) ->
        ###
        NOT YET IMPLEMENTED.</br>
        **returns**: boolean - JSON-Object#result</br>
        **imageId**: string</br>
        **output**: stream | file</br>
        **cbs**: AjaxCBS</br>
        ###

    getMachineImage: (imageId, cbs) ->
        ###
        **returns**: MachineImage</br>
        **imageId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['ImageId.1', imageId]]
        me=this
        h= (data) -> cbs?.success?(me.aws.ute().getFirst( me.munch_xml(data)))
        @awscall( 'DescribeImages', p, h, cbs)

    getProviderTermForImage: (locale) -> 'AMI'

    hasPublicLibrary: () -> true

    imageVirtualMachine: (vmId, name, desc, safe, cbs) ->
        ###
        **returns**: MachineImage</br>
        **vmId**: string</br>
        **name**: string</br>
        **desc**: string</br>
        **safe**: boolean - true if imaging is done after vm is shutdowned</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['InstanceId', vmId] , ['Name', name] ]
        if @aws.ute().vstr(desc) then p.push(['Description', desc])
        if not safe then p.push(['NoReboot', true])
        me=this
        h=(data) -> me.on_image_vm(data,cbs)
        @awscall('CreateImage', p, h, cbs)

    imageVirtualMachineToStorage: (vmId, name, desc, safe, dirPath, cbs) ->
        ###
        NOT YET IMPLEMENTED.</br>
        **returns**: MachineImage</br>
        **vmId**: string</br>
        **name**: string</br>
        **desc**: string</br>
        **safe**: boolean - true if imaging is done after vm is shutdowned</br>
        **dirPath**: string - path to cloud storage, such as S3.</br>
        **cbs**: AjaxCBS</br>
        ###
        null

    isImageSharedWithPublic: (imageId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **imageId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs?
            cbs.success=(data)->
                ok=if data? then data.getTag('isPublic') else false
                cbs.success=old
                me.aws.cb_boolean(ok,cbs)
        @getMachineImage(imageId, cbs)

    hasSupport: () -> true

    listMachineImages: (cbs) ->
        ###
        **returns**: [ MachineImage, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['Filter.1.Name', 'owner-id'], ['Filter.1.Value.1', @aws.ctx().getAccountNumber() ] ]
        me=this
        h= (data) -> cbs?.success?( me.munch_xml(data))
        @awscall('DescribeImages', p, h, cbs)

    listMachineImagesOwnedBy: (acct, cbs) ->
        ###
        **returns**: [ MachineImage, ... ]</br>
        **acct**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        acct ?= ''
        p= [ ['Filter.1.Name', 'owner-id'], ['Filter.1.Value.1', acct.replace(/[^0-9]/g, '')] ]
        me=this
        h= (data) -> cbs?.success?( me.munch_xml(data))
        @awscall('DescribeImages', p, h, cbs)

    listShares: (imageId, cbs) ->
        ###
        **returns**: [ string , ... ]</br>
        **imageId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['ImageId', imageId], ['Attribute','launchPermission'] ]
        me=this
        h= (data) -> cbs?.success?( me.munch_perms(data))
        @awscall('DescribeImageAttribute', p, h, cbs)

    registerMachineImage: (imgPath, cbs) ->
        ###
        **returns**: Machine</br>
        **imgPath**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['ImageLocation', imgPath] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top= dom.getNode(data, '/RegisterImageResponse')
            iid=dom.ffcn(top,'imageId')
            a=new ComZotoh.CloudAPI.Compute.MachineImage(iid)
            me.aws.cas(a)
            cbs?.success?(a)
        @awscall('RegisterImage', p, h, cbs)

    searchMachineImages: (keyword, platform, arch, cbs) ->
        ###
        **returns**: [ MachineImage, ... ]</br>
        **keyword**: string</br>
        **platform**: ComZotoh.CloudAPI.Compute.Platform</br>
        **arch**: ComZotoh.CloudAPI.Compute.Architecture</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['ExecutableBy.1', 'all'] ]
        pos=1
        if ComZotoh.CloudAPI.Compute.Platform.WINDOWS is platform
            p.push( ['Filter.'+pos+'.Name', 'platform'] )
            p.push( ['Filter.'+pos+'.Value.1', 'windows' ] )
            ++pos
        if arch?
            p.push( ['Filter.'+pos+'.Name', 'architecture'] )
            p.push( ['Filter.'+pos+'.Value.1', arch.toString() ] )
            ++pos
        p.push( ['Filter.'+pos+'.Name', 'state'] )
        p.push( ['Filter.'+pos+'.Value.1', 'available' ] )
        ++pos

        keyword = (keyword || '').toLowerCase()
        me=this
        ff= (a,b,c,d,e) -> me.aws.ute().join('\n', a,b,c,d,e).toLowerCase().indexOf(keyword) >= 0
        h= (data) -> cbs?.success?( me.munch_xml(data, ff))
        @awscall( 'DescribeImages', p, h, cbs)

    sharePublic: (imageId, allow, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **imageId**: string</br>
        **allow**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        opType = if allow then 'Add' else 'Remove'
        @share_xxx(imageId, opType, 'Group', 'all', cbs)

    shareMachineImage: (imageId, acct, allow, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **imageId**: string</br>
        **acct**: string</br>
        **allow**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        opType = if allow then 'Add' else 'Remove'
        acct ?= ''
        @share_xxx(imageId, opType, 'UserId', acct.replace(/[^0-9]/g, ''), cbs)

    supportsCustomImages: () -> true

    supportsImageSharing: () -> true

    supportsImageSharingWithPublic: () -> true

##SKIP_GEN_DOC##

    share_xxx: (imageId, actionStr, type, receiver, cbs) ->
        p=[]
        p.push ['ImageId', imageId]
        p.push ['LaunchPermission.'+actionStr+'.1.'+type, receiver]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data,'/ModifyImageAttributeResponse',cbs)
        @awscall('ModifyImageAttribute', p, h, cbs)

    on_image_vm: (data,cbs) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        x= dom.ffcn(data, '/CreateImageResponse/imageId')
        a= new ComZotoh.CloudAPI.Compute.MachineImage(x)
        @aws.cas(x)
        cbs?.success?(a)

    munch_perms: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt( data, '/DescribeImageAttributeResponse/launchPermission/item')
        ii= items.length
        lst=[]
        for i in [0...ii]
            t= dom.ffcn( items[i] ,'userId')
            if uu.vstr(t) then lst.push(t)
            t= dom.ffcn( items[i] ,'group')
            if uu.vstr(t) then lst.push(t)
        lst

    munch_xml: (data, filter) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data, '/DescribeImagesResponse/imagesSet/item')
        lst=[]
        ii=items.length
        for i in [0...ii]
            iid = dom.ffcn(items[i],'imageId')
            desc = dom.ffcn( items[i],'description')
            loc = dom.ffcn(items[i],'imageLocation')
            state = dom.ffcn(items[i],'imageState')
            owner = dom.ffcn(items[i], 'imageOwnerId')
            isPublic = dom.ffcn(items[i],'isPublic')
            arch = dom.ffcn( items[i],'architecture')
            pf = uu.getNVal(items[i], 'platform')
            name = uu.getNVal(items[i], 'name')
            ok= if filter? then filter(iid, name, desc, loc, owner) else true
            if ok
                a=new ComZotoh.CloudAPI.Compute.MachineImage(iid)
                @aws.cas(a)
                a.setName(name)
                a.addTag('imageLocation', loc)
                a.setProviderOwnerId(owner)
                a.setDescription(desc)
                a.setArchitecture(ComZotoh.CloudAPI.Compute.Architecture.valueOf(arch))
                a.setPlatform(ComZotoh.CloudAPI.Compute.Platform.valueOf(pf))
                a.setCurrentState(state)
                a.addTag('isPublic', 'true' is isPublic)
                lst.push(a)
        lst

##SKIP_GEN_DOC##

#}

class LaunchConfiguration extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores config data when launching vms. ###

    constructor: (@cid) -> super()

    getProviderFirewallIds: () -> @fwIds

    setProviderFirewallIds: (ids) -> if ids? then @fwIds= ids

    getProviderImageId: () -> @amiId

    setProviderImageId: (id) -> @amiId = id ? ''

    getProviderLaunchConfigurationId: () -> @cid

    setProviderLaunchConfigurationId: (n) -> @cid = n ? ''

    getServerSizeId: () -> @serverSize

    setServerSizeId: (n) -> @serverSize = n ? ''

#}


class AutoScalingSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.AutoScalingSupport interface ###

    constructor: (scaler) ->
        ### internal ###
        super(scaler)

    createAutoScalingGroup: (name, cfgId, minVms, maxVms, coolDownSecs, dcs, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cfgId**: string</br>
        **minVms**: int</br>
        **maxVms**: int</br>
        **coolDownSecs**: int</br>
        **dcs**: [ string,...] - datacenters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['AutoScalingGroupName', name],['LaunchConfigurationName', cfgId ], ['MinSize', minVms], ['MaxSize', maxVms] ]
        zz=dcs?.length || 0
        for z in [0...zz]
            p.push ( [ 'AvailabilityZones.member.'+(z+1), dcs[z] ] )
        if coolDownSecs? and not isNaN(coolDownSecs)
            p.push ( ['DefaultCooldown', coolDownSecs] )
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h= (data) ->
            top=dom.getNode(data, '/CreateAutoScalingGroupResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall('CreateAutoScalingGroup', p, h, cbs)

    createLaunchConfiguration: (name, imageId, product, fwalls, monitoring, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **imageId**: string</br>
        **product**: VirtualMachineProduct</br>
        **fwals**: [string,...] - list of firewalls.</br>
        **monitoring**: boolean</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['LaunchConfigurationName', name] , ['ImageId', imageId] , [ 'InstanceType', product.getProductId() ]]
        monitoring = if monitoring is true then 'true' else 'false'
        p.push( ['InstanceMonitoring.Enabled', monitoring] )
        ii=fwalls?.length || 0
        for i in [0...ii]
            p.push ( [ 'SecurityGroups.member.'+(i+1), fwalls[i] ] )
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data, '/CreateLaunchConfigurationResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall( 'CreateLaunchConfiguration', p, h, cbs)

    deleteAutoScalingGroup: (name, forceDelete, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **forceDelete**: boolean - true, removes the intances in the group.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['AutoScalingGroupName', name]]
        if forceDelete then p.push(['ForceDelete', 'true'])
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data, '/DeleteAutoScalingGroupResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall('DeleteAutoScalingGroup', p, h, cbs)

    deleteLaunchConfiguration: (name, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['LaunchConfigurationName', name]]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top=dom.getNode(data, '/DeleteLaunchConfigurationResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall('DeleteLaunchConfiguration', p, h, cbs)

    getLaunchConfiguration: (name, cbs) ->
        ###
        **returns**: LaunchConfiguration</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ 'LaunchConfigurationNames.member.1', name]
        me=this
        h=(data) ->
            [rc, ntk] = me.munch_cfgns(data)
            cbs?.success?( me.aws.ute().getFirst(rc))
        @awscall( 'DescribeLaunchConfigurations', p, h, cbs)

    getScalingGroup: (name, cbs) ->
        ###
        **returns**: ScalingGroup</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ 'AutoScalingGroupNames.member.1', name]
        me=this
        h=(data) ->
            [rc, ntk] = me.munch_grps(data)
            cbs?.success?( me.aws.ute().getFirst(rc))
        @awscall('DescribeAutoScalingGroups', p, h, cbs)

    listScalingGroups: (cursor, cbs) ->
        ###
        **returns**: [ ScalingGroup, ... ] , cursor</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        p=[]
        if uu.vstr(cursor) then p.push(['NextToken', cursor])
        me=this
        h=(data) ->
            [rc, ntk] = me.munch_grps(data)
            cbs?.success?( rc, ntk)
        @awscall('DescribeAutoScalingGroups', p, h, cbs)

    listLaunchConfigurations: (cursor, cbs) ->
        ###
        **returns**: [ LaunchConfiguration, ... ] , cursor</br>
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        p=[]
        if uu.vstr(cursor) then p.push(['NextToken', cursor])
        me=this
        h=(data) ->
            [rc, ntk] = me.munch_cfgns(data)
            cbs?.success?( rc, ntk)
        @awscall('DescribeLaunchConfigurations', p, h, cbs)

    setDesiredCapacity: (name, capacity, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **capacity**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['AutoScalingGroupName', name] , ['DesiredCapacity', capacity] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data)->
            top=dom.getNode(data, '/SetDesiredCapacityResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall( 'SetDesiredCapacity', p, h, cbs)

    updateAutoScalingGroup: (name, cfgId, minVms, maxVms, coolDownSecs, dcs, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cfgId**: string</br>
        **minVms**: int</br>
        **maxVms**: int</br>
        **coolDownSecs**: int</br>
        **dcs**: [ string, ... ] - datacenters.</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['AutoScalingGroupName', name] ]
        [uu,fcn,gt,dom]=@aws.cfns()
        if cfgId? then p.push(['LaunchConfigurationName', cfgId])
        if minVms? and not isNaN(minVms) then p.push(['MinSize', minVms])
        if maxVms? and not isNaN(maxVms) then p.push(['MaxSize', maxVms])
        if coolDownSecs? and not isNaN(coolDownSecs) then p.push(['DefaultCooldown', coolDownSecs])
        zz= dcs?.length || 0
        for z in [0...zz]
            p.push( ['AvailabilityZones.member.'+(z+1),  dcs[z] ] )
        me=this
        h=(data) ->
            top=dom.getNode(data, '/UpdateAutoScalingGroupResponse')
            me.aws.cb_boolean( is_alive(top), cbs)
        @awscall('UpdateAutoScalingGroup', p,h, cbs)

##SKIP_GEN_DOC##

    munch_grps: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items= gt(data, '/DescribeAutoScalingGroupsResponse/DescribeAutoScalingGroupsResult/AutoScalingGroups/member')
        ntk= dom.ffcn(data, '/DescribeAutoScalingGroupsResponse/DescribeAutoScalingGroupsResult/NextToken')
        if uu.vstr(ntk) then uu.debug('DescribeAutoScalingGroupsResponse: more to come, cursor=' + ntk)
        ii=items.length
        rc=[]
        for i in [0...ii]
            name= dom.ffcn(items[i], 'AutoScalingGroupName')
            a= new ComZotoh.CloudAPI.Compute.ScalingGroup(name)
            @aws.cas(a)
            x= uu.setISO8601(new Date(), dom.ffcn(items[i], 'CreatedTime') )
            a.setCreationTimestamp(x)
            a.setProviderLaunchConfigurationId( dom.ffcn(items[i], 'LaunchConfigurationName') )
            x= dom.ffcn(items[i], 'DesiredCapacity')
            a.setTargetCapacity(Number(x))
            a.setCurrentState( dom.ffcn( items[i], 'Status'))
            x= dom.ffcn(items[i], 'MinSize')
            a.setMinServers(Number(x))
            x= dom.ffcn(items[i], 'MaxSize')
            a.setMaxServers(Number(x))
            x= dom.ffcn(items[i], 'DefaultCooldown')
            a.setCooldown(Number(x))
            a.addTag('AutoScalingGroupARN', dom.ffcn(items[i], 'AutoScalingGroupARN') )
            zs= gt(items[i], 'AvailabilityZones/member')
            nn=zs?.length || 0
            zones=[]
            for n in [0...nn]
                zones.push( fcn(zs[n]) )
            a.setProviderDataCenterIds(zones)
            ns= gt(items[i], 'Instances/member')
            ssids=[]
            nn= ns?.length || 0
            for n in [0...nn]
                ssids.push( dom.ffcn(ns[n], 'InstanceId'))
            a.setProviderServerIds(ssids)
            rc.push(a)
        [ rc, ntk ]

    munch_cfgns: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items= gt(data, '/DescribeLaunchConfigurationsResponse/DescribeLaunchConfigurationsResult/LaunchConfigurations/member')
        ntk= dom.ffcn(data, '/DescribeLaunchConfigurationsResponse/DescribeLaunchConfigurationsResult/NextToken')
        if uu.vstr(ntk) then uu.debug('DescribeLaunchConfigurationsResponse: more to come, cursor=' + ntk)
        ii=items.length
        rc=[]
        for i in [0...ii]
            name= dom.ffcn(items[i], 'LaunchConfigurationName')
            a=new ComZotoh.CloudAPI.Compute.LaunchConfiguration(name)
            @aws.cas(a)
            a.setServerSizeId( dom.ffcn(items[i], 'InstanceType') )
            a.setProviderImageId( dom.ffcn(items[i], 'ImageId') )
            x = uu.setISO8601(new Date(), dom.ffcn(items[i], 'CreatedTime') )
            a.setCreationTimestamp(x)
            a.addTag('LaunchConfigurationARN', dom.ffcn(items[i], 'LaunchConfigurationARN') )
            gps=gt(items[i], 'SecurityGroups/member')
            groups=[]
            gg=gps?.length || 0
            for g in [0...gg]
                groups.push( fcn(gps[g]) )
            a.setProviderFirewallIds(groups)
            rc.push(a)
        [ rc, ntk ]


##SKIP_GEN_DOC##

#}

class VirtualMachine extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores vm information ###

    constructor: (@vmId) ->
        super()
        @pubIP=[]
        @prvIP=[]

    equals: (other) -> @getProviderVirtualMachineId() is other?.getProviderVirtualMachineId()

    toString: () -> @vmId

    getPlatform: () -> @platform

    setPlatform: (platform) -> if platform? then @platform=platform

    getProviderDataCenterId: () -> @dc

    setProviderDataCenterId: (dc) -> @dc = dc ? ''

    getProduct: () -> @product

    getArchitecture: () -> @arch

    setArchitecture: (arch) -> if arch? then @arch=arch

    getProviderMachineImageId: () -> @imgId

    setProviderMachineImageId: (imgId) -> @imgId = imgId ? ''

    getProviderVirtualMachineId: () -> @vmId

    setRootPassword: (pwd) -> @rootPwd = pwd ? ''

    getRootPassword: () -> @rootPwd

    isClonable: () -> true

    setClonable: (b) ->

    isImagable: () -> true

    setImagable: (imgable) ->

    getLastBootTimestamp: () -> @lastBootTS

    setLastBootTimestamp: (ts) -> if ts? then @lastBootTS=ts

    getLastPauseTimestamp: () -> @lastPauseTS

    setLastPauseTimestamp: (ts) -> if ts? then @lastPauseTS=ts

    isPausable: () -> true

    setPausable: (b) ->

    isPersistent: () -> true

    setPersistent: (b) ->

    getPrivateDnsAddress: () -> @prvDns

    setPrivateDnsAddress: (dns) -> @prvDns=dns ? ''

    getPrivateIpAddresses: () -> @prvIP

    setPrivateIpAddresses: (ip) -> if ip? then @prvIP= ip

    getProviderAssignedIpAddressId: () ->

    setProviderAssignedIpAddressId: (ip) ->

    setProviderVirtualMachineId: (id) -> @vmId= id ? ''

    getPublicDnsAddress: () -> @pubDns

    setPublicDnsAddress: (dns) -> @pubDns=dns ? ''

    getPublicIpAddresses: () -> @pubIP

    setPublicIpAddresses: (ip) -> if ip? then @pubIP = ip

    isRebootable: () -> true

    setRebootable: (b) ->

    getRootUser: () -> @root

    setRootUser: (user) -> @root = user ? ''

    getTerminationTimestamp: () -> @termTS

    setTerminationTimestamp: (ts) -> if ts? then @termTS=ts

    setProduct: (p) -> if p? then @product= p

    setProviderSubnetId: (subnet) -> @subnet= subnet ? ''

    getProviderSubnetId: () -> @subnet

    setProviderVlanId: (id) ->

    getProviderVlanId: () ->

#}

class Snapshot extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Snapshot information ###

    constructor: (@snapId) -> super()

    equals: (other) -> @snapId is other?.getProviderSnapshotId()

    toString: () -> @getProviderSnapshotId()

    getProviderSnapshotId: () -> @snapId

    getSnapshotTimestamp: () -> @tstamp

    getVolumeId: () -> @volId

    setProviderSnapshotId: (id) -> @snapId= id ? ''

    setSnapshotTimestamp: (ts) -> if ts? then @tstamp=ts

    setVolumeId: (vid) -> @volId = vid ? ''

    getProgress: () -> @progress

    setProgress: (p) -> @progress = p ? ''

    getSizeInGb: () -> @gbSize

    setSizeInGb: (gb) -> if gb? and not isNaN(gb) then @gbSize=gb

#}

class VirtualMachineProduct extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores VM product information ###

    constructor: (@prodId, @cpus, @ram, @gbSize, ds) ->
        ### internal ###
        super(@prodId)
        @setDescription(ds)

    equals: (other) -> @getProductId() is other?.getProductId()

    toString: () -> @getProductId()

    getProductId: () -> @prodId

    getCpuCount: () -> @cpus

    setCpuCount: (c) -> if c? and not isNaN(c) then @cpus= c

    getDiskSizeInGb: () -> @gbSize

    setDiskSizeInGb: (sz) -> if sz? and not isNaN(sz) then @gbSize=sz

    setProductId: (prod) -> @prodId = prod ? ''

    getRamInMb: () -> @ram

    setRamInMb: (ram) -> if ram? and not isNaN(ram) then @ram= ram

#}

class MetricType  #{
    ###
    Enums of metric types</br>
        { CPU, NETIO_OUT, NETIO_IN, DISK_WRITE_BYTES, DISK_WRITE_OPS, DISK_READ_BYTES, DISK_READ_OPS }</br>
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

MetricType.CPU=new MetricType('cpu-utilization')
MetricType.NETIO_OUT=new MetricType('netio-bytes-out')
MetricType.NETIO_IN=new MetricType('netio-bytes-in')
MetricType.DISK_WRITE_BYTES=new MetricType('disk-write-bytes')
MetricType.DISK_WRITE_OPS=new MetricType('disk-write-ops')
MetricType.DISK_READ_BYTES=new MetricType('disk-read-bytes')
MetricType.DISK_READ_OPS=new MetricType('disk-read-ops')

#}

class Metric  #{
    ### POJO stores Metric information ###
    constructor: (@name) ->
        @members=[]

    getProviderGroupId: () -> @group

    setProviderGroupId: (n) -> @group = n ? ''

    addMember: (m) -> if m? then @members.push(m)

    getMembers: () -> @members

    getName: () -> @name

    setName: (n) -> @name = n ? ''

#}

class MetricsSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Compute.MetricsSupport interface ###

    constructor: (cwm) ->
        ### internal ###
        super(cwm)

    listMetrics: (cursor,cbs) ->
        ###
        **cursor**: string or null</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        p=[]
        if @aws.ute().vstr(cursor) then p.push(['NextToken', cursor])
        h=(data)->
            [rc,ntk]= me.munch_xml(data)
            cbs?.success?(rc,ntk)
        @awscall('ListMetrics', p, h, cbs)

    getVMStatistics: (vmId, metric, fromTime, toTime, cbs) ->
        ###
        **returns**: MetricStats</br>
        **vmId**: string</br>
        **fromTime**: date</br>
        **toTime**: date</br>
        **metric**: metricType</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['Dimensions.member.1.Name', 'InstanceId'],['Dimensions.member.1.Value', vmId]]
        capi=ComZotoh.CloudAPI.Compute
        p.push(['Namespace', 'AWS/EC2'])
        start=@aws.ute().toISO8601String(fromTime,5)
        end=@aws.ute().toISO8601String(toTime,5)
        p.push(['StartTime', start], ['EndTime', end])
        p.push(['Period', 60])
        p.push(['Statistics.member.1', 'Average'])
        p.push(['Statistics.member.2', 'Sum'])
        p.push(['Statistics.member.3', 'SampleCount'])
        p.push(['Statistics.member.4', 'Maximum'])
        p.push(['Statistics.member.5', 'Minimum'])
        unit=''
        m=''
        switch metric
            when capi.MetricType.DISK_WRITE_BYTES
                m='DiskWriteBytes'
                unit='Bytes'
            when capi.MetricType.DISK_WRITE_OPS
                m='DiskWriteOps'
                unit='Count'
            when capi.MetricType.DISK_READ_BYTES
                m='DiskReadBytes'
                unit='Bytes'
            when capi.MetricType.DISK_READ_OPS
                m='DiskReadOps'
                unit='Count'
            when capi.MetricType.NETIO_OUT
                m='NetworkOut'
                unit='Bytes'
            when capi.MetricType.NETIO_IN
                m='NetworkIn'
                unit='Bytes'
            when capi.MetricType.CPU
                m='CPUUtilization'
                unit='Percent'
        p.push(['MetricName', m])
        p.push(['Unit', unit])
        me=this
        h= (data) -> cbs?.success?(me.munch_stats(data,metric))
        @awscall('GetMetricStatistics', p, h, cbs)

##SKIP_GEN_DOC##

    munch_stats: (data, type) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items=gt(data,'/GetMetricStatisticsResponse/GetMetricStatisticsResult/Datapoints/member')
        ii=items.length
        rc=[]
        for i in [0...ii]
            a= new ComZotoh.CloudAPI.Compute.MetricStats(type)
            x=dom.ffcn(items[i], 'Timestamp')
            a.setTimestamp(uu.setISO8601(new Date(), x))
            a.setUnit(dom.ffcn(items[i], 'Unit'))
            a.setSampleCount(dom.ffcn(items[i], 'SampleCount'))
            a.setMin(dom.ffcn(items[i], 'Minimum'))
            a.setMax(dom.ffcn(items[i], 'Maximum'))
            a.setTotalSum(dom.ffcn(items[i], 'Sum'))
            a.setAverage(dom.ffcn(items[i], 'Average'))
            rc.push(a)
        rc

    munch_xml: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items=gt(data, '/ListMetricsResponse/ListMetricsResult/Metrics/member')
        ntk=dom.ffcn(data, '/ListMetricsResponse/ListMetricsResult/NextToken')
        ii=items.length
        rc=[]
        for i in [0...ii]
            name=dom.ffcn(items[i], 'MetricName')
            a= new ComZotoh.CloudAPI.Compute.Metric(name)
            a.setProviderGroupId( dom.ffcn(items[i], 'Namespace'))
            ms=gt(items[i], 'Dimensions/member')
            nn=ms?.length || 0
            for n in [0...nn]
                a.addMember({ name: dom.ffcn(ms[n], 'Name'), value: dom.ffcn(ms[n], 'Value') })
            rc.push(a)
        [rc, ntk]

##SKIP_GEN_DOC##

#}


class ComputeServices #{
    ### ComZotoh.CloudAPI.Compute.ComputeServices interface ###

    constructor: (@ec2, @scaler, @cwm) ->
        ### internal ###
        @autos= new ComZotoh.CloudAPI.Compute.AutoScalingSupport(@scaler)
        @vms= new ComZotoh.CloudAPI.Compute.VirtualMachineSupport(@ec2)
        @ss= new ComZotoh.CloudAPI.Compute.SnapshotSupport(@ec2)
        @vs= new ComZotoh.CloudAPI.Compute.VolumeSupport(@ec2)
        @mis= new ComZotoh.CloudAPI.Compute.MachineImageSupport(@ec2)
        @sts= new ComZotoh.CloudAPI.Compute.MetricsSupport(@cwm)

    getMetricsSupport: () -> @sts

    getAutoScalingSupport: () -> @autos

    getImageSupport: () -> @mis

    getSnapshotSupport: () -> @ss

    getVirtualMachineSupport: () -> @vms

    getVolumeSupport: () -> @vs

    hasAutoScalingSupport: () -> is_alive(@autos)

    hasImageSupport: () -> is_alive(@mis)

    hasSnapshotSupport: () -> is_alive(@ss)

    hasVirtualMachineSupport: () -> is_alive(@vms)

    hasVolumeSupport: () -> is_alive(@vs)

    hasMetricsSupport: () -> is_alive(@sts)

#}

class MetricStats #{
    ### POJO stores Metric Statistics ###
    constructor: (@metric) ->

    setAverage: (n) -> if is_num(n) then @average=n
    getAverage: () -> @average

    setMax: (n) -> if is_num(n) then @max_val=n
    getMax: () -> @max_val

    setMin: (n) -> if is_num(n) then @min_val=n
    getMin: () -> @min_val

    setSampleCount: (n) -> if is_num(n) then @samples=n
    getSampleCount: () -> @samples

    setTotalSum: (n) -> if is_num(n) then @total=n
    getTotalSum: () -> @total

    setUnit: (s) -> @unit= s ? ''
    getUnit: () -> @unit

    setTimestamp: (ts) -> if ts? then @tstamp=ts
    getTimestamp: () -> @tstamp

    setMetricType: (m) -> if m? then @metric=m
    getMetricType: () -> @metric

#}

class Platform #{
    ###
    Enums for Platform types</br>
        { WINDOWS, LINUX }</br>
    ###

    constructor: (@idstr, @linux) ->
        ### private ###

    toString: () -> @idstr
    isLinux: () -> @linux
    isWindows: () -> not @linux

Platform.WINDOWS=new Platform('windows', false)
Platform.LINUX=new Platform('linux', true)


Platform.values=() ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ Platform.WINDOWS, Platform.LINUX ]

Platform.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'windows' then Platform.WINDOWS
        when 'linux' then Platform.LINUX
        else null

#}


class MachineImageType #{
    ###
    Enums for image types</br>
        { STORAGE, VOLUME }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

MachineImageType.STORAGE= new MachineImageType('storage')
MachineImageType.VOLUME= new MachineImageType('volume')

MachineImageType.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ MachineImageType.STORAGE, MachineImageType.VOLUME ]

MachineImageType.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toLowerCase() else ''
    switch s
        when 'storage' then MachineImageType.STORAGE
        when 'volume' then MachineImageType.VOLUME
        else null

#}




`

function iniz_vm_products() {
var z= ComZotoh.CloudAPI.Compute.VirtualMachineProduct;
var p=[
new z('m1.small', 1, 1.7, 160, 'Small/32bit/1 virtual core'),
new z('m1.large', 4, 7.5, 850, 'Large/64bit/2 virtual cores'),
new z('m1.xlarge', 8, 15, 1690, 'Extra Large/64bit/4 virtual cores'),
new z('t1.micro', 2, 0.613, 0, 'Micro/32bit & 64bit'),
new z('c1.medium', 5, 1.7, 350, 'High-CPU Medium/32bit/2 virtual cores'),
new z('c1.xlarge', 20, 7, 1690, 'High-CPU Extra Large/64bit/8 virtual cores'),
new z('m2.xlarge', 6.5, 17.1, 420, 'High-Memory Extra Large/64bit/2 virtual cores'),
new z('m2.2xlarge', 13, 34.2, 850, 'High-Memory Double Extra Large/64bit/4 virtual cores'),
new z('m2.4xlarge', 26, 68.4, 1690, 'High-Memory Quadruple Extra Large/64bit/8 virtual cores'),
new z('cc1.4xlarge', 33.5, 23, 1690, 'Cluster Compute Quadruple Extra Large/64bit/2 x Intel Xeon X5570, quad-core "Nehalem" architecture'),
new z('cc2.8xlarge', 88, 60.5, 3370, 'Cluster Compute Eight Extra Large/64bit/2 x Intel Xeon CPU with 8 cores'),
new z('cg1.4xlarge', 33.5, 22, 1690, 'Cluster GPU Quadruple Extra Large/64bit/2 x Intel Xeon X5570, quad-core "Nehalem" architecture, plus 2 NVIDIA Tesla M2050 "Fermi" GPUs') ];

    ComZotoh.CloudAPI.Compute.VirtualMachineProduct.entrySet=function() {
        var lst={};
        for (var i=0; i < p.length; ++i) {
            lst[ p[i].getProductId() ] = p[i];
        }
        return lst; 
    }
    ComZotoh.CloudAPI.Compute.VirtualMachineProduct.values=function() {
        var lst=[];
        for (var i=0; i < p.length; ++i) {
            lst[i]=p[i];
        }
        return lst;
    }
}

if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Compute)) { ComZotoh.CloudAPI.Compute={}; }
ComZotoh.CloudAPI.Compute.Volume=Volume;
ComZotoh.CloudAPI.Compute.MachineImage=MachineImage;
ComZotoh.CloudAPI.Compute.ScalingGroup=ScalingGroup;
ComZotoh.CloudAPI.Compute.VirtualMachineSupport=VirtualMachineSupport;
ComZotoh.CloudAPI.Compute.Architecture=Architecture;
ComZotoh.CloudAPI.Compute.VolumeSupport=VolumeSupport;
ComZotoh.CloudAPI.Compute.SnapshotSupport=SnapshotSupport;
ComZotoh.CloudAPI.Compute.MachineImageSupport=MachineImageSupport;
ComZotoh.CloudAPI.Compute.LaunchConfiguration=LaunchConfiguration;
ComZotoh.CloudAPI.Compute.AutoScalingSupport=AutoScalingSupport;
ComZotoh.CloudAPI.Compute.VirtualMachine=VirtualMachine;
ComZotoh.CloudAPI.Compute.Snapshot=Snapshot;
ComZotoh.CloudAPI.Compute.VirtualMachineProduct=VirtualMachineProduct;
ComZotoh.CloudAPI.Compute.ComputeServices=ComputeServices;
ComZotoh.CloudAPI.Compute.MetricStats=MetricStats;
ComZotoh.CloudAPI.Compute.MetricsSupport=MetricsSupport;
ComZotoh.CloudAPI.Compute.MetricType=MetricType;
ComZotoh.CloudAPI.Compute.Metric=Metric;
ComZotoh.CloudAPI.Compute.Platform=Platform;
ComZotoh.CloudAPI.Compute.MachineImageType=MachineImageType;
iniz_vm_products();


})(|GLOBAL|);



`


