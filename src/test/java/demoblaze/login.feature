@login
Feature: Servicio Login de Demoblaze - POST https://api.demoblaze.com/login

  Entradas : body JSON { "username": string, "password": string en Base64 }
  Salidas  : HTTP 200 siempre; body "Auth_token: <token>" si las credenciales son validas
             o { "errorMessage": "..." } si son invalidas

  Background:
    # Precondicion: un usuario registrado (se crea una sola vez para todo el feature)
    * def usuario = callonce read('crear-usuario.feature')
    * url baseUrl
    * path 'login'

  @exitoso
  Scenario: Usuario y password correcto en login
    * def requestBody = { username: '#(usuario.username)', password: '#(encodePassword(usuario.password))' }
    * print 'ENTRADA login correcto:', requestBody
    Given request requestBody
    When method post
    * print 'SALIDA login correcto -> status:', responseStatus, 'body:', response
    Then status 200
    # El servicio responde un string JSON: "Auth_token: <token>"
    * def authToken = JSON.parse(response)
    And match authToken == '#regex Auth_token: [A-Za-z0-9+/=]+'
    * def token = authToken.replace('Auth_token: ', '')
    * print 'Token obtenido:', token

  @fallido
  Scenario Outline: Usuario y password incorrecto en login - <caso>
    * def user = <username>
    * def requestBody = { username: '#(user)', password: '#(encodePassword("<password>"))' }
    * print 'ENTRADA login incorrecto (<caso>):', requestBody
    Given request requestBody
    When method post
    * print 'SALIDA login incorrecto (<caso>) -> status:', responseStatus, 'body:', response
    Then status 200
    And match response == { errorMessage: '<mensaje>' }

    Examples:
      | caso                          | username                        | password       | mensaje              |
      | usuario valido, pwd erroneo   | usuario.username                | ClaveErronea1  | Wrong password.      |
      | usuario inexistente           | uniqueUsername('noexiste')      | ClaveErronea1  | User does not exist. |
