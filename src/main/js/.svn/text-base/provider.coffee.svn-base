###
file: comzotoh.cloudapi.provider.coffee
###

`

(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;


`

class CloudProvider #{
    ###
    Abstract interface for all cloud providers
    ###

    constructor: (@ctx) ->
        ### protected ###

    getContext: () -> @ctx

    close: () ->

    release: () ->

    getAdminServices: () -> @admSvcs

    getComputeCloud: () -> this

    getCloudName: () -> @ctx.getCloudName()

    getDataCenterServices: () -> @dcSvcs

    getComputeServices: () -> @cmpSvcs

    getIdentityServices: () -> @idSvcs

    getNetworkServices: () -> @netSvcs

    getPlatformServices: () -> @plfSvcs

    getProviderName: () -> @ctx.getProviderName()

    getStorageServices: () -> @stoSvcs

    hasComputeServices: () -> is_alive( @cmpSvcs)

    hasIdentityServices: () -> is_alive( @idSvcs)

    hasNetworkServices: () -> is_alive( @netSvcs)

    hasPlatformServices: () -> is_alive( @plfSvcs)

    hasStorageServices: () -> is_alive( @stoSvcs)

    isConnected: () -> true

    testContext: () -> is_alive(@ctx)

#}



`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
ComZotoh.CloudAPI.CloudProvider=CloudProvider;


})(|GLOBAL|);



`


