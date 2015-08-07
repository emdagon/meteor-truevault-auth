
class TrueVault

  constructor: (@account_id, @ROOT_URL = "https://api.truevault.com/v1") ->

  login: (username, password) ->
    $.ajax
      type: 'POST'
      data:
        username: username
        password: password
        account_id: @account_id
      url: "#{@ROOT_URL}/auth/login"
      dataType: 'json'

  logout: (accessToken) ->
    $.ajax
      type: 'POST'
      url: "#{@ROOT_URL}/auth/logout"
      headers: Authorization: 'Basic ' + Base64.encode(accessToken + ":")
      dataType: 'json'
