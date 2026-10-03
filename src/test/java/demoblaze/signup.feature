@signup
Feature: Servicio Signup de Demoblaze - POST https://api.demoblaze.com/signup

  Entradas : body JSON { "username": string, "password": string en Base64 }
  Salidas  : HTTP 200 siempre; body "" si se crea el usuario
             o { "errorMessage": "This user already exist." } si ya existe

  Background:
    * url baseUrl
    * path 'signup'
    * def password = 'Sofka123*'

  @nuevo
  Scenario: Crear un nuevo usuario en signup
    * def username = uniqueUsername('sofka')
    * def requestBody = { username: '#(username)', password: '#(encodePassword(password))' }
    * print 'ENTRADA signup nuevo usuario:', requestBody
    Given request requestBody
    When method post
    * print 'SALIDA signup nuevo usuario -> status:', responseStatus, 'body:', response
    Then status 200
    # El servicio responde el string JSON "" (con content-type json) -> se parsea para validarlo
    And match JSON.parse(response) == ''
    And match header Content-Type contains 'application/json'

  @existente
  Scenario: Intentar crear un usuario ya existente
    # Precondicion: se crea un usuario para garantizar que existe
    * def usuario = call read('crear-usuario.feature')
    * def requestBody = { username: '#(usuario.username)', password: '#(encodePassword(usuario.password))' }
    * print 'ENTRADA signup usuario existente:', requestBody
    Given request requestBody
    When method post
    * print 'SALIDA signup usuario existente -> status:', responseStatus, 'body:', response
    Then status 200
    And match response == { errorMessage: 'This user already exist.' }
