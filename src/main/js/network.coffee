###
file: comzotoh.cloudapi.network.coffee
###

`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`

class NetworkInterface extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores NetworkInterface information ###

    constructor: (@netId) -> super()

    equals: (other) -> @getProviderNetworkInterfaceId() is other?.getProviderNetworkInterfaceId()

    getProviderNetworkInterfaceId: () -> @netId

    setProviderNetworkInterfaceId: (s) -> @netId = s ? ''

    setIpAddress: (s) -> @addr = s ? ''

    getIpAddress: () -> @addr

    setNetmask: (s) -> @netmask = s ? ''

    getNetmask: () -> @netmask

    setProviderVirtualMachineId: (id) -> @vmId = id ? ''

    getProviderVirtualMachineId: () -> @vmId

    setProviderVlanId: (s) -> @vlanId = s ? ''

    getProviderVlanId: () -> @vlanId


#}

class VLANSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Network.VLANSupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    hasSupport: () -> true

    allowsNewVlanCreation: () -> true

    allowsNewSubnetCreation: () -> true

    createSubnet: (vlanId, cidr, datacenter, params, cbs) ->
        ###
        Create a subnet in the given virtual network.</br>
        **returns**: Subnet</br>
        **vlanId**: string</br>
        **cidr**: string</br>
        **datacenter**: string</br>
        **params**: object - optional params</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ [ 'CidrBlock', cidr] , ['VpcId', vlanId] ]
        if @aws.ute().vstr(datacenter) then p.push( [ 'AvailabilityZone', datacenter ] )
        me=this
        h=(data) -> me.on_new_snet(data,cbs)
        @awscall('CreateSubnet', p, h, cbs)

    createVlan: (cidr, params, cbs) ->
        ###
        Create a new virtual network.</br>
        **returns**: VLAN</br>
        **cidr**: string</br>
        **type**: string</br>
        **params**: object - optional params</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ [ 'CidrBlock', cidr] ]
        if @aws.ute().vstr(params?.type) then p.push( [ 'instanceTenancy', params.type ] )
        me=this
        h=(data) -> me.on_new_vlan(data,cbs)
        @awscall('CreateVpc', p, h, cbs)

    getMaxVlanCount: () -> 1

    getProviderTermForNetworkInterface: (locale) -> 'NetworkInterface'

    getProviderTermForSubnet: (locale) -> 'Subnet'

    getProviderTermForVlan: (locale) -> 'VPC'

    getSubnet: (subnetId, cbs) ->
        ###
        **returns**: Subnet</br>
        **subnetId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['SubnetId.1', subnetId] ]
        me=this
        h=(data)-> cbs?.success?( me.aws.ute().getFirst( me.munch_subnets(data) ) )
        @awscall('DescribeSubnets', p, h, cbs)

    getVlan: (vlanId, cbs) ->
        ###
        **returns**: VLAN</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['VpcId.1',vlanId ]]
        me=this
        h=(data)-> cbs?.success?(me.aws.ute().getFirst( me.munch_vpcs(data) ) )
        @awscall('DescribeVpcs', p, h, cbs)

    isSubnetDataCenterConstrained: () -> false

    isVlanDataCenterConstrained: () -> false

    listNetworkInterfaces: (cbs) ->
        ###
        **returns**: [ NetworkInterface, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        me=this
        h=(data)-> cbs?.success?( me.munch_netwifs(data))
        @awscall( 'DescribeNetworkInterfaces', p, h, cbs)

    listSubnets: (vlanId, cbs) ->
        ###
        **returns**: [ Subnet, ... ]</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        if @aws.ute().vstr(vlanId) then p.push( ['Filter.1.Name', 'vpc-id'], ['Filter.1.Value.1', vlanId ] )
        me=this
        h=(data)-> cbs?.success?( me.munch_subnets(data) )
        @awscall('DescribeSubnets', p, h, cbs)

    listVlans: (cbs) ->
        ###
        **returns**: [ VLAN , ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h=(data)-> cbs?.success?(me.munch_vpcs(data))
        @awscall('DescribeVpcs', [], h, cbs)

    removeSubnet: (subnetId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **subnetId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['SubnetId', subnetId]]
        me=this
        h=(data)-> me.aws.on_boolean_reply(data, '/DeleteSubnetResponse', cbs)
        @awscall('DeleteSubnet', p, h, cbs)

    removeVlan: (vlanId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['VpcId', vlanId]]
        me=this
        h=(data)-> me.aws.on_boolean_reply(data, '/DeleteVpcResponse', cbs)
        @awscall('DeleteVpc', p, h, cbs)

##SKIP_GEN_DOC##

    munch_netwifs: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data,'/DescribeNetworkInterfacesResponse/networkInterfaceSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            a= new ComZotoh.CloudAPI.Network.NetworkInterface()
            @aws.cas(a)
            a.setProviderNetworkInterfaceId( dom.ffcn(items[i],'networkInterfaceId'))
            a.addTag('subnetId', dom.ffcn(items[i],'subnetId') )
            a.setProviderVlanId( dom.ffcn( items[i],'vpcId') )
            a.addTag('availabilityZone', dom.ffcn( items[i],'availabilityZone'))
            a.setDescription( dom.ffcn( items[i],'description'))
            a.setProviderOwnerId( dom.ffcn( items[i],'ownerId'))
            a.addTag('requesterManaged', dom.ffcn( items[i],'requesterManaged'))
            a.setCurrentState( dom.ffcn( items[i],'status'))
            a.addTag('macAddress', dom.ffcn( items[i],'macAddress'))
            a.setIpAddress( dom.ffcn(items[i],'privateIpAddress'))
            a.addTag('privateDnsName', dom.ffcn( items[i],'privateDnsName') )
            a.addTag('sourceDestCheck', dom.ffcn( items[i],'sourceDestCheck'))
            grps=gt(items[i],'groupSet/item')
            nn=grps?.length || 0
            x=[]
            for n in [0...nn]
                x.push({ groupName: dom.ffcn( grps[n], 'groupName' ), groupId: dom.ffcn( grps[n], 'groupId' ) })
            a.addTag('groupSet', x)
            att=gt(items[i],'attachment')[0]
            if att?
                dom.ffcn(att, 'attachmentId' )
                a.setProviderVirtualMachineId( dom.ffcn(att, 'instanceId' ))
                a.addTag('instanceOwnerId', dom.ffcn(att, 'instanceOwnerId' ) )
                dom.ffcn(att, 'deviceIndex' )
                dom.ffcn(att, 'status' )
                dom.ffcn(att, 'attachTime' )
                dom.ffcn(att, 'deleteOnTermination' )
            rc.push(a)
        rc

    on_new_snet: (data,cbs) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        item=gt(data, '/CreateSubnetResponse/subnet')[0]
        id=dom.ffcn(item, 'subnetId' )
        a= new ComZotoh.CloudAPI.Network.Subnet(id)
        @aws.cas(a)
        a.setCurrentState( dom.ffcn( item, 'state' ) )
        a.setProviderVlanId( dom.ffcn(item, 'vpcId' ) )
        a.setCidr( dom.ffcn(item, 'cidrBlock' ) )
        a.setProviderDataCenterId( dom.ffcn(item, 'availabilityZone' ) )
        x= dom.ffcn(item, 'availableIpAddressCount' )
        a.setAvailableIpAddresses(Number(x))
        cbs?.success?(a)

    on_new_vlan: (data,cbs) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        item=gt(data, '/CreateVpcResponse/vpc')[0]
        id=dom.ffcn(item, 'vpcId' )
        a= new ComZotoh.CloudAPI.Network.VLAN(id)
        @aws.cas(a)
        a.addTag('dhcpOptionsId', dom.ffcn( item, 'dhcpOptionsId' ) )
        a.setCurrentState( dom.ffcn(item, 'state' ) )
        a.setCidr( dom.ffcn(item, 'cidrBlock' ) )
        cbs?.success?(a)

    munch_subnets: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items=gt(data, '/DescribeSubnetsResponse/subnetSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            sub=dom.ffcn(items[i], 'subnetId' )
            a= new ComZotoh.CloudAPI.Network.Subnet(sub)
            @aws.cas(a)
            a.setCidr( dom.ffcn(items[i], 'cidrBlock' ) )
            a.setProviderVlanId( dom.ffcn(items[i], 'vpcId' ) )
            a.setCurrentState( dom.ffcn(items[i], 'state' ) )
            x=dom.ffcn(items[i], 'availableIpAddressCount' )
            a.setAvailableIpAddresses(Number(x))
            a.setProviderDataCenterId( dom.ffcn(items[i], 'availabilityZone' ) )
            rc.push(a)
        rc

    munch_vpcs: (data) ->
        [uu,fcn,gt,dom]= @aws.cfns()
        items=gt(data, '/DescribeVpcsResponse/vpcSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            id= dom.ffcn(items[i], 'vpcId')
            a= new ComZotoh.CloudAPI.Network.VLAN(id)
            @aws.cas(a)
            a.setCurrentState(dom.ffcn(items[i], 'state'))
            a.setCidr( dom.ffcn(items[i], 'cidrBlock') )
            a.addTag('dhcpOptionsId', dom.ffcn(items[i], 'dhcpOptionsId') )
            a.addTag('instanceTenancy', dom.ffcn(items[i], 'instanceTenancy') )
            rc.push(a)
        rc

##SKIP_GEN_DOC##

#}


class FirewallSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Network.FirewallSupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    list: (cbs) ->
        ###
        **returns**: [Firewall, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_xml(data))
        @awscall( 'DescribeSecurityGroups', [], h, cbs)

    delete: (name, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['GroupName', name]]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data,'/DeleteSecurityGroupResponse',cbs)
        @awscall('DeleteSecurityGroup', p , h, cbs)

    create: (name, desc, cbs) ->
        ###
        **returns**: Firewall</br>
        **name**: string</br>
        **desc**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        @createInVLAN(name,desc,'',cbs)

    authorize: (name, cidr, protocol, fromPort, toPort, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cidr**: string</br>
        **formPort**: int</br>
        **toPort**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['GroupName', name], ['IpProtocol', protocol.toString()], ['FromPort', fromPort], ['ToPort', toPort], ['CidrIp', cidr]]
        @call_xxx('AuthorizeSecurityGroupIngress', p, cbs)

    createInVLAN: (name, desc, vlanId, cbs) ->
        ###
        **returns**: Firewall</br>
        **name**: string</br>
        **desc**: string</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['GroupName', name], ['GroupDescription', desc ]]
        if @aws.ute().vstr(vlanId) then p.push(['VpcId', vlanId])
        me=this
        h= (data) -> me.on_create(data,name,desc,cbs)
        @awscall( 'CreateSecurityGroup', p, h, cbs)

    getFirewall: (name, cbs) ->
        ###
        **returns**: Firewall</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['GroupName', name]]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst(me.munch_xml(data)))
        @awscall('DescribeSecurityGroups', p, h, cbs)

    getProviderTermForFirewall: (locale) -> 'Security Group'

    getRules: (name, cbs) ->
        ###
        **returns**: [FirewallRule, ... ]</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        if cbs?
            cbs.success= (fw) -> old?( if fw? then fw.getRules() else [] )
        @getFirewall(name,cbs)

    revoke: (name, cidr, protocol, fromPort, toPort, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cidr**: string</br>
        **protocol**: ComZotoh.CloudAPI.Network.Protocol</br>
        **fromPort**: int</br>
        **toPort**: int</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['GroupName', name], ['IpProtocol', protocol.toString() ], ['FromPort', fromPort], ['ToPort', toPort], ['CidrIp', cidr]]
        @call_xxx('RevokeSecurityGroupIngress', p, cbs)

    allowAccess: (name, sourceGroupName, userId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **sourceGroupName**: string</br>
        **userId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p = [ ['SourceSecurityGroupName', sourceGroupName], ['SourceSecurityGroupOwnerId', userId], ['GroupName', name]]
        @call_xxx('AuthorizeSecurityGroupIngress', p, cbs)

    revokeAccess: (name, sourceGroupName, userId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **sourceGroupName**: string</br>
        **userId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['SourceSecurityGroupOwnerId', userId], ['GroupName', name], ['SourceSecurityGroupName', sourceGroupName]]
        @call_xxx('RevokeSecurityGroupIngress', p, cbs)

##SKIP_GEN_DOC##

    call_xxx: (opStr, p,cbs) ->
        xpath= '/'+opStr+'Response'
        me=this
        h= (data) -> me.aws.on_boolean_reply(data, xpath,cbs)
        @awscall( opStr, p, h, cbs)

    on_create: (data, name, desc, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        top= dom.getNode(data, '/CreateSecurityGroupResponse')
        a=new ComZotoh.CloudAPI.Network.Firewall(name,desc)
        @aws.cas(a)
        a.setProviderFirewallId( dom.ffcn(top, 'groupId') )
        cbs?.success?(a)

    munch_xml: (data) ->
        [uu,fcn,gt, dom]=@aws.cfns()
        items = gt(data, '/DescribeSecurityGroupsResponse/securityGroupInfo/item')
        ii = items.length
        lst= []
        for i in [0...ii]
            fw=new ComZotoh.CloudAPI.Network.Firewall( dom.ffcn(items[i],'groupName') )
            @aws.cas(fw)
            fw.setProviderFirewallId( dom.ffcn(items[i],'groupId') )
            fw.setProviderOwnerId(dom.ffcn(items[i],'ownerId'))
            fw.setDescription(dom.ffcn(items[i],'groupDescription'))
            ipRules = []
            ipPerms = dom.getNode( items[i], 'ipPermissions')
            ipPermsItems = dom.getCS(ipPerms)
            jj=ipPermsItems?.length || 0
            for j in [0...jj]
                if dom.getNName(ipPermsItems[j]) is '#text' then continue
                x = dom.ffcn(ipPermsItems[j], 'ipProtocol')
                ipProto=ComZotoh.CloudAPI.Network.Protocol.valueOf(x)
                fPort = dom.ffcn( ipPermsItems[j], 'fromPort')
                tPort = dom.ffcn( ipPermsItems[j], 'toPort')
                groups = gt( ipPermsItems[j], 'groups')[0]
                groupsItems = if groups? then dom.getCS( groups) else null
                kk=groupsItems?.length || 0
                for k in [0...kk]
                    if dom.getNName(groupsItems[k]) is '#text' then continue
                    obj=new ComZotoh.CloudAPI.Network.FirewallRule(ipProto,fPort,tPort)
                    @aws.cas(obj)
                    obj.setGroup( dom.ffcn( groupsItems[k], 'userId'), dom.ffcn( groupsItems[k],'groupName'))
                    ipRules.push(obj)
                ipRanges = gt( ipPermsItems[j], 'ipRanges')[0]
                ipRangesItems = if ipRanges? then dom.getCS(ipRanges) else null
                kk= ipRangesItems?.length || 0
                for k in [0...kk]
                    if dom.getNName(ipRangesItems[k]) is '#text' then continue
                    obj=new ComZotoh.CloudAPI.Network.FirewallRule(ipProto,fPort,tPort)
                    @aws.cas(obj)
                    obj.setCidr( dom.ffcn(ipRangesItems[k],'cidrIp') )
                    ipRules.push(obj)
            fw.setRules(ipRules)
            lst.push(fw)
        lst

##SKIP_GEN_DOC##

#}


class VPNSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Network.VPNSupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    hasSupport: () -> true

    listVPNGateways: (type, cbs) ->
        ###
        **type**: string - internet|private|vlan</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        pms=null
        if 'internet' is type
            pms= [ 'DescribeInternetGateways','/DescribeInternetGatewaysResponse/internetGatewaySet/item' ]
            cs= (item, a) ->
                a.setProviderVpnGatewayId( dom.ffcn(item,'internetGatewayId'))
                gt(item, 'attachmentSet/item')
            pms.push( cs )
        if 'private' is type
            pms= [ 'DescribeCustomerGateways', '/DescribeCustomerGateways/customerGatewaySet/item']
            cs= (item, a) ->
                a.setProviderVpnGatewayId( dom.ffcn(item,'customerGatewayId'))
                a.setCurrentState(dom.ffcn(item,'state'))
                a.setProtocol(dom.ffcn(item,'type'))
                a.setEndpoint(dom.ffcn(item,'ipAddress'))
                a.setBgpAsn(dom.ffcn(item,'bgpAsn'))
                []
            pms.push(cs)
        if 'vlan' is type
            pms= [ 'DescribeVpnGateways','/DescribeVpnGatewaysResponse/vpnGatewaySet/item' ]
            cs= (item, a) ->
                a.setProviderVpnGatewayId(dom.ffcn(item,'vpnGatewayId'))
                a.setCurrentState(dom.ffcn(item,'state'))
                a.setProtocol(dom.ffcn(item,'type'))
                a.setProviderDataCenterId(dom.ffcn(item,'availabilityZone'))
                gt(item, 'attachments/item')
            pms.push(cs)
        if pms? then @list_xxx_gateways(pms, cbs)

    attachToVLAN: (vpnId, vlanId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vpnId**: string</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs?
            cbs.success= (vpnObj) -> me.attach_to_vlan(vpnObj, vlanId, old, cbs)
        @getVPN(vpnId, cbs)

    disconnectGateway: (gatewayId, vlanId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **gatewayId**: string</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['VpcId', vlanId], ['InternetGatewayId', gatewayId]]
        me=this
        h=(data) ->
            me.aws.on_boolean_reply(data,'/DetachInternetGatewayResponse',cbs)
        @awscall('DetachInternetGateway', p, h, cbs)

    connectGateway: (gatewayId, vlanId, cbs) ->
        ###
        **results**: boolean - JSON-Object#result</br>
        **gatewayId**: string</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['VpcId', vlanId], ['InternetGatewayId', gatewayId]]
        me=this
        h=(data) ->
            me.aws.on_boolean_reply(data,'/AttachInternetGatewayResponse',cbs)
        @awscall('AttachInternetGateway', p, h, cbs)

    createVPN: (datacenter, protocol, params, cbs) ->
        ###
        **returns**: VPN</br>
        **datacenter**: string</br>
        **protocol**: string</br>
        **params**: object - optional params.</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['Type', protocol] ]
        if params?
            p.push(['CustomerGatewayId', params.privateGatewayId ], ['VpnGatewayId', params.awsGatewayId ])
        me=this
        h= (data) -> me.on_new_vpn(data,cbs)
        @awscall('CreateVpnConnection', p, h, cbs)

    createVPNGateway: (type, protocol, ipAddr, datacenter, bgpAsn, params,cbs) ->
        ###
        **returns**: VPNGateway</br>
        **type**: string - internet|private|vlan</br>
        **protocol**: string</br>
        **ipAddr**: string</br>
        **datacenter**: string</br>
        **bgpAsn**: int</br>
        **params**: object - optional parameters.</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]= @aws.cfns()
        pms=null
        if 'internet' is type
            pms=['CreateInternetGateway', [] ]
            pms.push('/CreateInternetGatewayResponse/internetGateway')
            cs= (item,a) ->
                a.setProviderVpnGatewayId( dom.ffcn(item,'internetGatewayId'))
            pms.push(cs)
        if 'private' is type
            pms=['CreateCustomerGateway']
            pms.push( [ ['Type', protocol], ['IpAddress', ipAddr ], ['BgpAsn', bgpAsn] ] )
            pms.push('/CreateCustomerGatewayResponse/customerGateway')
            cs= (item,a) ->
                a.setProviderVpnGatewayId(dom.ffcn(item,'customerGatewayId'))
                a.setCurrentState(dom.ffcn(item,'state'))
                a.setProtocol(dom.ffcn(item,'type'))
                a.setEndpoint(dom.ffcn(item,'ipAddress'))
                a.setBgpAsn(dom.ffcn(item,'bgpAsn'))
            pms.push(cs)
        if 'vlan' is type
            pms=[ 'CreateVpnGateway',  [['Type', protocol]] ]
            if uu.vstr(datacenter) then pms[1].push( ['AvailabilityZone', datacenter ] )
            pms.push('/CreateVpnGatewayResponse/vpnGateway')
            cs= (item,a) ->
                a.setProviderVpnGatewayId(dom.ffcn(item,'vpnGatewayId'))
                a.setCurrentState(dom.ffcn(item,'state'))
                a.setProtocol(dom.ffcn(item,'type'))
                a.setProviderDataCenterId(dom.ffcn(item,'availabilityZone'))
            pms.push(cs)
        if pms? then @new_xxx_gateway(pms, cbs)

    deleteVPN: (vpnId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vpnId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [[ 'VpnConnectionId', vpnId]]
        me=this
        h=(data) -> me.aws.on_boolean_reply(data, '/DeleteVpnConnectionResponse',cbs)
        @awscall('DeleteVpnConnection',p,h,cbs)

    deleteVPNGateway: (type, gatewayId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **type**: string - internet|private|vlan</br>
        **gatewayId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        pms=null
        if 'internet' is type
            pms= ['DeleteInternetGateway', [['InternetGatewayId', gatewayId]] ]
            pms.push('/DeleteInternetGatewayResponse')
        if 'private' is type
            pms=['DeleteCustomerGateway', [['CustomerGatewayId', gatewayId]] ]
            pms.push('/DeleteCustomerGatewayResponse')
        if 'vlan' is type
            pms=['DeleteVpnGateway', [['VpnGatewayId', gatewayId]] ]
            pms.push('/DeleteVpnGatewayResponse')
        if pms? then @del_xxx_gateway(pms,cbs)

    detachFromVLAN: (vpnId, vlanId, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **vpnId**: string</br>
        **vlanId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        old=cbs?.success
        me=this
        if cbs?
            cbs.success= (vpnObj) -> me.detach_from_vlan(vpnObj, vlanId, old, cbs)
        @getVPN(vpnId, cbs)

    getVPN: (vpnId, cbs) ->
        ###
        **returns**: VPN</br>
        **vpnId**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['VpnConnectionId.1', vpnId] ]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_vpns(data)))
        @awscall('DescribeVpnConnections', p, h, cbs)

    listVPNs: (cbs) ->
        ###
        **returns**: [ VPN, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[]
        me=this
        h= (data) -> cbs?.success?( me.munch_vpns(data) )
        @awscall('DescribeVpnConnections', p, h, cbs)

##SKIP_GEN_DOC##

    detach_from_vlan: (vpnObj, vlanId, old, cbs) ->
        gwid= vpnObj.getTag('vpnGatewayId')
        cbs?.success=old
        [uu,fcn,gt,dom] = @aws.cfns()
        me=this
        p=[ ['VpcId', vlanId], ['VpnGatewayId', gwid] ]
        h= (data) ->
            me.aws.on_boolean_reply(data,'/DetachVpnGatewayResponse', cbs)
        @awscall( 'DetachVpnGateway',p,h,cbs)

    del_xxx_gateway: (pms, cbs) ->
        me=this
        h= (data) -> me.aws.on_boolean_reply(data, pms[2], cbs)
        @awscall(pms[0], pms[1], h, cbs)

    new_xxx_gateway: (pms, cbs) ->
        me=this
        h= (data) -> me.on_new_gway(data, pms, cbs)
        @awscall( pms[0], pms[1], h, cbs)

    on_new_gway: (data,pms, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        item= gt(data, pms[2])[0]
        a= new ComZotoh.CloudAPI.Network.VPNGateway()
        @aws.cas(a)
        pms[3](item,a)
        cbs?.success?(a)

    on_new_vpn: (data, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        item= gt(data,'/CreateVpnConnectionResponse/vpnConnection')
        a= @munch_one_vpn(item)
        cbs?.success?(a)

    attach_to_vlan: (vpnObj, vlanId, old, cbs) ->
        gwid= vpnObj.getTag('vpnGatewayId')
        cbs?.success=old
        me=this
        p=[ ['VpcId', vlanId], ['VpnGatewayId', gwid] ]
        h= (data) -> me.on_attach_vlan(data,cbs)
        @awscall( 'AttachVpnGateway',p,h,cbs)

    on_attach_vlan: (data,cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        item= gt(data, '/AttachVpnGatewayResponse/attachment')
        @aws.cb_boolean( is_alive(item), cbs)

    list_xxx_gateways: (pms, cbs) ->
        p=[]
        me=this
        h= (data) -> cbs?.success?(me.munch_gways(data,pms))
        @awscall(pms[0], p, h, cbs)

    munch_vpns: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data, '/DescribeVpnConnectionsResponse/vpnConnectionSet/item')
        ii=items.length
        rc=[]
        for i in [0...ii]
            a= @munch_one_vpn(items[i])
            rc.push(a)
        rc

    munch_one_vpn: (item) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        a= new ComZotoh.CloudAPI.Network.VPN( dom.ffcn(item, 'vpnConnectionId') )
        @aws.cas(a)
        a.setCurrentState( dom.ffcn(item, 'state') )
        a.addTag('customerGatewayConfiguration', dom.ffcn(item, 'customerGatewayConfiguration') )
        a.setProtocol( dom.ffcn(item, 'type') )
        a.addTag('customerGatewayId', dom.ffcn(item, 'customerGatewayId'))
        a.addTag('vpnGatewayId', dom.ffcn(item, 'vpnGatewayId'))
        a

    munch_gways: (data, pms) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items=gt(data, pms[1])
        ii=items.length
        rc=[]
        cs= pms[2]
        for i in [0...ii]
            a= new ComZotoh.CloudAPI.Network.VPNGateway()
            @aws.cas(a)
            atts=cs(items[i],a)
            nn=atts?.length || 0
            x=[]
            for n in [0...nn]
                x.push({ vpcId: dom.ffcn(atts[n],'vpcId'), state: dom.ffcn(atts[n],'state') } )
            a.addTag('attachments',x)
            rc.push(a)
        rc

##SKIP_GEN_DOC##

#}

class LoadBalancer extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores LoadBalancer information ###

    constructor: (@lbId) -> super()

    equals: (other) -> @getProviderLoadBalancerId() is other?.getProviderLoadBalancerId()

    toString: () ->  @getProviderLoadBalancerId()

    getAddress: () -> @addr

    getProviderDataCenterIds: () -> @zones

    setProviderDataCenterIds: (zones) -> if zones? then @zones=zones

    setProviderServerIds: (vms) -> if vms? then @servers=vms

    getProviderServerIds: () -> @servers

    getAddressType: () -> @type

    getProviderLoadBalancerId: () -> @lbId

    setAddress: (addr) -> @addr = addr ? ''

    setProviderLoadBalancerId: (id) -> @lbId = id ? ''

    setAddressType: (t) -> if t? then @type= t

    getPublicPorts: () -> @ports

    setPublicPorts: (ps) -> if ps? then @ports= ps

    setListeners: (lsns) -> if lsns? then @listeners= lsns

    getListeners: () -> @listeners

#}

class Subnet extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Subnet information ###

    constructor: (@subnetId) -> super()

    equals: (other) -> @getProviderSubnetId() is other?.getProviderSubnetId()

    toString: () -> @getProviderSubnetId()

    getProviderDataCenterId: () -> @zone

    setProviderDataCenterId: (z) -> @zone = z ? ''

    setProviderSubnetId: (id) -> @subnetId = id ? ''

    getProviderSubnetId: () -> @subnetId

    setProviderVlanId: (id) -> @vlanId = id ? ''

    getProviderVlanId: () -> @vlanId

    getAvailableIpAddresses: () -> @ipAddrCount

    setAvailableIpAddresses: (c) -> if c? and not isNaN(c) then @ipAddrCount=c

    getCidr: () -> @cidrStr

    setCidr: (c) -> @cidrStr = c ? ''

#}

class Direction #{
    ###
    Enums for Direction of Access</br>
        { INGRESS, EGRESS }</br>
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

Direction.INGRESS=new Direction('INGRESS')
Direction.EGRESS=new Direction('EGRESS')

Direction.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ Direction.INGRESS, Direction.EGRESS]

Direction.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toUpperCase() else ''
    switch s
        when 'INGRESS' then Direction.INGRESS
        when 'EGRESS' then Direction.EGRESS
        else null

#}


class Firewall extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Firewall information ###

    constructor: (n,d) ->
        super(n)
        @available=true
        @active=true
        @rules=[]
        @setDescription(d)

    toString: () -> @getName() + '|' + @getProviderFirewallId()

    isActive: () -> @active

    isAvailable: () -> @available

    setActive: (b) -> if b? then @active = b

    setAvailable: (b) -> if b? then @available=b

    setProviderVlanId: (p1) -> @vlanId = p1 ? ''

    getProviderVlanId: () -> @vlanId

    getProviderFirewallId: () -> @fwId

    setProviderFirewallId: (id) -> @fwId = id ? ''

    getRules: () -> @rules

    setRules: (rules) ->
        if rules?
            ii= rules.length
            for i in [0...ii]
                rules[i].setFirewallName( @getName() )
            @rules=rules

#}


class NetworkServices #{
    ### ComZotoh.CloudAPI.Network.NetworkServices interface ###

    constructor: (@ec2, @elb) ->
        ### internal ###
        @fwall= new ComZotoh.CloudAPI.Network.FirewallSupport(@ec2)
        @ipa= new ComZotoh.CloudAPI.Network.IpAddressSupport(@ec2)
        @dns=null
        @lbs=new ComZotoh.CloudAPI.Network.LoadBalancerSupport(@elb)
        @vls=new ComZotoh.CloudAPI.Network.VLANSupport(@ec2)
        @vpn=new ComZotoh.CloudAPI.Network.VPNSupport(@ec2)

    getDnsSupport: () -> @dns

    getFirewallSupport: () -> @fwall

    getIpAddressSupport: () -> @ipa

    getLoadBalancerSupport: () -> @lbs

    getVlanSupport: () -> @vls

    getVpnSupport: () -> @vpn

    hasDnsSupport: () -> is_alive(@dns)

    hasFirewallSupport: () -> is_alive(@fwall)

    hasIpAddressSupport: () -> is_alive(@ipa)

    hasLoadBalancerSupport: () -> is_alive(@lbs)

    hasVlanSupport: () -> is_alive(@vls)

    hasVpnSupport: () -> is_alive(@vpn)

#}

class VPN extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores VPN information ###

    constructor: (@vpnId) -> super()

    toString: () -> @getProviderVpnId()

    getProtocol: () -> @protocol

    getProviderDataCenterId: () -> @zone

    setProviderDataCenterId: (z) -> @zone = z ? ''

    setProviderVlanId: (p1) -> @vlanId = p1 ? ''

    getProviderVlanId: () -> @vlanId

    setProtocol: (p) -> if p? then @protocol=p

    getProviderVpnId: () -> @vpnId

    setProviderVpnId: (id) -> @vpnId = id ? ''

#}

##SKIP_GEN_DOC##

class DNSRecord extends ComZotoh.CloudAPI.CObject #{

    constructor: () -> super()

    getType: () -> @type

    setType: (t) -> @type = t ? ''

    getTtl: () -> @ttl

    setTtl: (n) -> if n? and not isNaN(n) then @ttl=n

    getValues: () -> @vals

    setValues: (vs) -> if vs? then @vals= vs

    setProviderZoneId: (z) -> @dnsZone = z ? ''

    getProviderZoneId: () -> @dnsZone

#}

##SKIP_GEN_DOC##

class LoadBalancerSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Network.LoadBalancerSupport interface ###

    constructor: (elb) ->
        ### internal ###
        super(elb)

    remove: (name, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['LoadBalancerName', name ]]
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        h=(data) ->
            top= dom.getNode(data, '/DeleteLoadBalancerResponse')
            me.aws.cb_boolean(is_alive(top), cbs)
        @awscall('DeleteLoadBalancer', p, h, cbs)

    create: (name, desc, addrId, datacenters, listeners, fwalls, cbs) ->
        ###
        **returns**: LoadBalancer</br>
        **name**: string</br>
        **desc**: string</br>
        **addrId**: string</br>
        **datacenters**: [ string, ... ]</br>
        **listeners**: [ LbListener, ... ]</br>
        **fwalls**: [ string, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[['LoadBalancerName', name]]
        nn=listeners?.length || 0
        for n in [0...nn]
            ln=listeners[n]
            fld='Listeners.member.'+(n+1)+'.'
            p.push( [ fld+'LoadBalancerPort', ln.getPublicPort()] )
            p.push( [ fld+'InstancePort', ln.getPrivatePort()] )
            p.push( [ fld+'Protocol', ln.getPublicProtocol().toString()] )
            p.push( [ fld+'InstanceProtocol', ln.getPrivateProtocol().toString()] )
            if ln.isSecure() then p.push( [ fld+'SSLCertificateId', ln.getSSLCert().toString()] )
        nn=datacenters?.length || 0
        for n in [0...nn]
            p.push( [ 'AvailabilityZones.member.'+(n+1),  datacenters[n] ] )
        nn=fwalls?.length || 0
        for n in [0...nn]
            p.push( [ 'SecurityGroups.member.'+(n+1),  fwalls[n] ] )
        me=this
        h=(data) -> me.on_create(data, name, desc, cbs)
        @awscall('CreateLoadBalancer', p, h, cbs)

    hasSupport: () -> true

    addDataCenters: (name, datacenters, cbs) ->
        ###
        Bind more datacenters to this Load Balancer.</br>
        **returns**: [ string, ... ]</br>
        **name**: string</br>
        **datacenters**: [ string, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['LoadBalancerName', name ] ]
        nn= datacenters?.length || 0
        for n in [0...nn]
            p.push( [ 'AvailabilityZones.member.'+(n+1), datacenters[n] ] )
        me=this
        h= (data) -> me.on_xxx_dcs(data, '/EnableAvailabilityZonesForLoadBalancerResponse/EnableAvailabilityZonesForLoadBalancerResult', cbs)
        @awscall('EnableAvailabilityZonesForLoadBalancer', p, h, cbs)

    addServers: (name, vms, cbs) ->
        ###
        Bind more VMs to this Load Balancer.</br>
        **returns**: [ string, ... ]</br>
        **name**: string</br>
        **vms**: [ string, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [[ 'LoadBalancerName', name]]
        nn=vms?.length || 0
        for n in [0...nn]
            p.push([ 'Instances.member.'+(n+1)+'.InstanceId', vms[n] ])
        me=this
        h=(data) -> me.on_xxx_servers(data,'/RegisterInstancesWithLoadBalancerResponse/RegisterInstancesWithLoadBalancerResult',cbs)
        @awscall('RegisterInstancesWithLoadBalancer',p,h,cbs)

    getLoadBalancer: (name, cbs) ->
        ###
        **returns**: LoadBalancer</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=[ ['LoadBalancerNames.member.1', name ]]
        me=this
        h=(data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_xml(data)) )
        @awscall('DescribeLoadBalancers', p, h, cbs)

    getAddressType: () ->
        ###
        **returns**: LoadBalancerAddressType</br>
        ###
        ComZotoh.CloudAPI.Network.LoadBalancerAddressType.DNS

    #getMaxPublicPorts: () -> 0

    getProviderTermForLoadBalancer: (locale) -> 'Elastic Load Balancing'

    listSupportedAlgorithms: () ->
        ###
        **returns**: [ LbAlgorithm, ... ]</br>
        ###
        [ ComZotoh.CloudAPI.Network.LbAlgorithm.ROUND_ROBIN ]

    listSupportedProtocols: () -> 
        ###
        **returns**: [LbProtocol, ...]</br>
        ###
        [ ComZotoh.CloudAPI.Network.LbProtocol.SSL, ComZotoh.CloudAPI.Network.LbProtocol.HTTPS, ComZotoh.CloudAPI.Network.LbProtocol.HTTP, ComZotoh.CloudAPI.Network.LbProtocol.TCP ]

    isAddressAssignedByProvider: () -> true

    isDataCenterLimited: () -> true

    requiresListenerOnCreate: () -> true

    requiresServerOnCreate: () -> false

    supportsMonitoring: () -> true

    listLoadBalancers: (cbs) ->
        ###
        **returns**: [ LoadBalancer, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?( me.munch_xml(data))
        @awscall('DescribeLoadBalancers', [], h, cbs)

    removeDataCenters: (name, datacenters, cbs) ->
        ###
        Unbind datacenters from this Load Balancer.</br>
        **returns**: [ string, ... ]</br>
        **name**: string</br>
        **datacenters**: [string,...]</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['LoadBalancerName', name ] ]
        nn= datacenters?.length || 0
        for n in [0...nn]
            p.push( [ 'AvailabilityZones.member.'+(n+1), datacenters[n] ] )
        me=this
        h= (data) -> me.on_xxx_dcs(data,'/DisableAvailabilityZonesForLoadBalancerResponse/DisableAvailabilityZonesForLoadBalancerResult', cbs)
        @awscall('DisableAvailabilityZonesForLoadBalancer', p, h, cbs)

    removeServers: (name, vms, cbs) ->
        ###
        Unbind VMs from this Load Balancer.</br>
        **returns**: [ string, ... ]</br>
        **name**: string</br>
        **vms**: [ string, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [[ 'LoadBalancerName', name]]
        nn=vms?.length || 0
        for n in [0...nn]
            p.push([ 'Instances.member.'+(n+1)+'.InstanceId', vms[n] ])
        me=this
        h=(data) -> me.on_xxx_servers(data,'/DeregisterInstancesFromLoadBalancerResponse/DeregisterInstancesFromLoadBalancerResult',cbs)
        @awscall('DeregisterInstancesFromLoadBalancer',p,h,cbs)

##SKIP_GEN_DOC##

    on_xxx_servers: (data,pfx, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items=gt(data, pfx+'/Instances/member/InstanceId')
        ii=items.length
        rc=[]
        for i in [0...ii]
            rc.push( fcn( items[i]) )
        cbs?.success?(rc)

    on_xxx_dcs: (data,pfx, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items=gt(data, pfx+'/AvailabilityZones/member')
        ii=items.length
        rc=[]
        for i in [0...ii]
            rc.push( fcn( items[i]) )
        cbs?.success?(rc)

    munch_xml: (data) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        items=gt(data, '/DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member')
        ii=items.length
        rc=[]
        for i in [0...ii]
            a=new ComZotoh.CloudAPI.Network.LoadBalancer( dom.ffcn(items[i], 'LoadBalancerName') )
            @aws.cas(a)
            a.setAddressType( ComZotoh.CloudAPI.Network.LoadBalancerAddressType.DNS)
            x= uu.setISO8601( new Date(), dom.ffcn(items[i], 'CreatedTime') )
            a.setCreationTimestamp(x)
            a.setAddress( dom.ffcn(items[i], 'DNSName') )
            grps= gt(items[i], 'SecurityGroups/member')
            sns= gt(items[i], 'Subnets/member')
            zones= gt(items[i], 'AvailabilityZones/member')
            ls=[]
            nn=zones?.length || 0
            for n in [0...nn]
                ls.push( fcn( zones[n]) )
            a.setProviderDataCenterIds(ls)
            iids= gt(items[i], 'Instances/member/InstanceId')
            ls=[]
            nn=iids?.length || 0
            for n in [0...nn]
                ls.push( fcn(iids[n]) )
            a.setProviderServerIds(ls)
            lsns= gt(items[i], 'ListenerDescriptions/member')
            xxx=ComZotoh.CloudAPI.Network.LbProtocol
            nn=lsns?.length || 0
            ls=[]
            for n in [0...nn]
                ss=gt( lsns[n], 'Listener')
                _n=ss?.length || 0
                for s in [0..._n]
                    _l= new ComZotoh.CloudAPI.Network.LbListener()
                    _l.setPublicProtocol( xxx.valueOf( fcn(gt(ss[s],'Protocol')[0]) ) )
                    _l.setPublicPort( Number( fcn(gt(ss[s],'LoadBalancerPort')[0]) ))
                    _l.setPrivateProtocol( xxx.valueOf( fcn(gt(ss[s],'InstanceProtocol')[0]) ) )
                    _l.setPrivatePort( Number( fcn(gt(ss[s],'InstancePort')[0]) ))
                    ls.push(_l)
            a.setListeners(ls)
            rc.push(a)
        rc

    on_create: (data, name, desc, cbs) ->
        [uu,fcn,gt,dom] = @aws.cfns()
        a=new ComZotoh.CloudAPI.Network.LoadBalancer(name)
        @aws.cas(a)
        a.setAddress( dom.ffcn(data, '/CreateLoadBalancerResponse/CreateLoadBalancerResult/DNSName') )
        a.setAddressType( ComZotoh.CloudAPI.Network.LoadBalancerAddressType.DNS)
        a.setDescription(desc)
        cbs?.success?(a)

##SKIP_GEN_DOC##

#}

class Protocol #{
    ###
    Enums for network protocol</br>
        { ICMP, TCP, UDP }</br>
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

Protocol.ICMP=new Protocol('icmp')
Protocol.TCP=new Protocol('tcp')
Protocol.UDP=new Protocol('udp')

Protocol.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ Protocol.ICMP, Protocol.TCP, Protocol.UDP]

Protocol.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'icmp' then Protocol.ICMP
        when 'tcp' then Protocol.TCP
        when 'udp' then Protocol.UDP
        else null

#}

##SKIP_GEN_DOC##

class DNSSupport #{

    constructor: () ->

    hasSupport: () -> false

    # returns: org.dasein.cloud.network.DNSRecord
    # p1: java.lang.String
    # p2: org.dasein.cloud.network.DNSRecordType
    # p3: java.lang.String
    # p4: int
    # p5: [Ljava.lang.String;
    # cbs: AjaxCBS
    addDnsRecord: (p1, p2, p3, p4, p5, cbs) ->

    # returns: java.lang.String
    # p1: java.lang.String
    # p2: java.lang.String
    # p3: java.lang.String
    # cbs: AjaxCBS
    createDnsZone: (p1, p2, p3, cbs) ->

    # returns: void
    # p1: [Lorg.dasein.cloud.network.DNSRecord;
    # cbs: AjaxCBS
    deleteDnsRecords: (p1, cbs) ->

    # returns: void
    # p1: java.lang.String
    # cbs: AjaxCBS
    deleteDnsZone: (p1, cbs) ->

    # returns: org.dasein.cloud.network.DNSZone
    # p1: java.lang.String
    # cbs: AjaxCBS
    getDnsZone: (p1, cbs) ->

    # returns: java.lang.String
    # p1: java.util.Locale
    # cbs: AjaxCBS
    getProviderTermForRecord: (p1, cbs) ->

    # returns: java.lang.String
    # p1: java.util.Locale
    # cbs: AjaxCBS
    getProviderTermForZone: (p1, cbs) ->

    # returns: java.lang.Iterable
    # p1: java.lang.String
    # p2: org.dasein.cloud.network.DNSRecordType
    # p3: java.lang.String
    # cbs: AjaxCBS
    listDnsRecords: (p1, p2, p3, cbs) ->

    # returns: java.lang.Iterable
    # cbs: AjaxCBS
    listDnsZones: (cbs) ->

#}

##SKIP_GEN_DOC##

class Permission #{
    ###
    Enums for access permissions</br>
        { ALLOW, DENY }</br>
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

Permission.ALLOW=new Permission('ALLOW')
Permission.DENY=new Permission('DENY')

Permission.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ Permission.ALLOW,Permission.DENY]

Permission.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toUpperCase() else ''
    switch s
        when 'ALLOW' then Permission.ALLOW
        when 'DENY' then Permission.DENY
        else null

#}

##SKIP_GEN_DOC##

class IpForwardingRule extends ComZotoh.CloudAPI.CObject #{

    constructor: (@ruleId) -> super()

    equals: (other) -> @getProviderRuleId() is other?.getProviderRuleId()

    toString: () -> @getProviderRuleId()

    getProtocol: () -> @protocol

    getServerId: () -> @vmId

    setServerId: (id) -> @vmId = id ? ''

    getPrivatePort: () -> @prvPort

    setPrivatePort: (p1) -> if p1? and not isNaN(p1) then @prvPort = p1

    getPublicPort: () -> @pubPort

    setPublicPort: (p1) -> if p1? and not isNaN(p1) then @pubPort = p1

    setProtocol: (p1) -> if p1? then @protocol=p1

    getAddressId: () -> @addr

    getProviderRuleId: () -> @ruleId

    setAddressId: (p1) -> @addr = p1 ? ''

    setProviderRuleId: (p1) -> @ruleId = p1 ? ''

#}

##SKIP_GEN_DOC##

class VLAN extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Virtual Network information ###

    constructor: (@vlanId) -> super()

    equals: (other) -> @getProviderVlanId() is other?.getProviderVlanId()

    toString: () -> @getProviderVlanId()

    getProviderDataCenterId: () -> @zone

    setProviderDataCenterId: (z) -> @zone = z ? ''

    setProviderVlanId: (p) -> @vlanId = p ? ''

    getProviderVlanId: () -> @vlanId

    getDomainName: () -> @domain

    setDomainName: (n) -> @domain = n ? ''

    getCidr: () -> @cidrStr

    setCidr: (c) -> @cidrStr = c ? ''

    setDnsServers: (dnss) -> if dnss? then @dnss= dnss

    getDnsServers: () -> @dnss

    setGateway: (gw) -> @gateway= gw ? ''

    getGateway: () -> @gateway

    setNtpServers: (ns) -> if ns? then @ntpss= ns

    getNtpServers: () -> @ntpss

#}


class LbListener extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Load Balancer Listener information ###

    constructor: ()->
        super()
        @algo= ComZotoh.CloudAPI.Network.LbAlgorithm.ROUND_ROBIN
        @prvProtocol= ComZotoh.CloudAPI.Network.LbProtocol.HTTP
        @pubProtocol= ComZotoh.CloudAPI.Network.LbProtocol.HTTP
        @prvPort= 7501
        @pubPort=8090

    isSecure: () ->
        s= @pubProtocol?.toString()
        if 'https' is s or 'ssl' is s then true else false

    getSSLCert: () -> @sslCert

    setSSLCert: (c) -> if c? then @sslCert=c

    getAlgorithm: () -> @algo

    setAlgorithm: (a) -> if a? then @algo = a

    getPrivateProtocol: () -> @prvProtocol

    setPrivateProtocol: (p) -> if p? then @prvProtocol = p

    getPublicProtocol: () -> @pubProtocol

    setPublicProtocol: (p) -> if p? then @pubProtocol = p

    getPrivatePort: () -> @prvPort

    setPrivatePort: (n) -> if n? and not isNaN(n) then @prvPort =n

    getPublicPort: () -> @pubPort

    setPublicPort: (n) -> if n? and not isNaN(n) then @pubPort =n

#}

class LbProtocol #{
    ###
    Enums for network protocols supported by Load Balancers.</br>
        { HTTPS, HTTP, RAW_TCP, SSL, AJP }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

LbProtocol.AJP = new LbProtocol('ajp')
LbProtocol.HTTPS = new LbProtocol('https')
LbProtocol.SSL = new LbProtocol('ssl')
LbProtocol.HTTP = new LbProtocol('http')
LbProtocol.RAW_TCP = new LbProtocol('tcp')

LbProtocol.values=() ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ LbProtocol.SSL, LbProtocol.AJP, LbProtocol.HTTPS, LbProtocol.HTTP, LbProtocol.RAW_TCP ]

LbProtocol.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toLowerCase() else ''
    switch s
        when 'ajp' then LbProtocol.AJP
        when 'https' then LbProtocol.HTTPS
        when 'ssl' then LbProtocol.SSL
        when 'http' then LbProtocol.HTTP
        when 'tcp' then LbProtocol.TCP
        else null

#}

class LbAlgorithm #{
    ###
    Enums for Load Balancer algorithms.</br>
        { ROUND_ROBIN, LEAST_CONN, SOURCE }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

LbAlgorithm.ROUND_ROBIN= new LbAlgorithm('round_robin')
LbAlgorithm.LEAST_CONN= new LbAlgorithm('least_conn')
LbAlgorithm.SOURCE= new LbAlgorithm('source')

LbAlgorithm.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ LbAlgorithm.ROUND_ROBIN, LbAlgorithm.LEAST_CONN, LbAlgorithm.SOURCE ]

LbAlgorithm.valueOf=(s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toLowerCase() else ''
    switch s
        when 'round-robin' then LbAlgorithm.ROUND_ROBIN
        when 'least-conn' then LbAlgorithm.LEAST_CONN
        when 'source' then LbAlgorithm.SOURCE
        else null

#}

class LoadBalancerAddressType #{
    ###
    Enums for Load Balancer Address types.</br>
        { DNS, IP }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

LoadBalancerAddressType.DNS= new LoadBalancerAddressType('dns')
LoadBalancerAddressType.IP= new LoadBalancerAddressType('ip')

LoadBalancerAddressType.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'dns' then LoadBalancerAddressType.DNS
        when 'ip' then LoadBalancerAddressType.IP
        else null

LoadBalancerAddressType.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ LoadBalancerAddressType.DNS, LoadBalancerAddressType.IP ]

#}

class IpAddress extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores IP Address information ###

    constructor: (@addr, @type) -> super()

    equals: (other) ->
        other?.getProviderIpAddressId() is @getProviderIpAddressId() and other?.getAddressType() is @getAddressType()

    toString: () -> @getProviderIpAddressId()

    getServerId: () -> @server

    setServerId: (s) -> @server = s ? ''

    isAssigned: () -> is_alive(@server) and @server.length > 0

    getAddressType: () -> @type

    getProviderIpAddressId: () -> @addr

    getProviderLoadBalancerId: () -> @lbId

    setProviderIpAddressId: (a) -> @addr = a ? ''

    setProviderLoadBalancerId: (p1) -> @lbId = p1 ? ''

    setAddressType: (t) -> if t? then @type =t

#}

##SKIP_GEN_DOC##

class DNSZone extends ComZotoh.CloudAPI.CObject #{

    constructor: (@dnsZone) -> super()

    equals: (other) -> @getProviderDnsZoneId() is other?.getProviderDnsZoneId()

    toString: () -> @getProviderDnsZoneId()

    getDomainName: () -> @domain

    setDomainName: (n) -> @domain = n ? ''

    getNameservers: () -> @namess

    setNameservers: (ss) -> if ss? then @namess= ss

    getProviderDnsZoneId: () -> @dnsZone

    setProviderDnsZoneId: (id) -> @dnsZone = id ? ''

#}

##SKIP_GEN_DOC##

class IpAddressSupport extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Network.IpAddressSupport interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    hasSupport: () -> true

    assign: (addr, server, cbs) ->
        ###
        Assign an IP Address to a VM.</br>
        **returns**: boolean - JSON-Object#result</br>
        **addr**: string</br>
        **server**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['PublicIp', addr], ['InstanceId', server] ]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data, '/AssociateAddressResponse',cbs)
        @awscall('AssociateAddress', p, h, cbs)

    forward: (addr, pubPort, protocol, prvPort, toServer, cbs) ->
        ###
        Port forwarding.</br>
        NOT YET IMPLEMENTED.</br>
        **returns**: string</br>
        **addr**: string</br>
        **pubPort**: int - public port.</br>
        **protocol**: Protocol.</br>
        **prvPort**: private port.</br>
        **toServer**: target server.</br>
        **cbs**: AjaxCBS</br>
        ###

    getIpAddress: (addr, cbs) ->
        ###
        **returns**: IpAddress</br>
        **addr**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['PublicIp', addr] ]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_xml(data)) )
        @awscall('DescribeAddresses', p, h, cbs)

    getProviderTermForIpAddress: (locale) -> 'Elastic IP'

    isRequestable: (type) ->
        ###
        **returns**: boolean</br>
        **type**: AddressType</br>
        ###
        if ComZotoh.CloudAPI.Network.AddressType.PUBLIC is type then true else false

    isForwarding: () -> false

    listPrivateIpPool: (unassignedOnly, cbs) ->
        ###
        List private (VLAN) addresses.</br>
        **returns**: [ string, ... ]</br>
        **unassignedOnly**: boolean - true if only interested in ones not bound to a VM.</br>
        **cbs**: AjaxCBS</br>
        ###
        @list_ips('vpc', unassignedOnly, cbs)

    listPublicIpPool: (unassignedOnly, cbs) ->
        ###
        List public addresses.</br>
        **returns**: [ string, ... ]</br>
        **unassignedOnly**: boolean - true if only interested in ones not bound to a VM.</br>
        **cbs**: AjaxCBS</br>
        ###
        @list_ips('standard', unassignedOnly, cbs)

    listRules: (addr, cbs) ->
        ###
        List forwarding rules for this address.</br>
        NOT YET IMPLEMENTED</br>
        **returns**: [IpForwardingRule, ...]</br>
        **addr**: string</br>
        **cbs**: AjaxCBS</br>
        ###

    releaseFromPool: (addr, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **addr**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [ ['PublicIp', addr] ]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data,'/ReleaseAddressResponse',cbs)
        @awscall('ReleaseAddress', p , h, cbs)

    releaseFromServer: (addr, cbs) ->
        ###
        **returns**: boolean - JSON-Object#result</br>
        **addr**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p=  [ ['PublicIp', addr] ]
        me=this
        h= (data) -> me.aws.on_boolean_reply(data,'/DisassociateAddressResponse',cbs)
        @awscall('DisassociateAddress', p, h, cbs)

    request: (type, cbs) ->
        ###
        Request a new IP Address.</br>
        **returns**: IpAddress</br>
        **type**: AddressType</br>
        **cbs**: AjaxCBS</br>
        ###
        [uu,fcn,gt,dom]=@aws.cfns()
        me=this
        if ComZotoh.CloudAPI.Network.AddressType.PUBLIC isnt type
            @aws.cb_badrequest(cbs)
        else
            h = (data) ->
                top= dom.getNode(data, '/AllocateAddressResponse')
                a=dom.ffcn(top,'publicIp')
                cbs?.success?(new ComZotoh.CloudAPI.Network.IpAddress(a))
            @awscall('AllocateAddress', [], h, cbs)

    stopForward: (addr, cbs) ->
        ###
        NOT YET IMPLEMENTED</br>
        **returns**: boolean - JSON-Object#result</br>
        **addr**: string</br>
        **cbs**: AjaxCBS</br>
        ###

##SKIP_GEN_DOC##

    list_ips: (type, unassignedOnly, cbs) ->
        p=[ ['Filter.1.Name', 'domain'], ['Filter.1.Value.1', type] ]
        me=this
        h= (data) -> cbs?.success?( me.munch_xml( data, if unassignedOnly then -1 else 0))
        @awscall('DescribeAddresses', p, h, cbs)

    munch_xml: (data, filter) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data,'/DescribeAddressesResponse/addressesSet/item')
        lst=[]
        ii= items.length
        filter ?= 0
        for i in [0...ii]
            publicIp = dom.ffcn(items[i],'publicIp')
            domain = dom.ffcn(items[i],'domain')
            type =ComZotoh.CloudAPI.Network.AddressType.valueOf(domain)
            a=new ComZotoh.CloudAPI.Network.IpAddress(publicIp, type)
            @aws.cas(a)
            iid=dom.ffcn(items[i],'instanceId')
            a.setServerId( iid)
            switch filter
                when -1
                    if not uu.vstr(iid) then lst.push(a)
                when 0
                    lst.push(a)
                when 1
                    if uu.vstr(iid) then lst.push(a)
        lst

##SKIP_GEN_DOC##

#}

class VPNGateway extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores VPN gateway information ###

    constructor: (@gwayId) -> super()

    toString: () -> @getProviderVpnGatewayId()

    setProviderDataCenterId: (s) -> @zone= s ? ''

    getProviderDataCenterId: () -> @zone

    getProtocol: () -> @protocol

    setEndpoint: (p1) -> @endPoint = p1 ? ''

    getEndpoint: () -> @endPoint

    setProtocol: (p1) -> if p1? then @protocol = p1

    getBgpAsn: () -> @bgpAsn

    setBgpAsn: (s) -> @bgpAsn = s ? ''

    getProviderVpnGatewayId: () -> @gwayId

    setProviderVpnGatewayId: (id) -> @gwayId = id ? ''

#}

class AddressType #{
    ###
    Enums for IP Address types.</br>
        { PUBLIC, PRIVATE }</br>
    ###
    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

AddressType.PRIVATE=new AddressType('private')
AddressType.PUBLIC=new AddressType('public')

AddressType.values= () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [AddressType.PUBLIC, AddressType.PRIVATE ]

AddressType.valueOf= (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toLowerCase() else ''
    switch s
        when 'private', 'vpc' then AddressType.PRIVATE
        when 'public', 'standard' then AddressType.PUBLIC
        else null

#}

class FirewallRule extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Firewall Rule information ###

    constructor: (@protocol,@fromPort,@toPort) ->
        super()
        @perm=ComZotoh.CloudAPI.Network.Permission.ALLOW
        @dir=ComZotoh.CloudAPI.Network.Direction.INGRESS

    toString: () -> @getProviderRuleId()

    setPermission: (perm) -> if perm? then @perm= perm

    getPermission: () -> @perm

    getProtocol: () -> @protocol

    getCidr: () -> @cidrStr

    setCidr: (cidr) -> @cidrStr = cidr ? ''

    getGroup: () -> @group

    setGroup: (user,grp) -> @group=[ user ? '' ,  grp ? '' ]

    setProtocol: (protocol) -> if protocol? then @protocol=protocol

    getEndPort: () -> @toPort

    getFirewallName: () -> @fwName

    getStartPort: () -> @fromPort

    setEndPort: (port) -> if port? then @toPort=port

    setFirewallName: (n) -> @fwName = n ? ''

    setStartPort: (port) -> if port? then @fromPort= port

    setDirection: (dir) -> if dir? then @dir=dir

    getDirection: () -> @dir

    setProviderRuleId: (rid) -> 

    getProviderRuleId: () -> [ @fwName, @protocol?.toString(), @cidrStr, @fromPort, @toPort ].join('|')

#}


`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Network)) { ComZotoh.CloudAPI.Network={}; }
ComZotoh.CloudAPI.Network.VLANSupport=VLANSupport;
ComZotoh.CloudAPI.Network.FirewallSupport=FirewallSupport;
ComZotoh.CloudAPI.Network.VPNSupport=VPNSupport;
ComZotoh.CloudAPI.Network.LoadBalancer=LoadBalancer;
ComZotoh.CloudAPI.Network.Subnet=Subnet;
ComZotoh.CloudAPI.Network.Direction=Direction;
ComZotoh.CloudAPI.Network.Firewall=Firewall;
ComZotoh.CloudAPI.Network.NetworkServices=NetworkServices;
ComZotoh.CloudAPI.Network.VPN=VPN;
ComZotoh.CloudAPI.Network.DNSRecord=DNSRecord;
ComZotoh.CloudAPI.Network.LoadBalancerSupport=LoadBalancerSupport;
ComZotoh.CloudAPI.Network.Protocol=Protocol;
ComZotoh.CloudAPI.Network.DNSSupport=DNSSupport;
ComZotoh.CloudAPI.Network.Permission=Permission;
ComZotoh.CloudAPI.Network.VLAN=VLAN;
ComZotoh.CloudAPI.Network.LoadBalancerAddressType=LoadBalancerAddressType;
ComZotoh.CloudAPI.Network.IpAddress=IpAddress;
ComZotoh.CloudAPI.Network.DNSZone=DNSZone;
ComZotoh.CloudAPI.Network.IpAddressSupport=IpAddressSupport;
ComZotoh.CloudAPI.Network.VPNGateway=VPNGateway;
ComZotoh.CloudAPI.Network.AddressType=AddressType;
ComZotoh.CloudAPI.Network.FirewallRule=FirewallRule;
ComZotoh.CloudAPI.Network.LbAlgorithm=LbAlgorithm;
ComZotoh.CloudAPI.Network.LbProtocol=LbProtocol;
ComZotoh.CloudAPI.Network.LbListener=LbListener;
ComZotoh.CloudAPI.Network.NetworkInterface=NetworkInterface;


})(|GLOBAL|);



`


