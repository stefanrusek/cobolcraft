#!/usr/bin/env python3
"""Loopback HTTP and HTTPS test server (research R9, R10; T196). Test infrastructure, stdlib only.

usage: testsrv.py --dir DIR [--http-port N] [--https-port N] [--cert PEM --key PEM]
                  [--status CODE] [--chunked] [--oversize BYTES] [--request-log FILE] [--ready-file FILE]

Serves the files of DIR on 127.0.0.1 over HTTP (--http-port) and/or HTTPS (--https-port; the
certificate and key default to build/testsrv/server.pem and server.key from make-ca.sh). Port 0 asks
the system for a free port. Clients trust the test CA through the standard OpenSSL environment
variable SSL_CERT_FILE=build/testsrv/ca.pem, so no shipped code exists only for tests.

Every GET answers, by default, 200 with the file's bytes and Content-Length, or 404. Options:
  --status CODE     answer every request with CODE and a short text body instead.
  --chunked         send the body with Transfer-Encoding: chunked (no Content-Length).
  --oversize BYTES  answer every request with 200 and BYTES bytes of 0x00 instead of a file.
  --request-log F   append the request line and headers of each request to F, then a blank line.
  --ready-file F    write "http=<port> https=<port>" (0 when not served) to F once listening.

When listening it prints "testsrv: http=<port> https=<port>" on standard output. It runs until
SIGTERM or SIGINT (Ctrl+C).
"""
import argparse
import http.server
import os
import signal
import ssl
import sys
import threading

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DEFAULT_CERT_DIR = os.path.join(REPO, "build", "testsrv")
CHUNK_SIZE = 4096


def make_handler(options):
    root = os.path.realpath(options.dir)
    log_lock = threading.Lock()

    class Handler(http.server.BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def log_message(self, format, *args):  # noqa: A002 (stdlib signature)
            pass

        def record_request(self):
            if not options.request_log:
                return
            with log_lock, open(options.request_log, "a", encoding="utf-8") as handle:
                handle.write(self.requestline + "\n")
                for name, value in self.headers.items():
                    handle.write("%s: %s\n" % (name, value))
                handle.write("\n")

        def resolve(self):
            """The file for the request path, or None if it does not exist under root."""
            path = self.path.split("?", 1)[0].split("#", 1)[0]
            candidate = os.path.realpath(os.path.join(root, path.lstrip("/")))
            if candidate != root and not candidate.startswith(root + os.sep):
                return None
            return candidate if os.path.isfile(candidate) else None

        def send_body(self, status, body, content_type):
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Connection", "close")
            if options.chunked:
                self.send_header("Transfer-Encoding", "chunked")
            else:
                self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if self.command == "HEAD":
                return
            if options.chunked:
                for start in range(0, len(body), CHUNK_SIZE):
                    chunk = body[start:start + CHUNK_SIZE]
                    self.wfile.write(b"%x\r\n" % len(chunk) + chunk + b"\r\n")
                self.wfile.write(b"0\r\n\r\n")
            else:
                self.wfile.write(body)
            self.close_connection = True

        def do_GET(self):  # noqa: N802 (stdlib naming)
            self.record_request()
            if options.status is not None:
                text = ("status %d\n" % options.status).encode("ascii")
                self.send_body(options.status, text, "text/plain")
            elif options.oversize is not None:
                self.send_body(200, bytes(options.oversize), "application/octet-stream")
            else:
                path = self.resolve()
                if path is None:
                    self.send_body(404, b"not found\n", "text/plain")
                else:
                    with open(path, "rb") as handle:
                        self.send_body(200, handle.read(), "application/octet-stream")

        do_HEAD = do_GET

    return Handler


def start(server):
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return thread


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description="Loopback HTTP and HTTPS test server.")
    parser.add_argument("--dir", required=True, help="directory to serve")
    parser.add_argument("--http-port", type=int, help="HTTP port on 127.0.0.1 (0 = any free port)")
    parser.add_argument("--https-port", type=int, help="HTTPS port on 127.0.0.1 (0 = any free port)")
    parser.add_argument("--cert", default=os.path.join(DEFAULT_CERT_DIR, "server.pem"))
    parser.add_argument("--key", default=os.path.join(DEFAULT_CERT_DIR, "server.key"))
    parser.add_argument("--status", type=int, help="answer every request with this status code")
    parser.add_argument("--chunked", action="store_true", help="use Transfer-Encoding: chunked")
    parser.add_argument("--oversize", type=int, metavar="BYTES", help="answer with BYTES zero bytes")
    parser.add_argument("--request-log", help="append each request line and headers to this file")
    parser.add_argument("--ready-file", help="write the listening ports to this file")
    options = parser.parse_args(argv)
    if options.http_port is None and options.https_port is None:
        parser.error("give --http-port and/or --https-port")
    if not os.path.isdir(options.dir):
        parser.error("not a directory: %s" % options.dir)
    return options


def main(argv):
    options = parse_arguments(argv)
    handler = make_handler(options)
    servers = []
    ports = {"http": 0, "https": 0}
    if options.http_port is not None:
        server = http.server.ThreadingHTTPServer(("127.0.0.1", options.http_port), handler)
        ports["http"] = server.server_address[1]
        servers.append(server)
    if options.https_port is not None:
        server = http.server.ThreadingHTTPServer(("127.0.0.1", options.https_port), handler)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.load_cert_chain(options.cert, options.key)
        server.socket = context.wrap_socket(server.socket, server_side=True)
        ports["https"] = server.server_address[1]
        servers.append(server)

    stop = threading.Event()
    signal.signal(signal.SIGTERM, lambda *_: stop.set())
    signal.signal(signal.SIGINT, lambda *_: stop.set())
    for server in servers:
        start(server)

    ready = "http=%d https=%d" % (ports["http"], ports["https"])
    if options.ready_file:
        with open(options.ready_file + ".tmp", "w", encoding="ascii") as handle:
            handle.write(ready + "\n")
        os.replace(options.ready_file + ".tmp", options.ready_file)
    print("testsrv: " + ready, flush=True)

    while not stop.wait(0.2):
        pass
    for server in servers:
        server.shutdown()
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
