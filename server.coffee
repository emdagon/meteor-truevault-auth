
class TrueVaultException
  constructor: (@code, @message) ->
  toString: ->
    "#{@code}, #{@message}"

class TrueVault
  constructor: (@apiKey, @vaultId, @ROOT_URL = "https://api.truevault.com/v1") ->

  getAuth: (token) -> Base64.encode((token or @apiKey) + ':')

  getUser: (userId, full = false) ->
    url = "#{@ROOT_URL}/users/#{userId}"

    if full
        url += '?full=1'

    response = HTTP.get url, auth: @getAuth()

    if response.statusCode is 200
      user = response.data.user
      if user.attributes
        user.attributes = JSON.parse Base64.decode(user.attributes)
      return user
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  createUser: (username, password, attributes = null) ->
    url = "#{@ROOT_URL}/users"

    _attributes = email: username

    internalAttributes = Base64.decode JSON.stringify(_attributes)

    payload = username: username, password: password, attributes: internalAttributes

    response = HTTP.post url, data: payload, auth: @getAuth()

    if response.statusCode is 200
      user = response.data.user
      if attributes instanceof Object
        _.extend attributes _attributes

        attributesId = @setUserAttributes @apiKey, _attributes

        groupId = @createUserGroup user.user_id, attributesId

        if user and attributesId and groupId
          return user: user, attributesId: attributesId
        else
          console.error 'Failed trying to create User\'s attributes or group:', user, attributesId, groupId
          throw new TrueVaultException 500, 'Failed trying to create the User'
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  updateUser: (userId, password = null, attributes = null, username = null) ->
    if not password and not attributes
      return null

    url = "#{@ROOT_URL}/users/#{userId}"

    payload = {}

    if attributes instanceof Object
      user = @getUser userId, true
      if user
        payload.attributes = Base64.encode json.stringify(attributes)

    if password
      payload.password = password

    if username
      payload.username = username

    response = HTTP.put url, data: payload, auth: @getAuth()

    if response.statusCode is 200
      return response.data.user
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  searchUser: (email) ->
    url = "#{@ROOT_URL}/users/search"

    search = Base64.encode JSON.stringify(email: email)
    payload = search_option: search

    response = HTTP.post url, data: payload, auth: @getAuth()

    if response.statusCode is 200
      return response.data.users
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  verifyToken: (userId, token) ->
    url = "#{@ROOT_URL}/auth/me"

    response = HTTP.get url, auth: @getAuth(token)
    data = response.data

    if response.statusCode is 200 and data.user.user_id is userId
      return data.user
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  setUserAttributes: (tokenOrKey, attributes, documentId = null) ->
    url = "#{@ROOT_URL}/vaults/#{@vaultId}/documents"

    if documentId is not null
      _attributes = {}
      url += "/" + documentId

      response = HTTP.get url, auth: @getAuth(tokenOrKey)
      data = response.data

      if response.statusCode is 200 and data.documents
        _attributes = Base64.decode data.documents[0].document
        _.extend _attributes, attributes
        payload = document: Base64.encode(JSON.stringify _attributes)
        response = HTTP.put url, data: payload, auth: @getAuth(tokenOrKey)

    else
      payload = document: Base64.encode(JSON.stringify attributes)
      response = HTTP.post url, data: payload, auth: @getAuth(tokenOrKey)

    data = response.data

    if response.statusCode is 200 and data.document_id
        return data.document_id
    else
      error = response.error
      throw new TrueVaultException error.code, error.message


  createUserGroup: (userId, attributesDocumentId) ->
    url = "#{@ROOT_URL}/groups"
    policy = [{
      Resources: ["Vault::#{@vaultId}::Document::#{attributesDocumentId}"]
      Activities: "RU"
    }]

    payload = name: userId, policy: Base64.encode(JSON.stringify policy), user_ids: userId

    response = HTTP.post url, data: payload, auth: @getAuth

    data = response.data

    if response.statusCode is 200 and data.group
      return data.group.group_id
    else
      error = response.error
      throw new TrueVaultException error.code, error.message
