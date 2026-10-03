package demoblaze;

import io.karatelabs.core.KarateConfig;
import io.karatelabs.http.DefaultHttpClientFactory;
import io.karatelabs.http.HttpClient;
import io.karatelabs.http.HttpClientFactory;
import io.karatelabs.http.HttpRequest;
import io.karatelabs.http.HttpResponse;

import java.io.IOException;

/**
 * El servidor de demoblaze deja colgado ~10% de los handshakes TLS (ver conclusiones.txt).
 * Este cliente reintenta el request solo ante ConnectTimeoutException: en ese caso la conexion
 * no llego a establecerse, asi que el POST nunca se envio y reintentarlo no duplica datos.
 */
class RetryingHttpClientFactory implements HttpClientFactory {

    private static final int MAX_ATTEMPTS = 4;

    private final HttpClientFactory delegate = new DefaultHttpClientFactory();

    @Override
    public HttpClient create() {
        return new RetryingHttpClient(delegate.create());
    }

    @Override
    public void release(HttpClient client) {
        delegate.release(((RetryingHttpClient) client).delegate);
    }

    private static class RetryingHttpClient implements HttpClient {

        private final HttpClient delegate;

        RetryingHttpClient(HttpClient delegate) {
            this.delegate = delegate;
        }

        @Override
        public HttpResponse invoke(HttpRequest request) {
            for (int attempt = 1; ; attempt++) {
                try {
                    return delegate.invoke(request);
                } catch (RuntimeException e) {
                    if (attempt >= MAX_ATTEMPTS || !isConnectTimeout(e)) {
                        throw e;
                    }
                    System.out.println("ConnectTimeout contra " + request.getUrlAndPath()
                            + " - reintento " + attempt + " de " + (MAX_ATTEMPTS - 1));
                }
            }
        }

        private static boolean isConnectTimeout(Throwable e) {
            for (Throwable t = e; t != null; t = t.getCause()) {
                if (t.getClass().getName().equals("org.apache.hc.client5.http.ConnectTimeoutException")) {
                    return true;
                }
            }
            return false;
        }

        @Override
        public void apply(KarateConfig config) {
            delegate.apply(config);
        }

        @Override
        public void abort() {
            delegate.abort();
        }

        @Override
        public void close() throws IOException {
            delegate.close();
        }
    }
}
