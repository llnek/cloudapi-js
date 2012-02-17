###
file: comzotoh.cloudapi.dc.coffee
###

`
(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`


class Region extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores Region information ###

    constructor: (rid,@jurDic) ->
        ### internal ###
        super()
        @available=true
        @active=true
        @setProviderRegionId(rid)

    equals: (other) -> @getProviderRegionId() is other?.getProviderRegionId() and other?.getJurisdiction() is @getJurisdiction()

    toString: () -> @getProviderRegionId()

    isActive: () -> @active

    isAvailable: () -> @available

    setActive: (b) -> if b? then @active=b

    setAvailable: (b) -> if b? then @available=b

    setJurisdiction: (n) -> @jurDic = n ? ''

    getJurisdiction: () -> @jurDic

#}

class DataCenter extends ComZotoh.CloudAPI.CObject #{
    ### POJO stores DataCenter information ###

    constructor: (@dcid, rid) ->
        ### internal ###
        super()
        @available=true
        @active=true
        @setProviderRegionId(rid)

    equals: (other) -> other?.getProviderDataCenterId() is @getProviderDataCenterId() and other?.getProviderRegionId() is @getProviderRegionId()

    toString: () -> @getProviderDataCenterId()

    getProviderDataCenterId: () -> @dcid

    isActive: () -> @active

    isAvailable: () -> @available

    setActive: (b) -> if b? then @active=b

    setAvailable: (b) -> if b? then @available=b

    setProviderDataCenterId: (id) -> @dcid = id ? ''

#}

class DataCenterServices extends ComZotoh.CloudAPI.AbstractSupport #{
    ### ComZotoh.CloudAPI.Dc.DataCenterServices interface ###

    constructor: (ec2) ->
        ### internal ###
        super(ec2)

    getDataCenter: (name, cbs) ->
        ###
        **returns**: DataCenter</br>
        **name**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['ZoneName.1', name]]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst(me.munch_dcs(data)))
        @awscall('DescribeAvailabilityZones', p, h, cbs)

    getProviderTermForDataCenter: (locale) -> 'Availability Zone'

    getProviderTermForRegion: (locale) -> 'Region'

    getRegion: (r, cbs) ->
        ###
        **returns**: Region</br>
        **r**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['RegionName.1', r]]
        me=this
        h= (data) -> cbs?.success?( me.aws.ute().getFirst( me.munch_xml(data)))
        @awscall( 'DescribeRegions', p , h, cbs)

    listDataCenters: (r, cbs) ->
        ###
        **returns**: [ DataCenter, ... ]</br>
        **r**: string</br>
        **cbs**: AjaxCBS</br>
        ###
        p= [['Filter.1.Name', 'region-name'], ['Filter.1.Value.1', r]]
        me=this
        h= (data) -> cbs?.success?(me.munch_dcs(data))
        @awscall( 'DescribeAvailabilityZones', p, h, cbs)

    listRegions: (cbs) ->
        ###
        **returns**: [ Region, ... ]</br>
        **cbs**: AjaxCBS</br>
        ###
        me=this
        h= (data) -> cbs?.success?(me.munch_xml(data))
        @awscall( 'DescribeRegions', [] , h, cbs)

##SKIP_GEN_DOC##

    munch_xml: (data) ->
        [uu,fcn,gt, dom]=@aws.cfns()
        items = gt(data,'/DescribeRegionsResponse/regionInfo/item')
        ii= items.length
        lst=[]
        for i in [0...ii]
            name = dom.ffcn( items[i], 'regionName')
            r= new ComZotoh.CloudAPI.Dc.Region()
            @aws.cas(r)
            r.setProviderRegionId(name)
            r.addTag('regionEndpoint', dom.ffcn( items[i], 'regionEndpoint') )
            lst.push(r)
        lst

    munch_dcs: (data) ->
        [uu,fcn,gt,dom]=@aws.cfns()
        items = gt(data,'/DescribeAvailabilityZonesResponse/availabilityZoneInfo/item')
        ii=items.length
        lst = []
        for i in [0...ii]
            name = dom.ffcn(items[i], 'zoneName')
            r = dom.ffcn(items[i], 'regionName')
            a=new ComZotoh.CloudAPI.Dc.DataCenter(name)
            @aws.cas(a)
            a.setProviderRegionId(r)
            a.setAvailable( 'available' is dom.ffcn(items[i], 'zoneState') )
            lst.push(a)
        lst

##SKIP_GEN_DOC##

#}


`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
if (!is_alive(ComZotoh.CloudAPI.Dc)) { ComZotoh.CloudAPI.Dc={}; }
ComZotoh.CloudAPI.Dc.Region=Region;
ComZotoh.CloudAPI.Dc.DataCenterServices=DataCenterServices;
ComZotoh.CloudAPI.Dc.DataCenter=DataCenter;


})(|GLOBAL|);



`


