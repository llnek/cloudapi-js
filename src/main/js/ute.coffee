###
file: comzotoh.ute.coffee
###

`

(function(genv) {
"use strict";

|PLATFORM_SPECIFIC_CODE|

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


/* logger */
    var tracer= function() {};
    var fbugLoaded=false;
    var level='OFF';
    function logg() {}
    if (is_alive(console)) {
        tracer= function(type, msg) { console.log( "[" + type + "] " + msg); } ;
        //tracer= function(type, msg) {  ute().log(msg); };
    } 
    else
    if ( is_alive(genv.console)) {
        tracer= function(type, msg) { genv.console.log( "[" + type + "] " + msg); } ;
        //tracer= function(type, msg) {  ute().log(msg); };
    } 
    if (is_obj(ComZotoh) && !is_alive(ComZotoh.LogJS)) {
        ComZotoh.LogJS=logg;
    }
    logg.setOFF = function() { level='OFF'; }
    logg.setDebug = function() { level='DEBUG'; }
    logg.setInfo = function() { level='INFO'; }
    logg.setError = function() { level='ERROR'; }
    logg.isDebugEnabled = function() { return 'DEBUG' === level; }
    logg.isErrorEnabled = function() { return 'OFF' !== level; }
    logg.isInfoEnabled = function() { 
        return ('DEBUG' === level || 'INFO' === level);
    }
    logg.setFBugLite = function() { fbugLoaded=true; f.setDebug(); }
    logg.isFBugLite = function() { return fbugLoaded; }
    logg.error = function(msg) {
        if (logg.isErrorEnabled()) { tracer('ERROR', msg); }
    }
    logg.info = function(msg) {
        if (logg.isInfoEnabled()) { tracer('INFO', msg); }
    }
    logg.debug = function(msg) {
        if (logg.isDebugEnabled()) { tracer('DEBUG', msg); }
    }
/* end loggr */

var ISO8601_regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" + 
            "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" + 
            "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";

var strftime_funks = {
  zpad: function( n ){ return n>9 ? n : '0'+n; },
  a: function(t) { return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()] },
  A: function(t) { return ['Sunday','Monday','Tuedsay','Wednesday','Thursday','Friday','Saturday'][t.getDay()] },
  b: function(t) { return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'][t.getMonth()] },
  B: function(t) { return ['January','February','March','April','May','June', 'July','August',
      'September','October','November','December'][t.getMonth()] },
  c: function(t) { return t.toString() },
  D: function(t) { return this.zpad(t.getDate()) },
  d: function(t) { return this.zpad(t.getDate()) },
  H: function(t) { return this.zpad(t.getHours()) },
  I: function(t) { return this.zpad((t.getHours() + 12) % 12) },
  m: function(t) { return this.zpad(t.getMonth()+1) }, // month-1
  M: function(t) { return this.zpad(t.getMinutes()) },
  p: function(t) { return this.H(t) < 12 ? 'AM' : 'PM'; },
  S: function(t) { return this.zpad(t.getSeconds()) },
  w: function(t) { return t.getDay() }, // 0..6 == sun..sat
  y: function(t) { return this.zpad(this.Y(t) % 100); },
  Y: function(t) { return t.getFullYear() },
  '%': function(t) { return '%' }
};

// from http://www.webtoolkit.info/javascript-base64.html
var __base64__ = {
    _keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
    encode : function (input) {
		var enc1, enc2, enc3, enc4;
        var chr1, chr2, chr3;
        var output = "";
        var i = 0;
        input = __base64__.utf8_encode(input);
        while (i < input.length) {
            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);
            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;
            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } 
			else if (isNaN(chr3)) {
                enc4 = 64;
            }
            output = output +
            __base64__._keyStr.charAt(enc1) + __base64__._keyStr.charAt(enc2) +
            __base64__._keyStr.charAt(enc3) + __base64__._keyStr.charAt(enc4);
        }
        return output;
    },
    decode : function (input) {
        var enc1, enc2, enc3, enc4;
        var output = "";
        var chr1, chr2, chr3;
        var i = 0;
        input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
        while (i < input.length) {
            enc1 = __base64__._keyStr.indexOf(input.charAt(i++));
            enc2 = __base64__._keyStr.indexOf(input.charAt(i++));
            enc3 = __base64__._keyStr.indexOf(input.charAt(i++));
            enc4 = __base64__._keyStr.indexOf(input.charAt(i++));
            chr1 = (enc1 << 2) | ((enc2 & 0x30) >> 4);
            chr2 = ((enc2 & 15) << 4) | ((enc3 & 0x3c) >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;
            output = output + String.fromCharCode(chr1);
            if (enc3 != 64) {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64) {
                output = output + String.fromCharCode(chr3);
            }
        }
        output = __base64__.utf8_decode(output);
        return output;
    },
    utf8_encode : function (s) {
        var utftext = "";
		var c;
        s = s.replace(/\r\n/g,"\n");
        for (var n = 0; n < s.length; ++n) {
            c = s.charCodeAt(n);
            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else 
			if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }
        }
        return utftext;
    },
    utf8_decode : function (utftext) {
        var c=0;
        var c1 =0;
        var c2=0;
        var s = "";
        var i = 0;
        var c3;
        while ( i < utftext.length ) {
            c = utftext.charCodeAt(i);
            if (c < 128) {
                s += String.fromCharCode(c);
                ++i;
            }
            else 
			if ((c > 191) && (c < 224)) {
                c2 = utftext.charCodeAt(i+1);
                s += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                i += 2;
            }
            else {
                c2 = utftext.charCodeAt(i+1);
                c3 = utftext.charCodeAt(i+2);
                s += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                i += 3;
            }
        }
        return s;
    }
}








`

##SKIP_GEN_DOC##

class Ute #{

    constructor: () ->

    logb: (msg) -> @log([ @makeStr('+', 78), msg, @makeStr('-',78) ].join('\n'))

    isDbg: () -> ComZotoh.LogJS.isDebugEnabled()
    error: (msg) -> ComZotoh.LogJS.error(msg)
    debug: (msg) -> ComZotoh.LogJS.debug(msg)
    log: (msg) -> ComZotoh.LogJS.info(msg)

    getFirst: (lst) -> if lst? and lst.length > 0 then lst[0] else null

    base64: () -> [ __base64__.encode, __base64__.decode ]
    b64: () -> __base64__

    urlencode : (str) ->
        encodeURIComponent(str).
            replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/'/g, '%27').replace(/\*/g, '%2A')

    randomMillis: () ->
        r= parseInt( Math.random() * 1000 )
        if r < 10 then r = r * 1000
        else if r < 100 then r= r * 100
        else if r < 1000 then r= r * 10
        r

    normalizeStrID: (id) ->
        id= (id ? '').toLowerCase()
        fc=[]
        ii=id.length
        for i in [0...ii]
            n= id.charCodeAt(i)
            if (122 >= n >= 97 ) or # a-z
                    ( 90 >= n >= 65 ) or # A-Z
                    ( 57 >= n >= 48) or # 0-9
                    (45 is n) or # dash
                    (95 is n) # underbar
                fc.push(id.charAt(i))
            else
                fc.push( Number(n).toString(16))
        fc.join('')

    isLinux: ()-> 
        if @isWIN() then false else if @isOSX() then false else true

    isOSX: ()->
        s=@maybe_getostype()
        if s? then (s.indexOf('osx') >= 0 or s.indexOf('mac') >= 0) else false

    isWIN: () ->
        s=@maybe_getostype()
        if s? then s.indexOf('win') >= 0 else false

    niceTS: (ts) -> if ts? then @strftime(ts, '%Y-%m-%d %H:%M:%S') else ''

    trim: (s) -> if s? then s.replace(/^\s*/, '').replace(/\s*$/, '') else ''

    join: (sep, parts...) ->
        ii=parts.length
        rc=[]
        for i in [0...ii]
            if parts[i]? then rc.push(parts[i])
        rc.join(sep)

    makeStr: (ch, len) ->
        s=''
        s+=ch for i in [0...len]
        s

    getNode: (parent, nodeName) -> ComZotoh.DomAPI.getNode(parent, nodeName)

    getTag: (o,n) -> ComZotoh.DomAPI.getTag(o,n)

    getFCN: (node) -> ComZotoh.DomAPI.getFCN(node)

    getCS: (node) -> ComZotoh.DomAPI.getCS(node)

    getNVal: (parent, nodeName) -> ComZotoh.DomAPI.getNVal(parent, nodeName)

    vstr: (s) -> if s? and s.length > 0 then true else false

    isNil: (o) -> not is_alive(o)

    jsonStr: (j) -> if j? then JSON.stringify(j) else ''

    strJson: (s) -> if s? then JSON.parse(s) else null

    toBytes: (s) ->
        rc=[]
        if s? then rc.push(s.charCodeAt(i)) for i in [0...s.length]
        rc

    tokenize: (str, sep) ->
        tokens = []
        tok = ''
        if str?
            ii=str.length
            for i in [0...ii]
                ch = str[i]
                if @isCharInStr(ch,sep)
                    if tok.length > 0 then tokens.push(tok)
                    tok = ''
                else
                    tok += ch
        if tok.length > 0 then tokens.push(tok)
        tokens

    isCharInStr: (str, ch) ->
        if str?
            ii=str.length
            for i in [0...ii]
                if ch is str[i] then return true
        false

    delayExec: (waitMillis, cb) -> genv?.setTimeout?(cb, waitMillis)

    midGrab: (src, head, tail) ->
        s= ''
        if src? and head? and tail?
            try 
                rp= src.lastIndexOf(tail)
                lp= src.indexOf(head)
                lp += head.length
                s= src.slice(lp, rp)
            catch e
                s= ''
        s

    genID: (n, max) ->
        width= ('' + max).length
        len= (''+n).length
        diff= width-len-1
        idStr=''
        idStr += '0' for i in [0...diff]
        idStr + n

    newGUID: () -> 'x' + Math.uuid().replace(/[-]/g, '').toLowerCase()

    encodeXML: (s) ->
        if s?
            s.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
        else
            ''

    mapHasKey: (m, key) -> 
        if m? and key? and m.hasOwnProperty(key) then true else false

    mapPut: (m, key, value) ->
        if m? and key? then m[key]=value

    mapGet: (m, key) ->
        if @mapHasKey(m,key) then m[ key] else undefined

    mapEntrySet: (m) -> 
        rc= []
        if m? then rc.push( {value: m[n], key: n } ) for own n of m
        rc

    mapKeys: (m) ->
        rc= []
        if m? then rc.push(n) for own n of m
        rc

    mapVals: (m) ->
        rc= []
        if m? then rc.push(m[n]) for own n of m
        rc

    mapSize: (m) ->
        i=0
        if m? then i += 1 for own n of m
        i

    mapDel: (m, key) ->
        rc= undefined
        if @mapHasKey(m,key)
            rc= m[ key]
            delete m[key]
        rc

    strftime: (dt,fmt) ->
        for own s of strftime_funks
            if s.length is 1
                fmt= fmt.replace('%'+s, strftime_funks[s](dt))
        fmt

    sclone: (src, des) -> 
        if src? and des? then des[k] = v for own k,v of src

    maybe_getostype: () ->
        if __os__? then p= __os__.platform()
        else if is_alive(genv.navigator) then p=navigator.platform
        else p=''
        (p ? '').toLowerCase()

    # With thanks to http://delete.me.uk/2005/03/iso8601.html
    setISO8601: (dt, str) ->
        if @vstr(str)
            d = str.match(new RegExp(ISO8601_regexp))
            offset = 0
            date = new Date(d[1], 0, 1)
            if d[3]? then date.setMonth(d[3] - 1)
            if d[5]? then date.setDate(d[5])
            if d[7]? then date.setHours(d[7])
            if d[8]? then date.setMinutes(d[8])
            if d[10]? then date.setSeconds(d[10])
            if d[12]? then date.setMilliseconds(Number("0." + d[12]) * 1000)
            if d[14]?
                offset = (Number(d[16]) * 60) + Number(d[17])
                offset *= if d[15] is '-' then 1 else -1
            offset -= date.getTimezoneOffset()
            time = (Number(date) + (offset * 60 * 1000))
            dt.setTime(Number(time))
        else
            dt=null
        dt

    toISO8601String: (dt,format,offset) ->
        # accepted values for the format [1-6]:
        # 1 Year:
        # YYYY (eg 1997)
        # 2 Year and month:
        # YYYY-MM (eg 1997-07)
        # 3 Complete date:
        # YYYY-MM-DD (eg 1997-07-16)
        # 4 Complete date plus hours and minutes:
        # YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
        # 5 Complete date plus hours, minutes and seconds:
        # YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
        # 6 Complete date plus hours, minutes, seconds and a decimal
        # fraction of a second
        # YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)
        zpad= (num) -> (if num < 10 then '0' else '') + num
        if not format? then format=6
        if not offset?
            offset='Z'
            date=dt
        else
            d = offset.match(/([-+])([0-9]{2}):([0-9]{2})/)
            offsetnum = (Number(d[2]) * 60) + Number(d[3])
            offsetnum *= if d[1] is '-' then -1 else 1
            date = new Date(Number(Number(dt) + (offsetnum * 60000)))
        str = '' + date.getUTCFullYear()
        if format > 1 then str += "-" + zpad(date.getUTCMonth() + 1)
        if format > 2 then str += "-" + zpad(date.getUTCDate())
        if format > 3
            str += "T" + zpad(date.getUTCHours()) + ":" + zpad(date.getUTCMinutes())
        if format > 5
            secs = Number(date.getUTCSeconds() + "." + (if date.getUTCMilliseconds() < 100 then '0' else '') + zpad(date.getUTCMilliseconds()))
            str += ":" + zpad(secs)
        else if format > 4
            str += ":" + zpad(date.getUTCSeconds())
        if format > 3 then str += offset
        str

#}


##SKIP_GEN_DOC##


`

if (!is_alive(ComZotoh.Ute)) { ComZotoh.Ute=Ute; }



})(|GLOBAL|);

`





