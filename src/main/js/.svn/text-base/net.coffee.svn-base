###
file: comzotoh.net.coffee
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

class AjaxArgs #{
    constructor: (@verb, @action, @params, @callbacks, @data, @dataSize) ->
        @content_type='text/xml'
        @tags={}
        @response_type='xml'
        @timeout_secs=10
        @cache=false
        @async=true
        @host=''
        @headers={}
        @preAjax=undefined
        @action_handler=undefined

#}

##SKIP_GEN_DOC##

class AjaxError #{
    ### ComZotoh.Net.AjaxError interface ###
    constructor: (action,fault,msg) ->
        ### private ###
        @faultString= msg ? 'Unexpected Error'
        @action= action
        @faultCode= fault ? 'ServerFault'

    getFaultCode: () ->
        ###
        **returns**: string</br>
        ###
        @faultCode

    getFaultMsg: () ->
        ###
        **returns**: string</br>
        ###
        @faultString

#}


`
var empty_func=function() {};
`


class AjaxCBS #{
    ### ComZotoh.Net.AjaxCBS object ###
    constructor: (ok,error,timeout)->
        ###
        Creates a callback holder.</br>
        **ok**: callback func on success</br>
        **error**: callback func on error</br>
        **timeout**: callback func on timeout</br>
        ###
        @success= ok ? empty_func
        @error= error ? empty_func
        @timeout= timeout ? empty_func
#}

##SKIP_GEN_DOC##

class AjaxCloudr extends ComZotoh.Net.AjaxPipe #{
    constructor: () ->
        super()
        @userAgent=''
        @site=''
        @retries=3
        @retryMillis=1500
        @uteObj=new ComZotoh.Ute()

    ute: () -> @uteObj

    setUserAgent: (a) -> @userAgent= a ? ''

    getUserAgent: () -> @userAgent

    setHost: (host) -> @site= host ? ''

    getHost: ()-> @site

    setRetryLimit: (n) -> @retries= if not isNaN(n) then n

    getRetryLimit: () -> @retries

    setRetryDelayMillis: (millis) -> @retryMillis= if not isNaN(millis) then millis

    getRetryDelayMillis: () -> @retryMillis

    doAjax: (args) -> super(args)

    get_url_prefix: (args) -> 'https'

    get_url_site: (args) ->
        s= @site
        if @uteObj.vstr(args.url)
            m= @url_matcher(args.url)
            if m? and m.length > 2 then s= m[2]
        s

    cache_pages: () -> true

    default_response: () -> 'xml'

    default_data_type: () -> 'application/x-www-form-urlencoded'

    default_content_type: () -> 'text/xml'

    on_statuscode_zero: (errObj, args) ->
        rc.faultString= 'If you are unable to load any data,\n' +
                "check your computer's network connection.\n\n" +
                'If your computer or network is protected by a firewall or proxy,\n' +
                'check permission to access the Internet.'
        rc.faultCode= 'Failed to access url ' + args.url

    on_statuscode_bad: (args) ->
        code= args.serverResponseType
        url=args.url
        if url.length > 48 then t= (url.substr(0, 48) + ' ... ') else t= url
        new ComZotoh.Net.AjaxError(args.action,'HTTPCode:'+code+'','Error while connecting to '+t)

    post_process_error: (retryCtx, args, rc, cb) ->
        t= retryCtx.count
        me=this
        if @ok_to_retry(rc)
            if t >= @getRetryLimit()
                @uteObj.error("Retry limit exceeded, returning error.  retry count = #{t}")
                cb?(rc)
            else
                retryCtx.count = 1 + t
                @uteObj.delayExec( me.getRetryDelayMillis(), () -> me.retry_ajax(retryCtx, args) )
        else
            cb?(rc)

    ok_to_retry: (errObj) -> false

    url_matcher: (url) -> url.match( /(\w+):\/\/([\w.-]+)\/(\S*)/ )

#}

##SKIP_GEN_DOC##


`

if (!is_alive(ComZotoh.Net)) { ComZotoh.Net={}; }
if (!is_alive(ComZotoh.Net.AjaxCBS)) { ComZotoh.Net.AjaxCBS=AjaxCBS; }
if (!is_alive(ComZotoh.Net.AjaxArgs)) { ComZotoh.Net.AjaxArgs=AjaxArgs; }
if (!is_alive(ComZotoh.Net.AjaxError)) { ComZotoh.Net.AjaxError=AjaxError; }
if (!is_alive(ComZotoh.Net.Ajaxer )){ ComZotoh.Net.Ajaxer=AjaxCloudr; }




})(|GLOBAL|);

`





