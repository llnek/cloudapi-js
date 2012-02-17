###
file: comzotoh.cloudapi.coffee
###

`

(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

`

##SKIP_GEN_DOC##

class AbstractSupport #{

    constructor: (@aws) ->

    awscall: (action,pms,h,cbs) -> @aws.doAjax( @aws.ec2Arg(action, pms, h,cbs))

#}

##SKIP_GEN_DOC##

class CObject #{
    ### Abstract base class for POJOs ###

    constructor: (@name) ->
        ### protected ###
        @tags={}

    getCurrentState: () -> @state

    setCurrentState: (state) -> @state = state ? ''

    getTags: () -> @tags

    setTags: (ts) -> if ts? then @tags= ts

    addTag: (k,v) -> if k? then @tags[k] =v

    getTag: (k) -> if k? then @tags[k] else undefined

    getName: () -> @name ? ''

    setName: (n) -> @name = n ? ''

    getProviderOwnerId: () -> @owner

    setProviderOwnerId: (o) -> @owner = o ? ''

    getProviderRegionId: () -> @region

    setProviderRegionId: (r) -> @region = r ? ''

    getDescription: () -> @desc

    setDescription: (d) -> @desc = d ? ''

    getCreationTimestamp: () -> @cr_tstamp

    setCreationTimestamp: (ts) -> if ts? then @cr_tstamp=ts


#}

class DayOfWeek #{
    ###
    Enum for weekdays:</br>
        { MON, TUE, WED, THU, FRI, SAT, SUN }</br>
    ###

    constructor: (@idstr, @sstr) ->
        ### private ###

    getShortString: () ->
        ###
        **returns**: short form, e.g. mon.</br>
        ###
        @sstr

    toString: () -> @idstr

DayOfWeek.MON = new DayOfWeek('Monday', 'Mon')
DayOfWeek.TUE = new DayOfWeek('Tuesday', 'Tue')
DayOfWeek.WED = new DayOfWeek('Wednesday', 'Wed')
DayOfWeek.THU = new DayOfWeek('Thursday', 'Thu')
DayOfWeek.FRI = new DayOfWeek('Friday', 'Fri')
DayOfWeek.SAT = new DayOfWeek('Saturday', 'Sat')
DayOfWeek.SUN = new DayOfWeek('Sunday', 'Sun')

DayOfWeek.values = () ->
    ###
    **returns**: list of Enums.</br>
    ###
    [ DayOfWeek.MON, DayOfWeek.TUE, DayOfWeek.WED, DayOfWeek.THU, DayOfWeek.FRI, DayOfWeek.SAT, DayOfWeek.SUN ]

DayOfWeek.valueOf = (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s= if s? then s.toLowerCase() else ''
    switch s
        when 'monday','mon' then DayOfWeek.MON
        when 'tuesday', 'tue' then DayOfWeek.TUE
        when 'wednesday', 'wed' then DayOfWeek.WED
        when 'thursday','thu' then DayOfWeek.THU
        when 'friday', 'fri' then DayOfWeek.FRI
        when 'saturday', 'sat' then DayOfWeek.SAT
        when 'sunday', 'sun' then DayOfWeek.SUN
        else null

#}



class DataFormat #{
    ###
    Enum for data format</br>
        { JSON,XML,TEXT,CSV }</br>
    ###

    constructor: (@idstr) ->
        ### private ###

    toString: () -> @idstr

DataFormat.CSV=new DataFormat('csv')
DataFormat.JSON=new DataFormat('json')
DataFormat.XML=new DataFormat('xml')
DataFormat.TEXT=new DataFormat('text')

DataFormat.values = () ->
    ###
    **returns**: the list of Enums.</br>
    ###
    [ DataFormat.CSV, DataFormat.XML, DataFormat.JSON, DataFormat.TEXT ]

DataFormat.valueOf = (s) ->
    ###
    **returns**: Enum given a string value.</br>
    ###
    s = if s? then s.toLowerCase() else ''
    switch s
        when 'csv' then DataFormat.CSV
        when 'xml' then DataFormat.XML
        when 'json' then DataFormat.JSON
        when 'text' then DataFormat.TEXT
        else null

#}



class TimeWindow #{
    ### Utility class to manage a time period. ###

    constructor: () ->
        ### creates a TimeWindow object. ###
        @startHour=0
        @endHour=0
        @endMin=0
        @startMin=0

    toString: () ->
        ###
        **returns**: the string representation of the period.</br>
            e.g. mon:05:30-fri:22:30.</br>
        ###
        out=[]
        if is_alive(@startOfWeek) then out.push( @startOfWeek.getShortString() , ':')
        out.push( @pad(@startHour), ':', @pad(@startMin) )
        out.push('-')
        if is_alive(@endOfWeek) then out.push( @endOfWeek.getShortString() , ':')
        out.push( @pad(@endHour), ':', @pad(@endMin) )
        out.join('').toLowerCase()

    getEndDayOfWeek: () -> @endOfWeek

    setEndDayOfWeek: (w) -> if w? then @endOfWeek= w

    getEndHour: () -> @endHour

    setEndHour: (n) -> if n? and not isNaN(n) then @endHour=n

    getEndMinute: () -> @endMin

    setEndMinute: (n) -> if n? and not isNaN(n) then @endMin=n

    getStartDayOfWeek: () -> @startOfWeek

    setStartDayOfWeek: (w) -> if w? then @startOfWeek=w

    getStartHour: () -> @startHour

    setStartHour: (n) -> if n? and not isNaN(n) then @startHour=n

    getStartMinute: () -> @startMin

    setStartMinute: (n) -> if n? and not isNaN(n) then @startMin=n

##SKIP_GEN_DOC##

    pad: (n) -> if n < 10 then '0'+n else ''+n

##SKIP_GEN_DOC##

#}




`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
ComZotoh.CloudAPI.DataFormat=DataFormat;
ComZotoh.CloudAPI.DayOfWeek=DayOfWeek;
ComZotoh.CloudAPI.TimeWindow=TimeWindow;
ComZotoh.CloudAPI.CObject=CObject;
ComZotoh.CloudAPI.AbstractSupport=AbstractSupport;


})(|GLOBAL|);



`


