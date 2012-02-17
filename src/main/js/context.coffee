###
file: comzotoh.cloudapi.providercontext.coffee
###

`

(function(genv) {
"use strict";

function is_alive(obj) { return typeof obj !== 'undefined' && obj !== null; }
function is_obj(obj) { return typeof obj === 'object'; }

if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
var ComZotoh=genv.ComZotoh;

`

class ProviderContext #{
    ### ComZotoh.CloudAPI.ProviderContext interface ###

    constructor: () ->
        ### private ###

    getCloudName: () -> @cloudName

    getProviderName: () -> @providerName

    getStorage: () -> @storage

    getStorageCustomProperties: () -> {}

    getRegionId: () -> @region

    setRegionId: (p1) -> @region= (p1 || '')

    setCloudName: (p1) -> @cloudName= (p1 || '')

    setProviderName: (p1) -> @providerName= (p1 || '')

    getAccountNumber: () -> @acctNum

    setAccountNumber: (p1) -> @acctNum= (p1 || '')

    getStorageEndpoint: () -> @storageEndPoint

    setEndpoint: (p1) -> @endPoint= (p1 || '')

    getStorageAccountNumber: () -> @storageAcctNum

    getStoragePublic: () -> null

    getStoragePrivate: () -> null

    setAccessKeys: (pubKey, prvKey) ->
        @setAccessPrivate(prvKey)
        @setAccessPublic(pubKey)

    getStorageX509Cert: () -> null

    setX509Cert: (cert) ->

    getStorageX509Key: () -> null

    setX509Key: (key) ->

    setCustomProperties: (props) -> @customProps= (props || {})

    getAccessPrivate: () -> @accessPrivate

    getAccessPublic: () -> @accessPublic

    getCustomProperties: () -> @customProps

    getEndpoint: () -> @endPoint

    setAccessPrivate: (prvKey) -> @accessPrivate=prvKey

    setAccessPublic: (pubKey) -> @accessPublic=pubKey

    setStorageKeys: (pubKey, privKey) ->

    setStoragePrivate: (key) ->

    setStoragePublic: (key) ->

    setStorage: (p1) -> @storage= (p1 || '')

    setStorageAccountNumber: (p1) -> @storageAcctNum= (p1 || '')

    getX509Cert: () -> null

    getX509Key: () -> null

    setStorageX509Cert: (cert) ->

    setStorageX509Key: (key) ->

    setStorageEndpoint: (p1) -> @storageEndPoint=(p1 || '')

    setStorageCustomProperties: (props) -> @storageProps= (props || {})

#}



`


if (!is_alive(ComZotoh.CloudAPI)) { ComZotoh.CloudAPI={}; }
ComZotoh.CloudAPI.ProviderContext=ProviderContext;


})(|GLOBAL|);



`


