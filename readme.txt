PRUEBA TECNICA - PRUEBAS DE API REST CON KARATE (DEMOBLAZE SIGNUP / LOGIN)
=========================================================================

Servicios bajo prueba
---------------------
  Signup: POST https://api.demoblaze.com/signup
  Login : POST https://api.demoblaze.com/login

Casos automatizados
-------------------
  signup.feature
    1. Crear un nuevo usuario en signup                     (@signup @nuevo)
    2. Intentar crear un usuario ya existente               (@signup @existente)
  login.feature
    3. Usuario y password correcto en login                 (@login @exitoso)
    4. Usuario y password incorrecto en login               (@login @fallido)
       4a. Usuario valido con password erroneo
       4b. Usuario inexistente

Cada escenario imprime la ENTRADA (request) y la SALIDA (status + body), que quedan
registradas en el reporte HTML de Karate.

Tecnologias
-----------
  - Karate 2.1.3 (io.karatelabs:karate-core)
  - JUnit 5
  - Gradle 9.6 (se usa el wrapper incluido, no es necesario instalar Gradle)
  - Java 21 (requisito de Karate v2)

Prerrequisitos
--------------
  1. Java 17 o superior instalado para ejecutar Gradle (verificar con: java -version).
     Las pruebas compilan y se ejecutan con Java 21 mediante el toolchain de Gradle:
     si no hay un JDK 21 en la maquina, Gradle lo descarga automaticamente.
  2. Git.
  3. Conexion a internet (las pruebas consumen la API publica de demoblaze).

Pasos de ejecucion
------------------
  1. Clonar el repositorio:
       git clone https://github.com/J-hurtado94/pruebasofkakarate.git
       cd pruebasofkakarate

  2. Ejecutar todas las pruebas:
       Linux / macOS :  ./gradlew clean test
       Windows       :  gradlew.bat clean test

  3. (Opcional) Ejecutar solo un feature o escenario por tag:
       ./gradlew clean test -Dkarate.tags=@signup      (todo signup.feature)
       ./gradlew clean test -Dkarate.tags=@login       (todo login.feature)
       ./gradlew clean test -Dkarate.tags=@nuevo       (caso 1)
       ./gradlew clean test -Dkarate.tags=@existente   (caso 2)
       ./gradlew clean test -Dkarate.tags=@exitoso     (caso 3)
       ./gradlew clean test -Dkarate.tags=@fallido     (caso 4)
     En Windows se usa gradlew.bat en lugar de ./gradlew.
     Una ejecucion filtrada no sobrescribe la carpeta reportes/ (solo la suite completa).

     Desde IntelliJ: el boton de ejecutar que aparece en los .feature pertenece al plugin
     de Cucumber y no funciona con Karate. Usar en su lugar las configuraciones incluidas
     en la carpeta .run/ (selector de ejecucion arriba a la derecha):
       "Karate - suite completa", "Karate - signup", "Karate - login"

  4. Revisar los resultados:
       - Consola: resumen de features y escenarios ejecutados.
       - Reporte HTML de Karate (generado en cada ejecucion):
           build/karate-reports/karate-summary.html
       - Copia del reporte versionada en el repositorio:
           reportes/karate-summary.html
           reportes/feature-html/   (detalle de cada feature con request/response)
           reportes/junit-xml/      (resultados en formato JUnit XML)
       Abrir reportes/karate-summary.html en un navegador y hacer clic en cada
       feature para ver paso a paso las entradas y salidas capturadas.

Estructura del proyecto
-----------------------
  build.gradle                              Dependencias, toolchain Java 21, reintentos y copia de reportes
  settings.gradle                           Nombre del proyecto y resolver de JDK (foojay)
  src/test/java/karate-config.js            Configuracion global: baseUrl, timeouts y funciones utilitarias
  src/test/java/demoblaze/DemoblazeTest.java  Runner JUnit 5 de Karate
  src/test/java/demoblaze/RetryingHttpClientFactory.java  Cliente HTTP que reintenta los connect timeout
  src/test/java/demoblaze/signup.feature    Casos del servicio signup
  src/test/java/demoblaze/login.feature     Casos del servicio login
  src/test/java/demoblaze/crear-usuario.feature  Feature reutilizable (@ignore) que crea un usuario
  reportes/                                 Reporte de la ultima ejecucion
  conclusiones.txt                          Hallazgos y conclusiones

Notas
-----
  - Los usuarios se generan con un nombre unico (prefijo + timestamp + aleatorio), por lo que
    la suite puede ejecutarse cuantas veces se quiera sin cambiar datos.
  - El password se envia codificado en Base64, igual que lo hace el front de demoblaze.
  - El servidor de demoblaze presenta cortes intermitentes de red (ver conclusiones.txt).
    Por eso cada request se reintenta hasta 3 veces ante un ConnectTimeoutException
    (en consola aparece "ConnectTimeout contra ... - reintento N de 3"), y como respaldo
    build.gradle reintenta la suite hasta 2 veces si aun asi falla.
