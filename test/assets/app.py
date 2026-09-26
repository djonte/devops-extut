from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


UNHEALTHY_FLAG = Path("/tmp/app-unhealthy")


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            if UNHEALTHY_FLAG.exists():
                self.send_response(503)
                response = b"unhealthy\n"
            else:
                self.send_response(200)
                response = b"healthy\n"
        elif self.path == "/":
            self.send_response(200)
            response = b"Container security tutorial\n"
        else:
            self.send_response(404)
            response = b"not found\n"

        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 8000), RequestHandler)
    print("Listening on port 8000", flush=True)
    server.serve_forever()
