function fn() {
  var env = karate.env || 'qa';
  karate.log('karate.env =', env);

  var config = {
    env: env,
    baseUrl: 'https://api.demoblaze.com'
  };

  // El front de demoblaze envia el password codificado en Base64 (btoa) - se replica el mismo comportamiento
  config.encodePassword = function (plain) {
    var Base64 = Java.type('java.util.Base64');
    var bytes = new java.lang.String(plain).getBytes('UTF-8');
    return Base64.getEncoder().encodeToString(bytes);
  };

  // Genera un username unico por ejecucion para que la prueba sea repetible
  config.uniqueUsername = function (prefix) {
    return prefix + '_' + java.lang.System.currentTimeMillis() + '_' + Math.floor(Math.random() * 10000);
  };

  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 15000);

  return config;
}
