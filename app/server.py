import os
import urllib.request
import urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler

TARGET_URL = os.environ.get("TARGET_URL", "http://example.com")
APP_NAME = os.environ.get("APP_NAME", "lattice-app")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self._respond(200, "ok")
            return

        if self.path == "/check":
            try:
                req = urllib.request.Request(TARGET_URL, method="GET")
                with urllib.request.urlopen(req, timeout=5) as resp:
                    body = resp.read().decode()
                    self._respond(200, f"[{APP_NAME}] [OK] {TARGET_URL} -> {resp.status}\n\n{body[:500]}")
            except Exception as e:
                self._respond(502, f"[{APP_NAME}] [FAIL] {TARGET_URL} -> {e}")
            return

        self._respond(200, f"[{APP_NAME}]\n\nGET /check - call {TARGET_URL}\nGET /health - health check")

    def _respond(self, code, text):
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(text.encode())


if __name__ == "__main__":
    print(f"Starting server on :8080, target: {TARGET_URL}")
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
