@ignore
Feature: Helper reutilizable - crea un usuario nuevo en demoblaze y retorna sus credenciales

  Scenario: Crear usuario
    * def username = uniqueUsername('sofka')
    * def password = 'Sofka123*'
    Given url baseUrl
    And path 'signup'
    And request { username: '#(username)', password: '#(encodePassword(password))' }
    When method post
    Then status 200
    # El servicio responde el string JSON "" (con content-type json) -> se parsea para validarlo
    And match JSON.parse(response) == ''
